function bool = shouldOutput(obj)
    bool = false;
    if length(obj.Results.CompletedTraces) > 20
        bool = true;
    end
end