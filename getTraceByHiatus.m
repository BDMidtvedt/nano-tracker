function [P, I] = getTraceByHiatus(T, frame, hiatus)

    P = {};
    I = [];
    for i = 1:length(T)
        if frame - T{i}.Positions(end,1) == hiatus
            P{end+1} = T{i};
            I(end+1) = i;
        end
    end
end