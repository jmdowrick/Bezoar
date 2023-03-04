classdef ui_info_velocities < TData
    properties (Constant)
        Name = "uiinfo_velocities"
    end
    properties (Constant, Access = private)
        bin_width = 0.2

        min_vel = 0
        max_vel = 10
    end
    properties (SetObservable, SetAccess = private)
        velocities          (:,:,1) double = []
        directions          (:,:,1) double = []

        str_min             (1,1)   string = ""
        str_max             (1,1)   string = ""

        bins                (1,1)   double = 0
        edges               (1,:)   double = double.empty(1,0)
        edges_dir           (1,:)   double = linspace(0, 2*pi, 13)

        counts              (1,:)   double = double.empty(1,0)
        counts_selected     (1,:)   double = double.empty(1,0)
    end
    
    methods
        function updateuiinfo(obj)
            [obj.velocities, obj.directions] = ...
                obj.Data.al_velo.calculateVelocities(obj.Data.uiprvw.at);
            obj.directions = wrapTo2Pi(obj.directions);

            v = obj.velocities;
            if any(v, "all")
                v_min = min(v, [], 'all');
                v_max = max(v, [], 'all');

                e_min = floor(v_min/obj.bin_width) * obj.bin_width;
                e_max = ceil(v_max/obj.bin_width) * obj.bin_width;

                e_min = max(e_min, obj.min_vel);
                e_max = min(e_max, obj.max_vel);

                e = e_min:obj.bin_width:e_max;

                if (v_min < e_min)
                    obj.str_min = "< " + num2str(e_min, '%1.2f');
                    
                    e(1) = -Inf;
                else
                    obj.str_min = num2str(e_min, '%1.2f');
                end

                if (v_max > e_max)
                    obj.str_max = "> " + num2str(e_max, '%1.2f');

                    e(end) = Inf;
                else
                    obj.str_max = num2str(e_max, '%1.2f');
                end

                obj.bins = length(e);
                obj.edges = e;

                obj.counts = histcounts(v, e);
            else
                obj.resetToDefaults()
            end
        end
        function updateuiinfo_selection(obj)
            v = obj.velocities;
            s = obj.selection;

            obj.counts_selected = histcounts(v(s), obj.edges);
        end
    end
    methods (Access = private)
        function resetToDefaults(obj)
            obj.str_min = "";
            obj.str_max = "";

            obj.bins = 2;
            obj.edges = [0 1];

            obj.counts = 0;
            obj.counts_selected = 0;
        end
    end

    properties (Dependent)
        selection
    end
    methods % DEPENDENT
        function s = get.selection(obj)
            s = obj.Data.uiinfo_selection.staggered;
        end
    end     % DEPENDENT
end
