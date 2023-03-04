classdef uiscale_line < TComponent
    properties (Constant)
        Type        = 'Line'
    end
    methods (Access = public)
        function update(obj)
            y = [-0.3 0.3 NaN];

%             if obj.Data.uisign_plot.normalised
%                 y = y + 1;
%             else 
%                 y = repmat(y, 1, 256);
%                 y = y + repelem(1:256, 3);
%             end

            y = repmat(y, 1, 256);
            y = y + repelem(1:256, 3);
            x = ones(size(y)) * 0.5;

            set(obj.Handle, ...
                .... Data
                'XData', x, ...
                'YData', y, ...
                'LineWidth', 0.5, ...
                'AlignVertexCenters', 'on', ...
                'Color', [0.2 0.2 0.2])
        end
        function updateuisign_signals(obj)
            obj.update()
        end
    end
    
    methods
        function obj = uiscale_line()
            set(obj.Handle, ...
                ... Line
                'Color', 'k', ...
                'LineWidth', 1, ...
                ... Callbacks
                'PickableParts', 'none')
        end
    end
end