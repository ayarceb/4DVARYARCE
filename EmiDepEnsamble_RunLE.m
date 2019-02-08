% Script to change Emission and Deposition factor in the LE and running
% Andres Yarce Botero
%% 

clear all
close all
clc

%% 

emisFact=1;
emisDepo=1;

% Generate 20 different emisFact and DepoFac and write it in a .txt file

for i=1:20
emis_Fact(i)=emisFact + 0.2*i;
depo_Fact(i)=emisDepo + 0.2*i;
end

csvwrite('emis_Fact.csv',emis_Fact);
csvwrite('depo_Fact.csv',emis_Fact);

%%  Read the csv files generated
%emisF=csvread('emis_Fact.csv'); depoF=csvread('depo_Fact.csv');
%%

% Write this values as a enviromental variable to modify lotos-euros.rc and
% compile the model for each one of the changes (Compile in paralel)



%%
% note 1: the file in the LE where the VddepoFac is modified for each
% substance is in D4_LUOR/base/001/src/le_drydepos.F90
% note 2: the way how the emission fact is modified is multiplied all the
% NO2 emission in the input conditions




% run ./setup_le.rc (Run each process in paralel)


