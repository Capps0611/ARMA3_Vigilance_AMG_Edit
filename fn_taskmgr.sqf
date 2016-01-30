/*	Task manager
		by Nikander

	Description:
		Server side function to manage mission task objectives (caches)

	Parameter(s):
		0: STRING - Mode
			"Initialize"	= Setup AO list of task objectives
			"KillCache"	= Task objective completion process
			"GetArea"	= Return the next AO objective task
			"FieldCache"	= Setup cache object to random spot
			"SetArea"	= Setup the area(s) of operations
			"MarkGrid"	= Create map marker for mission grid

		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/
#define SELF {_this call (missionNamespace getVariable ["VG_fnc_taskMgr", {}]);}
#define ENTY {_this call (missionNamespace getVariable ["VG_fnc_entyMgr", {}]);}
#define INTL {_this call (missionNamespace getVariable ["VG_fnc_intelMgr", {}]);}

#define GRID_DAKRONG	[[500,4600,0],[1500,4600,0],[2500,4600,0],[3500,4600,0],[4500,4600,0],[500,3600,0],[1500,3600,0],[2500,3600,0],[3500,3600,0],[4500,3600,0],[500,2600,0],[1500,2600,0],[2500,2600,0],[3500,2600,0],[4500,2600,0],[500,1600,0],[1500,1600,0],[2500,1600,0],[3500,1600,0],[4500,1600,0],[500,600,0],[1500,600,0],[2500,600,0],[3500,600,0],[4500,600,0]]

#define CACHE_MARKER	"Empty"
#define TARGETS_CAMP	["Box_FIA_Wps_F","Box_FIA_Support_F","Box_FIA_Ammo_F"]


params [["_mode", ""], ["_args",[]]];

["_mode(%1) _args(%2)", _mode, _args] call BIS_fnc_logFormat;

switch (_mode) do {
	/* Setup mission grids and shuffle to random order
	*/
	case "Initialize" : {
		_args params [
			["_count", -1, [1]],		// Number of grids to play (optional)
			["_grids", GRID_DAKRONG, [[]],[1]]// Mission grids array (optional)
		];

		// Select total number of mission grids
		_count = if (_count < 1) then {count _grids} else {_count};

		// Select number of grids not exceeding max
		if (_count > count _grids) then {_count = count _grids};

		private "_array"; // Shuffle grids to random order
		_array = _grids call BIS_fnc_arrayShuffle;

		// Select count number of grids for the mission
		_grids = [_array, _count * -1] call BIS_fnc_subSelect;

		// Store mission grids array
		missionNamespace setVariable ["fn_taskmgr_grids", _grids];

		// Store number of grids in mission
		missionNamespace setVariable ["fn_taskmgr_count", _count];

		// Number of occupied areas to begin with (2,2,4)
		["SetArea",[ceil(6/(paramsArray select 1))]] spawn SELF;

		// Initialize assault timer (recruit 40 min, regular 30 min, veteran 20 min)
		missionNamespace setVariable ["fn_taskmgr_timer", 300 * (paramsArray select 1) + time + 600, true];

		private "_trig"; // Insurgency timer trigger
		_trig = createTrigger ["EmptyDetector",[0, 0, 0], false];
		_trig setTriggerStatements [
			"time > fn_taskmgr_timer",
			"['SetArea',[1]] spawn VG_fnc_taskMgr",
			""
		];

		true
	};

	/* Set time bonus for slowing down enemy advance
	*/
	case "TimeBonus" : {
		_args params [["_bonus", 0]];

		// Set insurgency assault timer delay (recruit 30 min, regular 20 min, veteran 10 min) + time bonus
		missionNamespace setVariable ["fn_taskmgr_timer", 300 * (paramsArray select 1) + fn_taskmgr_timer + _bonus, true];
	};

	/* Cache explosion effects
	*/
	case "Explosion" : {
		_args params [["_pos", []]];

		if (typeName _pos isEqualTo "OBJECT") then {
			_pos = getPosASL _pos;
		};

		"HelicopterExploSmall" createVehicle _pos;
		_pos remoteExec ["VG_fnc_camShake", west];

		private "_tnt";
		for "_i" from 0 to 4 + ceil(random 12) do {
			_tnt = [
				"M_Titan_AT",
				"SmallSecondary",
				"M_Titan_AT",
				"Bo_GBU12_LGB"
			] call BIS_fnc_selectRandom;

			(_tnt createVehicle [
				_pos select 0,
				_pos select 1,
				2 + ceil(random 2)
			]) setDir random 360;

			sleep (1 + random 1);
		};

		true
	};

	/* Destroying the cache
	*/
	case "KillCache" : {
		_args params [["_obj", objNull]];

		// Control the function execution - eventhandlers may fire several times in a row
		if (missionNamespace getVariable ["fn_taskmgr_explode", false]) exitWith {false};
		missionNamespace setVariable ["fn_taskmgr_explode", true];

		["Explosion",[position _obj]] call SELF;

		private "_area"; // AO coordinates
		_area = ["GetGrid",[_obj]] call INTL;

		// Change marker color to cleared
		str(_area) setMarkerColor "ColorBLUFOR";
		str(_area) setMarkerText ""; // Global update

		{ // Delete cache and intel reference markers
			if (_x find format["obj_%1", _area] isEqualTo 0) then {deleteMarker _x};
			if (_x find format["int_%1", _area] isEqualTo 0) then {deleteMarker _x};
		} forEach allMapMarkers;

		 // Mission completed successfully
		if ({_x find "obj_" isEqualTo 0} count allMapMarkers isEqualTo 0) exitWith {
			missionNamespace setVariable ["gameover", "End2", true];
			true
		};

		["TimeBonus",[0]] call SELF;

		["Vigilance"] remoteExec ["BIS_fnc_showNotification", west];

		missionNamespace setVariable ["fn_taskmgr_explode", false];

		true
	};

	/* Get first grid from shuffled array
	*/
	case "GetArea" : {
		private "_grids"; // Get grids array
		_grids = missionNamespace getVariable "fn_taskmgr_grids";

		if (count _grids isEqualTo 0) exitWith {
			"empty _grids" call BIS_fnc_error; []
		};
		
		private "_area"; // Select first grid from array
		_area = [_grids] call BIS_fnc_arrayShift;

		missionNamespace setVariable ["fn_taskmgr_grids", _grids];

		_area
	};

	/* Setup randomized campsite
	*/
	case "SetCamp" : {
		_args params [
			["_pos",[]],	// Camp center position
			["_del", 0],	// Distance to cleanup
			["_obj",[]]	// Array of camp objects
		];

		private ["_item", "_type", "_azim", "_dist", "_clip"];

		for "_i" from 0 to (count _obj) - 1 do {
			_item = (_obj select _i) select 0;
			_azim = (_obj select _i) select 1;
			_dist = (_obj select _i) select 2;

			// Azim -1 meaning 50% random presence
			if (-1 < _azim || random 1 < 0.5) then {
				// Set object clipping and azimuth from center position
				_clip = if (_azim isEqualTo -1) then {_azim = random 360; "CAN_COLLIDE"} else {"NONE"};
				_type = if (typeName _item isEqualTo "ARRAY") then {_item call BIS_fnc_selectRandom} else {_item};

				// Create item to set distance and direction from camp center position
				_item = createVehicle [_type, _pos vectorAdd ([sin _azim, cos _azim, 0] vectorMultiply _dist), [], 0, _clip];
				_item setPos [(position _item) select 0, (position _item) select 1, 0];
				_item setDir ([_item, _pos] call BIS_fnc_dirTo);

				// Align item with terrain surface
				_item setVectorUp surfaceNormal position _item;

				 // Tag for removal with Entity Manager
				if (_del > 0) then {["AddTag",[_item, 5, _del, {}]] call ENTY};
			};
		};
	};

	/* Setup indoors cache object
	*/
	case "HouseCache" : {
		_args params [["_center", []]];

		private ["_models", "_house", "_index", "_cache"];

		_models = [
			"Land_raz_hut01",[0,0,1],
			"Land_raz_hut02",[0,0,0.1],
			"Land_raz_hut04",[0,0,1],
			"Land_raz_hut06",[0,0,1],
			"Land_raz_hut07",[2.5,1.3,0.5],
			"LAND_csj_hut01",[0,1.7,1.2],
			"LAND_csj_hut02",[-0.5,1.7,1.4],
			"LAND_CSJ_hut05",[1.4,1.3,-2],
			"LAND_CSJ_hut06",[0,-1,-1.6],
			"LAND_CSJ_hut07",[0,2,0.1],
			"Land_Slum_House02_F",[1,0.5,-0.5],
			"Land_Slum_House03_F",[0,1,-1]
		];

		_house = nearestObjects [_center, ["House"], 200] call BIS_fnc_selectRandom;

		_index = _models find typeOf _house;
		if (_index isEqualTo -1) exitWith {objNull};

		_cache = createVehicle ["Box_FIA_Wps_F", _house modelToWorld (_models select (_index + 1)), [], 0, "NONE"];

		_cache
	};
	/* Setup the cache object outdoors
	*/
	case "FieldCache" : {
		_args params [["_area",[]]];

		private ["_type", "_trig", "_pos", "_seek", "_obj", "_camp", "_x", "_y", "_marker"];

		// Use trigger area for positioning
		_trig = createTrigger ["EmptyDetector", _area, false];
		_trig setTriggerArea [400, 400, 0, true];

		// Search for random position
		_pos = [_trig] call BIS_fnc_randomPosTrigger;

		_seek = true;
		while {_seek} do { // Exclude positions not suitable
			_pos = [_trig] call BIS_fnc_randomPosTrigger;

			if !(mapGridPosition _pos in ["036970","036971","037970","037971"]) then { // Base camp
				if !(surfaceType _pos isEqualTo "#QT_MudClutter") then { // River bottom surface
					_seek = if ((surfaceNormal _pos) select 2 > 0.95) then {false} else {true};
				};
			};
		};

		deleteVehicle _trig;

		// Target object type
		_type = TARGETS_CAMP call BIS_fnc_selectRandom;

		// Create target object
		_obj = createVehicle [_type, _pos, [], 0, "NONE"];

		if (isNull _obj) exitWith {
			"cannot create _obj" call BIS_fnc_error;
			objNull
		};

		// Align target object with terrain surface
		_obj setVectorUp surfaceNormal position _obj;

		// Detect destruction with event handler
		_obj addEventHandler ["Killed", {["KillCache",[_this select 0]] spawn SELF;}];

		clearBackpackCargoGlobal _obj;
		clearMagazineCargoGlobal _obj;
		clearWeaponCargoGlobal _obj;
		clearItemCargoGlobal _obj;

		_obj addWeaponCargoGlobal ["NAM_AK47", 10];
		_obj addMagazineCargoGlobal ["AK_Magazine", 50];
		_obj addMagazineCargoGlobal ["APERSTripMine_Wire_Mag", 5];

		["SetCamp", [_pos, 0, [
			["Land_ClutterCutter_medium_F", 0, 0],
			["LAND_uns_vcshelter1", -1, 0],
			["Land_Sacks_heap_F", -1, 5],
			["Land_Sacks_goods_F", -1, 5],
			["Barel", -1, 5],
			["Land_FoodContainer_01_F", -1, 3],
			["Land_Ammobox_rounds_F", -1, 3],
			["Land_CanisterFuel_F", -1, 3],
			["uns_skull_GI", -1, 3]
		]]] spawn SELF;

		// Create cache marker
		_marker = createMarker [format["obj_%1", _area], _obj];
		_marker setMarkerSize [0.7,0.7];
		_marker setMarkerType CACHE_MARKER; // DEBUG
		_marker setMarkerColor "ColorRed";

		_obj
	};

	/* Setup area of operations
	*/
	case "SetArea" : {
		_args params [["_num", 1]];

		for "_i" from 1 to _num do {
			private "_area"; // Get area grid
			_area = ["GetArea", []] call SELF;

			// No more grids to play - insurgents win
			if (_area isEqualTo []) exitWith {
				missionNamespace setVariable ["gameover", "End1", true];
				true
			};

			// Create marker to area of operations
			["MarkGrid",[_area,"ColorRed"]] call SELF;

			if (_num isEqualTo 1) then { // Notify players about new AO
				["Insurgency"] remoteExec ["BIS_fnc_showNotification"];

				["TimeBonus",[600]] call SELF;
			};

			// Create outdoors cache
			["FieldCache",[_area]] spawn SELF;
		};

		true
	};

	/* Create grid marker
	*/
	case "MarkGrid" : {
		_args params [
			["_area", []],
			["_color", "ColorRed"]
		];

		if (typeName _area isEqualTo "OBJECT") then {_area = ["GetGrid",[_area]] call INTL};
		if (_area isEqualTo []) exitWith {"empty _area" call BIS_fnc_error; ""};

		private "_marker";

		_marker = createMarker [str(_area), _area];
		_marker setMarkerShape "RECTANGLE";
		_marker setMarkerSize [500,500];
		_marker setMarkerColor _color;
		_marker setMarkerAlpha 0.5;
		_marker setMarkerText ""; // Update globally

		str(_area)
	};
	
	case default {
		false
	};
};