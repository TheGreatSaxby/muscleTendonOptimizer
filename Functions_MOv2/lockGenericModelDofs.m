function lockGenericModelDofs(osimModel_ref_file)

import org.opensim.modeling.*

model = Model(osimModel_ref_file);

% Knee
joint_r = CustomJoint.safeDownCast(model.getJointSet().get('knee_r'));
jointCoordSet = joint_r.getCoordinateSet().get('knee_flexion_r');