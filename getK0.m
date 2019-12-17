function [kx0 ky0 kmax X Y KX KY]=getK0(Hol22)
[Ix Iy] = FindK0(Hol22); %rough method to find the off-axis angle

%% Find kvector vs reference position
Lx=size(Hol22,1);
Ly=size(Hol22,2);
x=[-Lx/2+1/2:Lx/2-1/2];
y=[-Ly/2+1/2:Ly/2-1/2];
[Y X]=meshgrid(y,x);

kx=linspace(-1/2,1/2,Lx);
ky=linspace(-1/2,1/2,Ly);
[KY KX]=meshgrid(ky,kx);

kx0=kx(Ix);
ky0=ky(Iy); %kx and ky of the reference beam 
kmax=sqrt(kx0^2+ky0^2)/2;
