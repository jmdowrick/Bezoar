classdef uiwavenumberslabels < TComponent
    properties (Constant)
        Type = 'panel'
    end

    methods (Access = protected)
        function initialise(obj)
            obj.Width = 20;
        end
    end     % PROTECTED
end