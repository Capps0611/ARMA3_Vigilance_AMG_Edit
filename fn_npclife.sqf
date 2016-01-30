/*	Non-player Controlled ambient life
		by Nikander

	Description:
		Function to spawn NPC groups around player

	Parameter(s):
		0: STRING - Mode
			"LifeLoop"	= Main loop
			"InWarZone"	= Player in enemy occupied area
			"InCivZone"	= True when player in villages
			"Hostile"	= Spawn enemy group
			"Friendly"	= Spawn civilians
			"Campsite"	= Spawn campsites
			"Tripwire"	= Spawn tripwire mines
			"Assassin"	= Create assassination target

		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/
#define SELF {_this call (missionNamespace getVariable ["VG_fnc_npcLife", {}]);}
#define ENTY {_this call (missionNamespace getVariable ["VG_fnc_entyMgr", {}]);}
#define TASK {_this call (missionNamespace getVariable ["VG_fnc_taskMgr", {}]);}
#define INTL {_this call (missionNamespace getVariable ["VG_fnc_intelMgr",{}]);}
#define GEAR {_this call (missionNamespace getVariable ["VG_fnc_loadout",{}]);}

#define SKILL		1/(paramsArray select 1)

#define MARKERS_EAST	["vc","vc_1","vc_2","vc_3","vc_4","vc_5","vc_6","vc_7","vc_8","vc_9","vc_10","vc_11","vc_12","vc_13","vc_14","vc_15"]
#define WALKERS_EAST	[["uns_local_vc1a","uns_local_vc1f","uns_local_vc2a","uns_local_vc1b"],["uns_rf_vc9a","uns_rf_vc10a","uns_rf_vc4b"]]

params ["_mode", "_args"];

switch (_mode) do {
	/* Main loop for player clients
	*/
	case "LifeLoop" : {
		private ["_count", "_grps", "_wire", "_camp"];

		// Process handles
		_grps = scriptNull;
		_wire = scriptNull;
		_camp = scriptNull;

		while {true} do {
			if !(vehicle player isKindOf "Helicopter") then {
				_count = {_x distance player < (paramsArray select 1) * 100} count allPlayers;

				if (["InWarZone",[player]] call SELF) then { // AO sectors
					// Spawn hostile groups until max count reached
					if ({typeName (_x select 0) isEqualTo "GROUP" && side (_x select 0) isEqualTo east} count fn_entymgr_tags < ceil(12/(paramsArray select 1)/_count)) then {
						if (isNull _grps) then {_grps = ["Hostile",[]] spawn SELF};
					};

					// Spawn boobytraps
					if (isNull _wire) then {_wire = ["Tripwire",[]] spawn SELF};

					// Spawn enemy campfires
					if (isNull _camp) then {_camp = ["Campsite",[]] spawn SELF};
				};
			};

			if (["InCivZone",[player]] call SELF) then { // Villages
				if ({typeName (_x select 0) isEqualTo "GROUP" && side (_x select 0) isEqualTo civilian} count fn_entymgr_tags < ceil(6/_count)) then {
					if (isNull _grps) then {_grps = ["Friendly",[]] spawn SELF};
				};
			};

			["CleanUp",[]] call ENTY;

			sleep 2;
		};
	};

	case "InWarZone" : {
		_args params [["_pos", []]];

		if (typeName _pos isEqualTo "OBJECT") then {_pos = ASLtoATL getPosASL _pos};
		if (_pos isEqualTo []) exitWith {["empty _pos"] call BIS_fnc_error; false};

		if (player in list fn_support_trig && random 1 < SKILL) exitWith {true};

		private "_zone";
		_zone = getMarkerPos ([MARKERS_EAST, _pos] call BIS_fnc_nearestPosition);

		if (_pos distance2D _zone < 400) exitWith {true};

		private "_area"; // Test for AO location
		_area = ["GetGrid", [_pos]] call INTL;

		if (format["obj_%1", _area] in allMapMarkers) exitWith {true};

		false
	};

	case "InCivZone" : {
		_args params [["_pos", []]];

		if (typeName _pos isEqualTo "OBJECT") then {_pos = ASLtoATL getPosASL _pos};
		if (_pos isEqualTo []) exitWith {["empty _pos"] call BIS_fnc_error; false};

		private "_zone";
		_zone = locationPosition nearestLocation [_pos, "NameVillage"];

		_pos distance2D _zone < 400
	};

	case "Hostile" : {
		private ["_grp", "_pos", "_type", "_spot", "_behav", "_speed"];

		_grp = grpNull;

		// Find spawn location
		_pos = ["FindPos",[]] call ENTY;

		// Exit if spawn pos not found
		if (_pos isEqualTo []) exitWith {grpNull};

		_behav = "SAFE";
		_speed = "LIMITED";

		if (missionNamespace getVariable ["fn_npclife_alert", []] isEqualTo (["GetGrid",[player]] call INTL)) then {
			_behav = "AWARE";
			_speed = "NORMAL";
		};

		_type = WALKERS_EAST call BIS_fnc_selectRandom;
		_grp = ["Spawn", [_pos, east, _type, [0,0.03], 0.7, _behav, [2, 400, {}]]] call ENTY;

		{if (random 1 < 0.5) then {removeHeadgear _x}} forEach units _grp;

		// Group leader is carrying intel
		leader _grp addEventHandler ["Killed", {
			missionNamespace setVariable ["fn_npclife_alert", ["GetGrid",[player]] call VG_fnc_intelMgr]; // Alert given
			_file = createVehicle ["Land_File1_F", getPosATL (_this select 0), [], 1, "CAN_COLLIDE"];

			["Menu",  [_file]] remoteExec ["VG_fnc_intelMgr", west];
			["AddTag",[_file, 5, 200, {}]] call VG_fnc_entyMgr;
		}];

		// Set waypoint to player
		["Waypoint",[_grp, ASLtoATL getPosASL player, "true", "[(group this), 1] setWaypointPosition [ASLtoATL getPosASL player, 20];", 60, 10, [2,4,3], "MOVE", _speed, "UNCHANGED", "COLUMN"]] spawn ENTY;

		_grp
	};

	case "Friendly" : {
		// Find spawn location
		_pos = ["FindPos",[]] call ENTY;

		// Exit if spawn pos not found
		if (_pos isEqualTo []) exitWith {grpNull};

		private "_grp";
		_grp = ["Spawn", [_pos, civilian, ["uns_civilian2","uns_civilian4"], [1,1], 0.5, "SAFE", [8, 200, {}]]] call ENTY;
		{_x addHeadgear "UNS_Conehat_VC"; ["Menu",[_x]] remoteExec ["VG_fnc_talkMgr", west]} forEach units _grp;

		private "_move";
		_move = locationPosition nearestLocation [_pos, "NameVillage"];

		// Move to village and around
		["Waypoint",[_grp, _move, "true", format["[(group this), 1] setWaypointPosition [%1 vectorAdd [random 100, random 100, 10], 50];", _move], 50, 10, [2,4,3], "MOVE", "LIMITED", "UNCHANGED", "COLUMN"]] spawn ENTY;

		_grp

	};

	case "Campsite" : {
		private "_pos"; // Forest In front of the player 100 m distance
		_pos = ASLtoATL getPosASL player vectorAdd (vectorDir player vectorMultiply 80);

		// Random occurence
		if !(random 1 < SKILL * 0.6) exitWith {false};

		// Test for forest surface
		if !(surfaceType _pos isEqualTo "#QT_ForestClutter") exitWith {false};

		// Area of operations only
		if !(["InWarZone",[_pos]] call SELF) exitWith {objNull};

		// Keep 100 m distance to nearest camp
		if ({_x isKindOf "Land_Campfire_F"} count nearestObjects [_pos, [], 100] > 0) exitWith {false};

		// Must be relatively flat surface
		if ((surfaceNormal _pos) select 2 < 0.98) exitWith {false};

		["SetCamp", [_pos, 400, [
			["Land_Campfire_F", 0, 0],
			["Land_ClutterCutter_medium_F", 0, 0],
			[["LAND_uns_firepit1","LAND_uns_vcshelter1"], -1, 0],
			["Land_FoodContainer_01_F", -1, 2],
			["Land_Ammobox_rounds_F", -1, 2],
			["Land_CanisterFuel_F", -1, 2],
			["uns_skull_GI", -1, 2]
		]]] spawn TASK;

		// Random chance intel found
		if (random 1 < 0.5) exitWith {true};

		private "_file";
		_file = createVehicle ["Land_Document_01_F", _pos, [], 1, "NONE"];

		["Menu", [_file]] remoteExec ["VG_fnc_intelMgr", west];
		["AddTag",[_file, 5, 100, {}]] call ENTY;

		true
	};

	case "Tripwire" : {
		private "_pos";
		_pos = ASLtoATL getPosASL player vectorAdd (vectorDir player vectorMultiply 30);

		// Random occurence
		if !(random 1 < SKILL * 0.6) exitWith {objNull};

		// Test for forest surface
		if !(surfaceType _pos isEqualTo "#QT_ForestClutter") exitWith {objNull};

		// Area of operations only
		if !(["InWarZone",[player]] call SELF) exitWith {objNull};

		// Keep 50 m distance to nearest mine
		if ({_x isKindOf "APERSTripMine_Wire_Ammo"} count nearestObjects [_pos, [], 50] > 0) exitWith {objNull};
			
		private "_mine";
		_mine = createMine ["APERSTripMine", [_pos select 0, _pos select 1, 0], [], 0];
		_mine setDir random 360;

		["AddTag",[_mine, 5, 50, {}]] call ENTY;

		private "_type";
		_type = ["uns_skull_GI","Land_CanisterFuel_F","uns_skull_bandana","Land_FoodContainer_01_F","Land_Ammobox_rounds_F"] call BIS_fnc_selectRandom;

		private "_deco";
		_deco = createVehicle [_type, [_pos select 0, _pos select 1, 0], [], 0, "CAN_COLLIDE"];
		["AddTag",[_deco, 5, 50, {}]] call ENTY; // Tag for removal

		_deco setPosATL (_mine modelToWorld [1.6,0,0]);

		// Show advanced hint once
		[["Weapons","Minesweep"], nil, nil, nil, nil, nil, nil, true] call BIS_fnc_advHint;

		_mine
	};

	/* Special Operations briefing
	*/
	case "SpecOps" : {
		_args params [
			["_msg", ""],
			["_mrk", ""]
		];

		private ["_pos", "_idx", "_loc", "_grp"];

		if (_mrk isEqualTo "") then {
			_mrk = MARKERS_EAST call BIS_fnc_selectRandom;
		};

		_pos = getMarkerPos _mrk;

		// Show advanced hint once
		[["Vigilance","Operations"], nil, nil, nil, nil, nil, nil, true] call BIS_fnc_advHint;

		if !(player diarySubjectExists "sog") then {player createDiarySubject ["sog", "Intel"]};

		_idx = str(round time);
		_loc = text (nearestLocations [_pos, ['NameVillage','NameCity'], 1000] select 0);

		_msg = format[_msg, _mrk, _loc];

		player createDiaryRecord ["sog",[
			format ["SOG #%1", _idx],
			format ["<img image='uns_patches\data\sub\capital_mil_assist_cmd_grn_ca.paa' width='48' height='48'/><font size='16'>  OPERATION '%1' ID %2</font><br/><br/>%3",
				toUpper _loc, _idx, _msg
			]
		]];

		titleText [format["Officer: ""Operation assigned for you, read intel report %1 for details""", _idx],"PLAIN DOWN",2];

		_pos
	};

	/* Raid operations
	*/
	case "RaidOps" : {
		if (!isNull (missionNamespace getVariable ["fn_npclife_sog", objNull])) exitWith {playSound "Affirmative"};

		playSound3D ["a3\dubbing_f_epb\b_hub\015_b_m05_briefing\b_hub_015_b_m05_briefing_STA_0.ogg", objNull, false, [3673.6,1202,119], 1, 1, 30];

		private "_obj";
		_obj = objNull;

		private "_sog";
		_sog = missionNamespace getVariable "fn_npclife_sog";

		private "_pos";
		if (isNil "_sog") then {
			["SpecOps",["Search the enemy <marker name='vc_10'>tunnel system</marker><br/>Intel suggest enemy is hiding weapons on the location<br/>Destroying enemy cache is going to delay their offensive", "vc_10"]] call SELF;

			_pos = [[1486,2827,1.4],[1532,2773,1.4],[1563,2718,1.4],[1544,2822,1.4],[1535,2834,1.4],[1568,2868,1.4]] call BIS_fnc_selectRandom;
			_obj = createVehicle ["Box_FIA_Wps_F", _pos, [], 0, "CAN_COLLIDE"];
		} else {
			_pos = ["SpecOps",["Search the houses near <marker name='%1'>%2</marker><br/>Intel suggest enemy is hiding weapons on the location<br/>Destroying weapons cache is going to delay their offensive", ""]] call SELF;

			while {isNull _obj} do {
				_obj = ["HouseCache",[_pos]] call TASK;
			};
		};

		// Detect destruction with event handler
		_obj addEventHandler ["Killed", {
			["Explosion",[_this select 0]] spawn VG_fnc_taskMgr;
			["TimeBonus"] remoteExec ["VG_fnc_taskMgr", 2];
			["SpecialOps",["RAID TASK"]] remoteExec ["BIS_fnc_showNotification", west];
			missionNamespace setVariable ["fn_npclife_sog", objNull];
		}];

		// Assign the target for player
		missionNamespace setVariable ["fn_npclife_sog", _obj];

		_obj
	};

	/* Assassination task
	*/
	case "Assassin" : {
		if (!isNull (missionNamespace getVariable ["fn_npclife_sog", objNull])) exitWith {playSound "Affirmative"};

		playSound3D ["a3\dubbing_f_epa\a_hub\050_a_m05_briefing\a_hub_050_a_m05_briefing_MIL_0.ogg", objNull, false, [3671,1197,119], 1, 1, 30];

		private "_pos";
		_pos = ["SpecOps",["High-ranking enemy officer spotted near <marker name='%1'>%2</marker><br/>Target is expected to be on location for 20 min at most<br/>Assassinate him and find detailed intel about nearest cache"]] call SELF;

		private "_grp"; // Spawn the assassination target group - remove after 20 minutes
		_grp = ["Spawn", [[_pos select 0, _pos select 1, 1], east, ["O_officer_F","O_soldier_PG_F","O_soldier_PG_F","O_soldier_PG_F"], [0.05,0.05], 1, "SAFE", [1200, 200, {}]]] call ENTY;

		// Assign the target for player
		missionNamespace setVariable ["fn_npclife_sog", leader _grp];

		{["Loadout",[_x, typeOf _x]] spawn GEAR;} forEach units _grp;

		leader _grp setSkill 0; // Escapist
		leader _grp addEventHandler ["Killed", {
			_file = createVehicle ["Land_File_research_F", getPosATL (_this select 0), [], 1, "CAN_COLLIDE"];
			["Menu",  [_file]] remoteExec ["VG_fnc_intelMgr", west];
			["AddTag",[_file, 5, 200, {}]] call VG_fnc_entyMgr;
			["SpecialOps",["ASSASSINATION"]] remoteExec ["BIS_fnc_showNotification", west];
			missionNamespace setVariable ["fn_npclife_sog", objNull];
			["AddTag",[group (_this select 0), 5, 200, {}]] spawn VG_fnc_entyMgr;
		}];

		// Move the group around
		["Waypoint",[_grp, _pos, "true", format["[(group this), 1] setWaypointPosition [%1 vectorAdd [random 40, random 40, 0], 10];", _pos], 10, 5, [6,8,4], "MOVE", "LIMITED", "SAFE", "DIAMOND"]] spawn ENTY;

		_grp
	};

	case default {
		false
	};
};