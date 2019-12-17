function [C C2] = getCostMatrix(OP, UP, T, h, th, th2, rescale, invert)
expectedPosition=zeros(length(T),4);
L=zeros(length(T),1);
dt=UP.T(1)-OP(:,7);
for i=1:length(T)
    meanVel=getFlowDirection(T{i});
    expectedPosition(i,1:3)=OP(i,2:4)+dt(i)*meanVel;  
    expectedPosition(i,4)=mean(T{i}.Positions(:,5));
    L(i)=length(T{i}.Positions(:,1));
end
L=L*ones(1,length(UP.X(:)));
L(L>5)=5;
C=pdist2(expectedPosition(:,1:2),[UP.X(:) UP.Y(:)], 'squaredeuclidean');
C2=abs(expectedPosition(:,4)./UP.M(:)'-1);%,'squaredeuclidean');

C3=C.*sqrt(L)/sqrt(5);
if rescale
    C=C3;
end
C(C>4) = inf;
C2(C2>th2)=inf;
if invert
    C(C<=th) = 0;
else
    C2(C2<=th2)=0;
end