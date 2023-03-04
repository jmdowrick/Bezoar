classdef ui_info < TData
    properties (Constant)
        Name = "uiinfo"
    end
    properties (SetObservable, AbortSet, SetAccess = private)
        duration            (1,1)   double  = 6
        samples             (1,1)   double  = NaN
    end
    properties (SetAccess = private, GetAccess = public)
        signals             (:,:,1) double  = []
    end

    methods
        function updatefilt(obj)
            obj.markForUpdate()
        end
        function updateuiprvw(obj)
            hz = obj.Data.filt.frequency;
            cf = obj.Data.cnfg.configuration;

            at = obj.Data.uiprvw.at;
            
            nh = round((obj.duration * hz) / 2);
            ns = 1 + (nh * 2);

            tg = round((at * obj.Data.filt.frequency)) + 1;
            tg = reshape(tg, 1, []);
            tg = tg + reshape(-nh:nh, [], 1);

            tf = (tg >= 1) & (tg <= obj.Data.filt.samples);
            
            tg(~tf) = NaN;
            tg = sub2ind( ...
                [obj.Data.filt.samples obj.Data.prop.channels], ...
                tg, ...
                repmat(reshape(cf, 1, []), ns, 1));
            
            tg(tf) = obj.Data.filt.filtered(tg(tf));

            obj.samples = ns;
            obj.signals = tg;

            obj.markForUpdate()
        end
    end
end