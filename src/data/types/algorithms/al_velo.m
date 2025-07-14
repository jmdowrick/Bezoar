classdef al_velo < TData
    properties (Constant)
        Name = 'al_velo'
    end
    properties (SetAccess = private)
        size            (1,2)   double = [0 0]

        xgrid           (:,:,1) double = []
        ygrid           (:,:,1) double = []
        zgrid           (:,:,1) double = []
    end
    properties (Access = private)
        lambda          (1,1)   double = 0.01
        grid_indices    (:,4)   double = double.empty(0,4)

        xv              (:,:,1) double = []
        yv              (:,:,1) double = []

        cache_at        (:,:,1) double = []
        cache_v         (:,:,1) double = []
        cache_b         (:,:,1) double = []
        cache_mode      (1,:)   char = ''
    end

    methods (Access = public)
        function [v, b] = calculateVelocities(obj, at)
            if all(obj.size)
                switch obj.Data.cnfg.mode
                    case 'flat'
                        [v, b] = obj.calculateFlatLPF(at);
                    case 'sphere'
                        [v, b] = obj.calculateSphereTPSDLF(at);
                end
            else
                v = [];
                b = [];
            end
        end
    end
    methods (Access = private)
        function [V, B] = calculateFlatLPF(obj, at)
            if strcmp(obj.cache_mode, 'flatlpf') && ...
                    isequal(size(at), size(obj.cache_at)) %#ok<CPROPLC> 
                tf = abs(at - obj.cache_at) > 0 | ...
                    (isnan(at) & isfinite(obj.cache_at)) | ...
                    (isfinite(at) & isnan(obj.cache_at));
                tf = conv2(tf, ones(2), "valid") > 0;

                ii = reshape(find(tf), 1, []);

                V = obj.cache_v;
                B = obj.cache_b;
            else
                ii = 1:prod(obj.size);

                V = NaN(obj.size);
                B = NaN(obj.size);
            end

            ind = obj.grid_indices;
                
            Tx = NaN(obj.size);
            Ty = NaN(obj.size);

            for i = ii
                A = [   ...
                    obj.Data.al_cont.xgrid(ind(i, :))' ...
                    obj.Data.al_cont.ygrid(ind(i, :))' ...
                    ones(4, 1)];
                b = at(ind(i, :))';
                x = mldivide(A, b);

                Tx(i) = x(1);
                Ty(i) = -x(2);
            end
            
            T = Tx.^2 + Ty.^2;
            
            V(ii) = 1./sqrt(T(ii));
            B(ii) = wrapTo2Pi(atan2(Tx(ii), Ty(ii)));
            
            obj.cache_at = at;
            obj.cache_v = V;
            obj.cache_b = B;
            obj.cache_mode = 'flatlpf';
        end
        function [v, b] = calculateSphereTPSDLF(obj, at)
            [~, b] = obj.calculateSphereTPS(at);

            vx = sin(b);
            vy = cos(b);

            gi = obj.grid_indices;
            gb = obj.grid_tps_bearings;

            v = NaN(obj.size);
            for i = 1:prod(obj.size)
                in = gi(i, :);
    
                d = dot( ...
                    [sin(gb(in)); cos(gb(in))], ...
                    repmat([vx(i); vy(i)], 1, 4), ...
                    1);
                
                s = NaN(1,4);
                t = at(in);
                for j = 1:4
                    if isfinite(t(j))
                        k = 1:4;
                        k(j) = [];

                        dt = t(j) - t(k);
                        dd = d(j) - d(k);

                        s(j) = median(dt./dd, 'omitnan');
                    end
                end

                v(i) = median(s, 'omitnan');
            end
            v(v < 0) = NaN;
            v = v * obj.Data.cnfg.r;
        end
        function [v, b] = calculateSphereTPS(obj, at)
            tf = isfinite(at(:));

            n = sum(tf);
            [i, j] = meshgrid(1:n);

            % Create tps interpolant
            ces = obj.sin_lat(tf);  cec = obj.cos_lat(tf);
            cas = obj.sin_lon(tf);  cac = obj.cos_lon(tf);

            gamma = acos(ces(i).*ces(j) + ...
                (cec(i).*cec(j)).*(cac(i).*cac(j) + cas(i).*cas(j)));
            gamma = real(gamma);

            cg = cos(gamma);

            W = (1 - cg)/2;
            A = log(1 + 1./sqrt(W));
            C = 2*sqrt(W);

            q = (A.*(12*W.^2 - 4*W) - 6*C.*W + 6*W + 1)/2;

            R = (1/(2*pi)).*(q/2 - 1/6);
            R(gamma < eps) = 1/(24*pi);

            Rn = reshape(R, [n n]);
            Rn = Rn + obj.lambda * eye(n);

            A = [Rn -ones(n, 1); ones(1, n) 0];
            b = [at(tf); 0];

            x = A\b; 
            
            c = x(1:end - 1);
            d = x(end);

            % Calculate velocities from interpolant
            ses = obj.sin_lat_vel;  sec = obj.cos_lat_vel;
            sas = obj.sin_lon_vel;  sac = obj.cos_lon_vel;
            
            [Tx, Ty] = deal(NaN(obj.size));
            for i = 1:(prod(obj.size))
                z = ses(i)*ces + (sac(i)*cac + (sas(i)*cas)).*(sec(i)*cec);
                
                W = (1 - z)/2;
                A = log(1 + 1./sqrt(W));
                C = 2*sqrt(W);
                
                dzda = sec(i)*cec.*(sac(i)*cas - sas(i)*cac);
                dzde = sec(i)*ces - (ses(i)*cec).*(sac(i)*cac + sas(i)*cas);

                dqdz = (3*W - 1)./(C + 2) - 6.*A.*W + A + (9/4)*C - 3/2;
                
                duda = (1/(4*pi))*dqdz.*dzda;
                dude = (1/(4*pi))*dqdz.*dzde;
                
                try
                    Tx(i) = c'*(duda);
                    Ty(i) = c'*(dude);
                catch 
                    Tx(i) = c*(duda);
                    Ty(i) = c*(dude);
                end
                Ty(i) = Ty(i)./sec(i);
            end

            T = Tx.^2 + Ty.^2;

            v = 1./sqrt(T);
            b = wrapTo2Pi(atan2(Tx, Ty));
        end
    end
    methods
        function updateal_cont(obj)
            obj.xv = conv2(obj.Data.cnfg.xgrid, 1/4*ones(2), 'valid');
            obj.yv = conv2(obj.Data.cnfg.ygrid, 1/4*ones(2), 'valid');

            obj.xv = padarray(obj.xv, obj.Data.al_cont.padding, "circular", "post");
            obj.yv = padarray(obj.yv, obj.Data.al_cont.padding, "circular", "post");

            obj.size = obj.Data.al_cont.size - 1;

            % Create grids for velocity calculations
            [ic, ir] = meshgrid(1:obj.size(2), 1:obj.size(1));

            ind = reshape(1:prod(obj.Data.cnfg.size), obj.Data.cnfg.size);
            ind = padarray(ind, obj.Data.al_cont.padding, "circular", "post");
            indg = NaN(prod(obj.size), 4);
            for i = 1:prod(obj.size)
                indg(i, 1) = ind(ir(i), ic(i));
                indg(i, 2) = ind(ir(i), ic(i) + 1);
                indg(i, 3) = ind(ir(i) + 1, ic(i));
                indg(i, 4) = ind(ir(i) + 1, ic(i) + 1);
            end

            obj.grid_indices = indg;

            % Update velocity grids
            switch obj.mode
                case 'flat'
                    obj.xgrid = obj.xv;
                    obj.ygrid = obj.yv;
                    obj.zgrid = zeros(obj.size);

                case 'sphere'
                    obj.updateTPSGridPositions()

                    [obj.xgrid, obj.ygrid, obj.zgrid] = sph2cart( ...
                        obj.xv, ...
                        obj.yv, ...
                        1);
            end
        end
    end

    % For thin-plate spline calculations
    properties (SetAccess = private)
        sin_lon;        sin_lat
        cos_lon;        cos_lat
        sin_lon_vel;    sin_lat_vel
        cos_lon_vel;    cos_lat_vel

        grid_tps_distances
        grid_tps_bearings
    end
    methods (Access = private)
        function updateTPSGridPositions(obj)
            obj.sin_lon = sin(obj.lon);
            obj.sin_lat = sin(obj.lat);
            obj.cos_lon = cos(obj.lon);
            obj.cos_lat = cos(obj.lat);

            obj.sin_lon_vel = sin(obj.lon);
            obj.sin_lat_vel = sin(obj.lat);
            obj.cos_lon_vel = cos(obj.lon);
            obj.cos_lat_vel = cos(obj.lat);
            
            indv = repmat((1:prod(obj.size))', 1, 4);
            indg = obj.grid_indices;

            obj.grid_tps_distances = findDistances( ...
                obj.latv(indv), ...
                obj.lonv(indv), ...
                obj.lat(indg), ...
                obj.lon(indg));
            obj.grid_tps_bearings = findBearings( ...
                obj.latv(indv), ...
                obj.lonv(indv), ...
                obj.lat(indg), ...
                obj.lon(indg));
        end
    end

    properties (Dependent, Access = private)
        lat;    latv
        lon;    lonv
        mode
    end
    methods
        function m = get.mode(obj)
            m = obj.Data.cnfg.mode;
        end
        function lon = get.lon(obj)
            lon = obj.Data.cnfg.xgrid;
        end
        function lat = get.lat(obj)
            lat = obj.Data.cnfg.ygrid;
        end
        function lon = get.lonv(obj)
            lon = obj.xv;
        end
        function lat = get.latv(obj)
            lat = obj.yv;
        end
    end
end

function d = findDistances(lat_0, lon_0, lat_1, lon_1)
sslat = sin(lat_0);     sslon = sin(lon_0);
sclat = cos(lat_0);     sclon = cos(lon_0);

eslat = sin(lat_1);     eslon = sin(lon_1);
eclat = cos(lat_1);     eclon = cos(lon_1);

d =  acos(sslat.*eslat + ...
    (sclat.*eclat).* (sclon.*eclon + sslon.*eslon));
end
function b = findBearings(lat_0, lon_0, lat_1, lon_1)
sslat = sin(lat_0);     sslon = sin(lon_0);
sclat = cos(lat_0);     sclon = cos(lon_0);

eslat = sin(lat_1);     eslon = sin(lon_1);
eclat = cos(lat_1);     eclon = cos(lon_1);

den = sclat.*eslat - sslat.*eclat.*(sclon.*eclon + sslat.*sslon);
num = eclat.*(eslon.*eclon - eclon.*sslon);

b = atan2(num, den);
end