 classdef dc_filt < TData 
    properties (Constant)
        Name = "filt"
    end
    properties (SetAccess = immutable)
        list            (1,:)   TFilter = TFilter.empty(1,0)
    end
    properties (SetAccess = private)
        frequency       (1,1)   double  = NaN
        samples         (1,1)   double  = 0
        median          (1,:)   double  = double.empty(1,0)
        mad             (1,:)   double  = double.empty(1,0)
    end
    properties (SetObservable, SetAccess = private)
        current         (1,:)   TFilter = TFilter.empty(1,0)
        filtered                double  = []
    end
    
    methods
        function filter(obj, f)
            d = obj.Data.file.raw;
            p = FilterProperties;
            p.frequency = obj.Data.prop.frequency;
            p.samples = obj.Data.prop.samples;

            if obj.Data.file.isloaded
                nc = obj.Data.prop.channels;
                nf = length(f);
                h = gobjects();
                for i = 1:nf
                    if (i == 1)
                        h = createFilterWaitbar();
                    end
                    waitbar(1/nc, h, ...
                        ['Filtering: ' ...
                            num2str(i) ' of ' ...
                            num2str(nf) ' filters, ', ...
                            '1 of ' ...
                            num2str(nc) ' channels']);
                    p = f(i).validateProperties(p);

                    temp = f(i).filter(d(:, 1));
                    temp = repmat(temp, 1, nc);

                    for j = 2:nc
                        if h.UserData
                            waitbar(1, h, 'Cancelling import...')
                            pause(0.5)
                            close(h)
                            return
                        end

                        waitbar(j/nc, h, ...
                            ['Filtering: ' ...
                                num2str(i) ' of ' ...
                                num2str(nf) ' filters, ', ...
                                num2str(j) ' of ' ...
                                num2str(nc) ' channels'])
                        temp(:, j) = f(i).filter(d(:, j));
                    end
                    d = temp;
                end
                h.UserData = true;
                close(h)
            end
            
            obj.frequency = p.frequency;
            obj.samples = p.samples;
            
            obj.current = copy(f);
            obj.filtered = d;

            obj.update()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            obj.mad = mad(obj.filtered, 0, 1);  %#ok<CPROP> 
            obj.median = median(obj.filtered, 1);  %#ok<CPROP> 
        end
    end
    methods
        function updateprop(obj)
            obj.frequency = obj.Data.prop.frequency;
            obj.samples = obj.Data.prop.samples;
            obj.current = TFilter.empty(1,0);
            obj.filtered = obj.Data.file.raw;
        end
    end
    methods % CONSTRUCTOR
        function obj = dc_filt()
            s = what('data/misc/filters');
            for c = s.m'
                try % Try to create filters
                    c = char(c);    c = [c(1:end - 2) '()']; %#ok<FXSET>
                    o = eval(c);    assert(isa(o, 'TFilter'));
                    obj.list(end + 1) = o;
                catch
                end
            end
        end
    end     % CONSTRUCTOR
end

function h = createFilterWaitbar()
f = get(groot, 'Children');
if isempty(f)
    h = waitbar(0, ...
        'Creating filters...', ...
        'Name', 'Filtering signals', ...
        'WindowStyle',  'modal');
else
    sz = [360 75];
    p = f(1).Position;
    c = p([1 2]) + (p([3 4])/2);
    h = waitbar(0, ...
        'Creating filters...', ...
        'Name', 'Filtering signals', ...
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