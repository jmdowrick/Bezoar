classdef ui_sign_settings < TData
    properties (Constant)
        Name = "uisign_settings"
    end
    properties (SetAccess = private)
        mode                (1,:)   char ...
            {mustBeMember(mode, {'default', 'query', 'edit'})} = 'default'

        showOverlay         (1,1)   logical = true 
        showSelector        (1,1)   logical = true
    end
    
    methods
        function setModeDefault(obj)
            obj.mode = 'default';

            obj.update()
        end
        function setModeQuery(obj)
            obj.mode = 'query';

            obj.update()
        end
        function setModeEdit(obj)
            obj.mode = 'edit';

            obj.update()
        end

        function toggleOverlay(obj)
            obj.showOverlay = ~obj.showOverlay;
            
            obj.update()
        end
    end
end