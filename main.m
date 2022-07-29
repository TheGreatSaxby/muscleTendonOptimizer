%__________________________________________________________________________
% Author: Luca Modenese, August 2014
%                       revised for paper May 2015
% email: l.modenese@griffith.edu.au
%
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________

clear;clc
close all
% importing OpenSim libraries
import org.opensim.modeling.*
% importing muscle optimizer's functions
addpath(genpath('./Functions_MOv2'))

%========= USERS SETTINGS =======
% select case to simulate: 1 or 2
example = 1;
% evaluations
N_eval = 5;
%================================


%====== EXAMPLES DETAILS ======== 
% choosing folders and models for the desired example.
switch example
    case 1  
        %========= EXAMPLE 1 =============
        % string case identifier
        case_id = 'Case1';
        % reference model and its folder
        osimModel_ref_file = 'referenceModel.osim';
        % target model and its folder
        osimModel_targ_file = 'littleModel.osim';
    case 2
        %=========== SUBJECT SPECIFIC MODEL =============
        % string case identifier
        case_id = 'Case2';
        % reference model and its folder
        osimModel_ref_file = 'referenceModel.osim';
        % target model and its folder
        osimModel_targ_file = 'bigModel.osim';
    otherwise
        error('Please choose an example between 1 and 2.');
end

%=========== INITIALIZING FOLDERS AND FILES =============
% folders used by the script
refModel_folder         = './reference/';
targModel_folder        = ['./',case_id,'/MSK_Models'];
OptimizedModel_folder   = ['./',case_id,'/OptimModels'];% folder for storing optimized model
Results_folder          = ['./',case_id,'/Results'];
log_folder              = OptimizedModel_folder;
checkFolder(OptimizedModel_folder);% creates results folder is not existing
% model files with paths
osimModel_ref_filepath   = fullfile(refModel_folder,osimModel_ref_file);
osimModel_targ_filepath  = fullfile(targModel_folder,osimModel_targ_file);

% reference model for calculating results metrics
osimModel_ref = Model(osimModel_ref_filepath);


%====== MUSCLE OPTIMIZER ======== 
% optimizing target model based on reference model fro N_eval points per
% degree of freedom
limbSide=1; % 1 for right leg
osimModel_opt = optimSelectMuscleParams(osimModel_ref_filepath, osimModel_targ_filepath, N_eval, log_folder, limbSide);


%====== PRINTING OPT MODEL =======
% setting the output folder
if strcmp(OptimizedModel_folder,'') || isempty(OptimizedModel_folder)
    OptimizedModel_folder = targModel_folder;
end
% printing the optimized model
osimModel_opt.print(fullfile(OptimizedModel_folder, char(osimModel_opt.getName())));

%====== SAVING RESULTS ===========
% variation in muscle parameters
Results_MusVarMetrics = assessMuscleParamVar(osimModel_ref, osimModel_opt, N_eval);
% assess muscle mapping in terms of RMSE, max error
Results_MusMapMetrics = assessMuscleMapping(osimModel_ref,  osimModel_opt, N_eval);
% move results mat file to result folder
movefile('./*.mat',Results_folder)

% removing functions from path 
rmpath(genpath('./Functions_MOv2'));
    