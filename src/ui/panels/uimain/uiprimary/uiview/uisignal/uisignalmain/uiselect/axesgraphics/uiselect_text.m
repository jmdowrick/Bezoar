classdef uiselect_text < TComponent
    properties (Constant)
        Type = 'hggroup'
    end

    methods (Access = public)
        function updatecnfg(obj)
            delete(allchild(obj.Handle))

            x = obj.Data.cnfg.x;
            y = obj.Data.cnfg.y;

            tf = isfinite(x) & isfinite(y);

            text(obj.Handle, ...
                x(tf), y(tf), cellstr(string(num2cell(find(tf)))), ...
                ... Text
                'Color', [0.2 0.2 0.5], ...
                ... Font
                'FontSize', 6, ...
                'FontName', 'FixedWidth', ...
                'FontWeight', 'bold', ...
                ... Position
                'HorizontalAlignment', 'center', ...
                ... Callbacks
                'PickableParts', 'none')
        end
    end
end