function [Filt_pos, Filt_vel, Filt_acc] = Calculate_Acceleration_Option3(position,time)
%Calculate Acceleration Option 3
% Caclculate acceleration of COM
% Savitzky-Goley filter   - sgolayfilt


%Input
pos  = position;
time = time;
dt   = time(2)- time(1);

% Filter 
[b,g] = sgolay(5,11);
dpos = zeros(length(pos),3);
for p = 0:2
    dpos(:,p+1) = conv(pos, factorial(p)/(-dt)^p * g(:,p+1), 'same');
end

% pos = dpos(10:end-10,1) - mean(dpos(10:end-10,1));
% vel = dpos(10:end-10,2);
% acc = dpos(10:end-10,3);

pos = dpos(:,1); 
vel = dpos(:,2); 
acc = dpos(:,3); 

Filt_pos = pos; %Filt_pos = [ones(11,1)*Filt_pos(1); Filt_pos];
Filt_vel = vel; %Filt_vel = [ones(11,1)*Filt_vel(1); Filt_vel];
Filt_acc = acc; %Filt_acc = [ones(11,1)*Filt_acc(1); Filt_acc];

% figure(1000)
% subplot(311)
% plot(Filt_pos,'LineWidth',1.5); 
% subplot(312)
% plot(Filt_vel,'LineWidth',1.5); 
% subplot(313)
% plot(Filt_acc,'LineWidth',1.5); 

end

