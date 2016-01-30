// Apply daytime from multiplayer lobby setting
[paramsArray select 0] call BIS_fnc_paramDaytime;

// Setup mission operations
["Initialize",[]] call VG_fnc_taskMgr;

// Center of each side
{createCenter _x} forEach [EAST, CIVILIAN];

// Initialize dynamic groups
["Initialize",[true]] call BIS_fnc_dynamicGroups;

// Remove onPlayerDisconnected orphaned groups
["orphan", "onPlayerDisconnected", {["Orphan"] call VG_fnc_entyMgr;}] call BIS_fnc_addStackedEventHandler;

if (isNil "b_pallet_1") then { // Weapon loadouts from Unsung or Arma 3
	//["AmmoboxInit",[b_pallet, false, {true}]] spawn BIS_fnc_arsenal;
	0 = ["AmmoboxInit",[b_pallet,true]] spawn BIS_fnc_arsenal;
} else {
	//["AmmoboxInit",[b_pallet_1, false, {true}]] spawn BIS_fnc_arsenal
	0 = 0 = ["AmmoboxInit",[b_pallet_1,true]] spawn BIS_fnc_arsenal;
};

private "_trig"; // Base HQ bunker jukebox
_trig = createTrigger ["EmptyDetector",[0, 0, 0], false];
_trig setTriggerActivation ["NONE", "PRESENT", true];
_trig setTriggerStatements [
	"triggerActivated fn_support_trig",
	"playSound3D ['a3\missions_f\data\sounds\radio_track_02.ogg', objNull, false, [3657,1243,122], 1, 1, 40]",
	""
];