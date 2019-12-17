function y=heavisideGPU(x)

y=zeros(size(x));
y(x>0)=1;