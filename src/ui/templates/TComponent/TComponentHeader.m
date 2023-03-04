classdef TComponentHeader < handle
    properties (Hidden, Constant, Abstract)
        Type                    char
    end
    properties (Hidden, SetAccess = immutable)
        UUID            (1,36)  char = NaN(1,36)
        Data
    end
    properties (SetAccess = immutable)
        Window          (1,1)   matlab.graphics.Graphics = gobjects(1)
        Parent                  TComponent = TComponent.empty(1,0)
        Index           (1,1)   double = 1
    end
    properties (SetAccess = private)
        Handle          (1,1)   matlab.graphics.Graphics = gobjects(1)
        Listeners       (1,:)   event.listener = event.listener.empty(1,0)

        Children        (:,1)   TComponent = TComponent.empty(1,0)
    end
    properties (SetAccess = immutable, Hidden)
        Initialising    (1,1)   logical = true
    end
    
    methods (Access = public)
        function initialise_(obj)
            obj.initialise()
        end
        function addChild(obj, o)
            if ~isempty(obj)
                obj.Children(end + 1) = o;
            end
        end
        function varargout = addlistener(obj, varargin)
            el = listener(varargin{:});
            obj.Listeners = [obj.Listeners, el'];
            if nargout == 1
                varargout = {el};
            end
        end
    end
    methods (Access = protected)
        function resocket(obj, h)
            % Only called during object construction.

            % Sometimes we nest multiple components (i.e. uipanels) for
            % visual purposes only. This method allows us to redefine the
            % graphics handle that children objects attach to without
            % additional objects.

            % Ensure that the original handle is a parent of the new object
            p = h;
            while ~isa(p, "matlab.ui.Root") && ~isequal(p, obj.Handle)
                p = p.Parent;
            end

            if isa(p, "matlab.ui.Root")
                warning("Failed to resocket handle. New handle is not a child of original handle.")
            else
                obj.Handle = h;
            end
        end
        function initialise(~)
        end
    end
    methods % CONSTRUCTOR
        function obj = TComponentHeader()
            if obj.Initialising
                obj.Initialising = false;

                obj.UUID = char(matlab.lang.internal.uuid());
                obj.Data = DataContainer.instance();

                obj.Parent = Bezoar.instance.ActiveObject;
                obj.Handle = createHandle(obj.Type, obj.Parent.Handle);
                if isgraphics(obj.Handle)
                    obj.Window = ancestor(obj.Handle, 'figure');
                else
                    obj.Window = ancestor(obj.Parent.Handle, 'figure');
                end
                if isempty(obj.Parent)
                    obj.Index = 1;
                else
                    obj.Index = length(obj.Parent.Children) + 1;
                end

                Bezoar.instance.addObject(obj)
                obj.Parent.addChild(obj)
            end
        end
    end     % CONSTRUCTOR
end

function h = createHandle(type, parent)
switch lower(type)
    case 'figure';      h = figure();
    case 'hbox';        h = createHBox(parent);
    case 'vbox';        h = createVBox(parent);
    case 'hboxscroll';  h = createHBoxScroll(parent);
    case 'vboxscroll';  h = createVBoxScroll(parent);
    case 'panel';       h = createPanel(parent);        
    case 'uipanel';     h = createUIPanel(parent);
    case 'cardpanel';   h = createCardPanel(parent);
    case 'axes';        h = createAxes(parent);
    case 'line';        h = createLine(parent);
    case 'image';       h = createImage(parent);
    case 'patch';       h = createPatch(parent);
    case 'hggroup';     h = createGroup(parent);
    case 'histogram';   h = createHistogram(parent);
    case 'uicontainer'; h = uicontainer(parent);
    otherwise;          h = gobjects();
end
end

function h = createHBox(parent)
h = uix.HBox(...
    'Parent', parent);
end
function h = createVBox(parent)
h = uix.VBox(...
    'Parent', parent);
end
function h = createHBoxScroll(parent)
h = uixm.HBoxScroll(...
    'Parent', parent);
end
function h = createVBoxScroll(parent)
h = uixm.VBoxScroll(...
    'Parent', parent);
end
function h = createPanel(parent)
h = uix.Panel(...
    'Parent', parent, ...
    'BorderType', 'none');
end
function h = createUIPanel(parent)
h = uipanel(...
    'Parent', parent, ...
    'BorderType', 'none');
end
function h = createCardPanel(parent)
h = uix.CardPanel(...
    'Parent', parent);
end
function h = createAxes(parent)
h = axes(parent, ...
    ... Ticks
    'XTick', [], ...
    'YTick', [], ...
    'XTickMode', 'manual', ...
    'YTickMode', 'manual', ...
    'TickLength', [0 0], ...
    ... Rulers
    'XLimMode', 'manual', ...
    'YLimMode', 'manual', ...
    'XColor', 'none', ...
    'YColor', 'none', ...
    ... Multiple Plots
    'NextPlot', 'add', ...
    ... Box Styling
    'Color', [1 1 1], ...
    ... Position
    'Position', [0 0 1 1], ...
    'ActivePositionProperty', 'position');
end
function h = createLine(parent)
h = line(parent, ...
    ... Data
    'XData', double.empty(1,0), ...
    'YData', double.empty(1,0));
end
function h = createImage(parent)
h = image(parent, ...
    ... Color
    'CData', []);
end
function h = createPatch(parent)
h = patch(parent, ...
    ... Color
    'FaceColor', 'flat', ...
    'EdgeColor', 'none', ...
    'CData', [], ...
    'CDataMapping', 'direct', ...
    ... Data
    'XData', [], ...
    'YData', [], ...
    'ZData', []);
end
function h = createGroup(parent)
h = hggroup(parent);
end
function h = createHistogram(parent)
h = histogram(parent, []);
end