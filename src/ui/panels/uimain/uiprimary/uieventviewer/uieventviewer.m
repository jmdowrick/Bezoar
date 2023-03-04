classdef uieventviewer < TComponent
    properties (Constant)
        Type = 'hbox'
    end

    methods % CONSTRUCTOR
        function obj = uieventviewer()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [128 128 128]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 200;
            
            uieventviewerlabels();
            uieventviewermain();
        end
    end     % PROTECTED
end