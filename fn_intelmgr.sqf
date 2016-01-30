/*	Intelligence information manager
		by Nikander

	Description:
		Functionality for gathering intel

	Parameter(s):
		0: STRING - Mode
			"FindTarget"	= Show marker for nearest objective
			"ActionMenu"	= Add action menu entry 'Take Intel'
			"TakeIntel"	= Pick up intel (using action menu)
			"GetGrid"	= Object (or marker) grid reference
			"MarkIntel"	= Display marker with target distance


		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/
#define SELF {_this call (missionNamespace getVariable ["VG_fnc_intelMgr", {}]);}

params ["_mode", "_args"];

["_mode(%1) _args(%2)", _mode, _args] call BIS_fnc_logFormat;

switch (_mode) do {
	/* Nearest objective to given unit or position
	*/
	case "FindTarget" : {
		_args params [["_pos", []]];

		if (typeName _pos isEqualTo "OBJECT") then {_pos = getPosASL _pos};
		if (_pos isEqualTo []) exitWith {"empty _pos" call BIS_fnc_error; ""};

		private "_targets";
		_targets = [];

		{ // Collect all target objective markers
			if (_x find "obj_" isEqualTo 0) then {_targets pushBack _x};
		} forEach allMapMarkers;

		if (_targets isEqualTo []) exitWith {""};

		// Return nearest objective marker
		[_targets, _pos] call BIS_fnc_nearestPosition
	};

	/* Add action menu entry
	*/
	case "Menu" : {
		_args params [
			["_intel", objNull]
		];

		_intel addAction [
			"Take Intel",
			{["TakeIntel", _this] spawn SELF;},
			nil,
			0,
			true,
			true,
			"",
			"isPlayer _this && {_this distance _target < 3}"
		];
	};

	/* Pick up intel from ground
	*/
	case "TakeIntel" : {
		_args params [["_intel", objNull]];

		playSound "UAV_09";
		deleteVehicle _intel;

		private "_marker"; // Question mark intel marker
		_marker = ["FindTarget",[player]] call SELF;

		if (typeOf _intel isEqualTo "Land_File1_F") exitWith {
			["MarkIntel",[player, _marker]] spawn SELF;
			["CampLocated",[mapGridPosition player]] remoteExec ["BIS_fnc_showNotification", west];

			true
		};

		if (typeOf _intel isEqualTo "Land_File_research_F") exitWith {
			_marker setMarkerType "waypoint";
			_marker setMarkerText "Destroy";

			["CampLocated",[mapGridPosition getMarkerPos _marker]] remoteExec ["BIS_fnc_showNotification", west];

			true
		};

		["CampLocated",[mapGridPosition getMarkerPos _marker]] remoteExec ["BIS_fnc_showNotification", west];

		if (typeOf _intel isEqualTo "Land_Document_01_F") exitWith {
			["MarkGrid",[getMarkerPos _marker, "ColorRed"]] call SELF; true
		};

		// Precise target marker
		_marker setMarkerType "waypoint";
		_marker setMarkerText "Destroy";

		true
	};

	case "MarkGrid" : {
		_args params [
			["_pos", []],
			["_color", "ColorRed"]
		];

		private ["_trgt", "_area", "_x", "_y", "_marker"];

 		_x = _pos select 0;
	 	_x = _x - (_x % 100);

 		_y = _pos select 1;
	 	_y = _y - (_y % 100);

		_trgt = ["FindTarget",[_pos]] call SELF;
		_area = ["GetGrid",[_trgt]] call SELF;
		_name = format["int_%1_%2", _area, [_x + 50, _y + 46]];

		if (_name in allMapMarkers) exitWith {""};

		// Create 100x100 cache marker
		_marker = createMarker [_name, [_x + 50, _y + 46, 0]];
		_marker setMarkerShape "RECTANGLE";
		_marker setMarkerSize [50,50];
		_marker setMarkerBrush "Solid";
		_marker setMarkerColor _color;

		_marker
	};

	/* Get mission grid (1000x1000) of object or position
	*/
	case "GetGrid" : {
		_args params [["_pos", []]];

		if (typeName _pos isEqualTo "OBJECT") then {_pos = getPosASL _pos};
		if (typeName _pos isEqualTo "STRING") then {_pos = getMarkerPos _pos};

		if (_pos isEqualTo []) exitWith {"empty _pos" call BIS_fnc_error; []};

		[floor((_pos select 0)/1000) * 1000 + 500, floor((_pos select 1)/1000) * 1000 + 600, 0]
	};

	/* Create intel marker
	*/
	case "MarkIntel" : {
		_args params[
			["_pos",[]],	// Intel object (position)
			["_target", []] // Objective position (marker)
		];

		if (typeName _pos isEqualTo "OBJECT") then {_pos = getPosASL _pos};
		if (typeName _pos isEqualTo "STRING") then {_pos = getMarkerPos _pos};
		if (typeName _target isEqualTo "OBJECT") then {_target = getPosASL _target};
		if (typeName _target isEqualTo "STRING") then {_target = getMarkerPos _target};

		if (_pos isEqualTo []) exitWith {"empty _pos" call BIS_fnc_error; ""};
		if (_target isEqualTo []) exitWith {"empty _target" call BIS_fnc_error; ""};

		private "_area";
		_area = ["GetGrid",[_target]] call SELF;

		private "_marker";
		_marker = createMarker [format["int_%1_%2", _area, round(time)], _pos];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "mil_unknown_noShadow";
		_marker setMarkerSize [0.7,0.7];
		_marker setMarkerColor "ColorRed";
		_marker setMarkerText format["%1 m", floor((_pos distance _target)/100) * 100];

		_marker
	};

	case default {
		false
	};
};