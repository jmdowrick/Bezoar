classdef uipreview < TComponent
    properties (Constant)
        Type = "uipanel"
    end

    methods (Access = ?Bezoar)
        function updateuiprvw_settings(obj)
            obj.updateHeight()
        end
        function updateuiprvw_positions(obj)
            obj.updateHeight()
        end
    end
    methods (Access = private)
        function updateHeight(obj)
            switch obj.Data.cnfg.mode
                case "flat"
                    obj.Height = obj.Data.uiprvw_positions.height;
                case "sphere"
                    obj.Height = obj.Data.uiprvw_positions.height;
                    if obj.Data.uiprvw_settings.showProjection
                        obj.Height = obj.Data.uiprvw_positions.height;
                    else
                        obj.Height = obj.Data.uiprvw_positions.height_sphere;
                    end
            end
        end
    end     % PRIVATE
    methods % CONSTRUCTOR
        function obj = uipreview()
            set(obj.Handle, ...
                "BackgroundColor", [048 048 048]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 0;

            uipreview_main();
            uipreview_main_sphere();
            uipreview_colorbar();
        end
    end     % INITIALISE
end