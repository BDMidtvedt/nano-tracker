function record(obj)
    
    [~, z0i] = min(abs(obj.Options.zSpan));
    Image = imag(obj.State.S{z0i}(101:end-100, 101:end-100));
    fig = figure('visible', 'on', 'Renderer', 'painters', 'Position', [10 10 size(Image,2) size(Image,1)]);
    imagesc(Image, [-0.2 0.5]);
    hold on
    colormap gray;
    if ~isempty(obj.State.Positions)
        
        scatter((obj.State.Positions{:,1})/obj.Options.dx  - 100, (obj.State.Positions{:,2})/obj.Options.dx -100, 60, 'bx')
    end

    for trs = obj.State.ActiveTraces
        tr = trs{1};
        if (tr.Positions(end,1) == obj.State.Frame)
            plot(tr.Positions(:,2)/obj.Options.dx - 100, tr.Positions(:,3)/obj.Options.dx - 100, 'b', 'linewidth', 1.6)
        end
    end
    hold off
    xticks([])
    yticks([])
    set(gca,'Position', [0 0 1 1])
    frame = getframe(gcf);
    writeVideo(obj.Logs.RecordAvi, frame);
    close(fig);
end
