function registerFields(obj, fields)
    colors = [0 119 187; 51 187 238; 0 153 136; 238 119 51; 204 51 17; 238 51 119]/255;
    markers = {'o', 's', 'd', '^'};
    if ~isfield(obj.Logs.Tracking, 'fieldtomarker')
        obj.Logs.Tracking.fieldtomarker = {};
        obj.Logs.Tracking.FieldCount = 0;
    end
    for i = 1:length(fields)
        field = fields{i};
        if ~isfield(obj.Logs.Tracking.fieldtomarker, field)
            cc = obj.Logs.Tracking.FieldCount;
            obj.Logs.Tracking.FieldCount = cc + 1;
            obj.Logs.Tracking.fieldtomarker.(field) = struct('Color', colors(mod(cc, size(colors,1)) + 1,:), 'Marker', markers{floor(cc/size(colors,1)) + 1});
        end
    end
end