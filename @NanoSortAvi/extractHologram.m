
function [Field, b] = extractHologram(obj)
    I = obj.State.Image;
    N_original = size(I);
    I=I/mean(I(:))-1;
    FieldN = complex(padarray(I.*exp(-2*pi*1i*(obj.Indexes.X*obj.Indexes.kx0+obj.Indexes.Y*obj.Indexes.ky0)),obj.Indexes.NQ,'symmetric'));
    FieldN = complex(fftshift(fft2(FieldN)).*obj.Indexes.ww');
    FieldN = fftshift(FieldN);
    FieldN = ifft2(FieldN);
    FieldN = complex(FieldN);
    %imagesc(abs(FieldN))

    phi0=angle(FieldN(obj.Indexes.NQ(1)+1:N_original(1)+obj.Indexes.NQ(1),obj.Indexes.NQ(2)+1:N_original(2)+obj.Indexes.NQ(2)));
   
    
    
    X = obj.Indexes.X;
    X2 = X.*X;
    X3 = X2.*X;
    X4 = X3.*X;
    
    Y = obj.Indexes.Y;
    Y2 = Y.*Y;
    Y3 = Y2.*Y;
    Y4 = Y3.*Y;
    
    
    b = CorrectPhaseTracker(phi0(100:end-100,100:end-100),X(100:end-100,100:end-100), obj.Indexes.G, obj.Indexes.R);
    
    phasemat=   b(1)*X2 + ...
                b(3)*Y2 + ...
                b(2)*X.*Y + ...
                b(4)*X + ...
                b(5)*Y + ...
                b(6)*X3 + ...
                b(7)*X2.*Y + ...
                b(8)*X.*Y2 +...
                b(9)*Y3 + ...
                b(10)*X4 + ...
                b(11)*X3.*Y + ...
                b(12)*X2.*Y2 + ...
                b(13)*X.*Y3 + ...
                b(14)*Y4;

    Field=complex(exp(1i*(phi0-phi0(1,1))-1*1i*(phasemat)));
    Field=Field./mean(mean(Field(100:end-100,100:end-100))); 
    amp=abs(FieldN);
    amp=amp/mean(amp(:));
    Field=amp.*padarray(Field,obj.Indexes.NQ,'symmetric'); %Field is amplitude of field (amp) times phasefactor (contained in Field)! Otherwise propagation does not work!
end



