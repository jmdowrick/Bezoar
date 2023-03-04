classdef Downsample < TFilter
    properties (Constant)
        name                = 'Downsample'
        type                = 'single'
        
        parameterNames      = "Frequency"
        parameterUnits      = "Hz"
        parameterDefaults   = 32
    end
    properties (Access = private)
        nth                 double
    end
    
    methods (Access = private)
        function tf = validateFrequency(hz)
            tf = isscalar(hz) && isfinite(hz) && (hz > 0);
        end
    end
    methods
        function data = filter(obj, data)
            data = downsample(data, obj.nth);
        end
        function p = validateProperties(obj, p)
            % Current and target frequencies
            f_current = p.frequency;
            s_current = p.samples;
            f_target = obj.parameterValues(1);
            
            % Calculate downsampling factor
            factor = round(f_current/f_target);
            factor = max(factor, 1);
            
            % Calculates the actual frequency target
            f_target = f_current/factor;
            s_target = ceil(s_current/factor);
            
            % Set properties
            p.frequency = f_target;
            p.samples = s_target;
            
            % Set filter properties
            obj.parameterValues(1) = f_target;
            
            obj.nth = factor;
            
            obj.description = [ ...
                '<html>' ...
                '<b>Downsample</b><br/>' ...
                '&emsp ' ...
                'Downsampling factor = ' num2str(factor) '<br/>' ...
                '&emsp ' ...
                num2str(f_current) ' to ' ...
                num2str(f_target) ' Hz<br/>' ...
                '&emsp ' ...
                num2str(s_current) ' to ' ...
                num2str(s_target) ' samples<br/>' ...
                '</html>'];
        end
    end
end