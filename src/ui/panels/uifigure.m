classdef uifigure < TComponent
    properties (Constant)
        Type = 'figure'
    end

    methods
        function updatesave(obj)
            str1 = "Bezoar";
            str2 = string(obj.Data.file.file);
            str3 = string(obj.Data.save.file);

            if obj.Data.save.issaved || isempty(obj.Data.save.file)
                str4 = "";
            else
                str4 = "*";
            end
            
            str = str1 + " - " + str2 + " - " + str3 + " " + str4;

            set(obj.Handle, ...
                'Name', str)
        end
    end
    methods
        function obj = uifigure()
            set(obj.Handle, ...
                ... Window Appearance
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'DockControls', 'off', ...
                ... Position
                'Position', getDefaultWindowPosition(), ...
                ... Plotting
                'Renderer', 'opengl', ...
                ... Interactivitiy
                'Visible', 'off', ...
                ... Window Callbacks
                'WindowButtonMotionFcn', @(~,~) {}, ...
                'WindowKeyPressFcn', @(~,~) {}, ...
                ... Callback Execution Control
                'Interruptible', 'off', ...
                ... Identifiers
                'Name', 'Bezoar', ...
                'NumberTitle', 'off', ...
                ... Undocumented
                'DoubleBuffer', 'on');

            try
                jf = get(handle(obj.Handle), 'JavaFrame'); %#ok<JAVFM>
                fp = which('bezoar.png');

                ji = javax.swing.ImageIcon(fp);
                jf.setFigureIcon(ji);
            catch
            end
        end
    end
    methods (Access = protected)
        function initialise(~)
            uimain();
            uimenus();
        end
    end
end

function p = getDefaultWindowPosition()
% Calculate appropiate window positions
pos = get(0, 'MonitorPositions');
pos = pos(1, :);

p = [0 0 1280 720];

% x
if pos(3) - p(3) > 100
    p(1) = floor((pos(3) - p(3)) / 2);
else
    p(1) = 50;
    p(3) = p(3) - p(1);
end

% y
if pos(4) - p(4) > 100
    p(2) = floor((pos(4) - p(4)) / 2);
else
    p(2) = 50;
    p(4) = p(4) - p(2);
end
end