// Show briefing
[] call VG_fnc_briefing;

// Enable dynamic groups
["InitializePlayer", [player]] spawn BIS_fnc_dynamicGroups;

// Initialize weapon loadouts
if (isNil "b_pallet_1") then {
	//["Arsenal",[b_pallet, "B_UNSG"]] call VG_fnc_loadout;
	0 = ["AmmoboxInit",[b_pallet,true]] spawn BIS_fnc_arsenal;
	[player, configfile >> "CfgVehicles" >> "uns_army_8e"] call BIS_fnc_loadInventory;
} else {
	//["Arsenal",[b_pallet_1, "B_ARMA"]] call VG_fnc_loadout;
	//[player,configfile >> "CfgVehicles" >> "B_Soldier_F"] call BIS_fnc_loadInventory;
	0 = ["AmmoboxInit",[b_pallet_1,true]] spawn BIS_fnc_arsenal;
};

// Enable base hq support actions menu
["ActionMenu",[]] call VG_fnc_support;

// Spawn ambient NPCs
["Initialize",[{["LifeLoop",[]] spawn VG_fnc_npcLife}]] call VG_fnc_entyMgr;

waitUntil {!isNull findDisplay 46};

// Enemy advance timer display
["ShowTimer",[]] call VG_fnc_support;

// Enable using ear plugs
["EarPlugs",[]] call VG_fnc_support;

playMusic "EventTrack02_F_EPA";

task1 = player createSimpleTask ["t1"];
task1 setSimpleTaskDescription [
	"Patrol red grids, collect intel information and destroy weapons cache to halt enemy activity",
	"Search and destroy",
	""
];
task1 setTaskState "Assigned";
player setCurrentTask task1;

// Remind player once about the task at hand
[["Navigation","Tasks"], nil, nil, nil, nil, nil, nil, true] call BIS_fnc_advHint;