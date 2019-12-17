function [P,I] = getPointsByHiatus(T, frame, hiatus)
%GETLASTPOINTBYHIATUS Summary of this function goes here
%   Detailed explanation goes here

% TODO memory allocation.
P = [];
I = [];
for i = 1:length(T)
    if frame - T{i}.Positions(end,1) == hiatus
        P(end+1,:) = T{i}.Positions(end,:);
        I(end+1) = i;
    end
end


