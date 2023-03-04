classdef uiwavenumbersmain_text_select < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties (SetAccess = immutable)
        rc
        tx
    end
    methods (Access = public)
        function updateuiprvw(obj)
            obj.update()
        end
        function updateuiview(obj)
            obj.update()
        end
        function update(obj)
            if strcmp('maps', obj.Data.uiview.viewname)
                set(obj.Handle, 'Visible', 'off')
                return
            end

            if obj.Data.uiprvw.i
                x = min(obj.Data.uiprvw.at, [], 'all');
                w = range(obj.Data.uiprvw.at, 'all');
                
                set(obj.rc, ...
                    'Position', [x -2 w 4] + [-1 0 2 0], ...
                    'FaceColor', [192 192 192 192]/256, ...
                    'EdgeColor', [128 128 128 192]/256)
                set(obj.tx, ...
                    'String', num2str(obj.Data.uiprvw.i), ...
                    'Position', [median(obj.Data.uiprvw.at(:), 'omitnan') 0])

                set(obj.Handle, 'Visible', 'on')
            else
                set(obj.Handle, 'Visible', 'off') 
            end
        end
    end
    methods
        function obj = uiwavenumbersmain_text_select()
            set(obj.Handle, ...
                ... Callback Execution Control
                'PickableParts', 'none')

            obj.rc = rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [224 224 256 192]/256, ...
                'EdgeColor', [160 160 256 128]/256, ...
                'LineWidth', 2, ...
                ... Position
                'Position', [-2 -2 1 4], ...
                ... Callback Execution Control
                'HitTest', 'off');

            obj.tx = text(obj.Handle, ...
                0, 0, '', ...
                ... Text
                'Color', [032 032 032]/256, ...
                ... Font
                'FontSize', 8, ...
                'FontName', 'FixedWidth', ...
                'FontWeight', 'bold', ...
                ... Position
                'HorizontalAlignment', 'center', ...
                ... Callback Execution Control
                'HitTest', 'off');
        end
    end
end