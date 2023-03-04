classdef uithumbs < TComponent
    properties (Constant)
        Type = "axes"
    end
    properties (Constant, Access = private)
        sz = 32
    end

    methods
        function updateProp(obj)
            s = 35;
            set(obj.Handle, ...
                'Color', [064 064 064]/256, ...
                'XLim', [-150 150]/s, ...
                'YLim', [0 50]/s)
            set(obj.Handle, ...
                'Colormap', autumn)
        end
    end
    methods (Access = protected)
        function resizeFcn(obj)
            p = getpixelposition(obj.Handle);
            set(obj.Handle, ...
                'XLim', [0 p(3)] + 0.5, ...
                'YLim', [0 p(4)] + 0.5)
        end
    end     % PROTECTED
    methods % CONSTRUCTOR
        function obj = uithumbs()
            set(obj.Handle, ...
                'Color', [064 064 064]/256, ...
                'Colormap', flipud(autumn), ...
                'CLim', [0 1], ...
                'XLim', [0.5 300.5], ...
                'YLim', [0.5 50.5])
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 50;
            
            uithumbs_images();
        end
    end     % INITIALISE
end