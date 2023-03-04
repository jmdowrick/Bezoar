classdef uisignalmain < TComponent
    properties (Constant)
        Type = 'uipanel'
    end
    
    methods (Access = protected)
        function keyPress(obj)
            switch obj.Data.uiview.viewname
                case 'sign'
                    % Only capture keys when visible
                    switch obj.LastKey
                        case 'q'
                            if strcmp('query', obj.Data.uisign_settings.mode)
                                obj.Data.uisign_settings.setModeDefault()
                            else
                                obj.Data.uisign_settings.setModeQuery()
                            end
                        case 'e'
                            if strcmp('edit', obj.Data.uisign_settings.mode)
                                obj.Data.uisign_settings.setModeDefault()
                            else
                                obj.Data.uisign_settings.setModeEdit()
                            end
                        case 'delete'
                            obj.Data.uiprvw.deleteWave()
                        case 'escape'
                            if ~obj.Data.uiprvw.i && ~any(obj.Data.uiprvw.at, "all")
                                obj.Data.uisign_settings.setModeDefault()
                            end
                    end
                otherwise
                    % Do nothing
            end
        end
    end     % PROTECTED
    methods (Access = protected)
        function initialise(~)
            uisignalmain_axes();
            uiscale();
            uiselect();
        end
    end     % INITIALISE
end