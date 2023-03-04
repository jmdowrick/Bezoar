classdef uiinfopanel_velocities_histogram < TComponent
    properties (Constant)
        Type = "axes"
    end
    properties (SetAccess = immutable)
        cl_cursor; rc_cursor
        hs_all; hs_selected
        tx_min; tx_max
    end
    properties (Access = private)
        vel_range           (1,:)   double  = double.empty(1,0)
        vel_range_last      (1,:)   double  = double.empty(1,0)
        selection_last              logical = []
    end

    methods
        function updateuiprvw(obj)
            obj.vel_range = [];
            obj.vel_range_last = [];
        end
        function updateuiinfo_velocities(obj)
            if ~isequal(obj.selection_last, obj.Data.uiinfo_selection.staggered)
                obj.vel_range = [];
                obj.vel_range_last = [];
                obj.selection_last = [];
            end

            y = [-0.25 1.10];
            if any(obj.Data.uiinfo_velocities.velocities, "all")
                set(obj.Handle, ...
                    "XLim", [1 obj.Data.uiinfo_velocities.bins], ...
                    "YLim", y * max(obj.Data.uiinfo_velocities.counts))
            else
                set(obj.Handle, ...
                    "XLim", [1 2], ...
                    "YLim", y)
            end
            set(obj.tx_min, ...
                "String", obj.Data.uiinfo_velocities.str_min, ...
                "Position", [1 0])
            set(obj.tx_max, ...
                "String", obj.Data.uiinfo_velocities.str_max, ...
                "Position", [obj.Data.uiinfo_velocities.bins 0])
            set(obj.hs_all, ...
                "BinEdges", 1:obj.Data.uiinfo_velocities.bins, ...
                "BinCounts", obj.Data.uiinfo_velocities.counts);
            set(obj.hs_selected, ...
                "BinEdges", 1:obj.Data.uiinfo_velocities.bins, ...
                "BinCounts", obj.Data.uiinfo_velocities.counts_selected);

            if (length(obj.vel_range) == 2) || ...
                    any(obj.Data.uiinfo_selection.staggered, "all")
                set(obj.hs_all, ...
                    "FaceAlpha", 0.3)
            else
                set(obj.hs_all, ...
                    "FaceAlpha", 0.7)
            end

            obj.updateCursor()
        end
    end
    methods (Access = protected)
        function traverseFcn(obj)
            switch length(obj.vel_range)
                case {0, 1}                   
                    obj.vel_range = obj.CurrentPosition(1);
            end
            obj.updateCursor()
        end
        function exitFcn(obj)
            switch length(obj.vel_range)
                case 1
                    obj.vel_range = [];
            end
            obj.updateCursor()
        end

        function mouseDrag(obj)
            p0 = obj.ClickedPosition(1);
            p1 = obj.CurrentPosition(1);
            
            e = obj.Data.uiinfo_velocities.edges;
            v = obj.Data.uiinfo_velocities.velocities;

            r = sort([p0 p1]);
            r = [floor(r(1)) ceil(r(2))];
            r = max(min(r, length(e)), 1);

            s = (v > e(r(1))) & (v < e(r(2)));

            obj.vel_range = r;
            obj.selection_last = s;

            obj.Data.uiinfo_selection.setStaggered(s)
        end
        function mouseRelease(obj)
            p0 = obj.ClickedPosition(1);
            p1 = obj.CurrentPosition(1);
            
            e = obj.Data.uiinfo_velocities.edges;

            r = sort([p0 p1]);
            r = [floor(r(1)) ceil(r(2))];
            r = max(min(r, length(e)), 1);

            switch length(obj.vel_range_last)
                case 0
                case 1
                case 2
                    if (range(r) == 1) && isequal(r, obj.vel_range)
                        obj.vel_range = p1;
                        obj.Data.uiinfo_selection.setSelection([])
                    end
            end

            obj.vel_range_last = obj.vel_range;
        end
    end
    methods (Access = private)
        function updateCursor(obj)
            e = obj.Data.uiinfo_velocities.edges;
            n = obj.Data.uiinfo_velocities.bins;

            s = obj.vel_range;
            switch length(s)
                case 0
                    p = 0;
                    set(obj.cl_cursor, ...
                        "Visible", "off")
                    set(obj.rc_cursor, ...
                        "Visible", "off")
                case 1
                    p = s(1);
                    set(obj.cl_cursor, ...
                        "Value", p, ...
                        "Label", num2str(e(max(min(round(s), n), 1)), '%.1f'), ...
                        "Visible", "on")
                    set(obj.rc_cursor, ...
                        "Visible", "off")
                case 2
                    p = s(2);
                    set(obj.cl_cursor, ...
                        "Value", p, ...
                        "Label", num2str(e(s(1)), '%.1f') + " to " + num2str(e(s(2)), '%.1f'), ...
                        "Visible", "on")
                    set(obj.rc_cursor, ...
                        "Position", [s(1) -256 range(s) 512], ...
                        "Visible", "on")
            end

            if p > (obj.Data.uiinfo_velocities.bins - 1)/2
                set(obj.cl_cursor, ...
                    "LabelHorizontalAlignment", "left")
            else
                set(obj.cl_cursor, ...
                    "LabelHorizontalAlignment", "right")
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uiinfopanel_velocities_histogram()
            set(obj.Handle, ...
                ... Ticks
                'TickLength', [0 0], ...
                ... Rulers
                'XLim', [0 1], ...
                'YLim', [0 1], ...
                'XLimMode', 'manual', ...
                'YLimMode', 'manual', ...
                'XColor', 'none', ...
                'YColor', 'none', ...
                ... Multiple Plots
                'NextPlot', 'add', ...
                ... Box Styling
                'Color', [1 1 1], ...
                ... Position
                'Position', [0 0 1 1], ...
                'PositionConstraint', 'innerposition', ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'all');
            yline(obj.Handle, 0, ...
                ... Color and Styling
                'Color', [0.8 0.8 0.8])
            obj.cl_cursor = xline(obj.Handle, 0, ...
                ... Labels
                'LabelOrientation', 'horizontal', ...
                ... Color and Styling
                'Color', 'w', ...
                ... Font
                'FontName', 'fixedwidth', ...
                'FontSize', 8, ...
                'FontWeight', 'bold');

            obj.hs_all = histogram(obj.Handle, [],  ...
                ... Data
                'Normalization', 'count', ...
                ... Color and Styling
                'FaceColor', 'w', ...
                'FaceAlpha', 0.3, ...
                'LineStyle', 'none');
            obj.hs_selected = histogram(obj.Handle, [],  ...
                ... Data
                'Normalization', 'count', ...
                ... Color and Styling
                'FaceColor', 'w', ...
                'FaceAlpha', 1, ...
                'LineStyle', 'none');
            obj.rc_cursor = rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [256 256 256 032]/256, ...
                'EdgeColor', 'none', ..., ...
                'AlignVertexCenters', 'on', ...
                ... Position
                'Position', [0 0 1 1]);
            obj.tx_min = text(obj.Handle, 0, 0, '', ...
                ... Color and Styling
                'Color', 'w', ...
                ... Font
                'FontName', 'FixedWidth', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                ... Position
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'top');
            obj.tx_max = text(obj.Handle, 0, 0, '', ...
                ... Color and Styling
                'Color', 'w', ...
                ... Font
                'FontName', 'FixedWidth', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                ... Position
                'HorizontalAlignment', 'right', ...
                'VerticalAlignment', 'top');

            set(allchild(obj.Handle), ...
                'PickableParts', 'none')
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 90;
        end
    end
end