function [events, waves] = detectwaves(data, cfg, frequency)
warning('off', 'images:bwfilt:tie')
warning('off', 'MATLAB:scatteredInterpolant:InterpEmptyTri2DWarnId')
warning('off', 'MATLAB:scatteredInterpolant:TooFewPtsInterpWarnId')

sz = size(cfg);

h = createWaitbar();

% Detect signals
tic
waitbar(1/5, h, 'Step 1 of 4: Creating detection signal')
ds = createdetectionsignal(data, frequency);             % Create detection signal
[it, ic] = detectevents(ds, 4, frequency);               % Find events
[itf, icf] = detectevents(ds, 1, frequency);             % Find more events
time_detect = toc;

tic
waitbar(2/5, h, 'Step 2 of 4: Creating threads and connections')
[thrh, indh] = createthreads(it, ic, cfg, 'horz');  % Find horizontal threads
[thrv, indv] = createthreads(it, ic, cfg, 'vert');  % Find vertical threads
[cnth, cntv] = createconnections(thrh, indh, thrv, indv, cfg, size(data));
time_thread = toc;

% Weave threads
cnth(~(cnth > 0)) = NaN;
cntv(~(cntv > 0)) = NaN;
thrh(isnan(cnth)) = NaN;
thrv(isnan(cntv)) = NaN;
nh = sum(~isnan(cnth));
nv = sum(~isnan(cntv));

tic
n = 0;
waitbar(3/5, h, 'Step 3 of 4: Weaving threads')
waves = NaN([sz 500]);
while any(nh) || any(nv)
    [ch, cv] = deal(NaN(sz));
    if max(nh) > max(nv)
        [~, i] = max(nh);
        tv = reshape(cnth(:, i), [], 1);
        cv(:, tv > 0) = cntv(:, tv(tv > 0));
        th = reshape(mode(cv, 2), [], 1);
        ch(th > 0, :) = transpose(cnth(:, th(th > 0)));
    else
        [~, i] = max(nv);
        th = reshape(cntv(:, i), [], 1);
        ch(th > 0, :) = transpose(cnth(:, th(th > 0)));
        tv = reshape(mode(ch, 1), [], 1);
        cv(:, tv > 0) = cntv(:, tv(tv > 0));
    end
    
    while ~isequaln(tv, reshape(mode(ch, 1), [], 1)) ...
            || ~isequaln(th, reshape(mode(cv, 2), [], 1))
        th = reshape(mode(cv, 2), [], 1);
        tv = reshape(mode(ch, 1), [], 1);
        [ch, cv] = deal(NaN(sz));
        ch(th > 0, :) = transpose(cnth(:, th(~isnan(th))));
        cv(:, tv > 0) = cntv(:, tv(tv > 0));
    end
    
    [at, horz, vert] = deal(NaN(sz));
    horz(~isnan(th), :) = transpose(thrh(:, th(~isnan(th))));
    vert(:, ~isnan(tv)) = thrv(:, tv(~isnan(tv)));
    
    tf = horz == vert;
    at(tf) = horz(tf);
    mk = zeros(sz);
    mk(tf) = NaN;
    
    if checkmap(at, frequency)
        n = n + 1;
        if n > size(waves, 3)
            waves = cat(3, waves, NaN([sz 500]));
        end
        waves(:,:,n) = at;
    end
    
    thrh(:, th(~isnan(th))) = thrh(:, th(~isnan(th))) + transpose(mk(~isnan(th),:));
    thrv(:, tv(~isnan(tv))) = thrv(:, tv(~isnan(tv))) + mk(:, ~isnan(tv));
    cnth(:, th(~isnan(th))) = cnth(:, th(~isnan(th))) + transpose(mk(~isnan(th),:));
    cntv(:, tv(~isnan(tv))) = cntv(:, tv(~isnan(tv))) + mk(:, ~isnan(tv));
    nh(th(~isnan(th))) = sum(~isnan(thrh(:, th(~isnan(th)))));
    nv(tv(~isnan(tv))) = sum(~isnan(thrv(:, tv(~isnan(tv)))));
end
time_weave = toc;

i = any(~isnan(waves), [1 2]);
n = sum(squeeze(i));
waves = waves(:,:,i);

[~, i] = sort(squeeze(min(waves, [], [1 2])));
waves = waves(:,:,i);

tic
waitbar(4/5, h, 'Step 4 of 4: Reinterpolating events')
waves = waves(:,:,1:n);
for i = 1:n
    [wave, rein] = cleanmap(waves(:,:,i), frequency);
    
    % Find points to reinterpolate
    if any(rein, 'all')
        ind = find(rein);
        for j = 1:length(ind)
            tf = abs(itf - wave(ind(j))) < (0.5 * frequency) & icf == cfg(ind(j));
            ts = itf(tf);
            if isempty(ts)
                wave(ind(j)) = NaN;
            else
                [~, imin] = min(abs(ts - wave(ind(j))));
                wave(ind(j)) = ts(imin);
            end
        end
    end
    
    % Do a final check
    if checkmap(wave, frequency)
        waves(:,:,i) = wave;
    else
        waves(:,:,i) = NaN;
    end
end
time_interp = toc;

% for i = 1:n
%     subplot(5, 10, i)
%     at = waves(:,:,i);
%     im = imagesc((at - min(at(:)))/32);
%     im.AlphaData = isfinite(at);
%     
%     colormap winter(20)
%     axis equal
%     axis off
% end


% Clean up and reorder maps
i = any(~isnan(waves), [1 2]);
n = sum(squeeze(i));
waves = waves(:,:,i);

[~, i] = sort(squeeze(min(waves, [], [1 2])));
waves = waves(:,:,i);
cfgs = repmat(cfg, [1 1 n]);
grps = repmat(reshape(1:n, 1, 1, []), [size(cfg) 1]);

waitbar(1, h, 'Finishing detection...')
tf = ~isnan(waves);

events = spalloc(size(data, 1), size(data, 2), numel(waves) * 2);
inds = sub2ind(size(data), waves(tf), cfgs(tf));

events(inds) = grps(tf);

%evts = sparse(waves(tf), cfgs(tf), grps(tf), size(data, 1), size(data, 2));
waves = (waves - 1)/frequency;

% Why do I do this step???
events(events > n) = 0;

warning('on', 'images:bwfilt:tie')
warning('on', 'MATLAB:scatteredInterpolant:InterpEmptyTri2DWarnId')
warning('on', 'MATLAB:scatteredInterpolant:TooFewPtsInterpWarnId')

pause(0.2)
h.UserData = true;
close(h)
if false
    disp(['Detection time: ' num2str(time_detect)])
    disp(['Threading time: ' num2str(time_thread)])
    disp(['Weaving time: ' num2str(time_weave)])
    disp(['Reinterpolation time: ' num2str(time_interp)])
end
end

function [ds] = createdetectionsignal(data, hz)
% data  Signals in columns of array
% hz    Frequency in hz

kn = -1:-1:-(hz - 1)/2;
kp = (hz - 1)/2-0.5:-1:1;
pk = [kn, kp]/hz;

vd = padarray(data(2:end-1,:).^2 - data(3:end,:).*data(1:end-2,:), 1, 0);
ds = NaN(size(data));
for i = 1:size(data, 2)
    ds(:,i) = smooth(vd(:,i), hz).*conv(data(:,i), pk, 'same');
end
ds(ds < 0) = 0;
end
function [t, c] = detectevents(ds, sr, hz)
% ds    Detection signal
% sr    Search radius in seconds
% hz    Frequency in hz

ns = round(hz * sr);
mm = movmax(ds, ns);
ms = movsum(diff(mm) == 0, ns - 1);

[t, c] = find(ms == ns - 1);
[t, i] = sort(t);
c = c(i);
%evt = sparse(it, ic, NaN, nt, nc);
end
function [thr, ind] = createthreads(it, ic, cfg, dir)
% it    Times / index of times
% ic    Corresponding channels
% cfg   Configuration
% dir   'horizontal' or 'vertical' directions
[r, c] = size(cfg);

switch dir
    case {'horizontal', 'horz'}
        nth = r;
        thr = NaN(c, 100000);   % Pre-allocating, should be enough?
    case {'vertical', 'vert'}
        nth = c;
        thr = NaN(r, 100000);
        cfg = transpose(cfg);
    otherwise
        return
end
ind = NaN(1, 100000);

n = 0;
for i = 1:nth
    ch = cfg(i,:);
    t0 = it(ic == ch(1));
    i0 = transpose((1:length(t0)) + n);
    n = n + length(t0);
    
    thr(1, i0) = t0;
    ind(i0) = i;
    for j = 2:length(ch)
        [t0, ii] = sort(t0);
        i0 = i0(ii);
        t1 = it(ic == ch(j));
        
        p = interp1(t0, t0, t1, 'nearest', 'extrap');
        tf0 = ismember(t0, p);
        q = interp1(t1 + p.^2, t1 + p.^2, t0(tf0) + t0(tf0).^2, 'nearest', 'extrap');
        tf1 = ismember(t1 + p.^2, q);
        
        t1 = [t1(tf1); t1(~tf1)];
        i1 = [i0(tf0); transpose((1:sum(~tf1)) + n)];
        
        n = n + sum(~tf1);
        thr(j, i1) = t1;
        ind(i0) = i;
        
        t0 = t1;
        i0 = i1;
    end
end
tf = sum(~isnan(thr)) > 1;
thr = thr(:,tf);
ind = ind(tf);

[~, ii] = sort(min(thr));
thr = thr(:,ii);
ind = ind(ii);
end
function [h, v] = createconnections(thrh, indh, thrv, indv, cfg, sz)
[r, c] = size(cfg);

% Find connections
irh = repmat(indh, c, 1);
ich = repmat(transpose(1:c), 1, length(indh));
ithrh = repmat(1:length(indh), c, 1);
ichnh = cfg(sub2ind([r c], irh, ich));
tfh = ~isnan(thrh);

icv = repmat(indv, r, 1);
irv = repmat(transpose(1:r), 1, length(indv));
ithrv = repmat(1:length(indv), r, 1);
ichnv = cfg(sub2ind([r c], irv, icv));
tfv = ~isnan(thrv);

evth = sparse(thrh(tfh), ichnh(tfh), ithrh(tfh), sz(1), sz(2));
evtv = sparse(thrv(tfv), ichnv(tfv), ithrv(tfv), sz(1), sz(2));

h = NaN(size(thrh));
h(tfh) = evtv(sub2ind(sz, thrh(tfh), ichnh(tfh)));
h(h == 0) = NaN;

v = NaN(size(thrv));
v(tfv) = evth(sub2ind(sz, thrv(tfv), ichnv(tfv)));
v(v == 0) = NaN;
end

function [tf] = checkmap(at, hz)
n = numel(at);
tf = ~isnan(at);
dx = abs(diff(at, 1, 2));
dy = abs(diff(at, 1, 1));

dx = dx(isfinite(dx));
dy = dy(isfinite(dy));

chk1 = sum(tf(:)) > n * 0.1;
chk2 = max(movsum(any(tf, 1), 2)) > 1;
chk3 = max(movsum(any(tf, 2), 2)) > 1;
chk4 = sum(range(at, 1) > (0.2 * hz)) > 2;
chk5 = sum(range(at, 2) > (0.2 * hz)) > 2;
chk6 = sum([dx(:); dy(:)] < hz * 0.05) < numel([dx; dy])*0.25;
chk7 = numel(unique(0.05*round((at(isfinite(at))/32)/0.05))) > 0.25*sum(isfinite(at), 'all');

tf = chk1 & chk2 & chk3 & chk4 & chk5 & chk6 & chk7;
end
function [at, re] = cleanmap_(at, ~)
[nr, nc] = size(at);    % Get size of map
tf = ~isnan(at);        % Identify locations of valid times
[ir, ic] = find(tf);    % Find x and y locations of valid times

F = scatteredInterpolant(ic, ir, at(tf), 'linear', 'linear');
[ir, ic] = find(imclose(tf, strel('diamond', 1)) & ~tf);        % Find positions to interpolate
at(sub2ind([nr nc], ir, ic)) = F([ic ir]);                      % Interpolate values

re = isfinite(at) & ~tf;
%at = round(at);
end
function [at, re] = cleanmap(at, hz)
n = hz;
f = 1;



[nr, nc] = size(at);    % Get size of map
tf = ~isnan(at);        % Identify locations of valid times
[ir, ic] = find(tf);    % Find x and y locations of valid times

% Provisional interpolation step
F = scatteredInterpolant(ic, ir, at(tf), 'linear', 'linear');   % Create interpolation map
[ir, ic] = find(imclose(tf, strel('diamond', 1)) & ~tf);        % Find positions to interpolate
at(sub2ind([nr nc], ir, ic)) = F([ic ir]);                      % Interpolate values


dx = diff(at, 2, 1);
dy = diff(at, 2, 2);

d_max = median(abs([dx(:); dy(:)]), 'omitnan');
%disp([prctile(abs([dx(:); dy(:)]), 75) d_max])
%disp(d_max)
d_max = prctile(abs([dx(:); dy(:)]), 75) * 2;
d_max = hz;

blocks = false([nr, nc]*2 + 1);
for i = 1:nr    % Find blocks in horizontal threads
    t = at(i,:);
    if sum(~isnan(t)) > 2
        m = ~isnan(t) | (conv(~isnan(t), [1 0 1], 'same') == 2);
        t = interp1(find(~isnan(t)), t(~isnan(t)), 1:nc);
        t(~m) = NaN;
    end
    v = diff(t);    a = [NaN diff(v) NaN];  b = [true isnan(v) true];
    while any(abs(a) > d_max)
        [~, ind] = max(abs(a) - d_max);
        if abs(v(ind - 1)) > abs(v(ind))
            v(ind - 1) = NaN;   b(ind) = true;
        else
            v(ind) = NaN;       b(ind + 1) = true;
        end
        a = [NaN diff(v) NaN];
    end
    z = abs(v) < (0.05 * hz);
    b = b | [false z false];
    blocks(i*2, 1:2:end) = b(:);
end
for i = 1:nc    % Find blocks in vertical threads
    t = transpose(at(:,i));
    if sum(~isnan(t)) > 2
        m = ~isnan(t) | (conv(~isnan(t), [1 0 1], 'same') == 2);
        t = interp1(find(~isnan(t)), t(~isnan(t)), 1:nr);
        t(~m) = NaN;
    end
    v = diff(t);    a = [NaN diff(v) NaN];  b = [true isnan(v) true];
    while any(abs(a) > d_max)
        [~, ind] = max(abs(a) - d_max);
        if abs(v(ind - 1)) > abs(v(ind))
            v(ind - 1) = NaN;   b(ind) = true;
        else
            v(ind) = NaN;       b(ind + 1) = true;
        end
        a = [NaN diff(v) NaN];
    end
    z = abs(v) < (0.05 * hz);
    b = b | [false z false];
    blocks(1:2:end, i*2) = b(:);
end

g0 = imclose(blocks, strel('diamond', 1)); 	% g0    Grid of 'invalid' points
g1 = bwareafilt(~g0, 1, 4);                 % g1    Largest mapping area
g1 = imfill(g1, 'holes');                   %       Fill holes

l0 = g0(2:2:end, 2:2:end);                  % l0    Bad or missing points
l1 = g1(2:2:end, 2:2:end);                  % l1    All viable points
l1 = imdilate(l1, strel('diamond', 3));     %       Dilate
l2 = ~(~tf | l0 | ~l1);                     % l2    Positions with values
l3 = ~l2 & l1;                              % l3    Positions to (re)interpolate

at(~l2) = NaN;
[ir, ic] = find(l2);
F = scatteredInterpolant(ic, ir, at(l2), 'linear', 'linear');
[ir, ic] = find(l3);
interpolants = F([ic ir]);
if ~isempty(interpolants)
    at(sub2ind([nr nc], ir, ic)) = interpolants;
end

if sum(l3(:)) > sum(l2(:))
    at = NaN(size(at));
    re = false(size(at));
else
    re = l3;
end

%re = l3;
end

function h = createWaitbar()
f = get(groot, 'Children');
if isempty(f)
    h = waitbar(0, ...
        'Analysing: Detecting and grouping events', ...
        'Name', 'Activation time detection and clustering', ...
        'WindowStyle',  'modal');
else
    sz = [360 75];
    p = f(1).Position;
    c = p([1 2]) + (p([3 4])/2);
    h = waitbar(0, ...
        'Analysing: Detecting and grouping events', ...
        'Name', 'Activation time detection and clustering', ...
        'WindowStyle', 'modal', ...
        'Units', 'pixels', ...
        'Position',     [c - (sz/2), sz]);
end

set(h, 'CloseRequestFcn', @closePressed)
set(h, 'UserData', false)

    function closePressed(src, ~)
        if ~src.UserData
            src.UserData = true;
        else
            closereq
        end
    end
end