classdef dc_cnfg < TData
    properties (Constant)
        Name = "cnfg"
    end
    properties (SetObservable, SetAccess = private)
        size            (1,2)   double = [0 0] 
        configuration   (:,:,1) double = []

        mode            (1,:)   char ...
            {mustBeMember(mode,{'flat','sphere'})} = 'flat'
    end
    properties (SetAccess = private)
        % x- and y- positions
        x               (1,:)   double = double.empty(1,0)
        y               (1,:)   double = double.empty(1,0)

        % i- and j- threads
        i               (1,:)   double = double.empty(1,0)
        j               (1,:)   double = double.empty(1,0)

        % radius (for spherical configurations)
        r               (1,1)   double = 0
        
        % x- and y- positions in grid form
        xgrid           (:,:,1) double = []
        ygrid           (:,:,1) double = []
    end
    
    methods
        function setConfiguration(obj, c)
            obj.current = c;

            obj.update()
        end
        function load(obj)
            [file, path] = uigetfile( ...
                ... File extension filter
                {'*.toml;*.txt', 'Electrode configuration'; ...
                '*.toml', 'Bezoar configuration'; ...
                '*.txt', 'GEMS configuration'; ...
                '*.*', 'All Files (.*)'}, ...
                ... Dialogue box title
                'Import Data File', ...
                ... Default path
                getFilePath(obj));

            if ~or(isequal(0, file), isequal(0, path))
                fp = fullfile(path, file);
                [~, ~, e] = fileparts(fp);
                
                switch e
                    case '.txt'
                        if obj.parseTXT(fp)
                            obj.update()
                        end
                    case '.toml'
                        if obj.parseTOML(fp)
                            obj.update()
                        end
                end
            end
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            cf = obj.configuration;            
            tf = cf > 0;    

            [xg, yg] = deal(NaN(obj.size));

            xg(tf) = obj.x(cf(tf));
            yg(tf) = obj.y(cf(tf));

            obj.xgrid = xg;
            obj.ygrid = yg;
        end
    end
    methods (Access = private)
        function createDefaultConfiguration(obj)
            n = obj.Data.prop.channels;

            obj.createDefaultConfigurationFlat(n)

%             if (n == 64)
%                 obj.createDefaultConfigurationSphere()
%             else
%                 obj.createDefaultConfigurationFlat(n)
%             end
        end
        function createDefaultConfigurationFlat(obj, n)
            sp = 4; % Default spacing
            cf = defaultFPC();
            na = ceil(n/numel(cf));
            cf = repmat(cf, na, 1) + numel(cf) * repelem((0:na - 1)', 2, 16);
            sz = size(cf); %#ok<CPROPLC> 
            
            [xe, ye] = meshgrid(1:sz(2), 1:sz(1)); 

            obj.size = sz; 
            obj.configuration = cf;
            obj.mode = 'flat';

            obj.r = 0;

            obj.x = NaN(1, na);   obj.x(cf) = sp * xe;
            obj.y = NaN(1, na);   obj.y(cf) = sp * ye;

            obj.i = NaN(1, na);   obj.i(cf) = xe;
            obj.j = NaN(1, na);   obj.j(cf) = ye;
        end
        function createDefaultConfigurationSphere(obj)
            [lon, lat, i, j] = defaultSphere();

            cf = NaN(max(abs(j)), max(abs(i)));
            for k = 1:min(numel(i), numel(j))
                if (abs(i(k)) > 0) && (abs(j(k)) > 0)
                    cf(abs(j(k)), abs(i(k))) = k;
                end
            end

            obj.size = size(cf); %#ok<CPROP>
            obj.configuration = cf;
            obj.mode = 'sphere';

            obj.r = 30;

            obj.x = lon;
            obj.y = lat;

            obj.i = NaN(1, obj.n);
            obj.j = NaN(1, obj.n); 
        end

        function e = parseTXT(obj, fp)
            try
                ar = readmatrix(fp);                % Read csv
                sz = [ar(2, 3) ar(2, 2)];           % Get electrode size
                sp = ar(2, 4);                      % Get spacing
                cf = ar((1:sz(1)) + 2, 1:sz(2));    % Get configuration
                nc = max(cf(:));
                
                tf = isfinite(cf) & (cf > 0) & (cf <= nc);

                [xe, ye] = meshgrid(1:sz(2), 1:sz(1));
                
                obj.size = sz;
                obj.configuration = cf;
                obj.mode = 'flat';
                obj.r = 0;

                obj.x = NaN(1, nc);     obj.x(cf(tf)) = sp * xe(tf);
                obj.y = NaN(1, nc);     obj.y(cf(tf)) = sp * ye(tf);
                
                obj.i = NaN(1, nc);     obj.i(cf(tf)) = xe(tf);
                obj.j = NaN(1, nc);     obj.j(cf(tf)) = ye(tf);

                e = 1;  % SUCCESS!
            catch
                e = 0;  % FAILURE.
            end
        end
        function e = parseTOML(obj, fp)
            try
                m = toml.read(fp);
                s = toml.map_to_struct(m);
                f = fieldnames(s);
                
                % Find positions
                i = find(contains(f, 'pos')); %#ok<*PROPLC> 
                assert(any(i))
                p = s.(f{i(1)});
                pfn = fieldnames(p);
                if any(matches(pfn, {'x', 'y'}, 'IgnoreCase', true))
                    x = p.(pfn{matches(pfn, 'x', 'IgnoreCase', true)});
                    y = p.(pfn{matches(pfn, 'y', 'IgnoreCase', true)});
                    r = 0;
                    mode = 'flat';
                elseif any(matches(pfn, {'lat', 'lon'}, 'IgnoreCase', true))
                    x = p.(pfn{matches(pfn, 'lon', 'IgnoreCase', true)});
                    y = p.(pfn{matches(pfn, 'lat', 'IgnoreCase', true)});
                    r = s.radius;
                    mode = 'sphere';
                else
                    error("Invalid position fields.")
                end

                % Find threads
                i = find(contains(f, 'thr'));
                assert(any(i))
                t = s.(f{i(1)});
                tfn = fieldnames(t);
                if any(matches(tfn, {'i', 'j'}, 'IgnoreCase', true))
                    i = t.(tfn{matches(tfn, 'i', 'IgnoreCase', true)});
                    j = t.(tfn{matches(tfn, 'j', 'IgnoreCase', true)});
                else
                    error("Invalid thread fields.")
                end

                g = NaN(max(abs(j)), max(abs(i)));
                for k = 1:min(numel(i), numel(j))
                    if (abs(i(k)) > 0) && (abs(j(k)) > 0)
                        g(abs(j(k)), abs(i(k))) = k;
                    end
                end

                obj.size = size(g); %#ok<CPROPLC> 
                obj.configuration = g;
                obj.mode = mode;
                obj.r = r;

                obj.x = x;
                obj.y = y;

                obj.i = i;
                obj.j = j;

                e = 1;  % SUCCESS!
            catch
                e = 0;  % FAILURE.
            end
        end
    end
    methods
        function updateprop(obj)
            if isempty(obj.configuration)
                obj.createDefaultConfiguration()
            end
        end
    end

    properties (Dependent)
        lon
        lat
    end
    methods
        function p = get.lon(obj)
            p = obj.x;  
        end
        function p = get.lat(obj)
            p = obj.y;  
        end
    end
end

% Creates default file path
function path = getFilePath(~)
path = which('constellation3.toml');
if isempty(path)
    path = fullfile(getenv('USERPROFILE'), 'Documents');
end
end

function [template] = defaultFPC()
template = [...
    31  29  27  25  23  21  19  17  16  14  12  10  08  06  04  02
    32  30  28  26  24  22  20  18  15  13  11  09  07  05  03  01  ];
end
function [lon, lat, i, j] = defaultSphere()
lon = [ -3.14159265, -1.57079632, -3.14159265, -1.57079632, ...
        -3.14159265, -1.57079632, -3.14159265, -1.57079632, ...
        -3.14159265, -1.57079632, -3.14159265, -1.57079632, ...
        -3.14159265, -1.57079632, -3.14159265, -1.57079632, ...
        -2.35619449, -0.78539816, -2.35619449, -0.78539816, ...
        -2.35619449, -0.78539816, -2.35619449, -0.78539816, ...
        -2.35619449, -0.78539816, -2.35619449, -0.78539816, ...
        -2.35619449, -0.78539816, -2.35619449, -0.78539816, ...
         0.00000000,  1.57079632,  0.00000000,  1.57079632, ...
         0.00000000,  1.57079632,  0.00000000,  1.57079632, ...
         0.00000000,  1.57079632,  0.00000000,  1.57079632, ...
         0.00000000,  1.57079632,  0.00000000,  1.57079632, ...
         0.78539816,  2.35619449,  0.78539816,  2.35619449, ...
         0.78539816,  2.35619449,  0.78539816,  2.35619449, ...
         0.78539816,  2.35619449,  0.78539816,  2.35619449, ...
         0.78539816,  2.35619449,  0.78539816,  2.35619449  ];

lat = [ -0.98782037, -0.98782037, -0.76110750, -0.76110750, ...
        -0.53439463, -0.53439463, -0.30768175, -0.30768175, ...
        -0.08096888, -0.08096888,  0.14574399,  0.14574399, ...
         0.37245686,  0.37245686,  0.59916973,  0.59916973, ...
        -0.98782037, -0.98782037, -0.76110750, -0.76110750, ...
        -0.53439463, -0.53439463, -0.30768175, -0.30768175, ...
        -0.08096888, -0.08096888,  0.14574399,  0.14574399, ...
         0.37245686,  0.37245686,  0.59916973,  0.59916973, ...
        -0.98782037, -0.98782037, -0.76110750, -0.76110750, ...
        -0.53439463, -0.53439463, -0.30768175, -0.30768175, ...
        -0.08096888, -0.08096888,  0.14574399,  0.14574399, ...
         0.37245686,  0.37245686,  0.59916973,  0.59916973, ...
        -0.98782037, -0.98782037, -0.76110750, -0.76110750, ...
        -0.53439463, -0.53439463, -0.30768175, -0.30768175, ...
        -0.08096888, -0.08096888,  0.14574399,  0.14574399, ...
         0.37245686,  0.37245686,  0.59916973,  0.59916973  ];

i = [    1,  3,  1,  3,  1,  3,  1,  3, ...
         1,  3,  1,  3,  1,  3,  1,  3, ...
         2,  4,  2,  4,  2,  4,  2,  4, ...
         2,  4,  2,  4,  2,  4,  2,  4, ...
         5,  7,  5,  7,  5,  7,  5,  7, ...
         5,  7,  5,  7,  5,  7,  5,  7, ...
         6,  8,  6,  8,  6,  8,  6,  8, ...
         6,  8,  6,  8,  6,  8,  6,  8  ];

j = [    8,  8,  7,  7,  6,  6,  5,  5, ...
         4,  4,  3,  3,  2,  2,  1,  1, ...
         8,  8,  7,  7,  6,  6,  5,  5, ...
         4,  4,  3,  3,  2,  2,  1,  1, ...
         8,  8,  7,  7,  6,  6,  5,  5, ...
         4,  4,  3,  3,  2,  2,  1,  1, ...
         8, -8,  7, -7,  6, -6,  5, -5, ...
         4, -4,  3, -3,  2, -2,  1, -1  ];
end