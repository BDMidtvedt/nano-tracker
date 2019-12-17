 function initialize(obj)
    obj.next(obj.getVideo());
    I = obj.State.Image;
    obj.Indexes.image_size = size(I);
    obj.Indexes.paddedsize = getOptimalFFTsize(size(I));
    %%INIT K0
    [kx0, ky0, kmax, X, Y]=getK0(I);
    X = gpuArray(X);
    Y = gpuArray(Y);

    obj.Indexes.kx0 = kx0;
    obj.Indexes.ky0 = ky0;
    obj.Indexes.X = X;
    obj.Indexes.Y = Y;
    obj.Indexes.kmax = kmax;

    %%INIT FREQUENTLY REUSED MATRICES
    N_original=size(I);
    NQ= (obj.Indexes.paddedsize - N_original)/2;
    N1=N_original(1)+2*NQ(1);
    N2=N_original(2)+2*NQ(2);
    x=[-N1/2+.5:N1/2-.5]/N1;
    y=[-N2/2+.5:N2/2-.5]/N2;
    [KXt, KYt]=meshgrid(x,y);
    KXt=gpuArray(KXt);
    KYt=gpuArray(KYt);

    obj.Indexes.NQ = NQ;
    obj.Indexes.KXt = KXt;
    obj.Indexes.KYt = KYt;

    circ=@(r) 1-heavisideGPU((r-1));

    w=@(kx,ky,N) circ(sqrt(kx.^2+ky.^2)/N);%  heavisideGPU(-abs(kx)+N).*heavisideGPU(-abs(ky)+N);%.*sinc(kx).*sinc(ky).*sinc(kx/N).*sinc(ky/N);
    ww=w(KXt,KYt,1*kmax);
    ww = gpuArray(ww);
    obj.Indexes.ww = ww;



    Xt = X(100:end-100,100:end-100);
    Yt = Y(100:end-100,100:end-100);
    y1=Yt(2:end,2:end);
    x1=Xt(2:end,2:end);
    y1=y1(:);
    x1=x1(:);
    G=zeros(2*(size(Xt,1)-1)*(size(Xt,2)-1),14,'gpuArray');


    G(2:2:end,5)=1;
    G(1:2:end,4)=1;
    G(1:2:end,2)=y1;
    G(1:2:end,1)=2*x1;
    G(2:2:end,2)=x1;
    G(2:2:end,3)=2*y1;

    G(1:2:end,6)=3*x1.^2;
    G(1:2:end,7)=2*x1.*y1;
    G(2:2:end,7)=x1.^2;
    G(2:2:end,8)=2*x1.*y1;
    G(1:2:end,8)=y1.^2;
    G(2:2:end,9)=3*y1.^2;

    G(1:2:end,10)=4*x1.^3;
    G(1:2:end,11)=3*x1.^2.*y1;
    G(2:2:end,11)=x1.^3;
    G(1:2:end,12)=2*x1.*y1.^2;
    G(2:2:end,12)=2*x1.^2.*y1;
    G(1:2:end,13)=y1.^3;
    G(2:2:end,13)=3*x1.*y1.^2;
    G(2:2:end,14)=4*y1.^3;

    R=(G'*G)^-1;

    obj.Indexes.G = G';
    obj.Indexes.R = R;

    x=2*pi/obj.Options.dx*[-N1/2+0.5:N1/2-.5]/N1;
    y=2*pi/obj.Options.dx*[-N2/2+.5:N2/2-.5]/N2;


    [KXk, KYk]=meshgrid(x,y);
    KXk=gpuArray(KXk);
    KYk=gpuArray(KYk);
    circ=@(r) 1-heavisideGPU((r-1));
    k=2*pi/.633;
    C = circ((KXk/k).^2+(KYk/k).^2)';
    K = real(sqrt(complex((1-((KXk/k).^2+(KYk/k).^2)))));
    obj.Indexes.C=fftshift(C);
    obj.Indexes.K=K;
    
    obj.Indexes.ReduceBool = gather(obj.Indexes.C ~= 0);

    
    nz = obj.Options.zSpan;
    maxDZ=nz(end)-nz(1);
    minDZ=nz(2)-nz(1);
    cdz=minDZ;
    k2=1;

    while cdz<maxDZ
        nvec(k2)=cdz;
        cdz=cdz*4;
        k2=k2+1;
    end
    
    nvec=sort(nvec,'descend');
    Tz=cell(size(nvec));

    for i=1:length(nz)
        Tz{i}=gpuArray(obj.reduce(fftshift(complex(exp(k*1i*(nz(i)).*(K-1))')))); %OBS: Correcting for the phase shift due to propagation of field!
    end

    TzC=0;
    dzz = (nz(2) - nz(1))/2;
    nz2=linspace(-dzz,dzz,500);
    dz=nz2(2)-nz2(1);
    for i=1:length(nz2)
        TzC=TzC+fftshift(complex(exp(k*1i*(nz2(i)).*(K-1))'))*dz;
    end
    obj.Indexes.TzC=obj.reduce(TzC.*obj.Indexes.C);
    GenN=ConstructN(nvec,obj.Options.zSpan);
    obj.Indexes.Tmat = Tz;
    obj.Indexes.nvec = nvec;
    obj.Indexes.GenN = GenN;
    obj.Indexes.size = [size(I) length(nz)];
    obj.State.SI=cell(size(nz));
    obj.State.SI=gpuArray(ones(obj.Indexes.size));
    obj.State.Background = backgroundInit(obj);
    
    xm_onerow = -(obj.Options.roix-1)/2.0+0.5:(obj.Options.roix-1)/2.0-0.5;
    xm = xm_onerow(ones(obj.Options.roiy-1, 1), :);

    ym_onecol = (-(obj.Options.roiy-1)/2.0+0.5:(obj.Options.roiy-1)/2.0-0.5)';  % Note that y increases "downward"
    ym = ym_onecol(:,ones(obj.Options.roix-1,1));

    r2 = xm.*xm + ym.*ym;
    w = 1./sqrt(1+r2);
    r2l = r2>max(r2(:))/2;
    w(r2l) = 0;
    obj.Indexes.rcweight = w;
    
    obj.ReProp = Repropagator([-3:0.1:3]*obj.Options.dx, [-3:0.1:3]*obj.Options.dx, [-2.5:0.0025:2.5], obj.Options.dx, 0.635, obj.Options.roix, false);
end