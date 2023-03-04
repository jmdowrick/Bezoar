classdef uisignalmain_query < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties (SetAccess = immutable)
        rc; ln_select; ln_cursor; tx
    end
    properties (Access = private)
        clicked         (1,2)   double = [NaN NaN]
        
        window          (1,2)   double = [NaN NaN]
        channel         (1,1)   double = NaN
    end
    
    methods (Access = protected)
        function mouseClick(obj)
            obj.clicked = get(0, 'PointerLocation');

            p = obj.CurrentPosition;

            it = round(obj.Data.filt.frequency * p(1)) + 1;
            it = max(min(it, obj.Data.filt.samples), 1);

            ic = round(obj.Data.uisign.n - p(2)) + 1;
            ic = max(min(ic, obj.Data.uisign.n), 0);

            obj.window = [it NaN];
            obj.channel = ic;

            obj.updateSelection()
        end
        function mouseDrag(obj)
            p = get(0, 'PointerLocation');

            d = obj.clicked - p;
            d = abs(d(1));

            if (d < 20)
            else
                p = obj.CurrentPosition;

                it = round(obj.Data.filt.frequency * p(1)) + 1;
                it = max(min(it, obj.Data.filt.samples), 1);

                obj.clicked = [NaN NaN];
                obj.window(2) = it;
            end

            obj.updateSelection()
        end

        function traverseFcn(obj)
            switch sum(isfinite(obj.window))
                case {0, 1}
                    p = obj.CurrentPosition;

                    it = round(obj.Data.filt.frequency * p(1)) + 1;
                    it = max(min(it, obj.Data.filt.samples), 1);

                    ic = round(obj.Data.uisign.n - p(2)) + 1;
                    ic = max(min(ic, obj.Data.uisign.n), 0);

                    obj.window = [it NaN];
                    obj.channel = ic;

                    obj.updateSelection()
                case 2
            end
        end
        function exitFcn(obj)
            switch sum(isfinite(obj.window))
                case {0, 1}
                    obj.channel = NaN;

                    obj.updateSelection()
                case 2
            end
        end
    end
    methods (Access = private)
        function updateSelection(obj)
            if isfinite(obj.channel)
                switch sum(isfinite(obj.window))
                    case 0
                        set(obj.ln_cursor, ...
                            'Visible', 'off')
                        set(obj.tx, ...
                            'Visible', 'off')
                        set(obj.rc, ...
                            'Visible', 'off')
                    case 1
                        ix = obj.window(isfinite(obj.window));
                        iy = obj.channel;

                        x = obj.Data.uisign_signals.time(ix);
                        y = obj.Data.uisign.n - iy + 1;

                        s = obj.Data.uisign_signals.signals(ix, iy);
                        v = obj.Data.filt.filtered(ix, obj.Data.uisign.indices(iy));

                        e = obj.Data.evnt.tg(obj.Data.uisign.indices(iy), :);
                        e = e(isfinite(e));

                        str = [ ...
                            " T " + num2str(x, '%.2f') + " s " ...
                            " S " + num2str(ix) + " sample " ...
                            " A " + num2str(v, '%.1f') + " μV "];

                        set(obj.ln_select, ...
                            'XData', obj.Data.uisign_signals.time, ...
                            'YData', obj.Data.uisign_signals.signals(:, iy), ...
                            'MarkerIndices', e, ...
                            'Visible', 'on')
                        set(obj.ln_cursor, ...
                            'XData', [x x], ...
                            'YData', [min(y - 0.5, s) max(y + 0.5, s)], ...
                            'Visible', 'on')
                        set(obj.tx, ...
                            'Position', [x y], ...
                            'String', str, ...
                            'Visible', 'on')
                        set(obj.rc(1), ...
                            'Position', [0 y - 0.5 86400 1], ...
                            'Visible', 'on')
                        set(obj.rc(2), ...
                            'Visible', 'off')
                    case 2
                        ix = sort(obj.window);
                        iy = obj.channel;

                        c = obj.Data.uisign.indices(iy);
                        s = obj.Data.uisign_signals.signals(:, iy);

                        s(1:ix(1) - 1) = NaN;
                        s(ix(2) + 1:end) = NaN;

                        x = obj.Data.uisign_signals.time(ix);
                        y = obj.Data.uisign.n - iy + 1;
                        
                        v = obj.Data.filt.filtered(ix(1):ix(2), c);
                        e = obj.Data.evnt.tg(c, :);
                        e = e(e > ix(1) & e < ix(2));

                        str1 = [ ...
                            " T " + num2str(range(x), '%.2f') + " s "
                            " S " + num2str(range(ix)) + " samples  "
                            " A " + num2str(range(v), '%.1f') + " μV "
                            " E " + num2str(numel(e)) + " events"];
                        str2 = [ ...
                            "(" + num2str(min(x), '%.2f') + " to " + num2str(max(x), '%.2f') + ")"
                            "(" + num2str(min(ix)) + " to " + num2str(max(ix)) + ")"
                            "(" + num2str(min(v), '%.1f') + " to " + num2str(max(v), '%.1f') + ")"
                            strjoin(string(round(obj.Data.uisign_signals.time(e), 1)), ", ")];
                        str = append(pad(str1), str2);

                        set(obj.ln_select, ...
                            'XData', obj.Data.uisign_signals.time, ...
                            'YData', s, ...
                            'MarkerIndices', e, ...
                            'Visible', 'on')
                        set(obj.ln_cursor, ...
                            'XData', [x(1) x(1) NaN x(2) x(2) NaN], ...
                            'YData', [-0.5 0.5 NaN -0.5 0.5 NaN] + y, ...
                            'Visible', 'on')
                        set(obj.tx, ...
                            'Position', [x(2) y], ...
                            'String', str, ...
                            'Visible', 'on')
                        set(obj.rc(1), ...
                            'Position', [0, y - 0.5, x(1), 1], ...
                            'Visible', 'on')
                        set(obj.rc(2), ...
                            'Position', [x(2), y - 0.5, 86400 1], ...
                            'Visible', 'on')
                end
            else
                set(obj.ln_select, ...
                    'Visible', 'off')
                set(obj.ln_cursor, ...
                    'Visible', 'off')
                set(obj.tx, ...
                    'Visible', 'off')
                set(obj.rc, ...
                    'Visible', 'off')
            end
        end
    end
    methods (Access = ?Bezoar)
        function updateuisign_settings(obj)
            obj.channel = NaN;
            obj.clicked = [NaN NaN];
            obj.window = [NaN NaN];

            switch obj.Data.uisign_settings.mode
                case 'query'
                    set(obj.Handle, ...
                        'Visible', 'on', ...
                        'HitTest', 'on', ...
                        'PickableParts', 'all')

                    if isequal(obj.Handle, hittest) || isequal(obj.Parent.Handle, hittest)                        
                        obj.traverseFcn()
                    end
                otherwise
                    set(obj.Handle, ...
                        'Visible', 'off', ...
                        'HitTest', 'off', ...
                        'PickableParts', 'none')
            end

            obj.updateSelection()
        end
        function updateuisign(obj)
            obj.channel = NaN;
            obj.clicked = [NaN NaN];
            obj.window = [NaN NaN];

            obj.updateSelection()
        end
    end
    methods
        function obj = uisignalmain_query()
            set(obj.Handle, ...
                'HitTest', 'off', ...
                'Visible', 'off', ...
                'PickableParts', 'none')
            rectangle(obj.Handle, ...
                ... Position
                'Position', [0 0 86400 300], ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'all', ...
                'HitTest', 'off');

            obj.rc = [ ...
                rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [000 000 256 016]/256, ...
                'EdgeColor', 'none', ...
                ... Position
                'Position', [0 0.5 86400 1], ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'none'), ...
                ...
                rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [000 000 256 016]/256, ...
                'EdgeColor', 'none', ...
                ... Position
                'Position', [0 0.5 86400 1], ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'none') ...
                ];
            obj.ln_select = line(obj.Handle, ...
                ... Line
                'Color', [000 000 256]/256, ...
                ... Marker
                'Marker', 'o', ...
                'MarkerSize', 4, ...
                'MarkerFaceColor', [256 000 000]/256, ...
                'MarkerEdgeColor', [000 000 256]/256, ...
                'MarkerIndices', [], ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.tx = text(obj.Handle, ...
                0, 0, '', ...
                ... Text
                'Color', [0.5 0.5 0.5], ...
                ... Font
                'FontName', 'fixedwidth', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                ... Position
                'HorizontalAlignment','left', ...
                'VerticalAlignment', 'middle', ...
                ... Text Box
                'BackgroundColor', [1 1 1 0.9], ...
                'Margin', 1, ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.ln_cursor = line(obj.Handle, ...
                ... Line
                'Color', [128 128 128]/256, ...
                'AlignVertexCenters', 'on', ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                'PickableParts', 'none');
        end
    end
end