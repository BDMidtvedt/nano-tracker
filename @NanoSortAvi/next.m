function next(obj, video)
    obj.State.Image = video.read(1);

    obj.State.Frame = obj.State.Frame + 1;
    obj.State.currentTime = video.video.CurrentTime;
end