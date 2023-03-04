classdef ui_prvw < TData
    properties (Constant)
        Name = "uiprvw"
    end
    properties (SetObservable, SetAccess = private)
        i                   (1,1)   double  = 0
        at                  (:,:,1) double  = []
    end

    methods
        function deleteWave(obj)
            if obj.i
                obj.Data.wave.modifyWave(NaN(obj.Data.cnfg.size), obj.i)

                if obj.Data.evnt.ng
                    obj.i = max(min(obj.i - 1, obj.Data.evnt.ng), 1);
                    obj.at = obj.Data.wave.waves(:, :, obj.i);
                else
                    obj.i = 0;
                    obj.at = NaN(obj.Data.cnfg.size);
                end
            else
                obj.at = NaN(obj.Data.cnfg.size);
            end

            obj.update()
        end
        function modifyWave(obj, at)
            if obj.i
                md = obj.Data.wave.medians;

                md_this = median(at, 'all', 'omitnan');

                md_last = 0;
                md_next = Inf;

                if (obj.Data.wave.n > 1) && (obj.i > 1)
                    md_last = md(obj.i - 1);
                end
                if (obj.Data.wave.n > 1) && (obj.i < obj.Data.wave.n)
                    md_next = md(obj.i + 1);
                end

                if isnan(md_this) || (md_this > md_last && md_this < md_next)
                    obj.at = at;
                    obj.update()
                else
                    % Don't let obj.at be modified so that it is out-of-order
                end
            else
                obj.at = at;
                obj.update()
            end
        end
        
        function setWave(obj, i)
            if obj.i
                if ~isequaln(obj.Data.wave.waves(:, :, obj.i), obj.at)
                    % Try to save wave if wave was modified
                    obj.Data.wave.modifyWave(obj.at, obj.i)
                end
            else
                if any(obj.at, "all")
                    md = median(obj.at, "all", "omitnan");
                    obj.Data.wave.modifyWave(obj.at)

                    md_all = obj.Data.wave.medians;
                    [~, i_this] = min(abs(md - md_all));
                    if i_this <= i
                        obj.i = i + 1;
                    end
                end
            end

            if (i && obj.Data.wave.n)
                obj.i = max(min(i, obj.Data.wave.n), 1);
                obj.at = obj.Data.wave.waves(:, :, obj.i);
            else
                obj.i = 0;
                obj.at = NaN(obj.Data.cnfg.size);
            end
            
            obj.update()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            if isempty(obj.at)
                if obj.i
                    obj.i = max(min(obj.i, obj.Data.wave.n), 1);
                    obj.at = obj.Data.wave.waves(:, :, obj.i);
                else
                    obj.i = 0;
                    obj.at = NaN(obj.Data.cnfg.size);
                end
            end
        end
    end
    methods %(Access = ?TData)
        function updatefile(obj)
            obj.i = 0;
        end
        function updatewave(obj)
            if ~obj.Data.wave.n
                obj.i = 0;
            end
            obj.at = [];
        end
    end
end