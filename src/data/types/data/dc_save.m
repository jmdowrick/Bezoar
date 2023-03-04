classdef dc_save < TData
    properties (Constant)
        Name = "save"
    end
    properties (SetAccess = private)
        file            (1,:)   char    = ''
        path            (1,:)   char    = ''
        issaved         (1,1)   logical = false
    end

    methods
        function save(obj)
            if isempty(obj.file)
                obj.saveas()
            else
                try
                    str = struct();

                    str.header = obj.Data.file.header;
                    str.events = obj.Data.evnt.e;

                    save(fullfile(obj.path, obj.file), '-struct', 'str')

                    obj.issaved = true;

                    obj.update()
                catch
                    obj.saveas()
                end
            end
        end
        function saveas(obj)
            [~, name, ~] = fileparts(obj.Data.file.file);

            [file, path] = uiputfile('*.mat', 'Save Events', ...
                fullfile(getFilePath(obj), [name, '_savefile']));

            if ~(isequal(file, 0) || isequal(path, 0))
                str = struct();

                str.header = obj.Data.file.header;
                str.events = obj.Data.evnt.e;

                save(fullfile(path, file), '-struct', 'str')

                obj.file = file;
                obj.path = path;
                obj.issaved = true;

                obj.update()
            end
        end
        function load(obj)
            [file, path] = uigetfile({'*.mat', 'MAT-files (*.mat)'}, ...
                'Load Events', getFilePath(obj));

            if ~(isequal(file, 0) || isequal(path, 0))
                str = load(fullfile(path, file));
                if ~isfield(str, 'header') || ~isequaln(str.header, obj.Data.file.header)
                    error('Invalid .mat file')
                end

                obj.Data.evnt.load(str.events)

                obj.file = file;
                obj.path = path;
                obj.issaved = true;
            end
        end
    end
    methods (Access = ?DataContainer)
        function updatefile(obj)
            obj.issaved = false;
            obj.markForUpdate()
        end
        function updateevnt(obj)
            obj.issaved = false;
            obj.markForUpdate()
        end
    end
end

% Creates default file path
function path = getFilePath(obj)
if ~isempty(obj.path)
    path = obj.path;
elseif obj.Data.file.isloaded
    path = obj.Data.file.path;
else
    path = fullfile(getenv('USERPROFILE'), 'Documents');
end
end