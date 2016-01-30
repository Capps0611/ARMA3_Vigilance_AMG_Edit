/*	Basic headquarters support functions
		by Nikander

	Description:
		User support interface core

	Parameter(s):
		0: STRING - Mode
			"ActionMenu"	= Arsenal action menu
			"ShowIcons"	= Icons for Arsenal crates
			"HideIcons"	= Remove icons from crates
			"ShowTimer"	= Display time notification

		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/
#define SELF {_this call (missionNamespace getVariable ["VG_fnc_support", {}]);}
#define LIFE {_this call (missionNamespace getVariable ["VG_fnc_npcLife", {}]);}

params [["_mode", ""], ["_args",[]]];

["_mode(%1) _args(%2)", _mode, _args] call BIS_fnc_logFormat;

switch (_mode) do {
	/* Initialize HQ action menu
	*/
	case "ActionMenu" : {
		[] spawn {
			private "_id";

			if (isNil "b_pallet_1") then {
				waitUntil {!isNil {b_pallet getVariable "bis_fnc_arsenal_action"}};
				_id = b_pallet getVariable "bis_fnc_arsenal_action";
				b_pallet setUserActionText [_id, "<img image='\A3\ui_f\data\map\markers\nato\n_service.paa' color='#4d994d' shadow='1' /> Arsenal"];
			} else {
				waitUntil {!isNil {b_pallet_1 getVariable "bis_fnc_arsenal_action"}};
				_id = b_pallet_1 getVariable "bis_fnc_arsenal_action";
				b_pallet_1 setUserActionText [_id, "<img image='\A3\ui_f\data\map\markers\nato\n_service.paa' color='#004d99' shadow='1' /> Arsenal"];
			};
		};

		// Studies and Observations Group assassin operations
		sog_hq addAction [
			"<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\instructor_ca.paa' /> Talk to",
			{['Assassin',[]] spawn LIFE;},
			nil,
			0,
			true,
			true,
			"",
			"player distance _target < 2"
		];

		// Studies and Observations Group raid operations
		sog_hq_1 addAction [
			"<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\instructor_ca.paa' /> Talk to",
			{['RaidOps',[]] spawn LIFE;},
			nil,
			0,
			true,
			true,
			"",
			"player distance _target < 2"
		];

		true
	};

	/* Show icons over Arsenal crates (activation with area trigger)
	*/
	case "ShowIcons" : {
		missionNamespace setVariable ["fn_support_eh", 
			addMissionEventHandler ["Draw3D",{
				if (isNil "b_pallet_1") then {
					drawIcon3D [
						"UNS\uns_main\data\unsung_logo",
						[1,1,1,12/(player distance b_pallet)],
						b_pallet modelToWorldVisual [0,0,1],
						2,
						1,
						0,
						'',
						2,
						0.03,
						'PuristaMedium'
					];
				} else {
					drawIcon3D [
						"A3\Ui_f\data\Logos\arma3_expansion_ca",
						[1,1,1,(paramsArray select 2) * 12/(player distance b_pallet_1)],
						b_pallet_1 modelToWorldVisual [0,0,1],
						2,
						2,
						0,
						'',
						2,
						0.03,
						'PuristaMedium'
					];
				};
			}]
		];
	};

	/* Remove icons (activation with area trigger)
	*/
	case "HideIcons" : {
		removeMissionEventHandler ["Draw3D", missionNamespace getVariable "fn_support_eh"];

		// Remind player once about dynamic groups
		[["DynamicGroups","DG_DynamicGroups"], nil, nil, nil, nil, nil, nil, true] call BIS_fnc_advHint;

		true
	};

	/* Show time notification upon press-and-release of 'Wristwatch' key
	*/
	case "ShowTimer" : {
		[] spawn {
			waitUntil {!isNil "fn_taskmgr_timer"};

			findDisplay 46 displayAddEventHandler ["KeyUp", {
				if (_this select 1 in actionKeys "Watch") then {
					["EnemyTimer",[ceil((fn_taskmgr_timer - time)/60)]] call BIS_fnc_showNotification;

					false
				};
			}];
		};

		true
	};

	/* Earplugs using 'F1' key
	*/
	case "EarPlugs" : {
		[] spawn {
			findDisplay 46 displayAddEventHandler ["KeyUp", {
				if (_this select 1 isEqualTo 59) then {
					if (soundVolume > 0.1) then {hint "EARPLUGS IN"; 1 fadeSound 0.1; playMusic ""} else {hint "EARPLUGS OUT"; 1 fadeSound 1}
				};

				false
			}];
		};
	};

	/* Reset and respawn weapons crate to respawn marker
		["SetSupply", [this, false]] spawn VG_fnc_support (editor init line)

	*/
	case "SetSupply" : {
		_args params [
			["_obj", objNull],
			["_die", false]
		];

		if (isNull _obj) exitWith {false};

		private "_var";
		if (_die) then {
			sleep 5;

			_var = vehicleVarName _obj;
			_obj = createVehicle [typeOf _obj, getMarkerPos format["respawn_%1", _var], [], 0, "CAN_COLLIDE"];
			_obj setVehicleVarName _var;
		};

		_obj addEventHandler ["Killed", {
			["SetSupply", [_this select 0, true]] spawn VG_fnc_support;
		}];

		clearItemCargoGlobal _obj;
		clearWeaponCargoGlobal _obj;
		clearMagazineCargoGlobal _obj;
		clearBackpackCargoGlobal _obj;

		_obj addBackpackCargoGlobal ["B_Respawn_TentDome_F", 1];

		{_obj addMagazineCargoGlobal [_x, 2 + floor(random 8)]} forEach [
			"L2A3_Magazine_T",
			"L2A3_Magazine",
			"R700_Magazine",
			"20Rnd_762x51_Mag",
			"00BS_Magazine",
			"UGL_FlareWhite_F",
			"1Rnd_HE_Grenade_shell",
			"M63_Magazine",
			"M60_Magazine",
			"30Rnd_556x45_Stanag_Tracer_Red",
			"30Rnd_556x45_Stanag_Tracer",
			"30Rnd_556x45_Stanag",
			"20Rnd_556x45_Stanag",
			"1911_Magazine",
			"HandGrenade",
			"SmokeShellBlue",
			"SmokeShellGreen",
			"SmokeShell",
			"ClaymoreDirectionalMine_Remote_Mag",
			"DemoCharge_Remote_Mag",
			"APERSTripMine_Wire_Mag",
			"Chemlight_red",
			"Chemlight_yellow"
		];

		_obj addItemCargoGlobal ["FirstAidKit", 10];
	};

	case default {
		false
	};
};