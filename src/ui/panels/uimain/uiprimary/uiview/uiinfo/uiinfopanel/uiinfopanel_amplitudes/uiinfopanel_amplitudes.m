classdef uiinfopanel_amplitudes < TComponent
    properties (Constant)
        Type = "panel"
    end
    
    methods % CONSTRUCTOR
        function obj = uiinfopanel_amplitudes()
            set(obj.Handle, ...
                ... Title
                'Title', 'Amplitudes (mV)', ...
                ... Color and Styling
                'BorderType', 'etchedin', ...
                'BackgroundColor', [128 128 128]/256, ...
                'ForegroundColor', 'w', ...
                'Padding', 5);
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 225;

            obj.resocket(uix.VBox( ...
                'Parent', obj.Handle, ...
                'BackgroundColor', obj.Handle.BackgroundColor))

            uiinfopanel_amplitudes_histogram();
            uiinfopanel_amplitudes_information();

            set(obj.Handle, ...
                'Heights', [90 -1])
        end
    end     % INITIALISE
end