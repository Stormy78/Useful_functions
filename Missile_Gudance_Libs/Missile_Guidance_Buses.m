function Missile_Guidance_Buses() 
% MISSILE_GUIDANCE_BUSES initializes a set of bus objects in the MATLAB base workspace 

% Bus object: GscOutBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'B2D';
elems(1).Dimensions = [3;3];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'wAfterStabTF';
elems(2).Dimensions = [3;1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'wCmd_Rtn';
elems(3).Dimensions = [3;1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'thetaDotCmd';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

elems(5) = Simulink.BusElement;
elems(5).Name = 'psiDotCmd';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).Complexity = 'real';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = '';
elems(5).Description = '';

elems(6) = Simulink.BusElement;
elems(6).Name = 'thetaMeas';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).Complexity = 'real';
elems(6).Min = [];
elems(6).Max = [];
elems(6).DocUnits = '';
elems(6).Description = '';

elems(7) = Simulink.BusElement;
elems(7).Name = 'psiMeas';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).Complexity = 'real';
elems(7).Min = [];
elems(7).Max = [];
elems(7).DocUnits = '';
elems(7).Description = '';

GscOutBus = Simulink.Bus;
GscOutBus.HeaderFile = '';
GscOutBus.Description = '';
GscOutBus.DataScope = 'Auto';
GscOutBus.Alignment = -1;
GscOutBus.PreserveElementDimensions = 0;
GscOutBus.Elements = elems;
clear elems;
assignin('base','GscOutBus', GscOutBus);

% Bus object: LosOutBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'wCmd';
elems(1).Dimensions = [3;1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

LosOutBus = Simulink.Bus;
LosOutBus.HeaderFile = '';
LosOutBus.Description = '';
LosOutBus.DataScope = 'Auto';
LosOutBus.Alignment = -1;
LosOutBus.PreserveElementDimensions = 0;
LosOutBus.Elements = elems;
clear elems;
assignin('base','LosOutBus', LosOutBus);

% Bus object: missileBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'accelerationL0';
elems(1).Dimensions = [3;1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'positionL0';
elems(2).Dimensions = [3;1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'angularPoseL0';
elems(3).Dimensions = [3;1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'velocityL0';
elems(4).Dimensions = [3;1];
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

elems(5) = Simulink.BusElement;
elems(5).Name = 'angularRateL0';
elems(5).Dimensions = [3;1];
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).Complexity = 'real';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = '';
elems(5).Description = '';

elems(6) = Simulink.BusElement;
elems(6).Name = 'L02B';
elems(6).Dimensions = [3;3];
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).Complexity = 'real';
elems(6).Min = [];
elems(6).Max = [];
elems(6).DocUnits = '';
elems(6).Description = '';

missileBus = Simulink.Bus;
missileBus.HeaderFile = '';
missileBus.Description = '';
missileBus.DataScope = 'Auto';
missileBus.Alignment = -1;
missileBus.PreserveElementDimensions = 0;
missileBus.Elements = elems;
clear elems;
assignin('base','missileBus', missileBus);

% Bus object: sensorOutBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'epsMEAS_D';
elems(1).Dimensions = [2;1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'rangeMEAS_D';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'rangeDotMEAS_D';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'targetValid';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'boolean';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

elems(5) = Simulink.BusElement;
elems(5).Name = 'timeOfMeas';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).Complexity = 'real';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = '';
elems(5).Description = '';

sensorOutBus = Simulink.Bus;
sensorOutBus.HeaderFile = '';
sensorOutBus.Description = '';
sensorOutBus.DataScope = 'Auto';
sensorOutBus.Alignment = -1;
sensorOutBus.PreserveElementDimensions = 0;
sensorOutBus.Elements = elems;
clear elems;
assignin('base','sensorOutBus', sensorOutBus);

% Bus object: targetInsertionBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'targetEps_D';
elems(1).Dimensions = [2;1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'dLambda';
elems(2).Dimensions = [3;1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'ddLambda';
elems(3).Dimensions = [3;1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'Lambda';
elems(4).Dimensions = [3;1];
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

elems(5) = Simulink.BusElement;
elems(5).Name = 'targetRelPos_L0';
elems(5).Dimensions = [3;1];
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).Complexity = 'real';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = '';
elems(5).Description = '';

elems(6) = Simulink.BusElement;
elems(6).Name = 'targetRelPos_B';
elems(6).Dimensions = [3;1];
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).Complexity = 'real';
elems(6).Min = [];
elems(6).Max = [];
elems(6).DocUnits = '';
elems(6).Description = '';

elems(7) = Simulink.BusElement;
elems(7).Name = 'targetRelPos_D';
elems(7).Dimensions = [3;1];
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).Complexity = 'real';
elems(7).Min = [];
elems(7).Max = [];
elems(7).DocUnits = '';
elems(7).Description = '';

elems(8) = Simulink.BusElement;
elems(8).Name = 'targetRelVel_L0';
elems(8).Dimensions = [3;1];
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).Complexity = 'real';
elems(8).Min = [];
elems(8).Max = [];
elems(8).DocUnits = '';
elems(8).Description = '';

elems(9) = Simulink.BusElement;
elems(9).Name = 'Range';
elems(9).Dimensions = 1;
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).Complexity = 'real';
elems(9).Min = [];
elems(9).Max = [];
elems(9).DocUnits = '';
elems(9).Description = '';

elems(10) = Simulink.BusElement;
elems(10).Name = 'dRange';
elems(10).Dimensions = 1;
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).Complexity = 'real';
elems(10).Min = [];
elems(10).Max = [];
elems(10).DocUnits = '';
elems(10).Description = '';

elems(11) = Simulink.BusElement;
elems(11).Name = 't_go';
elems(11).Dimensions = 1;
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).Complexity = 'real';
elems(11).Min = [];
elems(11).Max = [];
elems(11).DocUnits = '';
elems(11).Description = '';

targetInsertionBus = Simulink.Bus;
targetInsertionBus.HeaderFile = '';
targetInsertionBus.Description = '';
targetInsertionBus.DataScope = 'Auto';
targetInsertionBus.Alignment = -1;
targetInsertionBus.PreserveElementDimensions = 0;
targetInsertionBus.Elements = elems;
clear elems;
assignin('base','targetInsertionBus', targetInsertionBus);

