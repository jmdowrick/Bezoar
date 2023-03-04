classdef uiinfopanel < TComponent
    properties (Constant)
        Type = "vboxscroll"
    end

    methods % CONSTRUCTOR
        function obj = uiinfopanel()
            set(obj.Handle, ...
                'BackgroundColor', [128 128 128]/256, ...
                'Spacing', 3)
            set(obj.Handle.Scrollbar, ...
                'ThumbColor', [0.9 0.9 0.9])
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Width = 200;

            uiinfopanel_amplitudes();
            uiinfopanel_velocities();
        end
    end     % INITIALISE
end