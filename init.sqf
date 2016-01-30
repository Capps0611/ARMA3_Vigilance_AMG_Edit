["Loadout",[sog_hq,"SOG_HQ"]] call VG_fnc_loadout;
sog_hq disableAI "ANIM";
sog_hq switchMove "HubStandingUC_idle1";
sog_hq enableSimulationGlobal false;

["Loadout",[sog_hq_1,"SOG_HQ"]] call VG_fnc_loadout;
sog_hq_1 disableAI "ANIM";
sog_hq_1 switchMove "AmovPercMstpSnonWnonDnon_Ease";
sog_hq_1 enableSimulationGlobal false;

dope disableAI "ANIM";
dope switchMove "c5efe_HonzaLoop";
dope enableSimulationGlobal false;

dope_1 disableAI "ANIM";
dope_1 switchMove "Acts_SittingWounded_in";
dope_1 enableSimulationGlobal false;

dope_2 disableAI "ANIM";
dope_2 switchMove "passenger_flatground_1_Idle";
dope_2 enableSimulationGlobal false;

private "_glow";
_glow = "#lightpoint" createVehicle [3657,1244,0.5];
_glow setLightAmbient [0.1, 0.01, 0.01];
_glow setLightBrightness 0.02;

private "_lamp";
_lamp = "#lightpoint" createVehicle [3674,1200,1.2];
_lamp setLightAmbient [0.2, 0.2, 0.02];
_lamp setLightBrightness 0.02;