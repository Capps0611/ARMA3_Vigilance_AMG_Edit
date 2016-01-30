/*	Talk manager
		by Nikander

	Description:
		Simple conversation interaction with ambient civilians

	Parameter(s):
		0: STRING - Mode
			"ActionMenu"	= Define 'Talk to' action menu
			"GetBearing"	= Distance and direction sentence
			"TalkTo"	= Asking for information process

		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/
#define SELF {_this call (missionNamespace getVariable ["VG_fnc_talkMgr", {}]);}
#define INTL {_this call (missionNamespace getVariable ["VG_fnc_intelMgr", {}]);}

#define SKILL		1/(paramsArray select 1)

#define SOUNDS_NO_HEAR	["a3\dubbing_f_epa\a_hub\077_ambient_talk_07\a_hub_077_ambient_talk_07_ALPB_2.ogg","a3\dubbing_f_bootcamp\boot_m03\105_Earthquake\boot_m03_105_earthquake_BSA_0.ogg","a3\dubbing_f_bootcamp\boot_m05\45_Aftermath\boot_m05_45_aftermath_LAC_1.ogg"]
#define PLAYER_NO_HEAR	["Yeah... maybe this whole thing is one big misunderstanding","Okay ?","Hey, what are you doing ?"]
#define PLAYER_IS_DEAD	"Damn. Poor bastard"
#define SOUNDS_IS_DEAD	"a3\dubbing_f_epb\b_hub\308_POI_Crashed_Plane_01_Player\b_hub_308_poi_crashed_plane_01_player_KER_0.ogg"
#define ANSWER_NO_INFO	["I know they're somewhere here","I'm afraid I can't help you","I know nothing, Sir","I have nothing to tell you, unfortunately so","Haven't seen them, I hope it stays that way","They haven't been around here","I'm just glad they are not here","I haven't seen them","I've seen nothing","They don't come here","I have nothing to do with them, Sir","I'm fortunate to know nothing about them","Well, for all I know, they are not here","Blessed be, they haven't been here","I hope to have nothing to do with them"]
#define SOUNDS_NO_INFO	["\a3\dubbing_f_epc\c_in1\13_ambient_talk_03\c_in1_13_ambient_talk_03_ABB_1.ogg","a3\dubbing_f_epb\b_hub\072_B_HUB_Ambient_Talk\b_hub_072_b_hub_ambient_talk_SFB_2.ogg","a3\dubbing_f_epb\b_hub\082_B_HUB_Ambient_Talk\b_hub_082_b_hub_ambient_talk_SFA_0.ogg"]
#define SOUNDS_IS_INFO	["a3\dubbing_f_epc\c_out2\60_Truck_Found\c_out2_60_truck_found_KER_0.ogg","a3\dubbing_f_epb\b_hub\403_welcome_b_hub03\b_hub_403_welcome_b_hub03_NIK_2.ogg","a3\dubbing_f_epb\b_hub\313_POI_Mysterious_Cache_01_Player\b_hub_313_poi_mysterious_cache_01_player_KER_0.ogg","a3\dubbing_f_epb\b_hub\310_POI_first_aid_02_Player\b_hub_310_poi_first_aid_02_player_KER_0.ogg"]
#define ANSWER_NO_TALK	["I told you all I know, Sir","I have nothing more to say, Sir"]
#define SOUNDS_NO_TALK	["a3\dubbing_f_epa\a_in\195_Bomber_Spotted\a_in_195_bomber_spotted_ICO_0.ogg","a3\dubbing_f_epb\b_hub\216_POI_Special_Forces_01\b_hub_216_poi_special_forces_01_GUB_1.ogg"]
#define PLAYER_REQUEST	["Hello. Have you seen Viet Cong ?","Hello. We are searching for VC","Hello. Viet Cong around here ?","Hello. Where are the VC ?", "Hello. Victor Charlie ?"]
#define ANSWER_REQUEST	["Sir, they're assembling weapons %1","I found their weapons cache %1","I just saw them %1, Sir !","I heard they are %1, Sir","Sir, they were %1 earlier today","They were unloading supplies %1","They are preparing something %1","Sure, I spotted a group %1","Sir, they seem to have a camp %1","We saw their vehicles %1, Sir","I spotted them %1 half an hour ago","Yes, they're transporting supplies %1"]
#define TALKUNITS	["uns_civilian2","uns_civilian4"]

#define BEARING	["north","northeast","east","southeast","south","southwest","west","northwest","north"]
#define DEGREES [0,45,90,135,180,225,270,315,360]

params ["_mode", "_args"];

["_mode(%1) _args(%2)", _mode, _args] call BIS_fnc_logFormat;

switch (_mode) do {
	/* Action menu interface
	*/
	case "Menu" : {
		_args params [
			["_talker", objNull]
		];

		_talker addAction [
			"<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\instructor_ca.paa' /> Talk to",
			{["TalkTo", _this] spawn SELF},
			nil,
			0,
			true,
			true,
			"",
			"isPlayer _this && {_this distance _target < 16}"
		];
	};

	/* Describe distance and bearing to nearest objective
	*/
	case "GetBearing" : {
		private "_marker"; // Find nearest objective
		_marker = ["FindTarget",[player]] call INTL;

		private "_distance";
		_distance = player distance getMarkerPos _marker;

		// Cannot get bearing to objective beyond 1 km
		if (_distance > 1000) exitWith {""};

		// Display distance with 100 m increments
		_distance = floor(_distance / 100) * 100;
		["MarkIntel",[player, _marker]] spawn INTL;

		private "_heading"; // Compass heading to objective
		_heading = [player, getMarkerPos _marker] call BIS_fnc_dirTo;

		private "_degrees"; // Convert heading to readable format
		_degrees = DEGREES find ([_heading, 45] call BIS_fnc_roundDir);

		private "_bearing";
		_bearing = BEARING select _degrees;

		format["%1 meters %2", _distance, _bearing]
	};

	/* Process simple asking for information conversation
	*/
	case "TalkTo" : {
		// Action menu variables
		_args params [
			["_talker", objNull]	// Talking unit
		];

		// Player selected talking while talking already in progress
		if (!isNull (missionNamespace getVariable ["fn_talkmgr_talker", objNull])) exitWith {false};

		// Say hello
		playSound3D ["a3\dubbing_f_epa\a_hub\350_greet_player\a_hub_350_greet_player_BRA_0.ogg", player];

		titleText [
			format["%1: ""%2""", name player, PLAYER_REQUEST call BIS_fnc_selectRandom],
			"PLAIN DOWN"
		];

		sleep 2;

		if (isNull _talker) exitWith {false};

		_talker = crew _talker select 0;

		if (!alive _talker) exitWith {
			titleText [ // Talker is dead
				format["%1: ""%2""", name player, PLAYER_IS_DEAD],
				"PLAIN DOWN"
			];

			playSound3D [SOUNDS_IS_DEAD, player];
		};

		missionNamespace setVariable ["fn_talkmgr_talker", _talker];

		private "_trig"; // Trigger to terminate talks when talkers die
		_trig = createTrigger ["EmptyDetector", [0,0,0], false];
		_trig setTriggerStatements [
			"alive player && alive fn_talkmgr_talker",
			"",
			"terminate fn_talkmgr_spawn; missionNamespace setVariable ['fn_talkmgr_talker', objNull]; deleteVehicle thisTrigger"
		];

		missionNamespace setVariable ["fn_talkmgr_trig", _trig];

		missionNamespace setVariable ["fn_talkmgr_spawn", _talker spawn {
			private "_random"; // Random phrase

			if (player distance _this > 10) exitWith {
				_random = PLAYER_NO_HEAR call BIS_fnc_randomIndex;

				titleText [ // Player is too far from talker
					format["%1: ""%2""", name player, PLAYER_NO_HEAR select _random],
					"PLAIN DOWN"
				];

				playSound3D [SOUNDS_NO_HEAR select _random, player];
			};

			if !(_this getVariable ["talk", true]) exitWith {
				titleText [ // Talker say no more talk
					format["Civilian: ""%1""", ANSWER_NO_TALK call BIS_fnc_selectRandom],
					"PLAIN DOWN"
				];

				playSound3D [(SOUNDS_NO_TALK call BIS_fnc_selectRandom), player];
			};

			_this setVariable ["talk", false];

			// Talker stop and talk
			[_this, true] remoteExec ["stop", _this];

			private "_dir";
			if (vehicle _this isKindOf "Man") then { // Face the player
				_dir = [_this, player] call BIS_fnc_dirTo;
				[_this, _dir] remoteExec ["setDir", _this];
			};

			private "_bearing";
			_bearing = ["GetBearing",[]] call VG_fnc_talkMgr;

			sleep 3;

			private "_answer";
			_answer = if (_bearing isEqualTo "") then {
				playSound3D [(SOUNDS_NO_INFO call BIS_fnc_selectRandom), player];

				ANSWER_NO_INFO call BIS_fnc_selectRandom
			} else {
				// Done talking after this
				_this setVariable ["talk", false, true];

				playSound3D [(SOUNDS_IS_INFO call BIS_fnc_selectRandom), player];

				format[ANSWER_REQUEST call BIS_fnc_selectRandom, _bearing]
			};

			titleText [ // Talker answer about enemy
				format["Civilian: ""%1""", _answer],
				"PLAIN DOWN"
			];

			[_this, false] remoteExec ["stop", _this];
		}];

		// Terminate and clean up
		deleteVehicle (missionNamespace getVariable "fn_talkmgr_trig");
		missionNamespace setVariable ['fn_talkmgr_talker', objNull]
	};

	default {
		false;
	};
};