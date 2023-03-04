classdef uieventviewermain < TComponent
    properties (Constant)
        Type        = 'Panel'
    end
    methods (Access = protected)
        function keyPress(obj)
            switch obj.Data.uiview.viewname
                case {'sign', 'flmv', 'info', 'maps'}

                    i = obj.Data.uiprvw.i;
                    n = obj.Data.wave.n;

                    switch obj.LastKey
                        case 'pageup'
                            obj.Data.uiprvw.setWave(max(1, i - 1))
                        case 'pagedown'
                            obj.Data.uiprvw.setWave(min(n, i + 1))
                        case 'home'
                            obj.Data.uiprvw.setWave(1)
                        case 'end'
                            obj.Data.uiprvw.setWave(n)
                        case 'escape'
                            obj.Data.uiprvw.setWave(0)
                    end
                otherwise
            end
        end

        function initialise(~)
            uieventviewermain_axes();
        end
    end
end