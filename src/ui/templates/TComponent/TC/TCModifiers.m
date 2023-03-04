classdef TCModifiers < TComponentHeader
    properties (Hidden, Dependent)
        isShift
        isCtrl
        isAlt
    end

    methods
        function tf = get.isShift(obj)
            modifiers = get(obj.Window, 'CurrentModifier');
            tf = ismember('shift', modifiers);
        end
        function tf = get.isCtrl(obj)
            modifiers = get(obj.Window, 'CurrentModifier');
            tf = ismember('control', modifiers);
        end
        function tf = get.isAlt(obj)
            modifiers = get(obj.Window, 'CurrentModifier');
            tf = ismember('alt', modifiers);
        end
    end
end