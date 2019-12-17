function [meanV]=getFlowDirection(T)
x=[];
y=x;
z=x;

    x=T.Positions(:,2)-mean(T.Positions(:,2));
    y=T.Positions(:,3)-mean(T.Positions(:,3));
    z=T.Positions(:,4)-mean(T.Positions(:,4));
    t=T.Positions(:,7);
if size(T.Positions,1)<2
    meanV=[0 0 0];
else
    meanV=[mean(diff(x)./diff(t)) mean(diff(y)./diff(t)) 0];
end

