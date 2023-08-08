# RotationalPerturbations
Input data can be found via doi: 10.5281/zenodo.8220096

**SRM model**
Run main file: 'Main_EMGreconstruction_TO_Opt4C_e0_MinPrimeTA_NoStictionTA.m'
Goal: reconstruct experimental EMG data based on CoM kinematics. 

**Zones**
Run main file: 'Calculate_Zones_EMG_CoM_IK.m'
Goal: Calculate average EMG activity, CoM kinematics, ankle angle kinematics for each time bin
Zones ankle/com = zones EMG - 100 ms 
Zone 1 = Onset - Onset + 150 ms 
Zone 2 = onset + 150 ms tot onset + 250 ms
Zone 3 = onset + 250 ms tot onset + 400 ms

** CCI **
Run main file: 'CCI_TO.m'
Goal: Calculate co-contraction index between PF and TA. 
