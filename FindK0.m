function [kx0 ky0] = FindK0Grating(FieldN)
N=size(FieldN);
x0=(N(1)+1)/2;
y0=(N(2)+1)/2;
xin=[1:N(1)];
yin=[1:N(2)];
[XIN YIN]=meshgrid(xin,yin);
FFTField=fftshift(fft2(FieldN));
mask=ones(size(FieldN));
mask(sqrt((XIN'-x0).^2+(YIN'-y0).^2)<40)=0;
mask(abs(XIN'-x0)<2)=0;
mask(abs(YIN'-y0)<2)=0;
mask(XIN'<N(1)/2)=0;
FFTField2=FFTField;


[C I] = max(conv2(abs(FFTField2).*mask,ones(5,5),'same')); %Find max with kx>0
[C2 I2] = max(C);

kx0=I(I2);
 ky0=I2;
