classdef VBoxScroll < uix.VBox
    properties (GetAccess = public)
        Panel
        Scrollbar
    end
    properties (SetAccess = private, GetAccess = public)
        Thumb = 0
        ThumbScroll = 24
    end
    properties (Dependent)
        ActiveSize
        ThumbColor
    end
    
    methods
        function s = get.ActiveSize(obj)
            p = getpixelposition(obj.Panel);
            s = p(3:4);
        end
        function c = get.ThumbColor(obj)
            c = obj.Scrollbar.ThumbColor;
        end
        function set.ThumbColor(obj, c)
            set(obj.Scrollbar, 'ThumbColor', c)
        end
    end
    
    methods (Access = private)
        function scroll(obj, e)
            if e.getWheelRotation < 0
                obj.Thumb = obj.Thumb - obj.ThumbScroll;
            else
                obj.Thumb = obj.Thumb + obj.ThumbScroll;
            end
            obj.resize()
        end
        function resize(obj)
            h = obj.Heights;
            s = obj.ActiveSize;
            
            if isempty(h)
                return
            elseif all(h >= 0)
                h = sum(h);
                h = h + obj.Spacing * (length(h) - 1);
                h = h + obj.Padding * 2;
                h = h + 6;
                
                if s(2) > h || obj.Thumb <= 0
                    % Let VBox handle resizing if the object is larger than
                    % the panel
                    obj.Thumb = 0;
                    set(obj, ...
                        'Units', 'normalized', ...
                        'Position', [0 0 1 1])
                else
                    if s(2) > (h - obj.Thumb)
                        obj.Thumb = h - s(2);
                    end
                    b = obj.Thumb + s(2) - h + 1;
                    set(obj, ...
                        'Units', 'pixels', ...
                        'Position', [1 b s(1) h])
                end
                set(obj.Scrollbar, ...
                    'ThumbPosition', [0 s(2)] + obj.Thumb, ...
                    'Limits', [0 h])
            else
                set(obj, ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1])
                set(obj.Scrollbar, ...
                    'ThumbPosition', [0 1], ...
                    'Limits', [0 1])
            end
        end
        function childAdded(obj)
            addlistener(obj.Contents(end), 'SizeChanged', @(~, ~) obj.resize());
        end
        function updateProperties(obj)            
            set(obj.Parent.Parent, 'BackgroundColor', obj.BackgroundColor);
        end
    end

    methods
        function obj = VBoxScroll(varargin)
            i = find(ismember(varargin(1:2:end), 'Parent'), 1);
            if isempty(i)
                % Do this anyway and let uix generate the error
            else
                % Hijack parent
                p = uix.Panel(...
                    'Parent', varargin{i * 2}, ...
                    'BorderType', 'none');
                h = uix.HBox( ...
                    'Parent', p, ...
                    'Spacing', 3);
                b = uipanel(h, ...
                    'BorderType', 'none', ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
                
                varargin{i * 2} = b;
            end
            
            obj@uix.VBox(varargin{:});
            obj.Panel = b;
            obj.Scrollbar = uixm.Scrollbar(h);
            
            set(obj.Scrollbar, ...
                'Direction', 'Vertical')
            set(p, ... 
                'BackgroundColor', obj.BackgroundColor)
            set(h, ... 
                'Widths', [-1 5], ...
                'Padding', 3, ...
                'Spacing', 3, ...
                'BackgroundColor', obj.BackgroundColor)
            set(obj, ...
                'Padding', 3)
            
            jh = handle(findjobj(p), 'CallbackProperties');
            
            set(jh, 'ComponentResizedCallback', @(~, ~) obj.resize())
            set(jh, 'MouseWheelMovedCallback', @(~, e) obj.scroll(e))
            
            addlistener(obj, 'ChildAdded', @(~, ~) obj.childAdded());
            addlistener(obj, 'BackgroundColor', 'PostSet', @(~, ~) obj.updateProperties());
            
            obj.resize()
        end
        
        function delete(obj)
            delete(obj.Parent.Parent.Parent)
        end
    end
end