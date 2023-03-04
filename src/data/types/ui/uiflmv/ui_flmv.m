classdef ui_flmv < TData
    properties (Constant)
        Name = "uiflmv"
    end
    properties (Constant, Access = private)
        fps = 20
        refractory_period = 5
    end
    properties (SetAccess = immutable, GetAccess = private)
        timer                       timer
    end
    properties (SetObservable, SetAccess = private)
        cursor              (1,1)   double  = 0
        speed               (1,1)   double  = 10
    end
    properties (SetObservable, Access = private)
        index               (3,:)   double  = double.empty(3,0)
        index_next          (1,1)   double  = 1
    end
    properties (SetAccess = private)
        data_scaled         (:,:,1) double  = []
    end

    methods
        function setSpeed(obj, s)
            obj.speed = s;

            obj.update()
        end

        function moviePausePlay(obj)
            switch obj.timer.running
                case 'on'
                    obj.stop()
                case 'off'
                    obj.start()
            end
        end
        
        function stop(obj)
            switch obj.timer.running
                case 'on'
                    obj.timer.stop()
            end
        end
        function start(obj)
            switch obj.timer.running
                case 'off'
                    obj.timer.start()
            end
        end
        
        function jumpTo(obj, t)
            obj.cursor = max(min(t, obj.Data.prop.duration), 0);
            
            refreshFrame(obj)

            obj.update()
        end
    end
    methods (Access = private)
        function nextFrame(obj)
            if strcmp(obj.Data.uiview.viewname, "flmv")
                dt = obj.timer.InstantPeriod;
                if isnan(dt)
                    % Shouldn't reach here
                    dt = 1 / obj.fps;
                end
                dt = dt * obj.speed;

                if obj.Data.uiprvw.i
                    obj.nextFrameSelected(dt)
                else
                    obj.nextFrameAll(dt)
                end
            else
                obj.stop()
            end

            obj.update()
        end
        function nextFrameSelected(obj, dt)
            c = obj.cursor + dt;
            t = obj.Data.uiprvw.at;
            p = 1;

            t_min = min(t, [], "all") - p;
            t_max = max(t, [], "all") + p;

            if (c > t_max) || (c < t_min)
                obj.cursor = t_min;
            else
                obj.cursor = c;
            end
            
            obj.refreshFrame()
        end
        function nextFrameAll(obj, dt)
            r = obj.refractory_period;
            i = obj.index_next;

            d = obj.data_scaled;
            d = max(d - dt/r, 0);
            
            while (i > 0) && (obj.index(1, i) <= obj.cursor)
                t = obj.index(1, i);
                c = obj.index(2, i);

                d(c) = 1 - (obj.cursor - t)/r;

                i = i + 1;

                if i > size(obj.index, 2)
                    i = NaN;
                end
            end

            obj.data_scaled = d;
            obj.index_next = i;

            if obj.cursor + dt > obj.Data.prop.duration
                obj.stop()

                obj.data_scaled = zeros(obj.Data.cnfg.size);

                if size(obj.index, 2)
                    obj.index_next = 1;
                else
                    obj.index_next = NaN;
                end

                obj.cursor = 0;
            else
                obj.cursor = obj.cursor + dt;
            end
        end

        function refreshFrame(obj)
            c = obj.cursor;
            r = obj.refractory_period;

            sz = obj.Data.cnfg.size;

            % Calculate frame
            if any(obj.Data.uiprvw.at, "all")            
                s = (obj.Data.uiprvw.at - c)/r;
                s(s > 1) = 0;

                obj.data_scaled = s;
            else
                tf = (obj.index(1,:) <= c) & (obj.index(1,:) > c - r);

                obj.data_scaled = zeros(sz);
                obj.data_scaled(obj.index(2, tf)) = 1 - (c - obj.index(1, tf))/r;
            end
            
            % Calculate next index
            e = find(obj.index(1,:) > obj.cursor, 1);
            if isempty(e)
                obj.index_next = NaN;
            else
                obj.index_next = e;
            end            
        end
        function refreshIndices(obj)
            cf = obj.Data.cnfg.configuration;
            nc = obj.Data.prop.channels;

            tf = ismember(cf, 1:nc);

            in = NaN(nc, 1);
            in(cf(tf)) = find(tf);

            [it, ic, ig] = find(obj.Data.evnt.e);
            [it, i_sort] = sort(it);

            ic = ic(i_sort);
            ig = ig(i_sort);

            obj.index = [ ...
                (reshape(it, 1, []) - 1) / obj.Data.filt.frequency; ...
                (reshape(in(ic), 1, [])); ...
                (reshape(ig, 1, []))];
        end        
    end
    methods (Access = ?DataContainer)
        function updateevnt(obj)
            if strcmp(obj.Data.uiview.viewname, "flmv")
                obj.refreshIndices()
                obj.refreshFrame()
            else
                obj.index = double.empty(3,0);
            end
        end
        function updatecnfg(obj)
            if strcmp(obj.Data.uiview.viewname, "flmv")
                obj.refreshIndices()
                obj.refreshFrame()
            else
                obj.index = double.empty(3,0);
            end
        end
        function updatefilt(obj)
            if strcmp(obj.Data.uiview.viewname, "flmv")
                obj.refreshIndices()
                obj.refreshFrame()
            else
                obj.index = double.empty(3,0);
            end
        end
        function updateuiprvw_contours(obj)
            obj.nextFrameSelected(-Inf)
            obj.markForUpdate()
        end
        function updateuiview(obj)
            if strcmp(obj.Data.uiview.viewname, "flmv")
                obj.refreshIndices()
                obj.refreshFrame()
            else
                obj.stop()
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = ui_flmv()
            obj.timer = timer(...
                ... Callback Function Properties
                'TimerFcn', @(~,~) obj.nextFrame(), ...
                ... Time Properties
                'Period', 1 / obj.fps, ...
                'BusyMode', 'drop', ...
                'ExecutionMode', 'fixedRate');
        end
    end     % CONSTRUCTOR

    properties (Dependent)
        isrunning
    end
    methods
        function status = get.isrunning(obj)
            switch obj.timer.running
                case 'on'
                    status = true;
                case 'off'
                    status = false;
                otherwise
                    % Shouldn't reach here?
                    status = false;
            end
        end
    end
end