classdef ui_view < TData
    properties (Constant)
        Name = "uiview"
    end

    properties (SetObservable, SetAccess = private)
        view                (1,1)   double  = 1

        navigator           (1,1)   logical = true
        property            (1,1)   logical = true
    end
    
    methods
        function setView(obj, i)
            obj.view = i;

            obj.update()
        end
        function toggleVisibilityProperty(obj)
            obj.property = ~obj.property;

            obj.update()
        end
        function toggleVisibilityNavigator(obj)
            obj.navigator = ~obj.navigator;

            obj.update()
        end
    end

    properties (Dependent)
        viewname
    end
    methods
        function v = get.viewname(obj)
            switch obj.view
                case 1
                    v = 'sign';
                case 2
                    v = 'flmv';
                case 3
                    v = 'info';
                case 4
                    v = 'maps';
            end
        end
    end
end