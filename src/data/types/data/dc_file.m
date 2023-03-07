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
                {'*.bdf', 'BioSemi Data Format (.bdf)'; ...
                '*.*', 'All Files (.*)'}, ...
                ... Dialogue box title
                'Import Data File', ...
                ... Default path
                getFilePath(obj));
            
            obj.importFile(file, path)
        end
        function importFile(obj, file, path)
            if ~or(isequal(0, file), isequal(0, path))
                [data, status] = importbdf(path, file); 
                
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
                'Name',         'Importing Data', ...
                'WindowStyle',  'modal');
        else
            sz = [360 75];
            p = f(1).Position;  
            c = p([1 2]) + (p([3 4])/2);
            h = waitbar(0, ...
                'Importing: Reading Header...', ...
                'Name',         'Importing Data', ...
                'WindowStyle',  'modal', ...
                'Units',        'pixels', ...
                'Position',     [c - (sz/2), sz]);
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