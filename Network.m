classdef Network
    
%     properties
%         size
%     end
    
    properties(Access = protected)
        N
    end
    
    methods
        function obj = Network(modelfile)
            obj.N = loadKerasNetwork(modelfile);
            
            % Find a way to fix undefined layers
        end
        function plot(obj)
            plot(obj.N);
        end
        function Y = predict(obj, X)
            Y = predict(obj.N)
        end
    end
end