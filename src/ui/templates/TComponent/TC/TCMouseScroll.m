classdef TCMouseScroll < TComponentHeader
    properties (SetAccess = immutable, GetAccess = private)
        HandleListeners     (1,:)
    end
    properties (SetAccess = private, GetAccess = protected)
        ScrolledUnits       (1,1)   double  = 0
    end
    
    methods (Access = protected)
        function mouseScroll(~);        end
    end
    methods (Access = private)
        function mouseScroll_(obj, ~, e)
            obj.ScrolledUnits = get(e.JavaEvent, 'WheelRotation');

            obj.mouseScroll()
        end
    end
    methods %CONSTRUCTOR
        function obj = TCMouseScroll()            
            methodslist = { ...
                'mouseScroll'};
            
            ml = (metaclass(obj).MethodList);
            mp = ml(ismember({ml.Name}, methodslist));
            if any([mp.DefiningClass] ~= ?TCMouseScroll)
                jh = handle(findjobj(ancestor(obj.Handle, 'uipanel')), 'CallbackProperties');
                obj.HandleListeners = handle.listener(jh, 'MouseWheelMoved', @obj.mouseScroll_);
            end
        end
    end     %CONSTRUCTOR
    events (ListenAccess = private)
        MouseScroll
    end
end