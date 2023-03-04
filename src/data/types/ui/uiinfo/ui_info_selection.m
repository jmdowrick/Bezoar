classdef ui_info_selection < TData
    properties (Constant)
        Name = "uiinfo_selection"
    end
    properties (SetObservable, SetAccess = private)
        mode                (1,:)   char ...
            {mustBeMember(mode,{'normal','offset'})} = 'normal'

        selection           (:,:,1) logical = []
        staggered           (:,:,1) logical = []
    end

    methods
        function setSelection(obj, s)
            if isequal(size(s), obj.Data.cnfg.size)
                obj.selection = s;
                obj.staggered = conv2(s, ones(2, 2), 'valid') >= 3;
            else
                obj.selection = false(obj.Data.cnfg.size);
                obj.staggered = false(obj.Data.cnfg.size - 1);
            end

            obj.update()
        end
        function setStaggered(obj, s)
            if isequal(size(s), obj.Data.cnfg.size - 1)
                obj.selection = conv2(s, ones(2, 2), 'full') >= 1;
                obj.staggered = s;
            else
                obj.selection = false(obj.Data.cnfg.size);
                obj.staggered = false(obj.Data.cnfg.size - 1);
            end
            
            obj.update()
        end
        function toggleMode(obj)
            switch obj.mode
                case 'normal'
                    obj.mode = 'offset';
                case 'offset'
                    obj.mode = 'normal';
            end
        end
    end

    methods
        function updateal_cont(obj)
            obj.selection = false(obj.Data.al_cont.size);
        end
        function updatefilt(obj)
            obj.markForUpdate()
        end
        function updateuiprvw(obj)
            obj.markForUpdate()
        end
    end
end