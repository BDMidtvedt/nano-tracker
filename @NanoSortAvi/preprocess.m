function preprocess(obj)
    hologram = obj.extractHologram(); 
    obj.State.Background{end+1} = obj.reduce(fft2(hologram));
    obj.State.Background(1) = [];
    if obj.Options.backgroundCorrect
        hologram = obj.backgroundSubtract();
    else
        hologram = obj.State.Background{obj.Options.frameRange+1};
    end
    
    obj.backpropagate(hologram);
end