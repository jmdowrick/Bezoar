classdef uiconfig_axes_sphere < TComponent
    properties (Constant)
        Type = "axes"
    end
    properties (SetAccess = immutable)
        ln_b; hg_t
        cm
    end
    properties (Access = private)
        clicked
    end

    methods
        function updatecnfg(obj)
            switch obj.Data.cnfg.mode
                case 'sphere'
                    cf = obj.Data.cnfg.configuration;
                    sz = obj.Data.cnfg.size;

                    if ~all(sz);   return;   end

                    % Background grid
                    long = obj.Data.cnfg.xgrid;
                    latg = obj.Data.cnfg.ygrid;

                    long = padarray(long, [1 1], NaN, "post");
                    latg = padarray(latg, [1 1], NaN, "post");

                    [xg, yg, zg] = sph2cart(long, latg, 1);
                    set(obj.ln_b, ...
                        'XData', [reshape(xg, 1, []), reshape(xg', 1, [])], ...
                        'YData', [reshape(yg, 1, []), reshape(yg', 1, [])], ...
                        'ZData', [reshape(zg, 1, []), reshape(zg', 1, [])])

                    % Text
                    lon = obj.Data.cnfg.lon;
                    lat = obj.Data.cnfg.lat;

                    [x, y, z] = sph2cart(lon, lat, 1.05);
                    i = find(ismember(1:min(length(lon), length(lat)), cf));

                    delete(allchild(obj.hg_t))
                    text(obj.hg_t, ...
                        x(i), y(i), z(i), ...
                        cellstr(string(i))', ...
                        ... Text
                        'Color', 'k', ...
                        ... Font
                        'FontSize', 6, ...
                        'FontName', 'fixedwidth', ...
                        'FontWeight', 'bold', ...
                        ... Text Box
                        'BackgroundColor', [248 248 248 160]/256, ...
                        ... Position
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', ...
                        ... Callback Execution Control
                        'PickableParts', 'none')

                    set(allchild(obj.Handle), ...
                        'Visible', 'on')
                    set(obj.Handle, ...
                        'Visible', 'off', ...
                        'PickableParts', 'all')

                    obj.enableClickInteractions()
                case 'flat'
                    set(allchild(obj.Handle), ...
                        'Visible', 'off')

                    obj.disableClickInteractions()
            end
        end
    end

    methods (Access = protected)
        function mouseClickLeft(obj)
            obj.clicked = get(0, 'PointerLocation');
        end
        function mouseDrag(obj)
            p = get(0, 'PointerLocation');
            if isempty(obj.clicked)
                return
            end
            
            v = obj.Handle.View + (obj.clicked - p);
            v(2) = max(min(v(2), +45), -60);

            set(obj.Handle, 'View', v)

            obj.clicked = p;
        end

        function mouseClickRight(obj)
            set(obj.cm, 'Visible', 'on', ...
                'Position', get(obj.Window, 'CurrentPoint'))
        end
        function menuFcn(obj, e)
            switch e.Source.Text
                case 'Load Configuration...'
                    obj.Data.cnfg.load()
            end
        end
    end

    methods % CONSTRUCTOR
        function obj = uiconfig_axes_sphere()
            set(obj.Handle, ...
                ... Rulers
                'XLim', [-1 1], ...
                'YLim', [-1 1], ...
                'ZLim', [-1 1], ...
                'YDir', 'reverse', ...
                ... Box Styling
                'XColor', 'none', ...
                'YColor', 'none', ...
                'ZColor', 'none', ...
                'Color', [0.8 0.8 1.0], ...
                'Box', 'on', ...
                ... Position
                'Units', 'normalized', ...
                'InnerPosition', [0.01 0.01 0.98 0.98], ...
                'DataAspectRatio', [1 1 1], ...
                ... View
                'View', [60 30], ...
                'CameraViewAngle', 10, ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'all')

            % Plot components
            obj.ln_b = line(obj.Handle, ...
                ... Line
                'Color', [224 224 224]/256, ...
                'AlignVertexCenters', 'on', ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.hg_t = hggroup(obj.Handle, ...
                ... Callback Execution Control
                'PickableParts', 'none');

            % Context menus
            obj.cm = uicontextmenu(obj.Window);
            uimenu(obj.cm, ...
                'Text', 'Load Configuration...')

            obj.addlistener(findobj(obj.cm, 'Children', gobjects(0)), ...
                'Action', @(~, e)obj.menuFcn(e))

            obj.disableClickInteractions()
        end
    end     % CONSTRUCTOR
end