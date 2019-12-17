function trace(obj)



    options = optimoptions('fmincon','Display','off');
    % Get all still active traces.
    minLength=10;
    AT = obj.State.ActiveTraces;
    UP = obj.State.Positions;
    P = obj.State.Positions;

    % If empty, no assignment can be made. Simply end.
    if isempty(UP)
        return;
    end
    
    maxHiatus=3;
    didUpdate = false(length(AT), 1);
    for i = 1:maxHiatus
        % Get the last observation of all traces which very updated i frames
        % ago. OP are points, I are index of that trace.
        [OP, I] = getPointsByHiatus(AT, obj.State.Frame, i);

        % Ensure there are traces.
        if ~isempty(OP)
            % Get cost matrix
            [C, C2] = getCostMatrix(OP, UP, AT(I), i, 0.6, inf, true, false);

            A = assignmentoptimal(C);

            for j = 1:length(A)
                a = A(j);
                if a ~= 0
                    O = [obj.State.Frame UP.X(a) UP.Y(a) UP.Z(a) UP.M(a) 0 UP.T(a)];
                    [obs, ATnew] = obj.addToTrace(AT{I(j)}, O);
                    if ~isempty(obs)
                        AT{I(j)} = ATnew;
                        didUpdate(I(j)) = true;
                    end
                end
            end

            % Remove assigned points for UP

            UP(A(A > 0), :) = [];
            % If all points have been assigned, break the loop and clean up.
            if isempty(UP.X) 
                break;
            end
        end
    end

    fU = find(~didUpdate);

    for i = 1:length(fU)
        
        j = fU(i);
        if size(AT{j}, 1) < 2 || AT{j}.Positions(end,1) == obj.State.Frame
            continue;
        end
        meanVel=getFlowDirection(AT{j});
        newP = (AT{j}.Positions(end,2:3) + meanVel(1:2)*(P.T(1) - AT{j}.Positions(end,7)))/obj.dx;
        xd = round(-63.5 + newP(1)):round(63.5 + newP(1));
        yd = round(-63.5 + newP(2)):round(63.5 + newP(2));


        isParticle = true;

        zp = AT{j}.Positions(end-1,4);
        [~, iz] = min(abs(zp-obj.zSpan));


        if xd(1) < 1 || yd(1) < 1 || xd(end) > obj.size(2) || yd(end) > obj.size(1) || iz == 1 || iz == obj.size(3)
            continue;
        end

        ROI128 = gather(obj.SI(yd,xd,iz));
        sig = sign(mean(AT{j}.Positions(:,5)));
        [row, col] = find(sig*imag(ROI128) == max(sig*imag(ROI128(:))), 1);

        dist = ((63.5 - row).^2 + (63.5 - col)^2)*(obj.dx^2);

        if dist > th

            continue;
        end
        centercols = xd(1) + col - 1 + (-2:3);
        centerrows = yd(1) + row - 1 + (-2:3);
        M = sum(sum(sum(gather(imag(obj.State.SI(centerrows,centercols,(iz-1):(iz+1)))))));


        xd2 = (xd(1)+col-1 -31):(xd(1)+col-1 +32);
        yd2 = (yd(1)+row-1 -31):(yd(1)+row-1 +32);
        ROI64 = gather(obj.State.SI(yd2,xd2,iz));
        slm = abs(imag(ROI64) - mean(imag(ROI64)));
        lev = max(slm(:))*0.5;
        slm(slm < lev) = lev;
        [xc, yc, d] = radialcenter(slm, obj.Indexes.rcweight);
        if d > 10 || isnan(xc) || isnan(yc)
            continue;
        end

        xd3 = round(xd2(1) + xc - 1 - 31.5):round(xd2(1) + xc - 1 + 31.5);
        yd3 = round(yd2(1) + yc - 1 - 31.5):round(yd2(1) + yc - 1 + 31.5);

        slice = gather((fft2(fftshift(obj.State.S{iz}(yd3,xd3)))));

        [Fn, r, vn] = obj.ReProp.match(slice, AROI{j,1}, zp-obj.zSpan(iz));
        Fn = obj.ReProp.expand(Fn);
        x = xd2(1) + xc - 1;
        y = yd2(1) + yc - 1;

        z = obj.zSpan(iz)+r(3);

        AT{j} = [AT{j}; obj.Frame x*obj.dx y*obj.dx z M vn obj.currentTime];

        AT{j}.Positions(end,6)=AT{j}.Positions(end-1,6);

        AT{j}.Positions(end,5)=AT{j}.Positions(end-1,5);


    end

    % If any observations are still unassigned, start new tracks.
    for i = 1:length(UP.X)
        O = [obj.State.Frame UP.X(i) UP.Y(i) UP.Z(i) UP.M(i) 0 UP.T(i)];
        [obs, Tnew] = obj.addToTrace({}, O);

        if ~isempty(obs)
            AT{end+1} = Tnew;
        end
    end

    % Loop through traces and move any traces older than maxHiatus to completed
    % traces. Loop backwards to avoid conflicts.
    for i = length(AT):-1:1
        if obj.State.Frame == AT{i}.Positions(end,1)
            obj.Logs.ParticlesPerFrame(obj.State.Frame) = obj.Logs.ParticlesPerFrame(obj.State.Frame) + 1;
        end
        if obj.State.Frame - AT{i}.Positions(end,1) >= maxHiatus 
            if size(AT{i}.Positions, 1) > minLength
                if obj.Options.outputROI
                    obj.Results.CompletedTraces{end+1} = AT{i};
                end
                obj.Logs.CompletedTraces = obj.Logs.CompletedTraces + 1;
                obj.Logs.TraceLength(end+1) = size(AT{i}.Positions,1);
                [obj.Logs.Diffusion(end+1),obj.Logs.Diffusionz(end+1),obj.Logs.Diffusionzmed(end+1),obj.Logs.hhz(:,end+1),obj.Logs.hhip(:,end+1), obj.Logs.IntegratedPhase(end+1)] = ProcessTrace(obj, AT{i}, obj.Indexes.ReduceBool);
%                obj.Logs.Diffusion(end+1) = 1;
%                obj.Logs.IntegratedPhase(end+1) = 1;
 %               size(obj.Logs.hhip)
            end
            AT(i) = [];
        end
    end
    
    
    
    obj.State.ActiveTraces = AT;
end