classdef dc_file < TData
    properties (Constant)
        Name = "file"
    end

    properties (SetObservable, SetAccess = private)
        isloaded        (1,1)   logical = false
    end
    properties (SetAccess = private)
        file            (1,:)   char    = ''
        path            (1,:)   char    = ''

        raw             (:,:,1) double  = []
        triggers        (:,:,1) logical = []
        header          (1,1)   struct  = struct()
    end

    methods
        function import(obj)
            [file, path] = uigetfile( ...
                ... File extension filter
                { '*.*', 'All Files (*.*)';...
                '*.tsy', 'INTSY Output (*.tsy)';...
                '*.bdf', 'BioSemi Data Format (*.bdf)'...
                }, ...
                ... Dialogue box title
                'Import Data File', ...
                ... Default path
                getFilePath(obj));

            obj.importFile(file, path)
        end
        function importFile(obj, file, path)
            if ~or(isequal(0, file), isequal(0, path))
                if contains(file, '.bdf')
                    [data, status] = importbdf(path, file);
                elseif contains(file, '.tsy')
                    [data, status] = importtsy(path,file);
                else
                    warning('Invalid file format selected.')
                    status = -1;
                end

                if (status ~= 0)
                    obj.isloaded = false;
                    return
                end

                obj.isloaded = true;

                obj.file = file;
                obj.path = path;

                obj.raw = data.data;
                obj.triggers = data.triggers;
                obj.header = data.header;

                obj.update()
            end
        end

    end
end

% Importer .bdf file
function [datastruct, status] = importbdf(path, file)
% Read binary
fid = fopen(fullfile(path, file), 'r', 'b');

if fid == -1
    datastruct = blankdata();
    status = -1;
    uiwait(msgbox('Error: Unable to open file', 'Error', 'error', 'modal'));
    return
else
    try
        f = get(groot, 'Children');
        if isempty(f)
            h = waitbar(0, ...
                'Importing: Reading Header...', ...
                'Name', 'Importing Data', ...
                'WindowStyle',  'modal');
        else
            sz = [360 75];
            p = f(1).Position;
            c = p([1 2]) + (p([3 4])/2);
            h = waitbar(0, ...
                'Importing: Reading Header...', ...
                'Name', 'Importing Data', ...
                'WindowStyle', 'modal', ...
                'Units', 'pixels', ...
                'Position', [c - (sz/2), sz]);
        end

        set(h, 'CloseRequestFcn', @closePressed)
        set(h, 'UserData', false)

        % Static header
        idcode = readchar(1);
        idtext = string(char(readchar(7)));
        idsubject = deblank(char(readchar(80)));
        idrecording = deblank(char(readchar(80)));
        startdate = string(char(readchar(8)));
        starttime = string(char(readchar(8)));
        headerbytes = str2double(char(readchar(8)));
        formatversion = string(char(readchar(44)));
        numrecords = str2double(char(readchar(8)));
        durrecords = str2double(char(readchar(8)));
        numchannels = str2double(char(readchar(4)));

        % Channel dependent header
        n = numchannels;
        channellabels = readchar(n * 16);
        channellabels = deblank(string(transpose(char(reshape(channellabels, [16 n])))));
        transducertype = readchar(n * 80);
        transducertype = deblank(string(transpose(char(reshape(transducertype, [80 n])))));
        units = readchar(n * 8);
        units = deblank(string(transpose(char(reshape(units, [8 n])))));
        pmin = readchar(n * 8);
        pmin = str2double(string(transpose(char(reshape(pmin, [8 n])))));
        pmax = readchar(n * 8);
        pmax = str2double(string(transpose(char(reshape(pmax, [8 n])))));
        dmin = readchar(n * 8);
        dmin = str2double(string(transpose(char(reshape(dmin, [8 n])))));
        dmax = readchar(n * 8);
        dmax = str2double(string(transpose(char(reshape(dmax, [8 n])))));
        prefilter = readchar(n * 80);
        prefilter = deblank(string(transpose(char(reshape(prefilter, [80 n])))));
        samplesperrecord = readchar(n * 8);
        samplesperrecord = str2double(string(transpose(char(reshape(samplesperrecord, [8 n])))));
        reserved = readchar(n * 32);
        reserved = deblank(string(transpose(char(reshape(reserved, [32 n])))));

        % Data and triggers
        samples = samplesperrecord(1);

        data = NaN(samples * numrecords, n - 1);
        trig = uint32(zeros(samples * numrecords, 1));

        for i = 1:numrecords
            if h.UserData
                datastruct = blankdata();   status = -1;
                waitbar(1, h, 'Cancelling import...');  pause(0.5);
                close(h)
                return
            end

            % Update waitbar
            waitbar(i/numrecords, h, ['Importing: ' num2str(i) ' of ' num2str(numrecords) ' seconds...'])

            data((samples*(i - 1) + 1):(samples*i), :) = ...
                reshape(readdata(samples*(n - 1)), [samples (n - 1)]);
            trig((samples*(i - 1) + 1):(samples*i)) = ...
                readtrig(samples);
        end

        % Convert triggers
        triggers = false(samples * numrecords, 24);
        for i = 1:(samples * numrecords)
            triggers(i, :) = bitget(trig(i), 1:24);
        end

        gain = (pmax - pmin)./(dmax - dmin);
        data = data.*gain(1:end - 1)';
        fileduration = durrecords * numrecords;
        filefrequency = samplesperrecord(1)/durrecords;
        filesamples = samplesperrecord(1)*numrecords;

        %Set up header
        header = struct();

        header.gain = gain;
        header.idcode = idcode;
        header.idtext = idtext;
        header.idsubject = idsubject;
        header.idrecording = idrecording;
        header.startdate = startdate;
        header.starttime = starttime;
        header.headerbytes = headerbytes;
        header.formatversion = formatversion;
        header.numrecords = numrecords;
        header.durrecords = durrecords;
        header.numchannels = numchannels - 1;

        header.channellabels = channellabels(1:end - 1);
        header.transducertype = transducertype(1:end - 1);
        header.units = units(1:end - 1);
        header.pmin = pmin(1:end - 1);
        header.pmax = pmax(1:end - 1);
        header.dmin = dmin(1:end - 1);
        header.dmax = dmax(1:end - 1);
        header.prefilter = prefilter(1:end - 1);
        header.samplesperrecord = samplesperrecord(1:end - 1);
        header.reserved = reserved(1:end - 1);

        header.fileduration = fileduration;
        header.filefrequency = filefrequency;
        header.filesamples = filesamples;

        % Create data file
        datastruct = blankdata();
        datastruct.data = data;
        datastruct.triggers = triggers;
        datastruct.header = header;

        status = 0; %SUCCESS!
    catch
        datastruct = blankdata();
        status = -1;
        uiwait(msgbox('Error: Unable to read file', 'Error', 'error', 'modal'));
    end
end

h.UserData = true;
close(h)
fclose(fid);

    function db = readchar(n)
        db = fread(fid, n, 'char');
    end
    function db = readdata(n)
        db = fread(fid, n, 'bit24', 'l');
    end
    function db = readtrig(n)
        db = fread(fid, n, 'ubit24=>uint32', 'l');
    end
    function closePressed(src, ~)
        if ~src.UserData
            src.UserData = true;
        else
            closereq
        end
    end
end

% Importer .tsy file
function [datastruct, status] = importtsy(path, file)
% Read binary
fid = fopen(fullfile(path, file), 'r');

if fid == -1
    datastruct = blankdata();
    status = -1;
    uiwait(msgbox('Error: Unable to open file', 'Error', 'error', 'modal'));
    return
else
    try
        f = get(groot, 'Children');
        if isempty(f)
            h = waitbar(0, ...
                'Importing: Reading tsy...', ...
                'Name', 'Importing Data', ...
                'WindowStyle',  'modal');
        else
            sz = [360 75];
            p = f(1).Position;
            c = p([1 2]) + (p([3 4])/2);
            h = waitbar(0, ...
                'Importing: Reading tsy...', ...
                'Name', 'Importing Data', ...
                'WindowStyle', 'modal', ...
                'Units', 'pixels', ...
                'Position', [c - (sz/2), sz]);
        end

        set(h, 'CloseRequestFcn', @closePressed)
        set(h, 'UserData', false)

        dataformat.Nwords = 144;
        dataformat.Noffset = 10;
        dataformat.Nchans = 64;
        dataformat.Naccel = 3;
        dataformat.Nflex = 1; %should set to 0 for files acquired prior to july 08 2019
        dataformat.MagicNum = 8481;

        % Define 32 bit clock roll over
        T_ROLLOVER = 2^32 - 1; % for 32 bit counter = 4294967295

        Nsamples = inf; %load the entire data file.

        ydat2 = uint16(fread(fid, [dataformat.Nwords, Nsamples], 'uint16')); %143 words (=286 bytes) written per data chunk
        ydat2(:,1) = []; %First read is always junk, cmd_pipeline offset not established.

        %% First 2 words should contain 73 and 78 'I' and 'N' in INTAN for amp A
        %  Next 2 words should contain  84 and 65  'T'  and 'A' in INTAN for amp B
        % these should be empty.  If not, SPI link was not working properly
        iiA = find(ydat2(1,:) ~=73);
        iiB = find(ydat2(3,:) ~=84);
        iiC = find(ydat2(5,:) ~=73);
        iiD = find(ydat2(7,:) ~=84);

        %% Next 2 words form timestamp in high and low byte packet
        %Compute time diffs between sample, identify any that did not conform to
        %DTsamp (microsec)

        %timestamp is 4 bytes, have to boolean operate together 2 byte reads
        %(uint16).
        % Note that first 2 words are result of aux_cmds, hence indices of 6 and 5
        % below to get timestamp).  Input of 16 comes from 2 bytes = 16 bits
        timestampRaw = bitor(bitshift(double(ydat2(dataformat.Noffset,:)), 16 ), double(ydat2(dataformat.Noffset-1,:) ));

        %unwrap any clock rollover.  0.99x factor is heuristic, could also occur at
        %a frame misread, but very unlikely.  In any case, user has access to raw
        %timestamps to do what they wish.
        timestamp = unwrap(timestampRaw, 0.999*T_ROLLOVER);
        timestamp = timestamp - timestamp(1);  %shift time origin to 0

        dt = diff(timestamp);

        %% valid time indices are those for which neither amp A or C reports errors
        % FS computation based on valid time indices.
        % This is done because a data file set for say 20 hours may only have 4
        % hours or valid recording time.  Thus, we want only valid samples to be
        % used when computing FS.
        validTimeIndex = setdiff(1:length(timestamp), intersect(intersect(iiA, iiB), intersect(iiC, iiD)));
        validTimeIndex(end) = [];

        FS = 1e6/median(dt(validTimeIndex));
        errMinIndex = min(validTimeIndex(end)); %first index at which sync error is detected
 
        %% get the ADC data. Offset +4 index (dataformat.Noffset) is to skip over
        % first 6 Uint16's which are 2*2 (=4) aux_cmd_results and 32-bit timestamp

        % truncate data file just before first sync error detected
        % This typically occurs when the power is turned off; e.g. we set a 4 hr
        % recording, but only actually record for 3 hrs, then turn system off 1 hr
        % early.
        lastValidIndex = errMinIndex-10*FS; %equiv to removing 10 s worth of points: Teensy writes ever 10 s to SD
        data = ydat2((1+dataformat.Noffset):end, 1:lastValidIndex);

        %loop over each channel
        [Nsigs, Nsamps] = size(data);

        if dataformat.Nflex==0 %no flex sensor
            accelRowIndex = (Nsigs-dataformat.Naccel - 1): (Nsigs-2);
            VddRowIndex = Nsigs - 1;
            flexRowIndex = [];
        else %flex sensor installed
            accelRowIndex = (Nsigs-dataformat.Naccel - 2): (Nsigs-3);
            VddRowIndex = Nsigs - 2;
            flexRowIndex = Nsigs - 1;
        end
        acceldata = data(accelRowIndex, :); %acceleromter data

        %scale accelerometer data
        accelvolts = double(acceldata)*(3.3/2^16);  % Teensy 3.6 operates as 3.3 volt device reading 16 bits

        accelg = (accelvolts-1.65)/0.3; %adxl335 acceleromter datasheet: 1.5V calibrated to be 0g and 1g/300 mV.
        Data.accelg = accelg;
        Data.acceldata = acceldata;
        Data.accelvolts = accelvolts;

        %% Vbattery (Vdd voltage supply for intan amp)
        Vbatdata = data(VddRowIndex, :); %Vdd data from Intan amp

        % the Intsy CDAB module made nov 19 2020 has firmware which reversed the
        % order of Vflex and Vdd, heuristic to check for this:
        if all(Vbatdata==0)
            flipVdd_vflex = true;
            Vbatdata = data(VddRowIndex+1,:);
        else
            flipVdd_vflex = false;
        end
        Vbatvolts = double(Vbatdata)*7.48E-5;
        Data.Vdd = Vbatvolts;

        %% Vflex (flex sensor reading)
        if dataformat.Nflex==1
            if flipVdd_vflex %check to see if we have firmware that flipped rows of Vdd and Vflex
                flexRowIndex = flexRowIndex-1; %
            end
            VflexBin = data(flexRowIndex ,:);
            Vflexvolts = double(VflexBin)*(3.3/2^16);
            Data.Vflex = Vflexvolts;
        else %no flex sensor attached fill in with nan as place holder
            Data.Vflex = nan(1,length(Vbatvolts));
        end

        % scale the Intan data from uint16 binary to uV. See pg 5 of:
        % http://intantech.com/files/Intan_RHD2000_data_file_formats.pdf
        % which specifies conversion factor
        IntanDataRaw = data(1:dataformat.Nchans, :); %electrical signal data only (last 3 chans are accelerometer)
        scaled_data = (double(IntanDataRaw) - 2^15) * 0.195;

        %Set up header
        header = struct();
        header.gain = 1;
        header.numrecords = Nsamps/FS;
        header.durrecords = 1;
        header.numchannels = dataformat.Nchans;
        header.fileduration = Nsamps/FS;
        header.filefrequency = FS;
        header.filesamples = Nsamps;

        % Create data file
        datastruct = blankdata();
        datastruct.data = scaled_data.';
        datastruct.triggers = false*ones(size(scaled_data.'));
        datastruct.header = header;

        status = 0; %SUCCESS!
    catch
        datastruct = blankdata();
        status = -1;
        uiwait(msgbox('Error: Unable to read file', 'Error', 'error', 'modal'));
    end
end

h.UserData = true;
close(h)
fclose(fid);
    function closePressed(src, ~)
        if ~src.UserData
            src.UserData = true;
        else
            closereq
        end
    end
end

% Creates default file path
function path = getFilePath(obj)
if isempty(obj.path)
    path = fullfile(getenv('USERPROFILE'), 'Documents');
else
    path = obj.path;
end
end

% Dummy data file
function d = blankdata()
d = struct();
d.data = [];
d.triggers = [];
d.header = struct();
end