classdef uimoviepanel_speed < TComponent
    properties (Constant)
        Type = 'panel'
    end
    properties (SetAccess = immutable, GetAccess = private)
        el; jh
    end
    properties (Access = private)
        levels = [01 05 10 20 30]
    end
    
    methods
        function changedSpeed(obj, ~, ~)
            i = get(obj.jh, 'Value');
            if isempty(i)
                return
            end

            try
                obj.jh.getParent.requestFocus()
            catch
            end
            
            obj.Data.uiflmv.setSpeed(obj.levels(i))
        end
    end
    methods % CONSTRUCTOR
        function obj = uimoviepanel_speed()
            obj.Height = 80;
            
            set(obj.Handle, ...
                'Title', 'Playback Speed', ...
                'BorderType', 'etchedin', ...
                'Padding', 5);
            p = uix.Panel( ...
                'Parent', obj.Handle, ...
                'BorderType', 'none');
            
            lv = obj.levels;
            nl = length(lv);

            jh = javaObjectEDT(javax.swing.JSlider(1, nl, 1));
            lj = javaObjectEDT('java.util.Hashtable');
            for i = 1:nl
                lj.put(java.lang.Integer(i), javax.swing.JLabel(['×' num2str(lv(i))]));
            end

            % Format slider bar
            set(jh, ...
                'MinorTickSpacing', 1, ...
                'MajorTickSpacing', 1, ...
                'SnapToTicks', true, ...
                'PaintLabels', true, ...
                'Orientation', jh.HORIZONTAL);
            jh.setLabelTable(lj)
            
            obj.el = handle.listener(handle(jh), 'StateChanged', @obj.changedSpeed);

            warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved')
            [jh, hc] = javacomponent(jh, [0 0 1 1], p); %#ok<JAVCM>
            warning('on', 'MATLAB:ui:javacomponent:FunctionToBeRemoved')
            
            bg = obj.Handle.BackgroundColor;
            jh.setBackground(java.awt.Color(bg(1), bg(2), bg(3)))
            
            set(jh, 'Value', 3)
            set(hc, 'Units', 'normalized', 'Position', [0 0 1 1])
            
            obj.jh = jh;
        end
    end     % CONSTRUCTOR
end

