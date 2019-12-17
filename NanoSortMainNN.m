%curd='E:\Fredrik_onE';
curd='D:'
%curd='E:/Daniel';
%curd='E:\Daniel\PSLmixforpaper'
%curd='C:\Users\HoloMaster\Tracking Code v 3';
% curd='C:\Users\HoloMaster\Documents\Erik';

video_folder = sprintf('%s\\videos\\', curd);
vids = dir(sprintf('%s*.avi', video_folder));

%%
% Run on Matlab 2018, not 2017.
%
o = {};
% Span over z to track. In units of pixel size.
o.zSpan = -20:2:20;

% A tracking threshold between 0 and 1, 1 being most restricitve.
o.threshold = 0.5;

% How often to update the background subtraction polynome. Increase for
% speed.
o.phaseCorrInt = 1;

%Whether to display meta data as it tracks. Slow.
o.display = false;

% Filter. Does not cost any time. Can be any convolutional filter.
o.filter = false;%fspecial('gaussian',4,0.5);


o.dt=1;%1/20; %1/fps of movie
o.dx=.115; %Pixel size in microns

% Maximum range (forwards and backwards), over which it searches for the best
% combinations of frames to background subtract.
o.frameRange = 30;
o.startFrame = 1;

% Minimum range it searches. Thus, no frames closer than this will be
% included in the background subtraction.
o.cutoff=10;

% Whether to output for each video, or aggregate the results.
o.aggregateOutput = false;
o.Record=false;
o.RecordMisses=false;
o.sizethr=150;
o.radialthr=10;
o.contrastthr=10;
o.roiy = 64;
o.roix = 64;
o.backgroundCorrect = true;
o.outputROI=true;
o.network_path = {'./@NanoSortNN/UNET_model'};
% o.crop = {401:1440, 401:1920};
%%
%NS = NanoSortNN(o, 'C:\Users\HoloMaster\Downloads\HoloTracer2\model107.48-0.104.hdf5');
NS=NanoSortNN(o);
profile off
profile on
for i = [1:3 length(vids)]
%     if i < 4
%         o.crop = {1:1440, 1:1920};
%     else
        o.crop = {1:1440, 1:1920};
%     end
    NS.start(AVIVideoReader(sprintf('%s/%s', vids(i).folder, vids(i).name), o));
    if o.Record
        close(NS.Logs.RecordAvi);
    end
end