classdef AVIVideoReader < handle
    properties
        temporalSubtractionCount
        frameQueue
        video
        frame
        subtraction
        crop
        dt
    end
    methods
        function obj = AVIVideoReader(video, opt) %CONSTRUCTOR METHOD
            
            obj.video = VideoReader(video);
            
            
            % SET DEFAULT PARAMETERS
            obj.temporalSubtractionCount = 1;
            obj.crop = {1:obj.video.height, 1:obj.video.width};
            obj.dt=1;
            %SET INPUT PARAMETERS
            if exist('opt', 'var')
                if isfield(opt, 'temporalSubtractionCount')
                    obj.temporalSubtractionCount = opt.temporalSubtractionCount;
                end
                if isfield(opt, 'crop')
                    obj.crop = opt.crop;
                end
                if isfield(opt, 'dt')
                    obj.dt = opt.dt;
                end
                if isfield(opt, 'startFrame')
                    obj.goto(opt.startFrame);
                    obj.frame = opt.startFrame;
                end
            end
            
            %INITIALIZE
            
            obj.frameQueue = zeros(...
                obj.temporalSubtractionCount,...
                length(obj.crop{1}),...
                length(obj.crop{2})...
            );
            obj.subtraction = zeros(...
                length(obj.crop{1}),...
                length(obj.crop{2})...
            );
            obj.frame = 1;
        end
        function I = next(obj)
            obj.video.CurrentTime=obj.video.CurrentTime+(obj.dt-1)/obj.video.FrameRate;
            In = readFrame(obj.video, 'native');
            In = double(In.cdata);
            In = In(obj.crop{1}, obj.crop{2}, 1);

            if obj.frame > obj.temporalSubtractionCount
                obj.shoveToQueue(In)
            else
                obj.appendToQueue(In, obj.frame)
            end
            
            I = double(In);% - obj.subtraction;
            
            obj.updateSubtraction();
            
            obj.frame = obj.frame + 1;
        end
        function I = read(obj, step)
            obj.video.CurrentTime=obj.video.CurrentTime+(step-1)/obj.video.FrameRate;
            I = readFrame(obj.video, 'native');
            I = double(I.cdata);
            I = I(obj.crop{1}, obj.crop{2}, 1);
        end
        
        function jump(obj, step)
            obj.video.CurrentTime= min(obj.video.CurrentTime + step/obj.video.FrameRate,obj.video.duration);
        end
        
        function goto(obj, frame)
            obj.video.CurrentTime= min(frame/obj.video.FrameRate,obj.video.duration);
        end
        
        function b = hasFrame(obj)
            b = hasFrame(obj.video);
        end
        function reset(obj)
            obj.video.CurrentTime = 0;
            obj.frame = 1;
            obj.frameQueue = zeros(size(obj.frameQueue));
            obj.subtraction = zeros(size(obj.subtraction));
        end
        
    end
    methods (Access = private)
        
        function shoveToQueue(obj, I)
            obj.frameQueue(mod(obj.frame - 1, obj.temporalSubtractionCount) + 1,:,:) = I;
        end
        
        function appendToQueue(obj, I, f)
            obj.frameQueue(f,:,:) = I;
        end
        
        function updateSubtraction(obj)
            obj.subtraction = squeeze(sum(obj.frameQueue)/obj.temporalSubtractionCount);%min(obj.frame, obj.temporalSubtractionCount));
        end
    end
end