classdef uimoviemain_image < TComponent
    properties (Constant)
        Type = "image"
    end
    
    methods
        function updateuiflmv(obj)
            set(obj.Handle, ...
                'CData', obj.Data.uiflmv.data_scaled, ...
                'CDataMapping', 'scaled')
        end
    end
end