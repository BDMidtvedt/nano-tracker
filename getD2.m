function [D, er] = getD2(T)

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

            dt=diff(ct(1:maxN,end));
            nl(k)=maxN;
        else
            x=ct(:,2);
            y=ct(:,3);

            dt=diff(ct(:,end));
            nl(k)=l;
        end
        
        c(1,1)=sum((x-mean(x)).^2);
        c(1,2)=sum((x-mean(x)).*(y-mean(y)));
        c(2,1)=c(1,2);

        c(2,2)=sum((y-mean(y)).^2);
        [v, l]=eig(c(1:2,1:2));
        [~, I]=sort(diag(l),'ascend');
        projv1=v(:,I(1));

          
        vx=diff(x);%*deltax(i);
        vy=diff(y);%*deltax(i);

        vx=vx./sqrt(dt);
        vy=vy./sqrt(dt);
        
        
        vp1=vx*projv1(1)+vy*projv1(2);
        
        vpp=[0;vp1(:)];
        vpm=[vp1(:);0];
        vpt=sum(vpp.*vpm)/(length(vp1)-1);
        D(k)=mean(vp1.^2)/2;%+0*vpt;
        
        
        fq=[fq;mean(vpt)];
        
        N(length(x))=N(length(x))+1;
    %end
end
er=fq;
end
