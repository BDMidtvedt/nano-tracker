function C = getCostMatrixNN(OP, UP, T, h, th, th2, rescale, invert)
expectedPosition=zeros(length(T),2);
L=zeros(length(T),1);
dt=UP.T(1)-OP(:,end);
for i=1:length(T)
    meanVel=getFlowDirectionNN(T{i});
    expectedPosition(i,1:2)=OP(i,2:3)+dt(i)*meanVel;  
end
C=pdist2(expectedPosition(:,1:2),[UP.X(:) UP.Y(:)], 'squaredeuclidean');


C(C>10) = inf;

end