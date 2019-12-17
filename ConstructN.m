function [N zout]=ConstructN(nz,zTarget)
zrem=zTarget;
%Tz=ones(size(obj.Crefined));
for j=1:length(zTarget)
for i=1:length(nz)
    N(j,i)=floor(zrem(j)/nz(i));
    zrem(j)=zrem(j)-N(j,i)*nz(i);
    %Tz=Tz.*obj.Tzrefined{i}.^N(i);
end
Nl=round(zrem(j)/nz(end));
N(j,end)=N(j,end)+Nl;
zout(j)=sum(N(j,:).*nz);
end
%Tz=Tz.*obj.Tzrefined{end}.^Nl;
%Tz=Tz.*obj.Crefined;