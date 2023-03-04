classdef ui_sign < TData 
    properties (Constant)
        Name = "uisign"
    end
    properties (SetObservable, AbortSet, SetAccess = private)
        selection       (:,:,1) logical = []
    end
    properties (SetAccess = private)
        mode            (1,:)   char ...
            {mustBeMember(mode,{'i', 'j', 'free'})} = 'i'
        
        n               (1,1)   double  = 0

        indices         (1,:)   double  = double.empty(1,0)
        indices_grid    (1,:)   double  = double.empty(1,0)
        divisions       (1,:)   double  = double.empty(1,0)
    end

    methods
        function setSelection(obj, s)
            obj.selection = s;

            obj.update()
        end
        function cycleSelectionMode(obj)
            switch obj.mode
                case 'i';       obj.mode = 'j';
                case 'j';       obj.mode = 'free';
                case 'free';    obj.mode = 'i';
            end
            
            obj.update()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            cf = obj.Data.cnfg.configuration;
            tf = obj.selection;
            in = reshape(1:numel(cf), obj.Data.cnfg.size);

            switch obj.mode
                case 'j'
                    cf = cf';   
                    tf = tf';
                    in = in';
            end

            obj.n = sum(tf, "all");

            obj.indices = cf(tf);
            obj.indices_grid = in(tf);

            obj.divisions = sum(tf, 1);
            obj.divisions(obj.divisions == 0) = [];
        end
    end
    methods (Access = ?DataContainer)
        function updatecnfg(obj)
            obj.mode = 'i';

            obj.selection = false(obj.Data.cnfg.size);
            obj.selection(:, 1) = true;
        end
    end
end