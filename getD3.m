function [D, D2, Dz2,nn,nnip, nl, fq, PH, G, nV, N,fq2] = getD3(T)

k=0;
fq=[];
fq2=[];
maxN=600;
nV=[1:600];
nl=[];
N=zeros(600,1);
clear c
fq=[];
%deltax=ones(3666,1);
%deltax(2614:end)=.8458;
D = [];
D2=0;
for i=1:length(T)
    ct=T{i};
    l=size(ct,1);
    

        k=k+1;
        if length(ct)>maxN
            x=ct(1:maxN,2);
            y=ct(1:maxN,3);
            z=ct(1:maxN,4);
            dt=diff(ct(1:maxN,end));
            nl(k)=maxN;
        else
            x=ct(:,2);
            y=ct(:,3);
            z=ct(:,4);
            dt=diff(ct(:,end));
            nl(k)=l;
        end
        
        c(1,1)=sum((x-mean(x)).^2);
        c(1,2)=sum((x-mean(x)).*(y-mean(y)));
        c(1,3)=sum((x-mean(x)).*(z-mean(z)));
        c(2,3)=sum((y-mean(y)).*(z-mean(z)));
        c(2,1)=c(1,2);
        c(3,1)=c(1,3);
        c(3,2)=c(2,3);
        c(3,3)=sum((z-mean(z)).^2);
        c(2,2)=sum((y-mean(y)).^2);
        [v, l]=eig(c(1:2,1:2));
        [~, I]=sort(diag(l),'ascend');
        projv1=v(:,I(1));

          
        vx=diff(x);%*deltax(i);
        vy=diff(y);%*deltax(i);
        vz=diff(z);

        vx=vx./sqrt(dt);
        vy=vy./sqrt(dt);
        vz=vz./sqrt(dt);
        
        Dz2=median(vz.^2)/2;
        [nn ee]=histcounts(vz(1:end-1).*vz(2:end),linspace(-2,2,100));
        vp1=vx*projv1(1)+vy*projv1(2);
        vp2=vz;
        [nnip eeip]=histcounts(vp1(1:end-1).*vp1(2:end),linspace(-2,2,100));
        vpp=[0;vp1(:)];
        vpm=[vp1(:);0];
        vpt=sum(vpp.*vpm)/(length(vp1)-1);
        D(k)=mean(vp1.^2+0*vp2.^2)/2;%+0*vpt;
        D2(k)=mean(vp2.^2/2);%mean(vp2.^2)/2;
        f=T{i}(:,5);
        PH(k)=median(f);
        g=T{i}(:,6);
        G(k)=median(g);
        
        fq=[fq;mean(z)];
        fq2=[fq2;mean(vx.^2)];
        N(length(x))=N(length(x))+1;
    %end
end

end
