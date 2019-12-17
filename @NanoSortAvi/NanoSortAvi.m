classdef NanoSortAvi < NanoSorter
    properties
        ReProp
    end
    methods 
        function obj = NanoSortAvi(options)
            options = setDefaultOptions(options);
            obj@NanoSorter(options)
        end
        function start(obj, varargin)
            if isempty(varargin)
                error('Could not start analysis, no supplied video!')
            end
            obj.Indexes.video = varargin{1};
            obj.State.Frame = 0;
            obj.State.ActiveTraces = {};
            obj.Results.CompletedTraces = [];
            obj.State.hasOutputted = false;
            obj.initialize();
            obj.initiateLogs();
            obj.run();
        end
    end
    
    methods (Access = protected)
        bool = shouldOutput(obj)
        red = reduce(obj, I)
        [isp, x, y] = isParticle(obj, I, obs)
        [o1, o2] = addToTrace(obj, T, O)
        initiateLogs(obj)
        record(obj)
        registerMiss(obj, obs, name)
        registerFields(obj, fields)
        recordMisses(obj)
    end
end