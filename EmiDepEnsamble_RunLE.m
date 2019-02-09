% Script to change Emission and Deposition factor in the LE to generate a paralel ensemble running
% Andres Yarce Botero-Arjo Segers 24-01-2019
%% Clear Workspace
clear all
close all
clc
%% Generate 20 different emisFact and DepoFac and write it in a .txt file
fprintf( '' );
fprintf( 'LOTOS-EUROS \n' );

l=2;
emis_Fact=normrnd(4,sqrt(l),[1,20]);  % Gaussian distributed parameter for emissions
depo_Vd=normrnd(4,sqrt(l),[1,20]);  % Gaussian distributed parameter for emissions

csvwrite('emis_Fact.csv',emis_Fact);
csvwrite('depo_Fact.csv',depo_Vd);  

% Create an array with the name of the folders to put the output result for
% each ensemble member 
folderOutput=["NOx_EnsMEM_1","NOx_EnsMEM_2","NOx_EnsMEM_3","NOx_EnsMEM_4","NOx_EnsMEM_5","NOx_EnsMEM_6",...
    "NOx_EnsMEM_7","NOx_EnsMEM_8","NOx_EnsMEM_9","NOx_EnsMEM_10","NOx_EnsMEM_11","NOx_EnsMEM_12","NOx_EnsMEM_13",...
    "NOx_EnsMEM_14","NOx_EnsMEM_15","NOx_EnsMEM_16","NOx_EnsMEM_17","NOx_EnsMEM_18","NOx_EnsMEM_19","NOx_EnsMEM_20"];

ResultsFolderEns=["ResultsEns4DVAR/NOx_EnsMEM_1","ResultsEns4DVAR/NOx_EnsMEM_2","ResultsEns4DVAR/NOx_EnsMEM_3",...
    "ResultsEns4DVAR/NOx_EnsMEM_4","ResultsEns4DVAR/NOx_EnsMEM_5","ResultsEns4DVAR/NOx_EnsMEM_6",...
    "ResultsEns4DVAR/NOx_EnsMEM_7","ResultsEns4DVAR/NOx_EnsMEM_8","ResultsEns4DVAR/NOx_EnsMEM_9",...
    "ResultsEns4DVAR/NOx_EnsMEM_10","ResultsEns4DVAR/NOx_EnsMEM_11","ResultsEns4DVAR/NOx_EnsMEM_12",...
    "ResultsEns4DVAR/NOx_EnsMEM_13","ResultsEns4DVAR/NOx_EnsMEM_14","ResultsEns4DVAR/NOx_EnsMEM_15",...
    "ResultsEns4DVAR/NOx_EnsMEM_16","ResultsEns4DVAR/NOx_EnsMEM_17","ResultsEns4DVAR/NOx_EnsMEM_18",...
    "ResultsEns4DVAR/NOx_EnsMEM_19","ResultsEns4DVAR/NOx_EnsMEM_20"];
%%  Cycle to generate the ensemble running with the modified parameters
B=0; %  variable for count number of ensemble that finished 
for j=1:7  % this is constraint by the number of cores available
 %while B<=7
CarpetasEns_Run(j)=convertCharsToStrings(sprintf('/run/media/dirac/Datos/scratch/projects/LOTOS-EUROS/Model_test_code1_4DEnVAR/ens-%i/run/le.ok',j));
CarpetasEns_Output(j)=convertCharsToStrings(sprintf('/run/media/dirac/Datos/scratch/projects/LOTOS-EUROS/Model_test_code1_4DEnVAR/ens-%i/run/',j));

d='/run/media/dirac/Datos/inputdata_Colombia/emissions/EDGAR/v42';
cd(d);
pwd
% next step remove all the content on the NOx folder
!rm -rf NOx/*     
% next step copy the content of the backup original NOx folder

!cp -a NOx-Original_copia/* NOx
cd NOx
pwd
t='/run/media/dirac/Datos/inputdata_Colombia/emissions/EDGAR/v42/NOx';
tipo='*.nc';
Nombres=get_list_files(t,tipo);
pwd


for i=1:length(Nombres)
f=ncread(Nombres{i},'emi_nox')*emis_Fact(j);
ncwrite(Nombres{i},'emi_nox',f);
end



%% Run LE model
cd /run/media/dirac/Datos/users/arjo/lotos-euros/Modelo_test_4D
pwd

fileID = fopen('ensemble-settings.rc','w');
fprintf(fileID, '! current ensemble number:\n');
fprintf(fileID, 'ensemble.id  : %i\n',j);
fprintf(fileID, '\n');
fprintf(fileID, '!Factor Applied to depositions\n');
fprintf(fileID,'deposition.adhoc.factor.nox  :  %f \n',depo_Vd(j));
fclose(fileID);

% check with -h for an overview of the flags in the compiling and
% submission.  -s argument is for change to run folder and submit inmediatelly

% info ...
fprintf( 'launching ensemble member %i', j );
% compile and start LOTOS-EUROS, run it in the background;
% write messages to "ensemble-NN.out" file with NN the ensemble member,
% and also write error messages to the same file
iret = system( sprintf( './setup_le lotos-euros.rc -s -b > ensemble-%i.out 2>&1', j ) );
if iret ~= 0,
    disp('error from calling setup LE');
    break;
end


B=isfile(CarpetasEns_Run(j))+B
%end
 
 fprintf( '\n First seven ensembles finished \n' );

end

% Ensemble members are running now ...
% Here check if they are finished, the "run" directory has a file "le.ok"
% when the model finished correctly.
%   while not all finished
%      check if all le.ok files are present
%      wait for 5 seconds
%   end
%

%%  Read the csv files generated
%emisF=csvread('emis_Fact.csv'); depoF=csvread('depo_Fact.csv');


%%
% note 1: the file in the LE where the VddepoFac is modified for each
% substance is in D4_LUOR/base/001/src/le_drydepos.F90





% run ./setup_le.rc (Run each process in paralel)


