function [boolout, x, y] = isParticle(obj, slm, obs)

    x=0;
    y=0;

    boolout = true;
    th = max(slm(:));
    if (th > 0.05) 
        th = th*0.5;
        bool = slm(:) < th;

        if sum(~bool) > obj.Options.sizethr
            boolout = false;
            obj.registerMiss(obs, 'Size');
            return
        end
        slm(bool) = th;

        [x, y, d] = radialcenter(slm, obj.Indexes.rcweight);

        if isnan(d)
            obj.registerMiss(obs, 'zero_ROI');
            boolout = false;
            return
        end
    else
        obj.registerMiss(obs, 'Weak');
        boolout = false;
        return;
    end

    if d>obj.Options.radialthr
        obj.registerMiss(obs, 'Radiality');
        boolout = false;
        return
    end

end
