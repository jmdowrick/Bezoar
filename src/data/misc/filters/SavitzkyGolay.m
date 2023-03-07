classdef SavitzkyGolay < TFilter
    properties (Constant)
        name                = 'Savitzky-Golay'
        type                = 'single'
        
        parameterNames      = ["Window", "Order"]
        parameterUnits      = ["s", ""]
        parameterDefaults   = [1.7, 9]
    end
    properties (Access = private)
        window              double
        samples             double
        order               double
    end
    
    methods
        function data = filter(obj, data)
            data = sgolayfilt(data, obj.order, obj.samples);
        end
        function p = validateProperties(obj, p)
            % Find current frequency
            f_current = p.frequency;
            s_current = p.samples;
            
            % Calculates numbers of samples in window
            s_window = round(obj.parameterValues(1) * f_current);
            s_window = min(s_window, s_current);
            s_window = 2 * ceil(s_window / 2) - 1;
            
            o = round(obj.parameterValues(2));
            o = max(o, 1);
            o = min(o, s_window);
            
            % Corrects frequency if necessary 
            t_window = s_window/f_current;
            
            % Set filter properties
            obj.parameterValues(1) = t_window;
            obj.parameterValues(2) = o;
            
            obj.window = t_window;
            obj.samples = s_window;
            obj.order = o;
            
            obj.description = [ ...
                '<html>' ...
                '<b>Savitzky-Golay Filter</b><br/>' ...
                '&emsp ' ...
                num2str(round(obj.window, 1)) ' s moving window<br/>' ...
                '&emsp ' ...
                num2str(obj.samples) ' samples per window<br/>' ...
                '&emsp ' ...
                'Order <i>k</i> = ' num2str(obj.order) ...
                '</html>'];
        end
    end
end