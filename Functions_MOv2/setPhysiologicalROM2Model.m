function setPhysiologicalROM2Model(modelPath , targetModel)

import org.opensim.modeling.*


% Check the conditions on the target model, and confine the reference DOFs
% and ROMs to the same values.
model1 = Model(modelPath);
model2 = Model(targetModel);
states1 = model1.initSystem();
states2 = model2.initSystem();

models = [model1 , model2];
states = [states1 , states2];

suffix = {'_r' , '_l'};
joints = {'hip' , 'knee' , 'ankle'};
hipAngles = {'_flexion' , '_adduction' , '_rotation'};
kneeAngles = {'_flexion' , '_adduction' , '_internal_rotation'};
ankleAngles = {'_angle' , '_Y_angle'};

hipROMs = [-45, 90 ; -60, 40 ; -30, 60];
hipLocked = [0, 0, 0];
kneeROMs = [-120, 10 ; 0, 0 ; 0, 0];
kneeLocked = [0 , 1, 0];
ankleROMs = [-75, 45 ; 0, 0];
ankleLocked = [0, 1];

for m = 1:length(models)
    for s = 1:length(suffix)
        for j = 1:length(joints)
            jointLocked = eval([char(joints{j}) , 'Locked']);
            roms = eval([char(joints{j}) , 'ROMs']);
            angles = eval([char(joints{j}), 'Angles']);
            if m == 1
                joint = CustomJoint.safeDownCast(model1.getJointSet().get([char(joints{j}), char(suffix{s})]));
            else
                joint = CustomJoint.safeDownCast(model2.getJointSet().get([char(joints{j}), char(suffix{s})]));
            end
            for a = 1:length(angles)
                jointCoordSet = joint.getCoordinateSet().get([char(joints{j}) , char(angles{a}) , char(suffix{s})]);                 
                if rad2deg(jointCoordSet.getDefaultValue) > roms(a,2)
                    jointCoordSet.setDefaultValue(deg2rad(roms(a,2)));
                end
                if rad2deg(jointCoordSet.getDefaultValue) < roms(a,1)
                    jointCoordSet.setDefaultValue(deg2rad(roms(a,1)));
                end
                jointCoordSet.setRangeMin(deg2rad(roms(a,1)));
                jointCoordSet.setRangeMax(deg2rad(roms(a,2)));                    
                jointCoordSet.setLocked(states(m), jointLocked(a));
            end
        end
    end
end

% print model
model1.print(modelPath);
model2.print(targetModel);



