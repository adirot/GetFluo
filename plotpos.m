function []=plotpos()
filename=uigetfile('.csv');
mat=csvread(filename,1,12);
[h,l]=size(mat);
x=mat(:,3:4:l);
y=mat(:,4:4:l);
mesure=mat(:,1:4:l);
area=mat(:,2:4:l);
figure;hold on;for i=1:l/4; plot(x(:,i),y(:,i));end
title('track')
figure;hold on;for i=1:l/4; plot(1:h,mesure(:,i));end
title('measurement')
figure;hold on;for i=1:l/4; plot(1:h,area(:,i));end
title('area')