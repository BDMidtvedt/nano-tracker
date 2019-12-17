function print(obj)
    if obj.Options.RecordMisses
        obj.recordMisses();
    elseif obj.Options.Record
        obj.record();
    end
    clc
    v = obj.getVideo().video;
    try 
        fprintf('Analyzed %i/%i of %s, ', v.CurrentTime*v.FrameRate, v.Duration*v.FrameRate, obj.getName());
        fprintf('%s s per frame\n', datestr(now() - obj.Logs.StartTime, 'SS.FFF'))
        fprintf('Noise level: %f using %i frames\n', obj.Logs.Noise, obj.Logs.BackgroundDepth)
        fprintf('Number of active traces: %i, and %i completed\n', length(obj.State.ActiveTraces), (obj.Logs.CompletedTraces))
        fprintf('Missed because:\n')
    
        fn = fieldnames(obj.Logs.Tracking.Misses);
    catch ME
        fn = {};
    end
    for i = 1:length(fn)
        field = fn{i};
        fprintf('%s: %i\n', field, obj.Logs.Tracking.Misses.(field).count)
    end
    obj.Logs.StartTime = now();
end