function recordMisses(obj)
    [~, z0i] = min(abs(obj.Options.zSpan));
    Image = imag(obj.State.S{z0i}(101:end-100, 101:end-100));
    fig = figure('visible', 'off', 'Renderer', 'painters', 'Position', [10 10 size(Image,2)+300 size(Image,1)]);
    imagesc(Image, [-0.2 0.5]);
    hold on
    colormap gray;
    if ~isempty(obj.State.Positions)
        
        scatter((obj.State.Positions{:,1})/obj.Options.dx  - 100, (obj.State.Positions{:,2})/obj.Options.dx -100, 60, 'bx', 'linewidth', 1.5)
    end

    for trs = obj.State.ActiveTraces
        tr = trs{1};
        if (tr.Positions(end,1) == obj.State.Frame)
            c = 'b';
            if length(tr.Positions(:,1)) > 10
                c = 'g';
            end
            plot(tr.Positions(:,2)/obj.Options.dx - 100, tr.Positions(:,3)/obj.Options.dx - 100, c, 'linewidth', 1.6)
        end
    end
    
    fn = fieldnames(orderfields(obj.Logs.Tracking.Misses));
    obj.registerFields(fn);
    LH = [];
    L = {};
    for f = 1:length(fn) 
        fieldname = fn{f};
        misses = obj.Logs.Tracking.Misses.(fieldname);
        color = obj.Logs.Tracking.fieldtomarker.(fieldname).Color;
        marker = obj.Logs.Tracking.fieldtomarker.(fieldname).Marker;
        LH(f) = scatter(misses.Y - 100, misses.X - 100, 60, color, marker, 'linewidth', 1.5);
        L{f} = fieldname;
        obj.Logs.Tracking.Misses.(fieldname).X = [];
        obj.Logs.Tracking.Misses.(fieldname).Y = [];
    end
    set(gca,'Position', [0 0 1-300/size(Image,2) 1])
    leg = legend(LH, L, 'fontsize', 24);
    set(leg, 'Position', [1-300/size(Image,2)+0.01 leg.Position(2) 300/size(Image,2) leg.Position(4)])
    hold off
    xticks([])
    yticks([])
    
    frame = getframe(gcf);
    writeVideo(obj.Logs.RecordAvi, frame);
    close(fig);


end