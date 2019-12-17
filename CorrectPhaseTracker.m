function [b] = CorrectPhaseTracker(An0,X,G,R)
An0=An0-An0(1,1);

dx=-pi+mod(pi+(diff(An0)),2*pi);
dy=-pi+mod(pi+(diff(An0')),2*pi)';

DX1=(dx(:,2:end)+dx(:,1:end-1))/2;
DY1=(dy(2:end,:)+dy(1:end-1,:))/2;

dx1=DX1(:);
dy1=DY1(:);



dt=zeros(2*(size(X,1)-1)*(size(X,2)-1),1,'gpuArray');
dt(1:2:end)=dx1;
dt(2:2:end)=dy1;

%b=G\dt;

b=R*(G*dt);

%Field=complex((exp(1i*(An0+pi/2)).*exp(-1i*(b(1)/2*X.^2+b(3)/2*Y.^2+b(2)*X.*Y+b(4)*X+b(5)*Y))));



%Field=Field./Field(1,1);
%ANT=angle((exp(1i*(An0+pi/2-An0(1,1))).*exp(-1i*(b(1)/2*X.^2+b(3)/2*Y.^2+b(2)*X.*Y+b(4)*X+b(5)*Y))));
