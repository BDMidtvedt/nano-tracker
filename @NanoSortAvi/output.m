function output(obj, isLast)
    if exist('res','dir') ~= 7
        mkdir res;
    end
    name = obj.getName();
    if obj.Options.outputROI
        Results = obj.Results;
        for field = fieldnames(Results)'
            fieldname = field{1};
            if ~obj.State.hasOutputted
                outp = {};
                outp.(fieldname) = Results.(fieldname);
                save(sprintf('./res/%s%s.mat', name, fieldname), '-struct', 'outp');
            else
                file=sprintf('./res/%s%s.mat', name, fieldname);
                a=whos('-file',file);
                X = load(sprintf('./res/%s%s.mat', name, fieldname));
                if a.bytes>5e8
                    filename=[sprintf('./res/%s%s',name,fieldname) num2str(obj.State.saveIterator) '.mat'];
                    save(filename,'-struct','X')
                    obj.State.saveIterator=obj.State.saveIterator+1;
                    X=struct();
                    X.(fieldname)=Results.(fieldname);
                    MDN = zeros(length(obj.Logs.Diffusion),5);
                    MDN(:,1) =obj.Logs.Diffusion;
                    MDN(:,2) =obj.Logs.IntegratedPhase;
                    MDN(:,3) =obj.Logs.Diffusionz;
                    MDN(:,4) =obj.Logs.Diffusionzmed;
                    MDN(:,5) =obj.Logs.TraceLength;
            
                    csvwrite(['./res/' name '_MD.csv'],MDN);
                    csvwrite(['./res/' name '_ParticlesPerFrame.csv'],obj.Logs.ParticlesPerFrame);
                    MDN = zeros(198,length(obj.Logs.Diffusion));
                    MDN(1:99,:) =obj.Logs.hhz;
                    MDN(100:end,:) =obj.Logs.hhip;
                    csvwrite(['./res/' name '_errorhistogram.csv'],MDN);
                else
                    
                    X.(fieldname) = [X.(fieldname) Results.(fieldname)];
                end
                
                save(sprintf('./res/%s%s.mat', name, fieldname), '-struct','X');
                
            end
            obj.Results.(fieldname) = [];
        end
        
    end    
        obj.State.hasOutputted = true;
    
        %if isLast
            MDN = zeros(length(obj.Logs.Diffusion),5);
            MDN(:,1) = obj.Logs.Diffusion;
            MDN(:,2) = obj.Logs.IntegratedPhase;
            MDN(:,3) = obj.Logs.Diffusionz;
            MDN(:,4) = obj.Logs.Diffusionzmed;
            MDN(:,5) = obj.Logs.TraceLength;
            
            csvwrite(['./res/' name '_MD.csv'],MDN);
            csvwrite(['./res/' name '_ParticlesPerFrame.csv'],obj.Logs.ParticlesPerFrame);
            MDN = zeros(198,length(obj.Logs.Diffusion));
            MDN(1:99,:) =obj.Logs.hhz;
            MDN(100:end,:) =obj.Logs.hhip;
            csvwrite(['./res/' name '_errorhistogram.csv'],MDN);
        %end
    end
