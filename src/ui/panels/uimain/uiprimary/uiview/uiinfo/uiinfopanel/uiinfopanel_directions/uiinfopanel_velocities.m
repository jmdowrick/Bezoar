classdef uiinfopanel_velocities < TComponent
    properties (Constant)
        Type = "panel"
    end
    
    methods % CONSTRUCTOR
        function obj = uiinfopanel_velocities()
            set(obj.Handle, ...
                ... Title
                'Title', 'Velocities (mm/s)', ...
                ... Color and Styling
                'BorderType', 'etchedin', ...
                'BackgroundColor', [128 128 128]/256, ...
                'ForegroundColor', 'w', ...
                'Padding', 5);
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 370;

            obj.resocket(uix.VBox( ...
                'Parent', obj.Handle, ...
                'BackgroundColor', obj.Handle.BackgroundColor))

            uiinfopanel_velocities_histogram();
            uiinfopanel_velocities_polar();
            uiinfopanel_velocities_information();

            set(obj.Handle, ...
                'Heights', [90 140 -1])
        end
    end     % INITIALISE
end