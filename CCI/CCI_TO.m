%% CCI
% Script to calculate co-contractie index between PF and TA
% Long and short time interval

clear all; close all; clc
subj = 'CP';            % CP or TD

% Read leg
info.leg = xlsread('D:\Zenodo/4.Demografie.xlsx',char(subj));


for i = [1:21]            % Subject number, loop over all subjects
    leg      = info.leg(i,4); % 0 = R , 1 = L
    for l = 1:4         % loop over all perturbation levels
        input = ['D:\Zenodo\',char(subj),num2str(i),'\Input Model\EMG_Reconstruction_TO_Level',num2str(l),'_Inputdata_Opt4C_PrimeTA_PrimePF_Stiction_minPrimeTA_Squared_e0_NoStictionTA.mat'];
        if exist(input)
            load(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'\EMG\EMGreconstruction\TO\Input/EMG_Reconstruction_TO_Level',num2str(l),'_Inputdata_Opt4C_PrimeTA_PrimePF_Stiction_minPrimeTA_Squared_e0_NoStictionTA_v2.mat']);

            %Input
            MG_in  = input.EMG(1,11:211); SOL_in = input.EMG(3,11:211); LG_in  = input.EMG(4,11:211); TA_in  = input.EMG(2,11:211);

            % Min waardes
            MG_min  = min(MG_in, TA_in);
            LG_min  = min(LG_in, TA_in);
            SOL_min = min(SOL_in, TA_in);

            % Plot
            figure(i*10+l)
            subplot(331)
            plot(MG_in); hold on; plot(TA_in); hold on
            plot(MG_min); hold on
            legend({'MG','TA'})
            line([50 50],[0 0.2],'Color',[0.7 0.7 0.7])
            subplot(332)
            plot(LG_in); hold on; plot(TA_in); hold on
            plot(LG_min); hold on
            line([50 50],[0 0.2],'Color',[0.7 0.7 0.7])
            legend({'LG','TA'})
            subplot(333)
            plot(SOL_in); hold on; plot(TA_in); hold on
            plot(SOL_min); hold on
            line([50 50],[0 0.2],'Color',[0.7 0.7 0.7])
            legend({'SOL','TA'})


            % Calculate CCI
            CCI_long_LG(i,l)  = sum(LG_min)/length(LG_min);
            CCI_long_MG(i,l)  = sum(MG_min)/length(MG_min);
            CCI_long_SOL(i,l) = sum(SOL_min)/length(SOL_min);

            CCI_short_LG(i,l)  = sum(LG_min(50:90))/length(LG_min(50:90));
            CCI_short_MG(i,l)  = sum(MG_min(50:90))/length(MG_min(50:90));
            CCI_short_SOL(i,l) = sum(SOL_min(50:90))/length(SOL_min(50:90));
        end
    end
end