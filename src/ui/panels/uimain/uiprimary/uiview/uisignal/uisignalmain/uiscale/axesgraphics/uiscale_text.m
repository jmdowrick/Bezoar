classdef uiscale_text < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties
        tx
    end
    methods (Access = public)
        function update(obj)
            i = obj.Data.uisign.indices;
            if isempty(i)
                set(obj.tx, ...
                    'String', '')
            else
                h = obj.Data.uisign_signals.heights';
                h = h/1000; % Convert to mV
                h = h * 0.6;
                s = num2str(h, '%.1f');
                s = cellstr(s);
                s = strtrim(s);
                s(h < 0.1) = {'<.1'};
                s = strcat(s, ' mV');

                set(obj.tx(1:length(i)), ...
                    {'String'}, s)
            end
        end
        function updateuisign_signals(obj)
            obj.update()
        end
    end   
    methods
        function obj = uiscale_text()
            obj.tx = text(obj.Handle, ...
                ones(256, 1), (1:256)', '', ...
                ... Text
                'Color', 'k', ...
                ... Font
                'FontSize', 8, ...
                'FontName', 'FixedWidth', ...
                'FontWeight', 'default', ...
                ... Position
                'HorizontalAlignment', 'left', ...
                ... Callbacks
                'PickableParts', 'none');
        end
    end
end