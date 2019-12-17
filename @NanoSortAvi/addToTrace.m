function [obs, T] = addToTrace(obj, T, O)
    fits=zeros(5,3);
    obs = O; %Maybe?
    if ~isempty(T)
        zp = T.Positions(end,4);
        [~, iz] = min(abs(zp-obj.Options.zSpan));

    else
        iz = O(4);
    end
    
    
    x = O(2)/obj.Options.dx;
    y = O(3)/obj.Options.dx;
    F = gather(obj.State.S{iz}(round(y-31.5):round(y-31.5)+63, round(x-31.5):round(x-31.5)+63));
    F = fftshift(F);
    ROIl = fft2(F);


    if ~isempty(T)
        [Fn, r, vz] = obj.ReProp.match(ROIl, transpose(T.ROI{1}(1,:)), zp-obj.Options.zSpan(iz));
    else
        [Fn, r, vz] = obj.ReProp.match(ROIl, ROIl, 0);
    end
    O(4) = obj.Options.zSpan(iz) + r(3);
    Fn = obj.ReProp.expand(Fn);
    O(end-1)= vz;

    if ~isempty(T) && abs(obj.Options.zSpan(iz)+r(3)-zp)>=3.5
        obs = [];
        return;
    end

    %SI=fftshift(imag(ifft2(abs(ROIl).*Fn)));

    
    if ~isempty(T)
%         bg = obj.ReProp.expand(T.ROI{1}(1,:));
%         SI2=fftshift(imag(ifft2(bg)));
%         bgN=sum(sum(SI2(1:20,:).^2))*100/(20*64);
%         df= (sum(sum((SI(25:35,25:35)-SI2(25:35,25:35)).^2))-bgN)/(sum(sum(SI2(25:35,25:35).^2))-bgN);
% 
%         dq=(sum(sum((SI(25:35,25:35)-SI2(25:35,25:35)).^2))-bgN);
%         if or(abs(df)<.5,dq<.5)
            Fnred = obj.ReProp.reduce(Fn.*abs(ROIl));
        	T.ROI{1}(end+1,:) = Fnred;
            T.Positions(end+1,:) = O;
    else
        Fnred = obj.ReProp.reduce(Fn.*abs(ROIl));
        T.ROI{1}(1,:) = Fnred;
        T.Positions(1,:) = O;
    end
    
end