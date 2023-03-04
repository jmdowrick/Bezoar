classdef dc_wave < TData 
    properties (Constant)
        Name = "wave"
    end
    
    properties (Access = private)
        index       (1,:)   double  = double.empty(1, 0)
        channels    (:,1)   double  = double.empty(0, 1)
    end
    properties (Access = private, SetObservable)
        waves_              double  = []
        medians_    (1,:)   double  = double.empty(1, 0)
    end

    methods
        function modifyWave(obj, t, varargin)
            assert(isequal(size(t), obj.Data.cnfg.size))

            tf = isfinite(obj.channels);
            it = NaN(size(obj.channels));
            it(tf) = t(obj.channels(tf));

            tf = isfinite(it);
            it(tf) = round(it(tf) * obj.Data.filt.frequency) + 1;           
            it(tf) = min(max(it(tf), 1), obj.Data.filt.samples);

            switch nargin
                case 2
                    obj.Data.evnt.addGroup(it)
                case 3
                    ig = varargin{1};
                    obj.Data.evnt.replaceGroup(it, obj.index(ig))
            end
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            tg = obj.Data.evnt.tg;
            tg(~ismember(1:obj.nc, obj.cf), :) = NaN;

            iw = repmat(obj.channels, 1, obj.n) + ...
                numel(obj.cf) * ((1:obj.n) - 1);
            
            tf = tg > 0;

            obj.waves_ = NaN([obj.sz obj.n]);
            obj.waves_(iw(tf)) = (tg(tf) - 1)/obj.hz;

            obj.medians_ = median(obj.waves_, [1 2], "omitnan");
            [~, obj.index] = sort(obj.medians_);
        end
    end
    methods (Access = ?DataContainer)
        function updatecnfg(obj)           
            tf = (obj.cf > 0) & (obj.cf <= obj.nc);

            obj.channels = NaN(obj.Data.prop.channels, 1);
            obj.channels(obj.cf(tf)) = find(tf);

            obj.markForUpdate()
        end
        function updateevnt(obj)
            obj.markForUpdate()
        end
    end

    properties (Dependent)
        n
        waves
        medians
    end
    methods
        function n = get.n(obj)
            n = obj.Data.evnt.ng;
        end
        function w = get.waves(obj)
            w = obj.waves_(:, :, obj.index);
        end
        function m = get.medians(obj)
            m = obj.medians_(obj.index);
        end
    end

    properties (Dependent, Access = private)
        hz; nc; sz; cf
    end
    methods
        function hz = get.hz(obj)
            hz = obj.Data.filt.frequency;
        end
        function nc = get.nc(obj)
            nc = obj.Data.prop.channels;
        end
        function sz = get.sz(obj)
            sz = obj.Data.cnfg.size;
        end
        function cf = get.cf(obj)
            cf = obj.Data.cnfg.configuration;
        end
    end
end