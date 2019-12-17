function initiateLogs(obj)
    obj.Logs.Tracking = {};
    obj.Logs.Tracking.Misses = {};
    
    obj.Logs.CompletedTraces = 0;
    
    if obj.Options.Record || obj.Options.RecordMisses
        obj.Logs.RecordAvi = VideoWriter(sprintf('./res/%s_recording.avi', obj.getName()));
        obj.Logs.RecordAvi.FrameRate = obj.getVideo().video.FrameRate;
        obj.Logs.RecordAvi.Quality = 95;
        open(obj.Logs.RecordAvi);
    end
    
    obj.Logs.StartTime = now();
    obj.Logs.Diffusion = [];
    obj.Logs.Diffusionz=[];
    obj.Logs.Diffusionzmed=[];
    obj.Logs.hhz=[];%zeros(100,1);
    obj.Logs.hhip=[];%zeros(100,1);
    obj.Logs.IntegratedPhase = [];
    obj.Logs.TraceLength = [];
    obj.Logs.error = [];
    v = obj.getVideo().video;
    obj.Logs.ParticlesPerFrame = zeros(ceil(v.Duration*v.FrameRate),1);
end