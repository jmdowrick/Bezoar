classdef HBoxScroll < uix.HBox
    properties (Access = private)
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
            w = obj.Widths;
            s = obj.ActiveSize;
            
            if isempty(w)
                return
            elseif all(w >= 0)
                w = sum(w);
                w = w + obj.Spacing * (length(w) - 1);
                w = w + obj.Padding * 2;
                w = w + 6;
                
                if s(1) > w || obj.Thumb <= 0
                    % Let HBox handle resizing if the object is larger than
                    % the panel
                    obj.Thumb = 0;
                    set(obj, ...
                        'Units', 'normalized', ...
                        'Position', [0 0 1 1])
                else
                    if s(1) > (w - obj.Thumb)
                        obj.Thumb = w - s(1);
                    end
                    b = 1 - obj.Thumb;
                    set(obj, ...
                        'Units', 'pixels', ...
                        'Position', [b 1 w s(2)])
                end
                set(obj.Scrollbar, ...
                    'ThumbPosition', [0 s(1)] + obj.Thumb, ...
                    'Limits', [0 w])
                disp(obj.Thumb)
                disp(w)
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
        function obj = HBoxScroll(varargin)
            i = find(ismember(varargin(1:2:end), 'Parent'), 1);
            if isempty(i)
                % Do this anyway and let uix generate the error
            else
                % Hijack parent
                p = uix.Panel(...
                    'Parent', varargin{i * 2}, ...
                    'BorderType', 'none');
                v = uix.VBox( ...
                    'Parent', p, ...
                    'Spacing', 3);
                b = uipanel(v, ...
                    'BorderType', 'none', ...
                    'Units', 'normalized', ...
                    'Position', [0 0 1 1]);
                
                varargin{i * 2} = b;
            end
            
            obj@uix.HBox(varargin{:});
            obj.Panel = b;
            obj.Scrollbar = uixm.Scrollbar(v);
            
            set(obj.Scrollbar, ...
                'Direction', 'Horizontal')
            set(p, ...
                'BackgroundColor', obj.BackgroundColor)
            set(v, ...
                'Heights', [-1 5], ...
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