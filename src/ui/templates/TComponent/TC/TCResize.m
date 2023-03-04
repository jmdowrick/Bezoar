classdef TCResize < TComponentHeader
    properties (Access = private)
        HandleListeners (1,:)   event.listener
    end
    properties (Access = private)
        Height_         (1,1)   double  = -1
        Width_          (1,1)   double  = -1
    end
    properties (Access = protected, Dependent)
        Height
        Width
    end
    
    methods (Access = public)
        function resize(obj)
            try
                obj.resizeFcn()
                switch lower(obj.Type)
                    case {'hbox', 'hboxscroll'}
                        set(obj.Handle, 'Widths', [obj.Children.Width])
                    case {'vbox', 'vboxscroll'}
                        set(obj.Handle, 'Heights', [obj.Children.Height])
                end
            catch
            end
        end
    end
    methods (Access = protected)
        function resizeFcn(~)
        end
    end
    methods % DEPENDENT
        function h = get.Height(obj)
            h = obj.Height_;
        end
        function set.Height(obj, h)
            obj.Height_ = h;
            obj.Parent.resize()
        end

        function w = get.Width(obj)
            w = obj.Width_;
        end
        function set.Width(obj, w)
            obj.Width_ = w;
            obj.Parent.resize()
        end
    end     % DEPENDENT
    methods % CONSTRUCTOR
        function obj = TCResize()
            methodslist = { ...
                'resizeFcn'};

            ml = metaclass(obj).MethodList;
            mp = ml(ismember({ml.Name}, methodslist));
            if (mp.DefiningClass ~= ?TCResize)
                obj.HandleListeners(end + 1) = listener(obj.Parent.Handle, ...
                    'SizeChanged', @(~,~) obj.resize());
            end
        end
    end     % CONSTRUCTOR
end