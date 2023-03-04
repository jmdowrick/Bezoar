classdef uimovie < TComponent
    properties (Constant)
        Type = 'HBox'
    end
    methods (Access = protected)
        function initialise(~)
            uimovielabels();
            uimoviemain();
            uimoviepanel();
        end
        function keyPress(obj)
            if obj.Handle.Visible
                switch obj.LastKey
                    case 'space'
                        obj.Data.uiflmv.moviePausePlay()
                end
            end
        end
    end
    methods
        function obj = uimovie()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [172 172 172]/256)
        end
    end
end