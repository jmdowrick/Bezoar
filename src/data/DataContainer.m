classdef DataContainer < dynamicprops
    properties (Hidden, SetAccess = private)
        DateTime        (1,1)   datetime = datetime

        Objects                 table
        Log                     table
    end
    properties (Hidden, SetAccess = private)
        Verbose         (1,1)   logical  = true
        ErrorLogging    (1,1)   logical  = true

        Graph           (1,1)   digraph = digraph()
    end
    properties (Hidden, SetAccess = private)
        Active          (1,1)   logical = false
    end

    methods (Access = public)
        function setVerbosity(obj, tf)
            obj.Verbose = tf;
        end
        function setErrorLogging(obj, tf)
            obj.ErrorLogging = tf;
            obj.Log(:, :) = [];
        end

        function reset(obj)
            obj.DateTime = datetime;

            obj.initialise()
        end
        function update(obj, name)
            if ~obj.Active
                % Prevent interrupts
                obj.Active = true;

                % Updates properties
                if obj.ErrorLogging
                    % Logging errors appears to take longer, so only record
                    % events and errors if flag is set to true
                    obj.updateErrorLogging(name)
                else
                    obj.updateNoLogging(name)
                end

                % Allow for updates
                obj.Active = false;
            end
        end
    end
    methods (Access = private)
        function updateErrorLogging(obj, name)
            % Clear log
            obj.Log(:, :) = [];

            for i = [name, obj.Objects.Queue{name}']
                % Check if an update is required
                if strcmp(i, name) || obj.Objects{i, 'Handle'}.Dirty
                    % Execute property.update()
                    tic
                    try
                        f = "update";
                        o = obj.Objects{i, 'Handle'};
                        o.(f);
                        obj.Log(end + 1, :) = { ...
                            datetime, ...
                            i + "." + f + "()", ...
                            toc, ...
                            true, ...
                            ""};
                    catch ME
                        obj.Log(end + 1, :) = { ...
                            datetime, ...
                            i + "." + f + "()", ...
                            toc, ...
                            false, ...
                            ME.identifier + ":" + ME.message};
                    end

                    f = "update" + i;
                    for j = obj.Objects.Subscribers{i}'
                        % Excute property.updateprop()
                        tic
                        try
                            o = obj.Objects{j, 'Handle'};
                            o.(f);
                            obj.Log(end + 1, :) = { ...
                                datetime, ...
                                j + "." + f + "()", ...
                                toc, ...
                                true, ...
                                ""};
                        catch ME
                            obj.Log(end + 1, :) = { ...
                                datetime, ...
                                j + "." + f + "()", ...
                                toc, ...
                                false, ...
                                ME.identifier + ":" + ME.message};
                        end
                    end
                end
            end

            if obj.Verbose && any(~obj.Log{:, 'SuccessFlag'})
                disp(obj.Log)
            end
        end
        function updateNoLogging(obj, name)
            % OPTIMISATIONS LIKELY POSSIBLE
            for i = [name, obj.Objects.Queue{name}']
                % Check if an update is required
                if strcmp(i, name) || obj.Objects{i, 'Handle'}.Dirty
                    % Execute property.update()
                    try
                        f = "update";
                        obj.Objects{i, 'Handle'}.(f)
                    catch
                        if obj.Verbose
                            disp("Error in executing " + i + "." + f + "()")
                        end
                    end

                    f = "update" + i;
                    for j = obj.Objects.Subscribers{i}'
                        % Excute property.updateprop()
                        try
                            obj.Objects{j, 'Handle'}.(f)
                        catch
                            if obj.Verbose
                                disp("Error in executing " + j + "." + f + "()")
                            end
                        end
                    end
                end
            end
        end

        function initialise(obj)
            % Find path containing data types
            s = what('src/data/types');

            % Create list of file names
            fl = dir(fullfile(s.path, '**\*.*'));
            fl = fl(~[fl.isdir]);

            % Create table containing object handles
            Handle = TData.empty(0,0);
            obj.Objects = table(Handle);

            % Iterate through files, attempting to instantiate objects
            for i = 1:length(fl)
                try
                    [~, f, ~] = fileparts(fl(i).name);
                    o = eval(strcat(f, '()'));

                    if ~isa(o, 'TData')
                        disp("'" + f + "' is not of TData class.")
                    elseif matches(o.Name, obj.Objects.Properties.RowNames)
                        disp("Multiple '" + o.Name + "' objects exist.")
                        disp("Only the first occurrence has been instantiated.")
                    else
                        obj.Objects = [obj.Objects; {o}];
                        if height(obj.Objects) == 1
                            obj.Objects.Properties.RowNames{1} = lower(char(o.Name));
                        else
                            obj.Objects.Properties.RowNames{end} = lower(char(o.Name));
                        end
                    end
                catch
                    disp("Unable to instantiate '" + f + "'.")
                end
            end

            obj.createDynamicProperties()

            obj.createSubscribesTo()
            obj.createSubscribers()

            obj.createQueues()
            obj.createListeners()
        end

        function createDynamicProperties(obj)
            p = string(obj.Objects.Properties.RowNames)';

            for n = p
                h = addprop(obj, n);
                obj.(n) = obj.Objects{n, 'Handle'};
                h.SetAccess = 'private';
                % h.Hidden = true;
            end
        end

        function createSubscribesTo(obj)
            % Find the objects each individual objects subscribes to
            o = obj.Objects;
            p = obj.Objects.Properties.RowNames;
            c = cell.empty(0, 1);
            
            for i = 1:length(p)
                h = o{i, 'Handle'};

                mc = metaclass(h);
                ml = mc.MethodList;

                pn = extractAfter({ml.Name}, "update");

                tf = ismember([ml.DefiningClass], mc) & ...
                    contains(pn, p);

                c{i, 1} = string(pn(tf));
            end

            obj.Objects = addvars(obj.Objects, c, ...
                'NewVariableNames', 'SubscribesTo');
        end
        function createSubscribers(obj)
            % Find subscribers to each object
            o = obj.Objects;
            p = obj.Objects.Properties.RowNames;
            c = cell.empty(0, 1);

            for i = 1:length(p)
                tf = cellfun(@(r) matches(p(i), r), o.SubscribesTo);

                c{i, 1} = string(p(tf));
            end

            obj.Objects = addvars(obj.Objects, c, ...
                'NewVariableNames', 'Subscribers', ...
                'Before', 'SubscribesTo');
        end
        function createQueues(obj)
            % Create event queues
            o = obj.Objects;
            c = cell.empty(0, 1);

            for i = 1:height(o)
                j = 1;
                q = o.Subscribers{i};

                while j <= length(q)
                    q = [q; o.Subscribers{q(j)}]; %#ok<AGROW> 
                    [~, v] = unique(q, 'last');
                    q = q(ismember(1:length(q), v));

                    j = j + 1;
                end

                c{i, 1} = q;
            end

            obj.Objects = addvars(obj.Objects, c, ...
                'NewVariableNames', 'Queue', ...
                'Before', 'Subscribers');
        end
        function createUpdateFunctions(obj)
            n = height(obj.Objects);

            updateFcn = cell(n, 1);
            for i = 1:n
                o = obj.Objects{i, 'Handle'};
                updateFcn{i} = @o.update;
            end

            obj.Objects = addvars(obj.Objects, updateFcn, ...
                'NewVariableNames', 'updateFcn');
        end
        function createListeners(obj)
            l = event.listener.empty(0, 1);
            p = obj.Objects.Properties.RowNames;

            for n = p'
                o = obj.Objects{n{:}, 'Handle'};
                l(end + 1, 1) = event.listener(o, ...
                    'PropertiesChanged', @(~, ~) obj.update(n{:})); %#ok<AGROW>
            end

            obj.Objects = addvars(obj.Objects, l, ...
                'NewVariableNames', 'Listener');
        end

        function obj = DataContainer()
            % Create log
            vn = {'TimeStamp', 'Function', 'Duration', 'SuccessFlag', 'Error'};
            vt = {'datetime', 'string', 'double', 'logical', 'string'};

            obj.Log = table( ...
                'Size', [0 5], ...
                'VariableTypes', vt,...
                'VariableNames', vn);
        end
    end
    methods (Static)
        function obj = instance()
            persistent UniqueDC
            if isempty(UniqueDC) || ~isvalid(UniqueDC)
                UniqueDC = DataContainer();
                UniqueDC.reset()
            end
            obj = UniqueDC;
        end
    end

    events (NotifyAccess = private)
        PropertiesChanged
    end
end
