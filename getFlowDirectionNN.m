function [meanV]=getFlowDirectionNN(T)
x=[];
y=x;


    x=T.Positions(:,2)-mean(T.Positions(:,2));
    y=T.Positions(:,3)-mean(T.Positions(:,3));
    t=T.Positions(:,end);
if size(T.Positions,1)<2
    meanV=[0 0];
else
    meanV=[mean(diff(x)./diff(t)) mean(diff(y)./diff(t))];
end

