function registerMiss(obj, obs, name)
    
    if ~isfield(obj.Logs.Tracking.Misses, name)
        obj.Logs.Tracking.Misses.(name) = {};
        obj.Logs.Tracking.Misses.(name).X = [];
        obj.Logs.Tracking.Misses.(name).Y = [];
        obj.Logs.Tracking.Misses.(name).count = 0;
    end
    obj.Logs.Tracking.Misses.(name).count = obj.Logs.Tracking.Misses.(name).count + 1;
    if ~obj.Options.RecordMisses
        return
    end
    obj.Logs.Tracking.Misses.(name).X(end+1) = obs(1);
    obj.Logs.Tracking.Misses.(name).Y(end+1) = obs(2);
end