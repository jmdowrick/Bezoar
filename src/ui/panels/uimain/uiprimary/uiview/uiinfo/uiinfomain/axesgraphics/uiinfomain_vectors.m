classdef uiinfomain_vectors < TComponent
    properties (Constant)
        Type = 'patch'
    end
    properties (Constant)
        tri_x = -sin(tri(pi/6))
        tri_y = -cos(tri(pi/6))
        scale = 0.3
    end
    properties (Access = private)
        queue = false
    end

    methods
        function updateuiinfo_velocities(obj)
            if ~strcmp(obj.Data.uiview.viewname, 'info')
                return
            end

            b = obj.Data.uiinfo_velocities.directions;

            n = numel(b);
            [xi, yi] = meshgrid(1:size(b, 2), 1:size(b, 1));
            
            xt = repmat(obj.tri_x, 1, n) * obj.scale;
            yt = repmat(obj.tri_y, 1, n) * obj.scale;

            xv = xt.*(cos(b(:)')) - yt.*(sin(b(:)'));
            yv = xt.*(sin(b(:)')) + yt.*(cos(b(:)'));

            xv = xv + xi(:)' + 0.5;
            yv = yv + yi(:)' + 0.5;

            s = obj.Data.uiinfo_selection.staggered(:);
            set(obj.Handle, ...
                'XData', xv, ...
                'YData', yv, ...
                'FaceVertexAlphaData', (s * 0.8) + (~s * 0.2))
        end
        function updateuiinfo_selection(obj)
            if ~strcmp(obj.Data.uiview.viewname, 'info')
                return
            end

            s = obj.Data.uiinfo_selection.staggered(:);
            set(obj.Handle, ...
                'FaceVertexAlphaData', (s * 0.8) + (~s * 0.2));
        end
        function updateuiview(obj)
            if ~strcmp(obj.Data.uiview.viewname, 'info')
                obj.updateuiinfo()
                obj.updateuiinfo_slct()
                return
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uiinfomain_vectors()
            set(obj.Handle, ...
                ... Color
                'FaceColor', [064 064 064]/256, ...
                'EdgeColor', 'none', ...
                ... Transparency
                'FaceAlpha', 'flat', ...
                'AlphaDataMapping', 'scaled', ...
                ... Line Style
                'LineJoin', 'miter', ...
                ... Callback Execution Control
                'PickableParts', 'none')
        end
    end     % CONSTRUCTOR
end

function angles = tri(theta)
angles = [ ...
    0
    pi - theta/2
    pi
    pi + theta/2
    0];
end