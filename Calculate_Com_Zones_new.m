%% Plot platform movement, CoM and EMG
% CoM indelen in zones
% Zones = zones EMG - 100 ms 
% Zone 1 = Onset - Onset + 150 ms 
% Zone 2 = onset + 150 ms tot onset + 200 ms
% Zone 3 = onset + 200 ms tot onset + 400 ms
% 18 november 2022
clear all; close all; clc
color = [229 229 229; 204 204 204; 179 179 179; 242 242 242; 214 214 214; 192 192 192; 153 153 153; 192 192 192]./255; % grijs
color2= [247, 163, 153; 251, 195, 188; 255, 227, 224; 228, 177, 171; 250, 224, 228; 247, 202, 208; 249, 190, 199; 255, 220, 204]./255; % rood
color3= [202, 240, 248; 202, 240, 248; 173, 232, 244; 202, 233, 255; 190, 233, 232; 187, 222, 251; 227, 242, 253; 187, 222, 251]./255; % blauw

colorz1 = [8 103 136]./255;
colorz2 = [240 200 8]./255;
colorz3 = [221 28 26]./255;
%% info
subj = 'CP19';
selection = [3 4 6 7 ]
leg = 'r'
%%
for l = 2
    %% Plaform movement
    c3d   = ['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'\C3D/PT_TO_L',num2str(l),'.c3d'];
    onset = xlsread(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'/OnsetPlatform.xlsx'],'TO');
    onset = onset - 10;
    
    x1 = ones(1,51);   y1 = 0:1:50; 
    x2 = ones(1,201);  y2 = 0:1:200; 
    x3 = ones(1,5001); y3 = -2500:1:2500; 
    
    if exist(c3d)
        [Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels,AUnits,AnalogFrameRate,Event,ParameterGroup,CameraInfo]=...
            readC3D(c3d);
        
        marker = find(strcmp('FP1',MLabels));
        if isempty(marker)
            marker = find(strcmp('FP2',MLabels)); %PLA1
        end
        
        figure(l*10)
        for t = selection
            subplot(7,3,1)
            pos = Markers(onset(t,l)-10:onset(t,l)+55,marker*3-1)- Markers(onset(t,l)-10,marker*3-1);
            plot(pos(1:end-5),'k','LineWidth',1.5); hold on
            line([10 10],[-10 50],'Color',[0.7 0.7 0.7]); hold on
            plot(x1*25,y1,'--','Color',[0.7 0.7 0.7]); hold on
            plot(x1*30,y1,'--','Color',[0.7 0.7 0.7]); hold on
            plot(x1*50,y1,'--','Color',[0.7 0.7 0.7]); hold on
            title([char(subj), ' - L',num2str(l)]); ylabel('Pos'); box off
            xticks([10 20 25 30 40 50]); xticklabels({'0','100','150','200','300','400'}); xlim([0 60])
            
            % Platform velocity
            % Filter
            dt    = 0.01;
            [b,g] = sgolay(5,11);
            dpos = zeros(length(pos),3);
            for p = 0:2
                dpos(:,p+1) = conv(pos, factorial(p)/(-dt)^p * g(:,p+1), 'same');
            end
            vel = dpos(1:end-5,2);
            
            subplot(7,3,4)
            plot(vel,'k','LineWidth',1.5); hold on
            line([10 10],[0 200],'Color',[0.7 0.7 0.7]); hold on
            plot(x2*25,y2,'--','Color',[0.7 0.7 0.7]); hold on
            plot(x2*30,y2,'--','Color',[0.7 0.7 0.7]); hold on
            plot(x2*50,y2,'--','Color',[0.7 0.7 0.7]); hold on
            ylabel('Vel'); hold on; box off
            xticks([10 20 25 30 40 50]); xticklabels({'0','100','150','200','300','400'}); xlim([0 60])
            
            % Acceleration
            subplot(7,3,7)
            acc = dpos(1:end-5,3);
            plot(acc,'k','LineWidth',1.5); hold on
            line([10 10],[-2500 2500],'Color',[0.7 0.7 0.7]); hold on
            plot(x3*25,y3,'--','Color',[0.7 0.7 0.7]); hold on
            plot(x3*30,y3,'--','Color',[0.7 0.7 0.7]); hold on
            plot(x3*50,y3,'--','Color',[0.7 0.7 0.7]); hold on
            ylabel('Acc'); hold on; box off
            xticks([10 20 25 30 40 50]); xticklabels({'0','100','150','200','300','400'}); xlim([0 60])
        end
    end
    
     %% CoM Movement
    BKpos = importdata(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'\/BK/PT_TO_L',num2str(l),'_BodyKinematics_pos_global.sto']);
    BKvel = importdata(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'\/BK/PT_TO_L',num2str(l),'_BodyKinematics_vel_global.sto']);
        
    % Extract COM data
    pCOM_all     = BKpos.data(:,find(strcmp(BKpos.colheaders,'center_of_mass_X')))- BKpos.data(:,find(strcmp(BKpos.colheaders,'calcn_r_X')));
    vCOM_all     = BKvel.data(:,find(strcmp(BKvel.colheaders,'center_of_mass_X'))) - BKvel.data(:,find(strcmp(BKvel.colheaders,'calcn_r_X')));
    
    % Calculate acceleration of COM
    [~, ~, NewAcc]  = Calculate_Acceleration_Option3(pCOM_all,BKpos.data(:,1));
    
    x1 = ones(1,21);   y1 = -0.05:0.01:0.15; 
    x2 = ones(1,11);   y2 = -0.5:0.1:0.5; 
    x3 = ones(1,41); y3 = -2:0.1:2; 


    for t = selection
        posCOM(:,t) = pCOM_all(onset(t,l)-10:onset(t,l)+55)-pCOM_all(onset(t,l)-10);
        velCOM(:,t) = vCOM_all(onset(t,l)-10:onset(t,l)+55);
        accCOM(:,t) = NewAcc(onset(t,l)-10:onset(t,l)+55);
        
        subplot(7,3,2)
        plot(posCOM(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-0.05 0.15],'Color',[0.7 0.7 0.7]); hold on
        plot(x1*15,y1,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x1*20,y1,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x1*40,y1,'--','Color',[0.7 0.7 0.7]); hold on
        ylabel('pCOM'); xticks([10 15 20 25 30 40 50]); xticklabels({'0','50','100','150','200','300','400'}); xlim([0 60])
        
        subplot(7,3,5)
        plot(velCOM(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-0.5 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot(x2*15,y2,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x2*20,y2,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x2*40,y2,'--','Color',[0.7 0.7 0.7]); hold on
        ylabel('vCOM'); xticks([10 15 20 25 30 40 50]); xticklabels({'0','50','100','150','200','300','400'}); xlim([0 60])
        
        subplot(7,3,8)
        plot(accCOM(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-2.5 2.5],'Color',[0.7 0.7 0.7]); hold on
        plot(x3*15,y3,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x3*20,y3,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x3*40,y3,'--','Color',[0.7 0.7 0.7]); hold on
        ylabel('aCOM');xticks([10 15 20 25 30 40 50]); xticklabels({'0','50','100','150','200','300','400'}); xlim([0 60])
    end
    
    subplot(7,3,2)
    plot(mean(posCOM'),'k','LineWidth',1.5); hold on
    subplot(7,3,5)
    plot(mean(velCOM'),'k','LineWidth',1.5); hold on
    subplot(7,3,8)
    plot(mean(accCOM'),'k','LineWidth',1.5); hold on

    m_posCOM  = mean(posCOM'); m_velCOM = mean(velCOM'); m_accCOM = mean(accCOM'); 

    %% EMG 
    EMG         = xlsread(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'/EMG/Filter_40/PT_TO_L',num2str(l),'_Filter40.xlsx']);
    scalefactor = xlsread(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'/EMG/MaxPerturbations_AcrossLevel.xlsx'],'Totaal');
    
    if leg == 'l'
        MG   = EMG(:,8); TA = EMG(:,10); SOL = EMG(:,9); LG = EMG(:,7);
        sMG  = MG./scalefactor(7);
        sSOL = SOL./scalefactor(8);
        sTA  = TA./scalefactor(9);
        sLG  = LG./scalefactor(6);
        
    else
        MG   = EMG(:,3);  TA = EMG(:,5); SOL = EMG(:,4); LG = EMG(:,2);
        sMG  = MG./scalefactor(2);
        sSOL = SOL./scalefactor(3);
        sTA  = TA./scalefactor(4);
        sLG  = LG./scalefactor(1);
    end
    
    % Interpoleer EMG to COM data
    time = 0.01:0.01:EMG(end,1); 
    sMG_interp_all  = interp1(EMG(:,1),sMG',time);
    sTA_interp_all  = interp1(EMG(:,1),sTA',time);
    sSOL_interp_all = interp1(EMG(:,1),sSOL',time);
    sLG_interp_all  = interp1(EMG(:,1),sLG',time);
    
    for t = selection
        MG_sel(:,t) = sMG_interp_all(onset(t,l)-10:onset(t,l)+55);
        TA_sel(:,t) = sTA_interp_all(onset(t,l)-10:onset(t,l)+55);
        SOL_sel(:,t)= sSOL_interp_all(onset(t,l)-10:onset(t,l)+55);
        LG_sel(:,t) = sLG_interp_all(onset(t,l)-10:onset(t,l)+55);
        
        subplot(7,3,10)
        plot(MG_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on        % Onset platform
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on   % Zone 1 - geen EMG verwacht
        plot([30 30],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on   % Zone 2 - reflex PF
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on   % Zone 3 - TA 
        ylabel('MG'); ylim([0 0.5]); box off 
         xticks([10 25 30 50]); xticklabels({'0','150','200','400'}); xlim([0 60])
        
        subplot(7,3,13)
        plot(LG_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([30 30],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        ylabel('LG'); ylim([0 0.5]); box off
        xticks([10 25 30 50]); xticklabels({'0','150','200','400'}); xlim([0 60])
        
        subplot(7,3,16)
        plot(SOL_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([30 30],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        ylabel('SOL'); ylim([0 0.5]); box off
        xticks([10 25 30 50]); xticklabels({'0','150','200','400'}); xlim([0 60])
        
        subplot(7,3,19)
        plot(TA_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([30 30],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        ylabel('TA'); ylim([0 0.5]); box off
        xticks([10 25 30 50]); xticklabels({'0','150','200','400'}); xlim([0 60])
    end
        subplot(7,3,10)
        plot(mean(MG_sel'),'k','LineWidth',1.5); hold on
        subplot(7,3,13)
        plot(mean(LG_sel'),'k','LineWidth',1.5); hold on
        subplot(7,3,16)
        plot(mean(SOL_sel'),'k','LineWidth',1.5); hold on
        subplot(7,3,19)
        plot(mean(TA_sel'),'k','LineWidth',1.5); hold on
        
        m_MG   = mean(MG_sel'); m_LG = mean(LG_sel'); m_SOL = mean(SOL_sel'); m_TA = mean(TA_sel'); 
        baseline.MG = mean(m_MG(1:10)); baseline.LG = mean(m_LG(1:10)); baseline.SOL = mean(m_SOL(1:10)); baseline.TA = mean(m_TA(1:10)); 

        %% optie 1 - EMG
        o1.z1_MG  = sum(m_MG(10:25));  o1.z2_MG  = sum(m_MG(25:30));  o1.z3_MG  = sum(m_MG(30:50)); 
        o1.z1_LG  = sum(m_LG(10:25));  o1.z2_LG  = sum(m_LG(25:30));  o1.z3_LG  = sum(m_LG(30:50)); 
        o1.z1_SOL = sum(m_SOL(10:25)); o1.z2_SOL = sum(m_SOL(25:30)); o1.z3_SOL = sum(m_SOL(30:50)); 
        o1.z1_TA  = sum(m_TA(10:25));  o1.z2_TA  = sum(m_TA(25:30));  o1.z3_TA  = sum(m_TA(30:50)); 
  
        subplot(7,3,11)
        bar(1,o1.z1_MG/15-baseline.MG,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_MG/5-baseline.MG,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_MG/20-baseline.MG,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        title('EMG'); box off; xticks([1 2 3])
        
        subplot(7,3,14)
        bar(1,o1.z1_LG/15-baseline.LG,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_LG/5-baseline.LG,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_LG/20-baseline.LG,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); box off
        
        subplot(7,3,17)
        bar(1,o1.z1_SOL/15-baseline.SOL,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_SOL/5-baseline.SOL,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_SOL/20-baseline.SOL,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); box off
        
        subplot(7,3,20)
        bar(1,o1.z1_TA/15-baseline.TA,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_TA/5-baseline.TA,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_TA/20-baseline.TA,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'})
        box off; 
        
        z.z1.MG =o1.z1_MG/15-baseline.MG;    z.z2.MG = o1.z2_MG/5-baseline.MG;    z.z3.MG = o1.z3_MG/20-baseline.MG; 
        z.z1.LG =o1.z1_LG/15-baseline.LG;    z.z2.LG = o1.z2_LG/5-baseline.LG;    z.z3.LG = o1.z3_LG/20-baseline.LG; 
        z.z1.SOL=o1.z1_SOL/15-baseline.SOL;  z.z2.SOL = o1.z2_SOL/5-baseline.SOL; z.z3.SOL = o1.z3_SOL/20-baseline.SOL; 
        z.z1.TA =o1.z1_TA/15-baseline.TA;    z.z2.TA = o1.z2_TA/5-baseline.TA;    z.z3.TA = o1.z3_TA/20-baseline.TA; 
        
        %save(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'\EMG\EMGreconstruction\TO\Output/EMGZones_Relative_L',num2str(l),'_v2_Opt1.mat'],'z')


        %% optie 1 - COM 
        c.z1_p  = sum(m_posCOM(10:15));  c.z2_p  = sum(m_posCOM(15:20));  c.z3_p  = sum(m_posCOM(20:40)); 
        c.z1_v  = sum(m_velCOM(10:15));  c.z2_v  = sum(m_velCOM(15:20));  c.z3_v  = sum(m_velCOM(20:40)); 
        c.z1_a  = sum(m_accCOM(10:15));  c.z2_a  = sum(m_accCOM(15:20)); c.z3_a  = sum(m_accCOM(20:40)); 
  
        subplot(7,3,12)
        bar(1,c.z1_p/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,c.z2_p/5,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,c.z3_p/20,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        title('CoM'); box off; xticks([1 2 3]); ylabel('Pos')
        
        subplot(7,3,15)
        bar(1,c.z1_v/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,c.z2_v/5,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,c.z3_v/20,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); box off; ylabel('Vel')
        
        subplot(7,3,18)
        bar(1,c.z1_a/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,c.z2_a/5,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,c.z3_a/20,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); box off; ylabel('Acc')
        
        cc.z1.p =c.z1_p/5;   cc.z2.p = c.z2_p/5;   cc.z3.p = c.z3_p/20; 
        cc.z1.v =c.z1_v/5;   cc.z2.v = c.z2_v/5;   cc.z3.v = c.z3_v/20; 
        cc.z1.a =c.z1_a/5;   cc.z2.a = c.z2_a/5;   cc.z3.a = c.z3_a/20; 
        
        save(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),'\EMG\EMGreconstruction\TO\Output/CoMZones_L',num2str(l),'_new.mat'],'cc')


end