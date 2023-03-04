classdef TCMouseOver < TComponentHeader
    properties (SetAccess = immutable,  GetAccess = private)
        WindowListeners     (1,:)   event.listener = event.listener.empty
        HandleListeners     (1,:)   event.listener = event.listener.empty
    end
    properties (Access = private)
        wasOver             (1,1)   logical = false
    end
    methods (Access = protected)
        function enterFcn(~);       end
        function traverseFcn(~);    end
        function exitFcn(~);        end
    end
    methods (Access = private)
        function mouseMotion(obj)
            h = hittest;

            if isequal(h, obj.Handle)
                if ~obj.wasOver
                    obj.enterFcn_()
                    obj.wasOver = true;
                end
                obj.traverseFcn_()
            else
                if obj.wasOver
                    obj.exitFcn_()
                    obj.wasOver = false;
                end
            end
        end

        function enterFcn_(obj)
            obj.enterFcn();     
        end
        function traverseFcn_(obj)
            obj.traverseFcn()
        end
        function exitFcn_(obj) 
            obj.exitFcn()
        end

        function updateListeners(obj)
            if (strcmp(obj.Handle.Visible, "on") && strcmp(obj.Handle.PickableParts, "on")) || ...
                    (strcmp(obj.Handle.Visible, "off") && strcmp(obj.Handle.PickableParts, "all"))
                obj.enableListeners()
            else
                obj.disableListeners()
            end
        end
        function enableListeners(obj)  
            [obj.WindowListeners(:).Enabled] = deal(true);  
        end
        function disableListeners(obj)
            [obj.WindowListeners(:).Enabled] = deal(false); 
        end
    end
    methods %CONSTRUCTOR
        function obj = TCMouseOver()
            methodslist = { ...
                'enterFcn', ...
                'traverseFcn', ...
                'exitFcn'};
            
            ml = (metaclass(obj).MethodList);
            mp = ml(ismember({ml.Name}, methodslist));
            if any([mp.DefiningClass] ~= ?TCMouseOver)
                obj.WindowListeners(1) = listener(obj.Window, ...
                    'WindowMouseMotion', @(~, ~) obj.mouseMotion());
            end
        end
    end     %CONSTRUCTOR
end

% obj.HandleListeners(1) = addlistener(obj.Handle, ...
%     'Visible', 'PostSet', @(~, ~) obj.updateListeners());
% obj.HandleListeners(2) = addlistener(obj.Handle, ...
%     'PickableParts', 'PostSet', @(~, ~) obj.updateListeners());