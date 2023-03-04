classdef TCKeyPress < TComponentHeader
    %#ok<*MCNPN>
    properties (SetAccess = immutable, GetAccess = private)
        WindowListeners     (1,:)   event.listener  = event.listener.empty
    end
    properties (SetAccess = private, GetAccess = protected)
        LastKey             (1,:)   char
    end
    
    methods (Access = protected)
        function keyPress(~);           end
    end
    methods (Access = private)
        function keyPress_(obj, e)
            obj.LastKey = e.Key;
            obj.keyPress()
        end
    end
    methods %CONSTRUCTOR
        function obj = TCKeyPress()            
            methodslist = { ...
                'keyPress'};
            
            ml = (metaclass(obj).MethodList);
            mp = ml(ismember({ml.Name}, methodslist));
            if any([mp.DefiningClass] ~= ?TCKeyPress)
                obj.WindowListeners(1) = listener(obj.Window, ...
                    'WindowKeyPress', @(~, e) obj.keyPress_(e));
            end
        end
    end     %CONSTRUCTOR
end