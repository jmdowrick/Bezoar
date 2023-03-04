classdef uifilters < TComponent
    properties (Constant)
        Type = "panel"
    end
    properties (SetAccess = immutable)
        uilb
        uilb_java
        uibt_edit
        uipu
        uivb_param
        uitx_param
        uied_param
        uibt_filter
    end
    
    methods (Access = public)
        function updateuifilt(obj)
            obj.update()
        end
        function updatefilt(obj)
            obj.update()
        end
    end
    methods (Access = protected)
        function initialise(obj)
            obj.updateSelectedFilter()
        end
    end
    methods (Access = private)
        function update(obj)
            obj.updateListbox()
            obj.updateSelectedFilter()
            obj.updateButtons()
        end

        function updateListbox(obj)
            d = {obj.Data.uifilt.provisional.description};
            if isempty(obj.uilb.Value)
                i = 1;
            else
                i = max(min(obj.uilb.Value, length(d)), 1);
            end
            set(obj.uilb, ...
                'Value', i, ...
                'String', {obj.Data.uifilt.provisional.description})
            drawnow
            obj.uilb_java.setFixedCellHeight(-1)
        end
        function updateSelectedFilter(obj)
            p = obj.Data.uifilt.provisional;
            n = length(p);
            s = obj.uilb.Value;

            % Modify buttons
            if n > 0
                set(obj.uibt_edit(2), 'Enable', 'on')
            else
                set(obj.uibt_edit(2), 'Enable', 'off')
            end
            if s > 1
                set(obj.uibt_edit(3), 'Enable', 'on')
            else
                set(obj.uibt_edit(3), 'Enable', 'off')
            end
            if s < n
                set(obj.uibt_edit(4), 'Enable', 'on')
            else
                set(obj.uibt_edit(4), 'Enable', 'off')
            end

            if n == 0
                set(obj.uipu, 'Enable', 'off')
                set(obj.uied_param, 'Enable', 'off')
                return
            else
                set(obj.uipu, 'Enable', 'on')
                set(obj.uied_param, 'Enable', 'on')
            end

            % Modify popup
            f = p(obj.uilb.Value);
            i = find(strcmp(f.name, obj.uipu.String));
        
            set(obj.uipu, 'Value', i)
            
            for i = 1:length(f.parameterNames)
                set(obj.uitx_param(i), ...
                    'String', strcat(f.parameterNames(i), " ", f.parameterUnits(i)))
                set(obj.uied_param(i), ...
                    'String', num2str(f.parameterValues(i)))
            end
            
            % Modify parameters
            h = zeros(1,5);
            h(1:length(f.parameterNames)) = 45;
            
            set(obj.uivb_param, 'Heights', h)
        end
        function updateButtons(obj)
            if isequal(obj.Data.uifilt.provisional, obj.Data.filt.current)
                set(obj.uibt_filter, 'Enable', 'off')
            else
                set(obj.uibt_filter, 'Enable', 'on')
            end
        end

        function changeFilter(obj, e)
            i = obj.uilb.Value;
            if isempty(i)
                i = 0;
            end

            switch e.Source.String
                case 'Add Filter'
                    obj.Data.uifilt.addFilter(i)
                    set(obj.uilb, ...
                        'Value', min(i + 1, length(obj.Data.uifilt.provisional)))
                case 'Remove Filter'
                    obj.Data.uifilt.removeFilter(i)
                case 'Move Up'
                    obj.Data.uifilt.shiftFilterUp(i)
                    set(obj.uilb, 'Value', i - 1)
                case 'Move Down'
                    obj.Data.uifilt.shiftFilterDown(i)
                    set(obj.uilb, 'Value', i + 1)
            end
            obj.update()
        end
        function changeFilterType(obj, e)
            n = length(obj.Data.uifilt.provisional);
            if n > 0
                obj.Data.uifilt.changeFilter(obj.uilb.Value, e.Source.Value)
            end
            obj.update()
        end
        function changeSelection(obj)
            obj.update()
        end
        function changeParameters(obj)
            i = obj.uilb.Value;
            v = str2double({obj.uied_param.String});

            obj.Data.uifilt.changeFilterParameters(i, v)
        end

        function reset(obj)
            obj.Data.uifilt.reset()
        end
        function refilter(obj)
            obj.Data.uifilt.refilter()
        end
    end
    methods % CONSTRUCTOR
        function obj = uifilters()
            obj.Height = 360;
            
            set(obj.Handle, ...
                'BorderType', 'etchedin', ...
                'Title', 'Filters', ...
                'Padding', 3)
            
            h = uix.HBox( ...
                'Parent', obj.Handle, ...
                'Padding', 5, ...
                'Spacing', 7);
            
            obj.uilb = createListbox(h);
            
            v = uix.VBox(...
                'Parent', h, ...
                'Spacing', 3);
            
            set(h, 'Widths', [-1 100])
            
            obj.uibt_edit = createButtonsEdit(v);
            obj.uipu = createPopup(v, obj.Data.filt.list);
            [   obj.uivb_param, ...
                obj.uitx_param, ...
                obj.uied_param  ] = createParameters(v);
            obj.uibt_filter = createButtonsFilter(v);
            
            set(v, 'Heights', [132 45 -1 24])
            
            h = findjobj(obj.uilb);
            obj.uilb_java = h.getViewport.getView;
            
            obj.addlistener(obj.uibt_edit, ...
                'Action', @(~, e) obj.changeFilter(e))
            obj.addlistener(obj.uipu, ...
                'Action', @(~, e) obj.changeFilterType(e))
            obj.addlistener(obj.uilb, ...
                'Action', @(~, ~) obj.changeSelection())
            obj.addlistener(obj.uied_param, ...
                'Action', @(~, ~) obj.changeParameters())
            obj.addlistener(obj.uibt_filter(1), ...
                'Action', @(~, ~) obj.reset())
            obj.addlistener(obj.uibt_filter(2), ...
                'Action', @(~, ~) obj.refilter())
        end
    end     % CONSTRUCTOR
end

function h = createListbox(parent)
p = uix.Panel( ...
    'Parent', parent, ...
    'Title', 'Filter List', ...
    'Padding', 5);
h = uicontrol(p, ...
    'Style', 'listbox', ...
    'Interruptible', 'off');
end
function h = createButtonsEdit(parent)
p = uix.Panel( ...
    'Parent', parent, ...
    'Title', 'Edit Filters', ...
    'Padding', 3);
v = uix.VBox( ...
    'Parent', p, ...
    'Spacing', 3);

h = gobjects(4, 1);
uix.Empty('Parent', v);
h(1) = uicontrol(v, ...
    'Style', 'pushbutton', ...
    'String', 'Add Filter');
h(2) = uicontrol(v, ...
    'Style', 'pushbutton', ...
    'String', 'Remove Filter');
h(3) = uicontrol(v, ...
    'Style', 'pushbutton', ...
    'String', 'Move Up');
h(4) = uicontrol(v, ...
    'Style', 'pushbutton', ...
    'String', 'Move Down');
uix.Empty('Parent', v);

sz = 24;
set(v, 'Heights', [-1 sz sz sz sz -1])
end
function h = createPopup(parent, list)
p = uix.Panel( ...
    'Parent', parent, ...
    'Title', 'Filter Type', ...
    'Padding', 3);
h = uicontrol(p, ...
    'Style', 'popupmenu', ...
    'String', {list.name}, ...
    'Interruptible', 'off');
end
function [vb, tx, ed] = createParameters(parent)
n = 5;
p = uix.Panel( ...
    'Parent', parent, ...
    'Title', 'Parameters', ...
    'Padding', 3);
vb = uixm.VBoxScroll( ...
    'Parent', p, ...
    'Spacing', 1);

tx = gobjects(n, 1);    ed = gobjects(n, 1);
for i = 1:n
    v = uix.VBox( ...
        'Parent', vb);
    tx(i) = uicontrol(v, ...
        'Style', 'text', ...
        'String', 'PLACEHOLDER', ...
        'HorizontalAlignment', 'left');
    h = uix.HBox( ...
        'Parent', v);
    ed(i) = uicontrol(h, ...
        'Style', 'edit');
    uix.Empty(...
        'Parent', h);
    set(h, 'Widths', [-1 0])
    uix.Empty(...
        'Parent', v);
    set(v, 'Heights', [16 24 -1])
end

set(vb, 'Heights', ones(n, 1))
end
function h = createButtonsFilter(parent)
v = uix.HBox( ...
    'Parent', parent, ...
    'Spacing', 3);

h = gobjects(2, 1);
h(1) = uicontrol(v, ...
    'Style', 'pushbutton', ...
    'String', 'Reset');
h(2) = uicontrol(v, ...
    'Style', 'pushbutton', ...
    'String', 'Filter');
end