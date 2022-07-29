function [dL, dT]=assessMuscleTendonOptimizer(expected_model, optimizedModel, nMuscleForUse)

import org.opensim.modeling.*

% Assessment
osimExp = Model(expected_model);
osimModel_opt = Model(optimizedModel);
% load muscles
exp_mus = osimExp.getMuscles();
opt_mus = osimModel_opt.getMuscles();

% compare musculotendon properties between optimized and expected 
for n = 0:nMuscleForUse-1
    cur_opt_mus = opt_mus.get(n);
    cur_exp_mus = exp_mus.get(n);
    dL = abs(cur_opt_mus.getOptimalFiberLength()- cur_exp_mus.getOptimalFiberLength());
    dT = abs(cur_opt_mus.getTendonSlackLength()- cur_exp_mus.getTendonSlackLength());
end