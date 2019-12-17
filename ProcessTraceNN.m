function [D, er] = ProcessTraceNN(obj,T, ~)
    
    [D,er] = getD2({T.Positions});
    
    T.ROI = [];
end