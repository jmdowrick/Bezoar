classdef Bezoar < handle
    properties (SetAccess = private)
        Objects                 table
        Actions                 table
    end
    properties (Hidden, SetAccess = private)
        FigureList              matlab.graphics.Graphics
        ActiveObject            TComponent
        CloseListener           event.listener
    end

    methods
        function addObject(obj, h)
            p = h.Parent;

            i = find(isequal(p, obj.Objects{:, 'Object'}));
            s = obj.getSubscriptions(h);

            if isempty(i)
                obj.Objects = [ ...
                    obj.Objects;
                    {h, h, h.Handle, {s}, h.UUID};
                    ];
            else
                obj.Objects = [ ...
                    obj.Objects(1:i, :); ...
                    {h, p, h.Handle, {s}, h.UUID}; ...
                    obj.Objects((i + 1):end, :)];
            end
        end
        function delete(obj)
            try     delete(obj.FigureList);         catch;   end
            try     delete(DataContainer.instance); catch;   end
        end
    end
    methods (Access = private)
        function updateObjects(obj, e)
            s = obj.Actions{e, 'Subscribers'}{:};
            m = "update" + e;

            for h = s'
                try
                    h.(m);
                catch
                    disp("Error updating " + class(h) + "." + m)
                end
            end
        end

        function initialise(~)
            uifigure();
        end
        function initialiseObjects(obj)
            i = 1;
            while i <= height(obj.Objects)
                obj.ActiveObject = obj.Objects{i, 'Object'};
                obj.ActiveObject.initialise_()

                i = i + 1;
            end
        end

        function createActions(obj)
            do = DataContainer.instance.Objects;
            co = obj.Objects;
            
            Subscribers = cell.empty(0, 1);
            Listener = event.listener.empty(0, 1);

            s = co{:, 'SubscribesTo'};
            p = do.Properties.RowNames;
            for i = 1:height(do)
                tf = cellfun(@(x) matches(p(i), x), s);

                Subscribers(i, 1) = {obj.Objects{tf, 'Object'}}; %#ok<CCAT1>
                Listener(i, 1) = listener(do{i, 'Handle'}, ...
                    'PropertiesChanged', @(~, ~) obj.updateObjects(p{i}));
            end

            obj.Actions = table(Subscribers, Listener, 'RowNames', p);
        end
    end
    methods (Static)
        function s = getSubscriptions(h)
            s = string.empty(1, 0);
            d = DataContainer.instance();
            p = d.Objects.Properties.RowNames;

            mc = metaclass(h);
            ml = mc.MethodList;
            for i = find(ismember([ml.DefiningClass], mc))
                nm = ml(i).Name;

                % Find update methods
                if startsWith(nm, "update")
                    pn = nm(7:end);
                    if matches(pn, p)
                        s(end + 1) = string(pn); %#ok<AGROW>
                    end
                end
            end
        end

        function obj = instance()
            persistent BezoarObject
            if isempty(BezoarObject) || ~isvalid(BezoarObject)
                % Get open figures
                hl_init = findobj(0, 'Type', 'figure');
                
                DataContainer.instance();

                s = SplashScreen('Bezoar', 'bezoar512.png', ...
                    'Border', 'on');
                s.addText(20, 490, 'Loading Bezoar...', ...
                    'FontSize', 12, ...
                    'Color', 'w', ...
                    'Shadow', 'off')

                BezoarObject = Bezoar();
                BezoarObject.initialise()
                BezoarObject.initialiseObjects()
                BezoarObject.createActions()

                % Save all new figures
                hl_next = findobj(0, 'Type', 'figure');
                BezoarObject.FigureList = hl_next(~ismember(hl_next, hl_init));
                BezoarObject.CloseListener = listener(BezoarObject.FigureList, ...
                    'Close', @(~,~) delete(BezoarObject));

                set(findobj(BezoarObject.FigureList, 'Name', 'Bezoar'), ...
                    'Visible', 'on')
                delete(s)
            end
            obj = BezoarObject;
        end
    end
    methods (Access = private)
        function obj = Bezoar()
            vn = { ...
                'Object', ...
                'Parent', ...
                'Handle', ...
                'SubscribesTo', ...
                'UUID'};
            vt = { ...
                'TComponent', ...
                'TComponent', ...
                'matlab.graphics.Graphics', ...
                'cell', ...
                'string'};

            obj.Objects = table( ...
                'Size', [0 5], ...
                'VariableTypes', vt,...
                'VariableNames', vn);
        end
    end
end