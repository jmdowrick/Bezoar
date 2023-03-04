classdef TCClickAxes < TCAxes
    properties (SetAccess = immutable,  GetAccess = private)
        HandleListeners     (1,:)   event.listener  = event.listener.empty
        WindowListeners     (1,:)   event.listener  = event.listener.empty
    end
    properties (SetAccess = private,    GetAccess = protected)
        ClickedAxesPosition (1,2)   double  = [NaN NaN]
        ClickedAxesButton   (1,1)   double  = NaN
    end
    
    methods (Access = protected)
        function mouseAxesClick(~);         end
        function mouseAxesDrag(~);          end
        function mouseAxesRelease(~);       end
        
        function mouseAxesClickLeft(~);     end
        function mouseAxesClickRight(~);    end
        function mouseAxesClickMiddle(~);   end

        function disableAxesClickInteractions(obj)
            obj.disableListeners()
            obj.mouseAxesRelease()
        end
        function enableAxesClickInteractions(obj)
            obj.enableListeners()
        end
    end
    methods (Access = private)
        function mouseAxesClick_(obj, e)
            if all(isfinite(obj.ClickedAxesPosition))
                obj.mouseAxesRelease_();
            else
                obj.ClickedAxesPosition = obj.CurrentPosition;
                obj.ClickedAxesButton = e.Button;
                
                switch e.Button
                    case 1
                        obj.mouseAxesClick()
                        obj.mouseAxesClickLeft()
                        obj.mouseAxesDrag()
                        obj.enableListeners()
                    case 2
                        obj.mouseAxesClickMiddle()
                        obj.ClickedAxesPosition = [NaN NaN];
                    case 3
                        obj.mouseAxesClickRight()
                        obj.ClickedAxesPosition = [NaN NaN];
                end
            end
        end
        function mouseAxesDrag_(obj)
            obj.mouseAxesDrag()
        end
        function mouseAxesRelease_(obj)
            obj.disableListeners()
            obj.mouseAxesRelease()
            obj.ClickedAxesPosition = [NaN NaN];
        end
        
        function enableListeners(obj)  
            [obj.WindowListeners(:).Enabled] = deal(true);  
        end
        function disableListeners(obj)
            [obj.WindowListeners(:).Enabled] = deal(false); 
        end
    end
    methods %CONSTRUCTOR
        function obj = TCClickAxes()            
            methodslist = { ...
                'mouseAxesClick', ...
                'mouseAxesDrag', ...
                'mouseAxesRelease', ...
                'mouseAxesClickLeft', ...
                'mouseAxesClickMiddle', ...
                'mouseAxesClickRight'};
            
            ml = (metaclass(obj).MethodList);
            mp = ml(ismember({ml.Name}, methodslist));
            if obj.hasAxes && any([mp.DefiningClass] ~= ?TCClickAxes)
                obj.HandleListeners(1) = listener(ancestor(obj.Handle, 'axes'), ...
                    'Hit', @(~,e) obj.mouseAxesClick_(e));
                obj.WindowListeners(1) = listener(obj.Window, ...
                    'WindowMouseMotion', @(~,~) obj.mouseAxesDrag_());
                obj.WindowListeners(2) = listener(obj.Window, ...
                    'WindowMouseRelease', @(~,~) obj.mouseAxesRelease_());
                
                obj.disableListeners()
            end
        end
    end     %CONSTRUCTOR
end