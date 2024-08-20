% This function was used to compute the COM of RB-KAIROS robot. Check
% Alessandro De Toni Thesis for more info.

clear all;
close all;
clc;

%% Wheels parallel to the ground 

% d = [d_x, d_y, d_z] distance from each force point of application to the origin
d = 1e-3*[-215, 267.5, -345; %IV
     215, 267.5, -345; %III
     215, -267.5, -345; %II
     -215, -267.5, -345]; %I
F = [(41.7+40.8)/2; %IV
     (56.6+59.2)/2; %III
     (51.4+51.8)/2; %II
     (54.6+54.4)/2]; %I

W = -sum(F);
    
d_COM_x = 1/W*(sum(d(:,1).*F));
d_COM_y = 1/W*(sum(d(:,2).*F));

%% Wheels inclined of alfa w.r.t. the ground 
alfa = asin(90.8/430);
 
Fz = [(29.2+30)/2;   %IV
     (64.5+64.5)/2; %III
     (67.2+66.8)/2; %II
     (41.9+42.4)/2]*cos(alfa); %I
Fx = -[(29.2+30)/2;   %IV
     (64.5+64.5)/2; %III
     (67.2+66.8)/2; %II
     (41.9+42.4)/2]*sin(alfa); %I
Wz = -sum(Fz)*cos(alfa);
Wx = -sum(Fx)*sin(alfa);
 
d_COM_z = 1/Wx*(sum(d(:,1).*Fz)-sum(d(:,3).*Fx))+Wz/Wx*d_COM_x;

fprintf("x = %d, y = %d, z = %d", d_COM_x,d_COM_y,d_COM_z)

%% OLD version (bad, do not consider it)

% horiz = [72 71.4 65.8 66.2;
%     68 67.6 62.4 63.4;
%     72 71.3 66.5 67.5];
% 
% h = 69; %TODO: measure it on site and then correct
% l = 33*2+72;
% w = 58;
% p = 56.5; %length of the perpendicular to the robot (from the hanging point)
% 
% % % for i = 1:size(horiz,1)
% % %     horiz_norm(i,:) = horiz(i,:)/norm(horiz(i,:));
% % % end
% % horiz_norm
% 
% %All the angles are depicted in radiants
% 
% alfa(1:3) = asin((horiz(:,2)-horiz(:,3))/l);
% alfa(4:6) = asin((horiz(:,1)-horiz(:,4))/l);
% 
% alfa_h_avg = mean(alfa)
% 
% beta(1:3) = asin((horiz(:,1)-horiz(:,2))/w);
% beta(4:6) = asin((horiz(:,4)-horiz(:,3))/w);
% 
% beta_h_avg = mean(beta)
% 
% vert = [69 69.3 66.8 66;
%     69.6 70 66.8 66.4;
%     67.4 67.4 64.8 64.5;
%     69.3 69.6 66.8 66.4;
%     71.3 71.8 68.8 67.9;];
% 
% alfa_v(1:5) = asin((vert(:,2)-vert(:,3))/l);
% alfa_v(6:10) = asin((vert(:,1)-vert(:,4))/l);
% 
% alfa_v_avg = mean(alfa_v)
% 
% beta_v(1:5) = asin((vert(:,1)-vert(:,2))/w);
% beta_v(6:10) = asin((vert(:,4)-vert(:,3))/w);
% 
% beta_v_avg = mean(beta_v)
% 
% %% Distance from perpendicular to the robot chassis:
% 
% % Horiz. meas. 1st intersection
% d_h_xz1 = p*tan(alfa_h_avg);
% d_h_yz1 = p*tan(beta_h_avg);
% 
% % Vert. meas. 1st intersection
% d_v_xz1 = p*tan(alfa_v_avg);
% d_v_yz1 = p*tan(beta_v_avg);
% 
% % Horiz. meas. 2nd intersection
% d_h_xz2 = (p+h)*tan(alfa_h_avg);
% d_h_yz2 = (p+h)*tan(beta_h_avg);
% 
% % Vert. meas. 2nd intersection
% d_v_xz2 = (p+h)*tan(alfa_v_avg);
% d_v_yz2 = (p+h)*tan(beta_v_avg);
% 
% figure
% plot([d_h_xz1, d_h_xz2], [h, 0]);
% axis([-w/2 w/2 0 inf]);
% title("xz plane")
% hold on;
% plot([d_v_xz1, d_v_xz2], [h, 0]);
% 
% figure
% plot([d_h_yz1, d_h_yz2], [h, 0]);
% axis([-w/2 w/2 0 inf]);
% title("yz plane")
% hold on;
% plot([d_v_yz1, d_v_yz2], [h, 0]);