classdef uipreview_main_sphere < TComponent
    properties (Constant)
        Type = "axes"
    end
    properties (SetAccess = immutable)
        hg; sf; pa; 
        cm; el
    end
    properties (SetAccess = private)
        clicked
    end

    methods (Access = ?Bezoar)
        function updateuiprvw_contours(obj)
            if obj.isVisible && obj.Data.uiprvw.i
                at = obj.Data.uiprvw.at;
                lv = obj.Data.uiprvw_contours.levels;

                [vx, vy, vz, cd] = ...
                    obj.Data.al_cont.createContoursSphere(at, lv);

                set(obj.pa, ...
                    "XData", vx, ...
                    "YData", vy, ...
                    "ZData", vz, ...
                    "CData", cd)

                set(obj.Handle, ...
                    "Colormap", obj.Data.uiprvw_contours.colourmap)
            end
        end
        function updateuiprvw_settings(obj)
            set(obj.Handle, ...
                "View", obj.Data.uiprvw_settings.view)

            if obj.isVisible
                set(obj.hg, ...
                    "Visible", "on")
            else
                set(obj.hg, ...
                    "Visible", "off")
            end
        end
        function updateal_cont(obj)
            o = 0.98;
            set(obj.sf, ...
                "XData", obj.Data.al_cont.xgrid * o, ...
                "YData", obj.Data.al_cont.ygrid * o, ...
                "ZData", obj.Data.al_cont.zgrid * o)
        end
    end
    methods (Access = protected)
        function mouseClickLeft(obj)
            obj.clicked = get(0, "PointerLocation");
        end
        function mouseDrag(obj)
            p = get(0, "PointerLocation");
            v = obj.Data.uiprvw_settings.view;

            obj.Data.uiprvw_settings.setView(v + obj.clicked - p)

            obj.clicked = p;
        end
        function mouseClickRight(obj)
            set(obj.cm, ...
                "Position", get(obj.Window, "CurrentPoint"), ...
                "Visible", "on")
            [obj.el(:).Enabled] = deal(true);
        end
    end     % PROTECTED
    methods (Access = private)
        function menuFcn(obj, e)
            try
                switch e.Source.Text
                    case "Copy to clipboard"
                        set(obj.Window, ...
                            "Pointer", "watch")
                        obj.copyToPlaceholderFigure()

                        export_fig("-clipboard", "-m1", "-nocrop", ...
                            obj.Data.uihfig.handle)

                    case "Save as .png"
                        obj.copyToPlaceholderFigure()

                        [file, path] = uiputfile("*.png", ...
                            "Save propagation map to file", ...
                            ["wave" num2str(obj.Data.uiprvw.i, "%04.f")]);

                        if ~isequal(file, 0) && ~isequal(path, 0)
                            export_fig(fullfile(path, file), "-m2", "-nocrop", ...
                                obj.Data.uihfig.handle)
                        end
                    case "Save as .eps"
                        [file, path] = uiputfile("*.eps", ...
                            "Save propagation map to file", ...
                            ["wave" num2str(obj.Data.uiprvw.i, "%04.f")]);

                        if ~isequal(file, 0) && ~isequal(path, 0)
                            export_fig(fullfile(path, file), "-eps", "-nocrop", "-painters", ...
                                obj.Data.uihfig.handle)
                        end
                end
            catch
            end
            set(obj.Window, ...
                "Pointer", "arrow")
        end
        function copyToPlaceholderFigure(obj)
            hp = ancestor(obj.Handle, "uipanel");
            pp = getpixelposition(hp);
            fg = obj.Data.uihfig.handle;
            set(fg, ...
                "Position", [1 1 pp(3:4)])

            delete(allchild(fg))
            set(copyobj(hp, fg), ...
                "Position", [1 1 pp(3:4)]);            
        end

        function checkCMVisibility(obj)
            if ~obj.cm.Visible
                [obj.el(:).Enabled] = deal(false);
            end
        end
    end     % PRIVATE
    methods % CONSTRUCTOR
        function obj = uipreview_main_sphere()
            set(obj.Handle, ...
                ... Rulers
                "XLim", [-1 1], ...
                "YLim", [-1 1], ...
                "ZLim", [-1 1], ...
                "YDir", "reverse", ...
                ... Position
                "Units", "pixels", ...
                "InnerPosition", obj.Data.uiprvw_positions.position_sphere, ...
                "DataAspectRatioMode", "manual", ...
                "DataAspectRatio", [1 1 1], ...
                ... View
                "View", [60 30], ...
                "CameraViewAngle", 10, ...
                ... Interactivity
                "Visible", "off", ...
                ... Callback Execution Control
                "PickableParts", "all")

            obj.hg = hggroup(obj.Handle);
            obj.sf = surf([], ...
                "Parent", obj.hg, ...
                ... Faces
                "FaceColor", [224 224 224]/256, ...
                "FaceAlpha", 0.8, ...
                ... Edges
                "EdgeColor", [128 128 128]/256);
            obj.pa = patch(obj.hg, ...
                ... Color
                "FaceColor", "flat", ...
                "EdgeColor", "none", ...
                "CData", [], ...
                "CDataMapping", "direct", ...
                ... Data
                "XData", [], ...
                "YData", [], ...
                "ZData", []);

            set(allchild(obj.Handle), ...
                "PickableParts", "none")

            % Create context menus
            obj.cm = uicontextmenu(obj.Window);
%             uimenu(obj.cm, ...
%                 "Text", "View contours")
%             uimenu(obj.cm, ...
%                 "Text", "View electrodes")
            uimenu(obj.cm, ...
                "Separator", "on", ...
                "Text", "Save as .png")
            uimenu(obj.cm, ...
                "Text", "Save as .eps")
            uimenu(obj.cm, ...
                "Separator", "on", ...
                "Text", "Copy to clipboard")

            obj.addlistener(findobj(obj.cm, "Children", gobjects(0)), ...
                "Action", @(~, e) obj.menuFcn(e))
            obj.el = [ ...
                obj.addlistener(obj.Window, ...
                "WindowMouseMotion", @(~, ~) obj.checkCMVisibility())
                obj.addlistener(obj.Window, ...
                "WindowMousePress", @(~, ~) obj.checkCMVisibility())];
        end
    end     % CONSTRUCTOR

    properties (Dependent, Access = private)
        isVisible
    end
    methods
        function tf = get.isVisible(obj)
            tf = strcmp(obj.Data.cnfg.mode, "sphere") & ...
                ~obj.Data.uiprvw_settings.showProjection;
        end
    end
end