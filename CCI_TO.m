%% CCI
% Script to calculate co-contractie index between PF and TA
% volledig tijd en 350 ms

subj = 'CP';
x= [90 90 90 90];
% Read leg
info.leg = xlsread('C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Subject Information/4.Demografie.xlsx',char(subj));


for i = [21]
leg      = info.leg(i,4); % 0 = R , 1 = L
    for l = 1:4
        input = ['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'\EMG\EMGreconstruction\TO\Input/EMG_Reconstruction_TO_Level',num2str(l),'_Inputdata_Opt4C_PrimeTA_PrimePF_Stiction_minPrimeTA_Squared_e0_NoStictionTA_v2.mat'];
        if exist(input)
            load(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'\EMG\EMGreconstruction\TO\Input/EMG_Reconstruction_TO_Level',num2str(l),'_Inputdata_Opt4C_PrimeTA_PrimePF_Stiction_minPrimeTA_Squared_e0_NoStictionTA_v2.mat']);
            load(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'\EMG\EMGreconstruction\TO\Output/EMGreconstruction_TO_Level',num2str(l),'_output_Opt4C_PrimeTA_PrimePF_Stiction_minPrimeTA_Squared_e0_NoStictionTA_v2.mat']);

            %Input
            MG_in  = input.EMG(1,11:211); SOL_in = input.EMG(3,11:211); LG_in  = input.EMG(4,11:211); TA_in  = input.EMG(2,11:211);

            % Un-scale
            scalefactor = xlsread(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'/EMG/MaxPerturbations_AcrossLevel.xlsx'],'Totaal');
            if leg == 0
                MG_in_ns  = MG_in*scalefactor(2);
                LG_in_ns  = LG_in*scalefactor(1);
                SOL_in_ns = SOL_in*scalefactor(3);
                TA_in_ns  = TA_in*scalefactor(4);
            else
                MG_in_ns  = MG_in*scalefactor(7);
                LG_in_ns  = LG_in*scalefactor(6);
                SOL_in_ns = SOL_in*scalefactor(8);
                TA_in_ns  = TA_in*scalefactor(9);
            end

            % Re-scale
            scalefactor_new = xlsread(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'/EMG/',char(subj),num2str(i),'_ScalingFactorsEMG.xlsx'],'SF');

            if leg == 0
                MG_in_s  = MG_in_ns/scalefactor_new(2);
                LG_in_s  = LG_in_ns/scalefactor_new(1);
                SOL_in_s = SOL_in_ns/scalefactor_new(3);
                TA_in_s  = TA_in_ns/scalefactor_new(4);
            else
                MG_in_s  = MG_in_ns/scalefactor_new(6);
                LG_in_s  = LG_in_ns/scalefactor_new(5);
                SOL_in_s = SOL_in_ns/scalefactor_new(7);
                TA_in_s  = TA_in_ns/scalefactor_new(8);
            end

            % Min waardes
            MG_min  = min(MG_in_s, TA_in_s);
            LG_min  = min(LG_in_s, TA_in_s);
            SOL_min = min(SOL_in_s, TA_in_s);

            figure(i*10+l)
            subplot(331)
            plot(MG_in_s); hold on; plot(TA_in_s); hold on
            plot(MG_min); hold on
            legend({'MG','TA'})
            line([50 50],[0 0.2],'Color',[0.7 0.7 0.7])
            subplot(332)
            plot(LG_in_s); hold on; plot(TA_in_s); hold on
            plot(LG_min); hold on
            line([50 50],[0 0.2],'Color',[0.7 0.7 0.7])
            legend({'LG','TA'})
            subplot(333)
            plot(SOL_in_s); hold on; plot(TA_in_s); hold on
            plot(SOL_min); hold on
            line([50 50],[0 0.2],'Color',[0.7 0.7 0.7])
            legend({'SOL','TA'})
            saveas(gcf, ['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Data\',char(subj),num2str(i),'\Combined plot\EMG_reconstruction_TO\Output/CCI_TO_Level',num2str(l),'_ScaledFunct.png'])

            CCI_long_LG(i,l)  = sum(LG_min)/(sum(LG_in_s) + sum(TA_in_s));
            CCI_long_MG(i,l)  = sum(MG_min)/(sum(MG_in_s) + sum(TA_in_s));
            CCI_long_SOL(i,l) = sum(SOL_min)/(sum(SOL_in_s) + sum(TA_in_s));

            CCI_short_LG(i,l)  = sum(LG_min(50:90))/(sum(LG_in_s(50:90)) + sum(TA_in_s(50:90)));
            CCI_short_MG(i,l)  = sum(MG_min(50:90))/(sum(MG_in_s(50:90)) + sum(TA_in_s(50:90)));
            CCI_short_SOL(i,l) = sum(SOL_min(50:90))/(sum(SOL_in_s(50:90)) + sum(TA_in_s(50:90)));
        end
    end


end
xlswrite(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Results\Perturbaties\EMGfits\TO/CCI_long',char(subj),'_Relative.xlsx'],CCI_long_LG,'LG')
xlswrite(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Results\Perturbaties\EMGfits\TO/CCI_long',char(subj),'_Relative.xlsx'],CCI_long_MG,'MG')
xlswrite(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Results\Perturbaties\EMGfits\TO/CCI_long',char(subj),'_Relative.xlsx'],CCI_long_SOL,'SOL')

xlswrite(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Results\Perturbaties\EMGfits\TO/CCI_short',char(subj),'_Relative.xlsx'],CCI_short_LG,'LG')
xlswrite(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Results\Perturbaties\EMGfits\TO/CCI_short',char(subj),'_Relative.xlsx'],CCI_short_MG,'MG')
xlswrite(['C:\Users\u0125183\OneDrive - KU Leuven\Active Reactive Balance\Results\Perturbaties\EMGfits\TO/CCI_short',char(subj),'_Relative.xlsx'],CCI_short_SOL,'SOL')