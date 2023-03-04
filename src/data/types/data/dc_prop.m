classdef dc_prop < TData 
    properties (Constant)
        Name = "prop"
    end
    properties (SetObservable, SetAccess = private)
        duration        (1,1)   double  = 0
        frequency       (1,1)   double  = NaN
        channels        (1,1)   double  = 0
        samples         (1,1)   double  = 0
    end
  
    methods (Access = ?DataContainer)
        function updatefile(obj)
            if obj.Data.file.isloaded
                h = obj.Data.file.header;
                
                obj.duration = h.fileduration;
                obj.frequency = h.filefrequency;
                obj.channels = h.numchannels;
                obj.samples = h.filesamples;
            end
        end
    end
end