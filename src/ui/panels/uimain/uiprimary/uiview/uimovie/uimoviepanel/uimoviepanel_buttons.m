classdef uimoviepanel_buttons < TComponent
    properties (Constant)
        Type = 'Panel'
    end
    properties
        jh
    end
    
    methods (Access = private)
        function resetFocus(obj, ~, ~)
            obj.jh.requestFocus
        end
    end
    methods (Access = protected)
        function start(obj)
            obj.Data.uiflmv.start()
            obj.resetFocus()
        end
        function stop(obj)
            obj.Data.uiflmv.stop()
            obj.resetFocus()
        end
    end
    methods (Hidden)
        function obj = uimoviepanel_buttons()
            obj.Height = 55;

            set(obj.Handle, ...
                'Title', 'Controls', ...
                'BorderType', 'etchedin', ...
                'Padding', 5);
            h = uix.HBox( ...
                'Parent', obj.Handle, ...
                'Spacing', 5);
            obj.jh = findjobj(h);
            
            uipb_play = uicontrol(h, ...
                'Style', 'pushbutton', ...
                'String', 'Play', ...
                'Tooltip', 'Resumes playback of flashlight movie (Space)');
            obj.addlistener(uipb_play, ...
                'Action', @(~, ~) obj.start());



%             jh = findjobj(obj.uipb_play);
%             set(jh, 'FocusGainedCallback', {@obj.resetFocus})
            
            uipb_pause = uicontrol(h, ...
                'Style', 'pushbutton', ...
                'String', 'Pause', ...
                'Tooltip', 'Pauses playback of flashlight movie (Space)');
            obj.addlistener(uipb_pause, ...
                'Action', @(~, ~) obj.stop());
%             jh = findjobj(obj.uipb_pause);
%             set(jh, 'FocusGainedCallback', {@obj.resetFocus})
        end
    end
end

