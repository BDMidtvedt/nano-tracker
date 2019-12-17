function track(obj)
    setzero = gpuArray(obj.Indexes.C ~= 0);
    xtr = gpuArray(obj.Indexes.NQ(1)+1:obj.Indexes.size(1)+obj.Indexes.NQ(1)); % TODO Precalculate these in initializeParameters
    ytr = gpuArray(obj.Indexes.NQ(2)+1:obj.Indexes.size(2)+obj.Indexes.NQ(2));

    dSC = cell(obj.Indexes.size(3));

    SIA = abs(obj.State.SI);
    dS=abs(SIA-mean(SIA(:)));
    [C1 , zindmap]=(max(dS,[],3));
    zindmap = gather(zindmap);
    h=fspecial('gaussian',15,5);

    dS2=imfilter(C1,h);
    dS2=C1-dS2;

    dS2=gather(imfilter(dS2,h));
    dS3=(imdilate(dS2,strel('disk',20)));

    th = 0;

    dS2(dS2<th)=th;

    Indices=gather(find(and((dS3==dS2),dS2>0.01)));
    [~, Inds]=sort(C1(Indices),'descend');
    Inds = gather(Inds);
    PartROI=cell(size(Inds));

    obj.State.Positions = table();

    x = zeros(length(Inds));
    y = x;
    z = x;
    maxp = x;
    siz = x;
    qind=0;

    C1 = gather(C1);
    for k=1:length(Inds) % For each local maxima

        I=Indices(Inds(k));

        

        [rq, cq] = ind2sub(size(dS2), I);
        
        if C1(I)>obj.Options.contrastthr
            obj.registerMiss([rq cq], 'HighContrast');
            continue;
        end
        
        if or(cq+obj.Options.roiy/2>obj.Indexes.size(2)-100, rq+obj.Options.roiy/2>obj.Indexes.size(1)-100)
            obj.registerMiss([rq cq], 'OutsideFOV');
            continue;
        end

        if or(cq-obj.Options.roiy/2<100,rq-obj.Options.roiy/2<100)
            obj.registerMiss([rq cq], 'OutsideFOV');
            continue;
        end

        idx = (cq-obj.Options.roiy/2+1):(cq+obj.Options.roiy/2);
        idy = (rq-obj.Options.roix/2+1):(rq+obj.Options.roix/2);

        zscan = zindmap(rq, cq);

        if or(zscan == 1, zscan == obj.Indexes.size(3))
            obj.registerMiss([rq cq], 'Outside_Z_FOV');
            continue;
        end

        if isempty(dSC{zscan})
            dSC{zscan} = gather(dS(:,:,zscan));
        end
        sl = gather(squeeze(obj.State.SI(rq,cq,:)));
        [~,I10]=max(real(sl));
        [~,I11]=min(real(sl));


        sf=real(sl);
        imsf=imag(sl);

        sf=sf-imsf;
        [~, I12]=sort(abs(sf),'descend');



        slm=(dSC{zscan}(idy, idx));
        [isp, xscan, yscan] = obj.isParticle(slm, [rq cq]);
         if I11<I10
             %Is bubble or antiparticle
             %sf=sf-imsf;
             sf2=sum(sf(I12(1:4)))/(sum(abs(sf(I12(1:4)))));
             %sf2 = max(abs(sf(:))) - max(abs(imsf(:)));
             if sf2 > 0.8
                obj.registerMiss([rq cq], 'AntiParticle');
                continue;
             end
         else
             %Is particle or antibubble
             %sf=sf-imsf;
             sf2=sum(sf(I12(1:4)))/(sum(abs(sf(I12(1:4)))));
             if sf2 > -.4
                obj.registerMiss([rq cq], 'AntiBubble');
                continue;
             end
         end
        
         
        if ~isp
            continue
        end
        xl = idx(1) + xscan - 1;
        yl = idy(1) + yscan - 1;


        idx = round(max(idx(1)+xscan-obj.Options.roiy/2+1,1):min(idx(1)+xscan+obj.Options.roiy/2, size(dS,2)));%-200);
        idy = round(max(idy(1)+yscan-obj.Options.roix/2+1,1):min(idy(1)+yscan+obj.Options.roix/2, size(dS,1)));%-200);
        if or(length(idx)~=obj.Options.roiy,length(idy)~=obj.Options.roix)
            obj.registerMiss([rq cq], 'OutsideFOV');
            continue;
        end

         centerrows = gpuArray(idy(1) + (29:34) - 1);
         centercols = gpuArray(idx(1) + (29:34) - 1);


        xscan = xscan + idx(1) - 1;
        yscan = yscan + idy(1) - 1;
        zest=zscan(1);
        idz = (zscan-1):(zscan+1);
        roi = obj.State.SI(centerrows,centercols,idz);

        maxp(k)=gather(sum(((imag(roi(:))))));
       siz(k)=0;
        qind=qind+1;

        x(k) = gather(xl);
        y(k) = gather(yl);
        siz(k) = gather(xscan)*obj.Options.dx;
        z(k) = gather(zest);                   

    end


    y = y(x ~= 0);
    z = z(x ~= 0);
    maxp = maxp(x ~= 0);
    siz = siz(x ~= 0);
    x = x(x ~= 0);

    obj.State.Positions.X = obj.Options.dx*x(:);
    obj.State.Positions.Y = obj.Options.dx*y(:);
    obj.State.Positions.Z = z(:);
    obj.State.Positions.M = maxp(:);
    obj.State.Positions.S = siz(:);
    obj.State.Positions.T = ones(size(z(:)))*obj.State.currentTime;
end