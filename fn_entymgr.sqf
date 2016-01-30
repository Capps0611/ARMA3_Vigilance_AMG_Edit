/*	Entity manager
		by Nikander

	Description:
		Manage dynamic spawning and removal of objects and groups

	Parameter(s):
		0: STRING - Mode
			"Initialize"	= Create trigger to monitor AI spawning and removal
			"FindPos"	= Search for suitable spawning position
			"Spawn"		= Spawn AI group
			"AddTag"	= Tag AI group for removal
			"CleanUp"	= Test AI tag to remove group
			"Waypoint"	= Add waypoint for AI group

		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/

#define SELF {_this call (missionNamespace getVariable ["VG_fnc_entyMgr", {}]);}

params ["_mode", "_vars"];

switch (_mode) do {
	/* Initialize entity management
	*/
	case "Initialize" : {
		_vars params [["_code", {}]];

		"_mode(Initialize)" call BIS_fnc_log;

		// Entity groups array
		missionNamespace setVariable ["fn_entymgr_tags", []];

		 // code for spawning groups
		call _code;

		true
	};

	/* Find spawn position
	*/
	case "FindPos" : {
		private ["_pos", "_fwpos", "_azim", "_val"];

		_pos	= [];
		_azim	= random 360;

		_fwpos = if (speed player isEqualTo 0) then { // Forward position 200 m
			getPosASL player vectorAdd [cos _azim * 200, sin _azim * 200, 1]
		} else {
			getPosASL player vectorAdd (vectorDir player vectorMultiply 200)
		};

		 // Convert to terrain level
		_fwpos = ASLtoATL _fwpos;

		{ // Search for tall grass positions 50 m from fwpos
			if (str(_x) find "arundod" > -1) exitWith {
				_pos = ASLtoATL getPosASL _x;
			};
			if (str(_x) find "tallgrass" > -1) exitWith {
				_pos = ASLtoATL getPosASL _x;
			};
		} forEach nearestObjects [_fwpos, [], 50];

		if (_pos isEqualTo []) then {
			_val = 0.85; // Search dense forest positions
			{
				if (_x select 1 > _val) then {
					_pos = _x select 0;
					_pos pushBack 0;
					_val = _x select 1;
				};
			} forEach selectBestPlaces [_fwpos, 50, "forest - (sea * 2)", 20, 3];
		};

		if (_pos isEqualTo []) exitWith {[]};

		// Discard position when nearest player is closer than 100 meters
		if ([allPlayers, _pos] call BIS_fnc_nearestPosition distance2D _pos < 100) exitWith {[]};

		_pos
	};

	/* Spawn group
	*/
	case "Spawn" : {
		_vars params [
			["_pos", []],		// Group position
			["_side", resistance],	// Group side
			["_compo", ["C_man_1"]],// Group composition
			["_skill", []],		// Group skill range
			["_count", 1],		// Probability all units spawn
			["_behav", "CARELESS"],	// Default behaviour
			["_tag", []]		// Tag for removal
		];

		if (typeName _pos == "OBJECT") then {_pos = getPosATL _pos};
		if (typeName _pos == "STRING") then {_pos = getMarkerPos _pos};

		if (_pos isEqualTo []) exitWith {grpNull};

		private "_grp";
		_grp = [_pos, _side, _compo, [], [], _skill, [], [1, _count], 0] call BIS_fnc_spawnGroup;
		_grp setBehaviour _behav;

		private "_add"; // Add tag if given
		if !(_tag isEqualTo []) then {
			_add = [_grp];
			_add append _tag;

			["AddTag", _add] call SELF;
		};

		_grp
	};

	/* Add tag for life cycle monitoring
	*/
	case "AddTag" : {
		_vars params [
			["_grp", grpNull, [grpNull, objNull]],	// Group or object
			["_time", 0, [0]],			// Minimum lifetime
			["_dist", 0, [0]],			// Minimum distance
			["_code", {}, [{}]]			// Code on completion
		];

		if (_grp isEqualTo grpNull) exitWith {"_mode(AddTag) empty _grp" call BIS_fnc_error; false};

		private "_tags";
		_tags = missionNamespace getVariable ["fn_entymgr_tags", []];

		private "_save";
		_save = [];  // Save tags

		for "_i" from 0 to (count _tags) - 1 do { // Skip old tag of input group
			if !((_tags select _i) select 0 isEqualTo _grp) then {
				_save pushBack (_tags select _i);
			};
		};

		// Add new tag entry
		_save pushBack [_grp, time + _time, _dist, _code];

		// Update the tags list
		missionNamespace setVariable ["fn_entymgr_tags", _save];

		true
	};

	/* Remove entities exceeding lifetime and distance
	*/

	case "CleanUp" : {
		private ["_tags", "_save", "_enty", "_grp", "_nearest", "_player", "_time", "_dist", "_code", "_units", "_unit"];

		_tags = missionNamespace getVariable ["fn_entymgr_tags", []];
		_save = []; // Save tags of valid existing groups or objects

		for "_i" from 0 to (count _tags) - 1 do {
			_enty = _tags select _i;

			_grp = _enty select 0;

			_time = _enty select 1;
			_dist = _enty select 2;
			_code = _enty select 3;

			if (time > _time) then { // Delete group only after minimum time
				_units = if (typeName _grp isEqualto "OBJECT") then {[_grp]} else {units _grp};

				// Delete empty group - it may still exist even without units
				if (count _units isEqualTo 0) exitWith {deleteGroup _grp};

				_nearest = [allPlayers, _grp] call BIS_fnc_nearestPosition;

				for "_j" from 0 to (count _units) - 1 do {
					_unit = _units select _j;

					// Delete only when minimum distance to nearest player exceeded
					if (_nearest distance2D _unit > _dist) then {
						if !(_code isEqualTo {}) then {_unit call _code};

						// Delete assigned vehicle
						if !(isNull assignedVehicle _unit) then {deleteVehicle assignedVehicle _unit};

						deleteVehicle _unit;
					};
				};
			};

			if (typeName _grp isEqualto "OBJECT") then { // Save alive object
				if (alive _grp) then {_save pushBack (_tags select _i)};
			} else {
				if !(isNull _grp) then {_save pushBack (_tags select _i)};
			};
		};

		// Update the tags list
		missionNamespace setVariable ["fn_entymgr_tags", _save];

		true
	};

	/* Add group waypoint
	*/
	case "Waypoint" : {
		_vars params [
			["_grp", grpNull, [grpNull]],		// Group
			["_pos", [], [[],objNull]],		// Waypoint position
			["_cnd", "true", [""]],			// Default condition
			["_stm", "", [""]],			// Completion statement
			["_rnd", 0, [0]],			// Random positioning
			["_rad", 0, [0]],			// Completion radius
			["_tmo", [2,4,6], [[]]],		// Waypoint timeout
			["_typ", "MOVE", [""]],			// Waypoint type
			["_spd", "LIMITED", [""]],		// Waypoint speed
			["_bhv", "CARELESS", [""]],		// Waypoint behaviour
			["_frm", "NO CHANGE", [""]]		// Waypoint formation
		];

		if (isNull _grp) exitWith {"_mode(Waypoint) empty _grp" call BIS_fnc_error; false};
		if (_pos isEqualTo []) exitWith {"_mode(Waypoint) empty _pos" call BIS_fnc_error; false};

		if (typeName _pos isEqualTo "OBJECT") then {_pos = getPosATL _pos};

		private "_wpt";
		_wpt = _grp addWaypoint [_pos, _rnd];
		_wpt setWaypointStatements [_cnd, _stm];
		_wpt setWaypointCompletionRadius _rad;
		_wpt setWaypointTimeout _tmo;
		_wpt setWaypointType _typ;
		_wpt setWaypointSpeed _spd;
		_wpt setWaypointBehaviour _bhv;
		_wpt setWaypointFormation _frm;

		_wpt
	};

	/* Remove 'onPlayerDisconnected' orphaned groups
	*/
	case "Orphan" : {
		private "_tags";
		_tags = missionNamespace getVariable ["fn_entymgr_tags", []];

		private "_kill";
		_kill = [];

		private "_orphan";
		{
			if (local _x) then {
				if !(side _x isEqualTo WEST) then {
					_orphan = true;	// Group is orphan until proven false

					for "_i" from 0 to (count _tags) - 1 do {
						_orphan = if ((_tags select _i) select 0 isEqualTo _x) then {false};
					};

					_kill pushBack _x;
				};
			};
		} forEach allGroups;

		["_mode(Orphan) _kill %1", _kill] call BIS_fnc_logFormat;

		for "_i" from 0 to (count _kill) - 1 do {
			{_x setDammage 1} forEach units (_kill select _i);
		};

		true
	};

	case default {
		false
	};
};