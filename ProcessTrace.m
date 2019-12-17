function [D, Dz,Dz2,ee,eeip, M] = ProcessTrace(obj,T, ~)
    ROIs = T.ROI{1};
    x=2*pi/.115*[-64/2:64/2-1]/64;
    y=2*pi/.115*[-64/2:64/2-1]/64;
    [X, Y]=meshgrid(.115*[-64/2+.5:64/2-.5],.115*[-64/2+.5:64/2-.5]);

    [KXk, KYk]=meshgrid(x,y);
    KXk=(KXk);
    KYk=(KYk);
    circ=@(r) 1-heaviside((r-1));
    k=2*pi/.635;
    kw=k;
    C = circ((KXk/k).^2+(KYk/k).^2)';
    K = real(sqrt(complex((1-((KXk/k).^2+(KYk/k).^2)))));
    nz = 1e-3*[5 25 100];
    clear Tz
    clear Tzz
    Tz=0;
    nz2=linspace(-1,1,400);
    nz3=linspace(-6,6,400);
    dz=nz3(2)-nz3(1);
    dz0=nz2(2)-nz2(1);
    N=zeros(1000,1);

    C=fftshift(C);
    K=fftshift(K);

    zv=linspace(-1,1,20);
    k=0;
    intph = zeros(size(ROIs,1),1);
    nll   = zeros(size(ROIs,1),1);
    k=0;

    
    for i=1:size(ROIs,1)

        k=k+1;
        Fi = zeros(64);
        Fi(obj.ReProp.redI) = ROIs(i,:);


        SI=ifftshift(ifft2(Fi));

        fitf='a*exp(-((x-b).^2+(y-c).^2)/(2*d^2))+e';


        z=double(angle(1+SI));
        z=z-median(z(:));
        fph=fit([X(:) Y(:)],z(:),fitf,'Start',[z(31,31) 0 0 .5 0],'Upper',[5 5 5 5 .1],'Lower',[-5 -5 -5 0.01 -.1]);
        intph(k)=2*pi*fph.a*fph.d^2;
    end
    M = mean(intph);
    [D, Dz, Dz2, ee, eeip] = getD3({T.Positions});
end