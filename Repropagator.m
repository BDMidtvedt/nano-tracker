classdef Repropagator < handle
    properties
        
        % The span over which to attempt to fit
        zspan
        xspan
        yspan
        
        % Optics
        dx
        lambda
        
        % Cell arrays including the reduced propagation matrixes
        TY
        TX
        TZ
        TYmr
        TXmr
        TZmr
        
        % size of input
        roix
        roiy
        
        % should use gpu
        onGpu = false
        
        % Indexes of reduced fourier spectrum
        redI
        redI2
        weighting
    end
    methods
        function obj = Repropagator(xspan, yspan, zspan, dx, lambda, side, onGpu)
            obj.xspan = linspace(-1,1,61);%xspan;
            obj.yspan = linspace(-1,1,61);%yspan;
            obj.zspan = zspan;
            obj.dx = dx;
            obj.lambda = lambda;
            obj.roix = side;
            obj.roiy = side;
            obj.onGpu = onGpu;
            obj.weighting = 1;% 1./normpdf(obj.zspan, 0, 3)';
            k=2*pi/lambda;

            delta_k=2*pi/(side*dx); % sampling distance in k-plane
            
            kxvekt=-(side/2)*delta_k:delta_k:(side/2-1)*delta_k;
            kyvekt=kxvekt;
            [kxmat,kymat]=meshgrid(kxvekt,kyvekt); % k-matrix
            kxmat=kxmat;
            kymat=kymat;
            kzmat=fftshift((k^2-kxmat.^2-kymat.^2).^(1/2)); 
            kzmat(abs(imag(kzmat))>0)=0;
         
            
            kxmat = fftshift(kxmat);
            kymat = fftshift(kymat);
            C2=zeros(size(kzmat));
            C2(sqrt((kxmat/k).^2+(kymat/k).^2)<.1)=1;
            C2(sqrt((kxmat/k).^2+(kymat/k).^2)>.5)=1;
            TZ = cell(length(zspan),1);
            TX = cell(length(xspan),1);
            TY = cell(length(yspan),1);
            
            obj.redI = ((kzmat) ~= 0);
            obj.redI2=(C2(obj.redI) ==0 );
            for i = 1:length(zspan)
                T = exp(1i*zspan(i)*(kzmat-k))';
                T(kzmat == 0) = 0;
                T = T(obj.redI);
                obj.TZ{i} = T;
                obj.TZmr{i}= T(obj.redI2);
            end
            
            for i = 1:length(xspan)
                T = exp(-1i*xspan(i)*kxmat);
                T(kzmat == 0) = 0;
                T=T(obj.redI);
                obj.TX{i} = T;
                obj.TXmr{i}= T(obj.redI2);

            end
            
            for i = 1:length(yspan)
                T = exp(-1i*yspan(i)*kymat);
                T(kzmat == 0) = 0;
                T=T(obj.redI);
                obj.TY{i} = T;
                obj.TYmr{i}= T(obj.redI2);

            end
        end
        
        function Fr = reduce(obj, F)
            Fr = F(obj.redI);
        end
        
        function Fr = expand(obj, F)
            Fr = zeros(obj.roix,obj.roiy);
            Fr(obj.redI) = F;
        end
        
        function F = propTo(obj, F, z)
            if size(F,2) ~= 1
                F = obj.reduce(F);
            end
            [~,zi] =min(abs(z-obj.zspan));
            F_prop = F.*obj.TZ{zi};
        end
        
        
        function [Fn, r, Vz] = match(obj, F, F0, z0)
            if size(F,2) ~= 1
                F = obj.reduce(F);
            end
            if size(F0,2) ~= 1
                F0 = obj.reduce(F0);
            end
            
            T0 = F0./F;
            T0=F./abs(F);
            
            [~,iz0] = min(abs(obj.zspan -z0));
            
            % very rare
            T0(isnan(T0)) = 0;
            T0(isinf(T0)) = 0;
            
            T0 = T0.*obj.TZ{iz0};
            T0mr=T0(obj.redI2);
            
%             E=zeros(64);
%             E(obj.redI)=T0;
%             figure(11)
%             imagesc(fftshift(angle(E)))
            
            x=0;
            y=0;
            z=obj.zspan(iz0);
            Fn=F.*obj.TZ{iz0};
            vn = inf;
            V = zeros(length(obj.zspan),1) + inf;
            for i = 1:10:length(obj.zspan)
            %vnn = sum(abs(T0 - obj.TZ{i}));
                vnn=std((T0mr.*obj.TZmr{i}));
                V(i) = vnn;
                if vnn < vn
                    iz = i;
                    vn = vnn;
                end
            end
            Vw = V.*obj.weighting;
            [Vz, izw] = min(Vw);
            
            idz = max(izw - 60, 1):5: min(izw + 60, length(obj.zspan));
            vn = inf;
            for i = 1:length(idz)
                vnn=std((T0mr.*obj.TZmr{idz(i)}));
                if vnn < vn
                    iz = idz(i);
                    vn = vnn;
                end
            end
            
            idz = max(iz - 4, 1): min(iz + 4, length(obj.zspan));
            vn = inf;
            for i = 1:length(idz)
                vnn=std(T0mr.*obj.TZmr{idz(i)});
                if vnn < vn
                    iz = idz(i);
                    vn = vnn;
                end
            end
            T0=T0.*(obj.TZ{iz});
            T0mr=T0mr.*obj.TZmr{iz};
            Fn = Fn.*obj.TZ{iz};
            vn = inf;
            ix = 1;
            for i = 1:length(obj.xspan)
                vnn=std(T0mr.*obj.TXmr{i});
                if vnn < vn
                    ix = i;
                    vn = vnn;
                end

            end
            
            vn = inf;
            iy = 1;
            T0=T0.*obj.TX{ix};
            T0mr=T0mr.*obj.TXmr{ix};
            for j = 1:length(obj.yspan)
                %vnn = sum(abs(T0 - obj.TY{j}));
                vnn=std(T0mr.*obj.TYmr{j});
                if vnn < vn
                    iy = j;
                    vn = vnn;
                end
            end
            
            T0 = T0.*(obj.TY{iy});
            T0mr=T0mr.*obj.TYmr{iy};
            x = x+obj.xspan(ix);
            y = y+obj.yspan(iy);
            z = z+obj.zspan(iz);
            Fn = T0;%Fn./(obj.obj.TY{iy}.*obj.TX{ix});
%             E=zeros(64);
%             E(obj.redI)=T0;
%             figure(12)
%             imagesc(fftshift(angle(E)))
            
            r = [x y z];
            %Fn = F.*obj.TZ{iz0}.*obj.TZ{iz}.*obj.TY{iy}.*obj.TX{ix};
        end
        
        function [iz, vm] = minimize(obj, T0, T, z0)
            
            vm0 = abs(sum(T0 - T{z0}));
            % Initial, rough sweep
            idz = linspace(1,length(obj.zspan), 20);
            
            [di, vm] = findMin(obj, T0, T, idz);
            
            if vm0 < vm
                iz = z0;
                vm = vm0;
                di = 0;
            else
                iz = idz(di);
            end
            
            dz = idz(2)-idz(1);
            if di == 1
                idz = round(linspace(1 + dz/2, 1 + 3*dz/2, 10));
            elseif di == length(idz)
                idz = round(linspace(idz(di) - dz/2, idz(di) - 3*dz/2, 10));
            else
                idz = round(linspace(max(iz - dz*3/2, 1), min(iz + dz*3/2, length(obj.zspan)), 10));
            end
            
            [izn, vmn] = findMin(obj, T0, T, idz);
            
            dz = idz(2)-idz(1);
            
            if vmn < vm
                iz = idz(izn);
                vm = vmn;
            else
                di = 0;
            end
            
        end
        
        function [iz, vm] = findMin(obj, T0, T, idz)
            vm = inf;
            for i = 1:length(idz)
                vn = sum(abs(T0 - T{idz(i)}));
                if vn < vm
                    vm = vm;
                    iz = i;
                end
            end
        end
    end
end

