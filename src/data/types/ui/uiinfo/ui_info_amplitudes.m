classdef ui_info_amplitudes < TData
    properties (Constant)
        Name = "uiinfo_amplitudes"
    end
    properties (Constant, Access = private)
        bin_width = 0.1

        min_amp = 0
        max_amp = Inf
    end
    properties (SetObservable, SetAccess = private)
        amplitudes          (:,:,1) double = []

        str_min             (1,1)   string = ""
        str_max             (1,1)   string = ""

        bins                (1,1)   double = 0
        edges               (1,:)   double = double.empty(1,0)

        counts              (1,:)   double = double.empty(1,0)
        counts_selected     (1,:)   double = double.empty(1,0)
    end
    
    methods
        function updateuiinfo(obj)
            obj.amplitudes = reshape(calculateAmplitudes( ...
                obj.Data.uiinfo.signals), obj.Data.cnfg.size);
            obj.amplitudes = obj.amplitudes./1000;   % Convert to mV

            a = obj.amplitudes;
            if any(a, "all")
                a_min = min(a, [], 'all');
                a_max = max(a, [], 'all');

                e_min = floor(a_min/obj.bin_width) * obj.bin_width;
                e_max = ceil(a_max/obj.bin_width) * obj.bin_width;

                e_min = max(e_min, obj.min_amp);
                e_max = min(e_max, obj.max_amp);

                e = e_min:obj.bin_width:e_max;

                if (a_min < e_min)
                    e(1) = -Inf;

                    obj.str_min = "< " + num2str(e_min, '%1.2f');
                else
                    obj.str_min = num2str(e_min, '%1.2f');
                end

                if (a_max > e_max)
                    e(end) = Inf;

                    obj.str_max = "> " + num2str(e_max, '%1.2f');
                else
                    obj.str_max = num2str(e_max, '%1.2f');
                end

                obj.bins = length(e);
                obj.edges = e;

                obj.counts = histcounts(a, e);
            else
                obj.resetToDefaults()
            end
        end
        function updateuiinfo_selection(obj)
            a = obj.amplitudes;
            s = obj.selection;

            obj.counts_selected = histcounts(a(s), obj.edges);
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
            s = obj.Data.uiinfo_selection.selection;
        end
    end     % DEPENDENT
end

function a = calculateAmplitudes(signals)
% Simple amplitude calculations
[v_max, ~] = max(signals, [], 1);
[v_min, ~] = min(signals, [], 1);

a = v_max - v_min;
end