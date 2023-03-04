classdef uipreview_main < TComponent
    properties (Constant)
        Type = "axes"
    end
    properties (SetAccess = immutable)
        hg; pa
        tx; rc
        cm; el
        fg
    end
    properties (Access = private)
        clicked
    end

    methods (Access = ?Bezoar)
        function updateuiprvw_settings(obj)
            obj.updateAxes()
        end
        function updateuiprvw_contours(obj)
            obj.updateGraphics()
        end
    end     % BEZOAR
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
        function updateAxes(obj)
            if obj.isVisible
                x = obj.Data.uiprvw_positions.xlim;
                y = obj.Data.uiprvw_positions.ylim;
                p = obj.Data.uiprvw_positions.position_axes;
                c = [240 240 240]/256;
            else
                x = [0 1];
                y = [0 1];
                p = obj.Data.uiprvw_positions.position_sphere;
                c = [128 128 128]/256;
            end

            set(obj.Handle, ...
                "XLim", x, ...
                "YLim", y, ...
                "InnerPosition", p, ...
                "Color", c)
            set(obj.rc, ...
                "Position", [x(1) y(1) range(x) range(y)])
        end
        function updateGraphics(obj)
            if obj.isVisible
                if obj.Data.uiprvw.i
                    at = obj.Data.uiprvw.at;
                    lv = obj.Data.uiprvw_contours.levels;

                    [vx, vy, cd] = obj.Data.al_cont.createContours(at, lv);
                    set(obj.pa, ...
                        "XData", vx, ...
                        "YData", vy, ...
                        "CData", cd)

                    set(obj.Handle, ...
                        "Colormap", obj.Data.uiprvw_contours.colourmap)
                else
                    set(obj.pa, ...
                        "XData", [], ...
                        "YData", [], ...
                        "CData", [])
                end

                set(obj.hg, ...
                    "Visible", "on")
            else
                
                set(obj.hg, ...
                    "Visible", "off")
            end

            if obj.Data.uiprvw.i
                set(obj.tx, ...
                    "String", "Wave " + num2str(obj.Data.uiprvw.i) + newline + newline)
            else
                set(obj.tx, ...
                    "String", "")
            end
        end

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
                set(obj.rc, ...
                    "LineWidth", 0.5)
                [obj.el(:).Enabled] = deal(false);
            end
        end
    end     % PRIVATE
    methods % CONSTRUCTOR
        function obj = uipreview_main()
            set(obj.Handle, ...
                ... Ticks
                "XTick", [], ...
                "YTick", [], ...
                ... Rulers
                "YDir", "reverse", ...
                "XColor", "w", ...
                "YColor", "w", ...
                ... Box Styling
                "Color", [0.9 0.9 0.9], ...
                "Box", "on", ...
                ... Position
                "Units", "pixels", ...
                "DataAspectRatioMode", "manual", ...
                "DataAspectRatio", [1 1 1])

            obj.tx = title(obj.Handle, "", ...
                ... Text
                "Color", "w", ...
                ... Position
                "Units", "normalized", ...
                "Position", [0.5 1 0], ...
                "HorizontalAlignment", "center", ...
                "VerticalAlignment", "middle");
            obj.hg = hggroup(obj.Handle);
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
            obj.rc = rectangle(obj.Handle, ...
                ... Color and Styling
                "FaceColor", "none", ...
                "EdgeColor", "w", ...
                "AlignVertexCenters", "on", ...
                ... Position
                "Position", [0 -1 1 1]);

            % Let axes capture all mouse clicks
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
            tf_1 = strcmp(obj.Data.cnfg.mode, "flat");
            tf_2 = strcmp(obj.Data.cnfg.mode, "sphere") & ...
                obj.Data.uiprvw_settings.showProjection;

            tf = tf_1 | tf_2;
        end
    end
end