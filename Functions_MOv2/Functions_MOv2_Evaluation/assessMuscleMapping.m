%__________________________________________________________________________
% Author: Luca Modenese, July 2014
% email: l.modenese@griffith.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
% Script to evaluate the results of the optimized muscle scaling.
% The script calculated the normalized fiber lengths for the model template
% and for the scaled model with optimized muscle parameters.
% The metrics considered for comparison are an RMSE (assuming that the
% optimization is aiming to "track" the normalized FL curve of the
% template muscles) and the maximum error in the tracking.
%
% NB Maximum error values can be deceiving as the L_norm has generally
% values between 0.5 and 1.5 (so small variations can lead to large %
% errors).

function Results_MusMapMetrics = assessMuscleMapping(Template_osimModel,...
                                                    Opt_osimModel, N_eval)


% importing OpenSim libraries
import org.opensim.modeling.*

% results file identifier
res_file_id_exp = ['_N',num2str(N_eval)];

% Extracting muscle sets from the two models
muscles_ref     = Template_osimModel.getMuscles();
muscles_opt     = Opt_osimModel.getMuscles();
% 
% %initializing the models
% initialState        = Template_osimModel.initSystem();
% initialState_Opt    = Opt_osimModel.initSystem();

% name of the result file
res_mat_file_name = ['Results_MusMapMetrics',res_file_id_exp];

% if the file exists it will ask if to re-calculate or just load the file
% if exist([res_mat_file_name,'.mat'], 'file')==2
%     % ask the user
%     pref = input([res_mat_file_name, ' exists. Do you want to re-evaluate? [y/n].'], 's');
%     switch pref
%         case 'n'
%             display('Loading existing file.')
%             load([res_mat_file_name,'.mat']);
%             return
%         case 'y'
%             display('Re-evaluating mapping results');
%     end
% end

for n_mus = 0:muscles_ref.getSize()-1
    
    % current muscle name
    curr_mus_name = muscles_ref.get(n_mus).getName;
    display(['Processing ',char(curr_mus_name)])
    
    % Extracting the current muscle from the two models
    currentMuscle_Templ = muscles_ref.get(curr_mus_name);
    currentMuscle_Opt   = muscles_opt.get(curr_mus_name);
    
    % Normalized fiber lengths for the template
    Lm_Norm_Templ = SampleMuscleQuantities(Template_osimModel,currentMuscle_Templ,'LfibNorm', N_eval); 

    % Normalized fiber lengths for the optimized model
    Lm_Norm_Opt = SampleMuscleQuantities(Opt_osimModel,currentMuscle_Opt,'LfibNorm', N_eval); 
    
    
    if isnan(Lm_Norm_Templ)
        warndlg(['NaN detected for muscle ',char(curr_mus_name),' in the template model.']);
    end
    if isnan(Lm_Norm_Opt)
        warndlg(['NaN detected for muscle ',char(curr_mus_name),' in optimized model.']);
    end
    
    % Check on the results of the sampling: if the template sampling gave some
    % unrealistic fiber lengths, this is where this should be corrected
    % boundaries for normalized fiber lengths
     % calculating minimum fiber length before having pennation 90 deg
    limitPenAngle = acos(0.1);
    % this is the minimum length the fiber can be for geometrical reasons.
    PenAngleOpt = currentMuscle_Templ.getPennationAngleAtOptimalFiberLength();
    LfibNorm_min_templ = sin(PenAngleOpt)/sin(limitPenAngle);
    % LfibNorm as calculated above can be shorter than the minimum length
    % at which the fiber can generate force (taken to be 0.5 Zajac 1989)
    if (LfibNorm_min_templ<0.5)==1
        LfibNorm_min_templ = 0.5;
    end
   % checking the muscle configuration that do not respect the condition.
   ok_point_ind = find(Lm_Norm_Templ>LfibNorm_min_templ);
   Lm_Norm_Templ = Lm_Norm_Templ(ok_point_ind);

   % checking the muscle configuration that do not respect the condition.
   Lm_Norm_Opt = Lm_Norm_Opt(ok_point_ind);
    
    if min(Lm_Norm_Templ)==0
        menu(['Zero Lnorm for muscle ',char(curr_mus_name),' in template model. Removing points with zero lengths.'],'OK');
        ok_points = (Lm_Norm_Templ~=0);
        Lm_Norm_Templ = Lm_Norm_Templ(ok_points);
        Lm_Norm_Opt = Lm_Norm_Opt(ok_points);
    end
    
        n_sample_old = length(Lm_Norm_Templ);
    
    if n_sample_old~=length(Lm_Norm_Templ);
        display(['Null fiber length detected for muscle ',char(currentMuscleScaled.getName),'. These points have been removed from the optimization.']);
        display(['From ', num2str(n_sample_old), ' to ', num2str(length(Lm_Norm_Templ))])
    end
    
    
    % difference between the two normalized fiber length vectors
    Diff_Lfnorm = Lm_Norm_Templ-Lm_Norm_Opt;
    
    % structure of results
    Results_MusMapMetrics.colheaders{n_mus+1}       = char(currentMuscle_Templ.getName);
    Results_MusMapMetrics.RMSE(n_mus+1)             = sqrt(sum(Diff_Lfnorm.^2.0)/length(Lm_Norm_Templ));
    Results_MusMapMetrics.MaxPercError(n_mus+1)     = max(abs(Diff_Lfnorm)./Lm_Norm_Templ)*100;
    Results_MusMapMetrics.MinPercError(n_mus+1)     = min(abs(Diff_Lfnorm)./Lm_Norm_Templ)*100;
    Results_MusMapMetrics.MeanPercError(n_mus+1)    = mean(abs(Diff_Lfnorm)./Lm_Norm_Templ,2)*100;
    Results_MusMapMetrics.StandDevPercError(n_mus+1)= std(abs(Diff_Lfnorm)./Lm_Norm_Templ,0,2)*100;
    [rho,P_val]                                     = corr(Lm_Norm_Templ', Lm_Norm_Opt');
    Results_MusMapMetrics.corrCoeff(n_mus+1,1:2)    = [rho,P_val];
end
clear  Lm_Norm_Opt Lm_Norm_Templ
% Extracting max and min variations for MaxPercError
[RMSE_max, Ind_max]                     = max(Results_MusMapMetrics.RMSE);
[RMSE_min, Ind_min]                     = min(Results_MusMapMetrics.RMSE);
Results_MusMapMetrics.RMSE_range(1)     = RMSE_min;
Results_MusMapMetrics.RMSE_range(2)     = RMSE_max;
Results_MusMapMetrics.RMSE_range_mus    = {Results_MusMapMetrics.colheaders{Ind_min}, Results_MusMapMetrics.colheaders{Ind_max}};

% Extracting max and min variations for MaxPercError
[MeanPercError_max, Ind_max]                     = max(Results_MusMapMetrics.MeanPercError);
[MeanPercError_min, Ind_min]                     = min(Results_MusMapMetrics.MeanPercError);
Results_MusMapMetrics.MeanPercError_range(1)     = MeanPercError_min;
Results_MusMapMetrics.MeanPercError_range(2)     = MeanPercError_max;
Results_MusMapMetrics.MeanPercError_range_mus    = {Results_MusMapMetrics.colheaders{Ind_min}, Results_MusMapMetrics.colheaders{Ind_max}};

% Extracting max and min variations for MaxPercError
[MaxPercError_max, Ind_max]                     = max(Results_MusMapMetrics.MaxPercError);
[MaxPercError_min, Ind_min]                     = min(Results_MusMapMetrics.MaxPercError);
Results_MusMapMetrics.MaxPercError_range(1)     = MaxPercError_min;
Results_MusMapMetrics.MaxPercError_range(2)     = MaxPercError_max;
Results_MusMapMetrics.MaxPercError_range_mus    = {Results_MusMapMetrics.colheaders{Ind_min}, Results_MusMapMetrics.colheaders{Ind_max}};

% Extracting max and min corr coeff and p values
Results_MusMapMetrics.rho_pval_range = [min(Results_MusMapMetrics.corrCoeff),max(Results_MusMapMetrics.corrCoeff)];

% save structures with results
save(res_mat_file_name,'Results_MusMapMetrics');

end


