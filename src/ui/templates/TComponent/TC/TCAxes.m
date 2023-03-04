classdef TCAxes < TComponentHeader
    properties (SetAccess = immutable, GetAccess = protected)
        Axes            (1,1)   matlab.graphics.Graphics = gobjects(1)
        hasAxes         (1,1)   logical = false
    end
    properties (Access = protected, Dependent)
        CurrentPosition
    end

    methods % DEPENDENT
        function p = get.CurrentPosition(obj)
            if obj.hasAxes
                p = obj.Axes.CurrentPoint(1, 1:2);
            else
                p = [NaN NaN];
            end
        end
    end     % DEPENDENT
    methods % CONSTRUCTOR
        function obj = TCAxes()
            ax = ancestor(obj.Handle, 'axes');
            if ~isempty(ax)
                obj.Axes = ax;
                obj.hasAxes = true;
            end
        end
    end     % CONSTRUCTOR
end