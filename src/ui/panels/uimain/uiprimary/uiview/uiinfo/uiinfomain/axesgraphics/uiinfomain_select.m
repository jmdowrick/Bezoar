classdef uiinfomain_select < TComponent
    properties (Constant)
        Type = "patch"
    end
    properties (Constant, Access = private)
        select_size = 1
    end
    properties (Access = private)
        select_mode         (1,1)   string ...
            {mustBeMember(select_mode, ["default", "add", "remove"])} = "default"

        select_original     (:,:,1) logical = []
    end

    methods
        function updatecnfg(obj)
            if all(obj.sz)
                tf = (obj.cf > 0) & (obj.cf <= obj.Data.prop.channels);

                [y, x] = find(tf);

                o = obj.select_size * 0.5;

                x = x';     x = [x - o; x + o; x + o; x - o];
                y = y';     y = [y + o; y + o; y - o; y - o];

                set(obj.Handle, ...
                    'XData', x, ...
                    'YData', y, ...
                    'Visible', 'on')
            else
                set(obj.Handle, ...
                    'Visible', 'off')
            end
        end
        function updateuiinfo_selection(obj)
            set(obj.Handle, ...
                'FaceVertexAlphaData', obj.s(:) * 0.2)
        end
    end
    methods (Access = protected)
        function mouseAxesClick(obj)
            if obj.isCtrl
                obj.select_mode = "remove";
            elseif obj.isShift
                obj.select_mode = "add";
            else
                obj.select_mode = "default";
            end
            obj.select_original = obj.s;
        end
        function mouseAxesDrag(obj)
            if ~all(obj.sz)
                return
            end

            % Get start and end positions
            p0 = round(obj.ClickedAxesPosition);
            p1 = round(obj.CurrentPosition);

            p0 = min(max(p0, [1 1]), obj.sz([2 1]));
            p1 = min(max(p1, [1 1]), obj.sz([2 1]));

            x = min(p0(1), p1(1)):max(p0(1), p1(1));
            y = min(p0(2), p1(2)):max(p0(2), p1(2));

            s = false(obj.sz);
            s(y, x) = true;

            o = obj.s;
            if ~isequal(size(o), size(obj.cf))
                o = false(obj.sz);
            end

            switch obj.select_mode
                case "default"
                    if any(obj.select_original, "all")
                        if sum(s, "all") > 1
                            obj.select_original = false(obj.sz);
                            s = s;
                        else
                            s = false(obj.sz);
                        end
                    end
                case "add"
                    s = o | s;
                case "remove"
                    s = o & ~s;
            end

            obj.Data.uiinfo_selection.setSelection(s)
        end
    end
    methods % CONSTRUCTOR
        function obj = uiinfomain_select()
            set(obj.Handle, ...
                ... Color
                'FaceColor', [128 128 256]/256, ...
                ... Transparency
                'FaceAlpha', 'flat', ...
                'FaceVertexAlphaData', 1, ...
                'AlphaDataMapping', 'none', ...
                ... Callback Execution Control
                'PickableParts', 'none')
        end
    end     % CONSTRUCTOR

    properties (Dependent, Access = private)
        sz; cf; s
    end
    methods
        function sz = get.sz(obj)
            sz = obj.Data.cnfg.size;
        end
        function cf = get.cf(obj)
            cf = obj.Data.cnfg.configuration;
        end
        function s = get.s(obj)
            s = obj.Data.uiinfo_selection.selection;
        end
    end
end