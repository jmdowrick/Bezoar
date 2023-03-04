classdef al_cont < TData
    properties (Constant)
        Name = "al_cont"
    end
    properties (Constant, Access = private)
        db = createContourLookupTable()
    end
    properties (SetObservable, SetAccess = private)
        size            (1,2)   double = [0 0]

        xgrid           (:,:,1) double = []
        ygrid           (:,:,1) double = []
        zgrid           (:,:,1) double = []

        padding         (1,2)   double = [0 0]
    end
    properties (Access = private)

        cache_at        (:,:,1) double = []
        cache_lv        (:,:,1) double = []

        cache_cd        (1,:)   double = []
        cache_vx        (:,:,1) double = []
        cache_vy        (:,:,1) double = []
    end

    methods (Access = public)
        function [vx, vy, cd] = createContours(obj, at, lv)
            obj.updateContourPatchVertices(at, lv)

            cd = obj.cache_cd;
            [vx, vy] = scaleContourVertices( ...
                obj.xgrid, obj.ygrid, ...
                obj.cache_vx, obj.cache_vy);
        end
        function [vx, vy, vz, cd] = createContoursSphere(obj, at, lv)
            at = padarray(at, obj.padding, "circular", "post");
            obj.updateContourPatchVertices(at, lv)

            cd = obj.cache_cd;
            [vx, vy, vz] = scaleContourVertices3D( ...
                obj.xgrid, obj.ygrid, obj.zgrid, ...
                obj.cache_vx, obj.cache_vy);
        end
    end
    methods (Access = private)
        function updateContourPatchVertices(obj, at, lv)
            % Regenerate vertices only as required
            if ~isequaln(at, obj.cache_at) || ~isequaln(lv, obj.cache_lv)
                [vx, vy, cd] = generateContourPatchVertices(at, lv, obj.db);

                obj.cache_at = at;
                obj.cache_lv = lv;
                obj.cache_cd = cd;

                obj.cache_vx = vx;
                obj.cache_vy = vy;
            end
        end
    end
    methods (Access = ?DataContainer)
        function updatecnfg(obj)
            pd = [0 0];
            switch obj.Data.cnfg.mode
                case 'flat'
                    obj.xgrid = obj.Data.cnfg.xgrid;
                    obj.ygrid = obj.Data.cnfg.ygrid;

                case 'sphere'
                    if any(obj.Data.cnfg.i < 0);   pd = pd + [1 0];   end
                    if any(obj.Data.cnfg.j < 0);   pd = pd + [0 1];   end

                    [obj.xgrid, obj.ygrid, obj.zgrid] = sph2cart( ...
                        padarray(obj.Data.cnfg.xgrid, pd, "circular", "post"), ...
                        padarray(obj.Data.cnfg.ygrid, pd, "circular", "post"), ...
                        1);
            end

            obj.padding = pd;
            obj.size = obj.Data.cnfg.size + obj.padding;
        end
    end
end

% Transforms gridded contours to arbitrary grids.
% Note that if the grid is excessively distorted, contours may be
% inaccurate. Nevertheless, this is a reasonable approximation most of the
% time.
function [vxs, vys] = scaleContourVertices(x, y, vx, vy)
Fx = griddedInterpolant(x);
Fy = griddedInterpolant(y);

vxs = Fx(vy, vx);
vys = Fy(vy, vx);
end
function [vxs, vys, vzs] = scaleContourVertices3D(x, y, z, vx, vy)
Fx = griddedInterpolant(x);
Fy = griddedInterpolant(y);
Fz = griddedInterpolant(z);

vxs = Fx(vy, vx);
vys = Fy(vy, vx);
vzs = Fz(vy, vx);
end

% Generate patch vertices for a filled contour.
% Compare with MATLAB in-built functions, contourc() and contourf().
% Contains known issues at grids saddle points.
function [vx, vy, cd] = generateContourPatchVertices(at, lv, db)
nl = length(lv);
sz = size(at);

nr = sz(1);
nc = sz(2);

ng = prod(sz - 1);

lv_3 = reshape(lv, 1, 1, []);

tf_n = isnan(at);
tf_l = ~tf_n & (at < lv_3(1:nl - 1));
tf_u = ~tf_n & (at >= lv_3(2:nl));
tf_m = ~tf_n & ~tf_l & ~tf_u;

id = 0*tf_l + 1*tf_m + 2*tf_u + 3*tf_n;

mx = (4.^(3:-1:0));
id = 1 + ...
    mx(1) * id(1:nr - 1, 1:nc - 1, :) + ...
    mx(2) * id(1:nr - 1, 2:nc, :) + ...
    mx(3) * id(2:nr, 2:nc, :) + ...
    mx(4) * id(2:nr, 1:nc - 1, :);
id = reshape(id, prod(sz - 1), nl - 1);

dr = (lv_3 - at(1:nr - 1, :, :))./ ...
    (at(2:nr, :, :) - at(1:nr - 1, :, :));
dr(dr < 0 | dr > 1) = NaN;

dc = (lv_3 - at(:, 1:nc - 1, :))./ ...
    (at(:, 2:nc, :) - at(:, 1:nc - 1, :));
dc(dc < 0 | dc > 1) = NaN;

de = (lv_3 - at(1:nr - 1, 1:nc - 1, :))./ ...
    (at(2:nr, 2:nc, :) - at(1:nr - 1, 1:nc - 1, :));
de(de < 0 | de > 1) = NaN;

dw = (lv_3 - at(1:nr - 1, 2:nc, :))./ ...
    (at(2:nr, 1:nc - 1, :) - at(1:nr - 1, 2:nc, :));
dw(dw < 0 | dw > 1) = NaN;

[ic, ir] = meshgrid(1:nc, 1:nr);

bx = repmat(reshape(ic(1:nr - 1, 1:nc - 1), 1, []), 20, 1);
by = repmat(reshape(ir(1:nr - 1, 1:nc - 1), 1, []), 20, 1);

ix = reshape(1:(nr * (nc - 1)), nr, nc - 1);
iy = reshape(1:((nr - 1) * nc), nr - 1, nc);

xn = reshape(ix(1:nr - 1, :), 1, ng);
xs = reshape(ix(2:nr, :), 1, ng);

ye = reshape(iy(:, 2:nc), 1, ng);
yw = reshape(iy(:, 1:nc - 1), 1, ng);

vx = NaN(12, ng * (nl - 1));
vy = NaN(12, ng * (nl - 1));

tf = false(1, ng * (nl - 1));

for i = 1:nl - 1
    xl = dc(:, :, i);
    xu = dc(:, :, i + 1);

    yl = dr(:, :, i);
    yu = dr(:, :, i + 1);

    el = de(:, :, i);
    eu = de(:, :, i + 1);

    wl = dw(:, :, i);
    wu = dw(:, :, i + 1);

    mx = bx + ...
        [ ...
        zeros(1, ng);   ones(1, ng);    ones(1, ng);    zeros(1, ng);
        xl(xn);         ones(1, ng);    xl(xs);         zeros(1, ng);
        xu(xn);         ones(1, ng);    xu(xs);         zeros(1, ng);
        1 - wl(1:ng);   el(1:ng);       1 - wl(1:ng);   el(1:ng);
        1 - wu(1:ng);   eu(1:ng);       1 - wu(1:ng);   eu(1:ng)];

    my = by + ...
        [ ...
        zeros(1, ng);   zeros(1, ng);   ones(1, ng);    ones(1, ng);
        zeros(1, ng);   yl(ye);         ones(1, ng);    yl(yw);
        zeros(1, ng);   yu(ye);         ones(1, ng);    yu(yw);
        wl(1:ng);       el(1:ng);       wl(1:ng);       el(1:ng);
        wu(1:ng);       eu(1:ng);       wu(1:ng);       eu(1:ng)];

    id_this = id(:, i);
    db_this = db(:, id_this);

    tf_db = db_this > 0;

    [~, jj] = find(tf_db);

    vx_temp = NaN(size(db_this));
    vy_temp = NaN(size(db_this));

    vx_temp(tf_db) = mx(sub2ind(size(mx), db_this(tf_db), jj));
    vy_temp(tf_db) = my(sub2ind(size(my), db_this(tf_db), jj));

    ii = (1:ng) + ((i - 1)*ng);

    vx(:, ii) = vx_temp;
    vy(:, ii) = vy_temp;

    tf(ii) = any(db_this, 1);
end

cd = repelem(1:nl - 1, ng);
cd = cd(tf);

vx = vx(:, tf);
vy = vy(:, tf);
end
function i = sub2ind(sz, r, c)
% Efficient version of sub2ind which forgoes no input validation or error
% generation.
i = r + sz(1)*(c - 1);
end

% Generate lookup table for generateContourPatchVertices().
function db = createContourLookupTable()
db = zeros(4^4, 12);

db_u = zeros(4^4, 12);
db_l = zeros(4^4, 12);

sd = false(4^4, 1);

for i1 = 1:4
    for i2 = 1:4
        for i3 = 1:4
            for i4 = 1:4
                g = [i1 i2 i3 i4];
                c = sum((4.^(3:-1:0)).*(g - 1)) + 1;
                v = [];

                if sum(g ~= 4) >= 3
                    g = [g(end) g g(1)];

                    for i = 2:5
                        if (g(i) == 2)
                            v = [v (i - 1)];
                        else
                            v = [v 0];
                        end

                        e = [];
                        switch g(i)
                            case 1
                                switch g(i + 1)
                                    case 1
                                    case 2; e = 4;
                                    case 3; e = [4 8];
                                end
                            case 2
                                switch g(i + 1)
                                    case 1; e = 4;
                                    case 2
                                    case 3; e = 8;
                                end
                            case 3
                                switch g(i + 1)
                                    case 1; e = [8 4];
                                    case 2; e = 8;
                                    case 3
                                end
                            case 4
                                switch g(i - 1)
                                    case 1
                                        switch g(i + 1)
                                            case 1
                                            case 2; e = 12;
                                            case 3; e = [12 16];
                                        end
                                    case 2
                                        switch g(i + 1)
                                            case 1; e = 12;
                                            case 2
                                            case 3; e = 16;
                                        end
                                    case 3
                                        switch g(i + 1)
                                            case 1; e = [16 12];
                                            case 2; e = 16;
                                            case 3
                                        end
                                end
                        end
                        e = (i - 1) + e;
                        e = [e zeros(1, 2 - length(e))];

                        v = [v e];
                    end

                    if sum(v > 0) >= 7
                        % 7 or 8 vertices are always saddles
                        if (i1 == 1) && (i3 == 1)
                            db_l(c, :) = v;
                        elseif (i2 == 1) && (i4 == 1)
                            db_l(c, :) = v([1:3 10:12 4:9]);
                        end

                        if (i1 == 2) && (i3 == 2)
                            db_u(c, :) = v([1:3 10:12 4:9]);
                        elseif (i2 == 2) && (i4 == 2)
                            db_u(c, :) = v;
                        end
                        sd(c) = true;
                    end

                    db(c, :) = v;
                end
            end
        end
    end
end

for i = 1:size(db, 1)
    v = db(i, :);
    v(v == 0) = [];
    if ~isempty(v)
        v = [v v(1)];
        n = length(v);

        db(i, 1:n) = v;
        db(i, (n + 1):end) = v(1);
    end
end

db = transpose(db);
end