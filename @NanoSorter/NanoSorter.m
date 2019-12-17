classdef (Abstract) NanoSorter < handle
    
    % Do not add more properties. Instead, create a subclass that extends
    % the list.
    properties(Access = protected)
        % All runtime options set by user
        Options
        
        % All internal setup. Constant during runtime. Set during
        % initialization
        Indexes
        
        % The internal state of the analysis.
        State
    end
    
    properties
        % All that which should be outputted
        Results
        
        % Logging information. May not affect runtime.
        Logs
    end
    
    methods
        function obj = NanoSorter(options)
            if exist('options', 'var')
                fields = fieldnames(options);
                for field = fields'
                    obj.Options.(field{1}) = options.(field{1});
                end
            end
        end
    end
    
    % Default lifecycle. Let subclass overwrite if needed.
    methods(Access = protected)
        function run(obj)
            obj.State.saveIterator=0;
            video = obj.getVideo();
            while obj.hasFrame(video)
                obj.next(video);
                obj.preprocess();
                if obj.shouldTrack()
                    obj.track();
                    obj.trace();
                end
                if obj.shouldOutput()
                    obj.output(false)
                end
                obj.print()
            end
            obj.output(true)
        end
        
        function bool = shouldOutput(obj)
            bool = false;
        end
        
        function bool = shouldTrack(obj)
            bool = true;
        end
    end
    
    methods(Abstract = true)
        % Starts the analysis. varargin can, for example, be used to input one or more
        % videos.
        start(obj, varargin)
        
        % Retrieves a pointer to the video to be analysed.
        getVideo(obj)
        
        % Are there more frames to be analysed?
        hasFrame(obj)
        
        % Fetches the next frame to be analysed
        next(obj)
        
        % All pre-backpropagation processing (Extracting the hologram, 
        % subtracting background polynomial, background subtraction)
        preprocess(obj)
        
        % Backpropagates the frame
        backpropagate(obj)
        
        % Tracks the frame
        track(obj)
        
        
        
        % Traces the frame
        trace(obj)
        
        % Outputs the results
        output(obj)
        
        print(obj)
        
    end
end