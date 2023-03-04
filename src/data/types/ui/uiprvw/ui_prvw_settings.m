classdef ui_prvw_settings < TData
    properties (Constant)
        Name = 'uiprvw_settings'
    end
    properties (SetAccess = private)
        showTimeDelays      (1,1)   logical = false
        showProjection      (1,1)   logical = false
        showElectrodes      (1,1)   logical = false
        showContours        (1,1)   logical = false

        view                (1,2)   double  = [60 30]
    end

    methods
        function setTimeDelayMode(obj, tf)
            % Determines if activation times are displayed as absolute
            % values or as a time-delay.
            obj.showTimeDelays = tf;

            obj.update()
        end
        function setProjectionMode(obj, tf)
            % Only relevant for spherical distributions.
            % Determines if preview is shown as a flat projected surface or
            % as a 3D object.
            obj.showProjection = tf;

            obj.update()
        end
        function setElectrodeMode(obj, tf)
            % Determines if electrodes are visible.
            obj.showElectrodes = tf;

            obj.update()
        end
        function setContourMode(obj, tf)
            % Determines if contours are visible.
            obj.showContours = tf;

            obj.update()
        end

        function setView(obj, v)
            v(2) = max(min(v(2), +45), -60);
            obj.view = v;

            obj.update()
        end
    end
    methods
        function updateuiprvw_positions(obj)
            obj.markForUpdate()
        end
    end
end