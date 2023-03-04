classdef ui_hfig < TData
    properties (Constant)
        Name = "uihfig"
    end
    properties (SetAccess = private)
        handle          (1,1)   matlab.graphics.Graphics = gobjects(1)
    end

    methods
        function obj = ui_hfig()
            obj.handle = figure('Visible', 'off');
        end
    end
end