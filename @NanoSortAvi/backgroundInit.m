function Sc = backgroundInit(obj)
    Sc = cell(2*obj.Options.frameRange+1,1);
    for i=1:2*obj.Options.frameRange+1
        obj.next(obj.getVideo());
        Sraw = obj.extractHologram();
        Sc{obj.State.Frame} = obj.reduce(fft2(Sraw));
    end
end

