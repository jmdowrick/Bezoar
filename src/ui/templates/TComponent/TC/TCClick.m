classdef TCClick < TCAxes
    %#ok<*MCNPN>
    properties (SetAccess = immutable, GetAccess = private)
        HandleListeners     (1,:)   event.listener = event.listener.empty
        WindowListeners     (1,:)   event.listener = event.listener.empty
    end
    properties (SetAccess = private, GetAccess = protected)
        ClickedPosition     (1,2)   double = [NaN NaN]
        ClickedButton       (1,1)   double = NaN
        ClickedEvent                event.EventData
    end
    
    methods (Access = protected)
        function mouseClick(~);         end
        function mouseDrag(~);          end
        function mouseRelease(~);       end
        
        function mouseClickLeft(~);     end
        function mouseClickRight(~);    end
        function mouseClickMiddle(~);   end

        function disableClickInteractions(obj)
            obj.disableListeners()
            obj.mouseRelease()
        end
        function enableClickInteractions(obj)
            obj.enableListeners()
        end
    end
    methods (Access = private)
        function mouseClick_(obj, e)
            obj.ClickedEvent = e;
            if all(isfinite(obj.ClickedPosition))
                obj.mouseRelease_();
            else
                obj.ClickedPosition = obj.CurrentPosition;
                if isprop(e, 'Button')
                    obj.ClickedButton = e.Button;
                else
                    obj.ClickedButton = 1;
                end

                switch obj.ClickedButton
                    case 1 
                        obj.mouseClick()
                        obj.mouseClickLeft()
                        obj.mouseDrag()
                        obj.enableListeners()
                    case 2 
                        obj.mouseClickMiddle()
                        obj.ClickedPosition = [NaN NaN];
                    case 3
                        obj.mouseClickRight()
                        obj.ClickedPosition = [NaN NaN];
                end
            end
        end
        function mouseDrag_(obj)
            obj.mouseDrag()
        end
        function mouseRelease_(obj)
            obj.disableListeners()
            obj.mouseRelease()
            obj.ClickedPosition = [NaN NaN];
        end
        
        function enableListeners(obj)  
            [obj.WindowListeners(:).Enabled] = deal(true);  
        end
        function disableListeners(obj)
            [obj.WindowListeners(:).Enabled] = deal(false); 
        end
    end
    methods %CONSTRUCTOR
        function obj = TCClick()            
            methodslist = { ...
                'mouseClick', ...
                'mouseDrag', ...
                'mouseRelease', ...
                'mouseClickLeft', ...
                'mouseClickMiddle', ...
                'mouseClickRight'};
            
            ml = (metaclass(obj).MethodList);
            mp = ml(ismember({ml.Name}, methodslist));
            if any([mp.DefiningClass] ~= ?TCClick)
                if obj.hasAxes
                    obj.HandleListeners(1) = listener(obj.Handle, ...
                        'Hit', @(~,e) obj.mouseClick_(e));
                else
                    obj.HandleListeners(1) = listener(obj.Handle, ...
                        'ButtonDown', @(~,e) obj.mouseClick_(e));
                end
                obj.WindowListeners(1) = listener(obj.Window, ...
                    'WindowMouseMotion', @(~,~) obj.mouseDrag_());
                obj.WindowListeners(2) = listener(obj.Window, ...
                    'WindowMouseRelease', @(~,~) obj.mouseRelease_());
                
                obj.disableListeners()
            end
        end
    end     %CONSTRUCTOR
end