classdef uiinfomain_trace < TComponent
    properties (Constant)
        Type  = 'line'
    end
    
    methods
        function updateuiinfo(obj)
            d = 0.4;

            c = obj.Data.cnfg.configuration;
            s = obj.Data.uiinfo.signals;

            s = s - min(s, [], 1, 'omitnan');
            s = s ./ range(s, 1);
            s = s - 0.5;
            s = s * d * 2;
            s = -s;

            [c, r] = meshgrid(1:size(c, 2), 1:size(c, 1));
            
            x = linspace(-d, d, obj.Data.uiinfo.samples)';
            x = repmat(x, 1, numel(c));
            x = x + c(:)';
            x = [x; NaN(1, numel(c))];

            y = s + r(:)';
            y = [y; NaN(1, numel(c))];

            set(obj.Handle, ...
                'XData', x(:), ...
                'YData', y(:))
        end
    end
    methods % CONSTRUCTOR
        function obj = uiinfomain_trace()
            set(obj.Handle, ...
                ... Color
                'Color', 'b', ...
                ... Callbacks
                'PickableParts', 'none')
        end
    end     % CONSTRUCTOR
end