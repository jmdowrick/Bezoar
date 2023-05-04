classdef dc_evnt < TData
    properties (Constant)
        Name = "evnt"
    end
    properties (SetAccess = private, SetObservable)
        e           (:,:,1) double  = sparse([])
    end
    properties (SetAccess = private)
        ng          (1,1)   double  = 0
        tg          (:,:,1) double  = double.empty(0, 0)
    end
    properties (Access = private)
        hz_current  (1,1)   double  = NaN
    end

    methods (Access = ?dc_wave)
        % Primitive methods for adding and removing temporal groups
        function addGroup(obj, t)
            % NOT QUITE WORKING
            assert(length(t) == obj.nc)

            tf = t > 0;
            if any(t)
                obj.e(sub2ind([obj.ns obj.nc], t(tf), find(tf))) = obj.ng + 1;
                obj.tg = [obj.tg, t];
                obj.ng = obj.ng + 1;

                obj.update()
            end
        end
        function replaceGroup(obj, t, i)
            assert(length(t) == obj.nc)

            tf = t > 0;
            obj.e(obj.e == i) = 0;
            if any(t)
                obj.e(sub2ind([obj.ns obj.nc], t(tf), find(tf))) = i;
                obj.tg(:, i) = t;
            else
                obj.e(obj.e > i) = obj.e(obj.e > i) - 1;
                obj.tg(:, i) = [];
                obj.ng = obj.ng - 1;
            end
            obj.update()
        end
    end
    methods (Access = ?dc_save)
        function load(obj, e)
            f = obj.ns/size(e, 1);

            [t, c, g] = find(e);

            t = round((t - 1) * f) + 1;
            t = min(max(t, 1), obj.ns);

            obj.e = sparse(t, c, g, obj.ns, obj.nc);
            ng = max(g, [], 'all', 'omitnan'); %#ok<*PROPLC>
            if isempty(ng) || isnan(ng)
                ng = 0;
            end
            sz = [obj.nc ng];

            obj.ng = ng;
            obj.tg = NaN(sz);
            obj.tg(sub2ind(sz, c, g)) = t;

            obj.update()
        end
    end
    methods
        function detect(obj)
            if ~obj.Data.file.isloaded
                return
            end

            obj.e = detectwaves( ...
                obj.Data.filt.filtered, ...
                obj.Data.cnfg.configuration, ...
                obj.Data.filt.frequency);

            [t, c, g] = find(obj.e);

            ng = max(g, [], 'all', 'omitnan');
            if isempty(ng) || isnan(ng)
                ng = 0;
            end
            sz = [obj.nc ng];

            obj.ng = ng;

            obj.tg = NaN(sz);
            obj.tg(sub2ind(sz, c, g)) = t;

            obj.update()
        end
        function clear(obj)
            obj.e = sparse(obj.ns, obj.nc);

            obj.ng = 0;
            obj.tg = double.empty(obj.nc, 0);

            obj.update()
        end
    end
    methods
        function updateprop(obj)
            obj.e = sparse(obj.Data.prop.samples, obj.nc);

            obj.ng = 0;
            obj.tg = double.empty(obj.nc, 0);

            obj.hz_current = obj.hz;
        end
        function updatefilt(obj)
            if (obj.hz_current ~= obj.hz)
                [t, c, g] = find(obj.e);

                t = round(((t - 1)/obj.hz_current) * obj.hz) + 1;

                obj.e = sparse(t, c, g, obj.ns, obj.nc);

                obj.tg = NaN(obj.nc, obj.ng);
                obj.tg(sub2ind([obj.nc obj.ng], c, g)) = t;

                obj.hz_current = obj.hz;
            end
        end
    end

    properties (Dependent, Access = private)
        nc; ns; hz
    end
    methods
        function nc = get.nc(obj)
            nc = obj.Data.prop.channels;
        end
        function ns = get.ns(obj)
            ns = obj.Data.filt.samples;
        end
        function hz = get.hz(obj)
            hz = obj.Data.filt.frequency;
        end
    end
end

function i = sub2ind(sz, r, c)
% Efficient version of sub2ind which forgoes no input validation or error
% generation.
i = r + sz(1)*(c - 1);
end