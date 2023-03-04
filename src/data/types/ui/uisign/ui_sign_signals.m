classdef ui_sign_signals < TData
    properties (Constant)
        Name = "uisign_signals"
    end
    properties (SetObservable, SetAccess = private)
        time                (:,1)   double = double.empty(1,0) 
        heights             (1,:)   double = double.empty(1,0) 

        factor              (1,1)   double = 8
        normalised          (1,1)   logical = false
    end
    properties (SetAccess = private)
        signals             (:,:,1) double = []
    end

    methods
        function scaleZoomIn(obj)
            obj.factor = obj.factor / 1.2;

            obj.update()
        end
        function scaleZoomOut(obj)
            obj.factor = obj.factor * 1.2;

            obj.update()
        end
        function scaleZoomReset(obj)
            obj.factor = 8;

            obj.update()
        end
        function scaleToggleNormalise(obj)
            obj.normalised = ~obj.normalised;

            obj.update()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            n = obj.Data.uisign.n;
            i = obj.Data.uisign.indices;

            tf = (i > 0) & (i <= obj.Data.prop.channels);

            % Determine factor
            if obj.normalised
                h = median(obj.Data.filt.mad(i(tf)));
            else
                h = NaN(1, n);
                h(tf) = obj.Data.filt.mad(i(tf));
            end
            h = h * obj.factor;

            y = NaN(obj.Data.filt.samples, n);
            y(:, tf) = obj.Data.filt.filtered(:, i(tf));
            y(:, tf) = y(:, tf) - obj.Data.filt.median(i(tf));

            y = y./h;
            y = y + (n:-1:1);

            obj.signals = y;
            obj.heights = h;
        end
    end
    methods (Access = ?DataContainer)
        function updatefilt(obj)
            obj.time = ((1:obj.Data.filt.samples)' - 1)/obj.Data.filt.frequency;
        end
        function updateprop(obj)
            obj.normalised = false;
            obj.factor = 8;
        end
        function updateuisign(obj)
            obj.markForUpdate()
        end
    end
end