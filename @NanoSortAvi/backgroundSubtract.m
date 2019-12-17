function F = backgroundSubtract(obj)
    Sc = obj.State.Background;
    
    FFT = Sc{obj.Options.frameRange+1};
    corr2=zeros(2*obj.Options.frameRange+1,1) + inf;
    for i=[1:(obj.Options.frameRange+1-obj.Options.cutoff) (obj.Options.frameRange+1+obj.Options.cutoff):(obj.Options.frameRange*2 +1)]
        fftbg = abs(Sc{i} - FFT);
        corr2(i)= gather(sum(fftbg));
    end
    
    [~,I2]=sort(corr2,'ascend');
    
    
    
    
    
    count = length(I2);
%     bgfft2 = (Sc{obj.Options.frameRange+3} + Sc{obj.Options.frameRange-1} + Sc{obj.Options.frameRange+4} + Sc{obj.Options.frameRange-2})/4;
    bgfft2 = (Sc{I2(1)} + Sc{I2(2)});
    F = FFT - bgfft2/2;
    err = gather(mean(abs(F)));
    cc = 2;
    for i=3:count
        bgfft2n = (bgfft2 + Sc{I2(i)});
        Fn = FFT - bgfft2n/(cc + 1);
        
        errn = gather(mean(abs(Fn)));
        
        if errn < err
            cc = cc + 1;
            err = errn;
            bgfft2 = bgfft2n;
            F = Fn;
        end
    end
    obj.Logs.Noise = err;
    obj.Logs.BackgroundDepth = cc;
end