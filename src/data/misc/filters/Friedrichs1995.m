classdef Friedrichs1995 < TFilter
    properties (Constant)
        name                = 'Median-Gaussian'
        type                = 'single'
        
        parameterNames      = "Window"
        parameterUnits      = "s"
        parameterDefaults   = 10
    end
    properties (Access = private)
        window              double
        samples             double
    end
    
    methods
        function data = filter(obj, data)
            data = data - smoothdata(movmedian(data, obj.samples), 'gaussian', obj.samples);
        end
        function p = validateProperties(obj, p)
            % Find current frequency
            f_current = p.frequency;
            s_current = p.samples;
            
            % Calculates numbers of samples in window
            s_window = round(f_current * obj.parameterValues(1));
            s_window = min(s_window, s_current);
            
            % Corrects frequency if necessary 
            t_window = s_window/f_current;
                        
            % Set filter properties
            obj.parameterValues(1) = t_window;
            
            obj.window = t_window;
            obj.samples = s_window;
            
            obj.description = [ ...
                '<html>' ...
                '<b>Median-Gaussian</b><br/>' ...
                '<i>Friedrichs, 1995</i><br/>' ...
                'Baseline Removal<br/>' ...
                '&emsp ' num2str(round(t_window, 1)) ' s moving window<br/>' ...
                '&emsp ' num2str(s_window) ' samples per window' ...
                '</html>'];
        end
    end
end