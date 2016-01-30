/*	Weapon loadouts
		by Nikander

	Description:
		Arsenal loadouts

	Parameter(s):
		0: STRING - Mode
			"AddCargo"	= Add virtual cargo to specific Arsenal
			"Arsenal"	= Setup and commit pre-defined loadouts
			"Loadout"	= Apply pre-defined loadout to unit

		1: ARRAY - Arguments (see mode)

	Returns:
		BOOLEAN (see mode)
*/
#define SELF {_this call (missionNamespace getVariable ["VG_fnc_loadout", {}]);}

#define B_UNSG_GUNS	["NAM_L2A3","NAM_L1A1","NAM_R700","NAM_XM21","NAM_M14","NAM_M72","NAM_R870","NAM_M79","NAM_CAR15_FG","NAM_CAR15_CM","NAM_CAR15_GL","NAM_M63AC","NAM_M63A","NAM_M60A","NAM_M16_GL","NAM_M16","NAM_M16_GL_30","NAM_M16_30","Colt1911"]
#define B_UNSG_MAGS	["Chemlight_red","Chemlight_yellow","M72","L2A3_Magazine_T","L2A3_Magazine","R700_Magazine","20Rnd_762x51_Mag","00BS_Magazine","UGL_FlareWhite_F","1Rnd_HE_Grenade_shell","M63_Magazine","M60_Magazine","30Rnd_556x45_Stanag_Tracer_Red","30Rnd_556x45_Stanag_Tracer","30Rnd_556x45_Stanag","20Rnd_556x45_Stanag","1911_Magazine","HandGrenade","SmokeShellRed","SmokeShellYellow","SmokeShellOrange","SmokeShellPurple","SmokeShellBlue","SmokeShellGreen","SmokeShell","ClaymoreDirectionalMine_Remote_Mag","DemoCharge_Remote_Mag","APERSTripMine_Wire_Mag"]
#define B_UNSG_BAGS	["UNS_USMC_MED","UNS_USMC_E1","UNS_USMC_R1","UNS_ARMY_AT","UNS_ARMY_RTO","UNS_ARMY_MED","UNS_Alice_F8","UNS_Alice_F7","UNS_Alice_F6","UNS_Alice_F5","UNS_Alice_F4","UNS_Alice_F3","UNS_Alice_2","UNS_Alice_1","B_Respawn_TentDome_F","B_Respawn_Sleeping_bag_F"]
#define B_UNSG_ITEM	["MineDetector","UNS_M1956_M19","UNS_M1956_A1","UNS_M1956_A3","UNS_M1956_A6","UNS_M1956_A9","UNS_M1956_M8","UNS_M1956_M15","UNS_M1_12","UNS_M1_11","UNS_M1_10","UNS_M1_9A","UNS_M1_8A","UNS_M1_7A","UNS_M1_6A","UNS_M1_5A","UNS_M1_4A","UNS_M1_3A","UNS_M1_2A","UNS_M1_1A","UNS_Bullets","UNS_Towel","UNS_Peace","G_Sport_Blackred","G_Squares_Tinted","G_Aviator","G_Spectacles_Tinted","UNS_Bandana_OD","UNS_Headband_BK","UNS_Headband_ED","UNS_Headband_OD","UNS_Boonie_TIG2","UNS_Boonie_TIGF","UNS_Boonie_ERDL","H_Booniehat_oli","UNS_Beret_G","G_Balaclava_blk","G_Balaclava_oli","UNS_USMC_Cover","UNS_USMC_Flak_F","UNS_USMC_Flak_ES","UNS_USMC_Flak","UNS_USMC_LERDL","UNS_ARMY_BDU","UNS_TIGER_BDU","Binocular","ItemRadio","ItemMap","ItemCompass","ItemWatch","FirstAidKit","Medikit","Sup_45","Sup_9","Sup_556","acc_flashlight"]

#define B_ARMA_GUNS	["launch_B_Titan_short_F","arifle_MXC_F","arifle_MX_F","arifle_MX_GL_F","arifle_MX_SW_F","hgun_P07_F","hgun_Pistol_heavy_01_F","arifle_MXM_F","srifle_LRR_camo_F","srifle_DMR_06_camo_F","srifle_GM6_camo_F"]
#define B_ARMA_MAGS	["30Rnd_65x39_caseless_mag","Titan_AT","Titan_AP","UGL_FlareCIR_F","UGL_FlareWhite_F","1Rnd_Smoke_Grenade_shell","1Rnd_SmokeBlue_Grenade_shell","1Rnd_SmokeGreen_Grenade_shell","1Rnd_HE_Grenade_shell","7Rnd_408_Mag","20Rnd_762x51_Mag","5Rnd_127x108_Mag","FirstAidKit","16Rnd_9x21_Mag","11Rnd_45ACP_Mag","B_IR_Grenade","HandGrenade","Chemlight_red","Chemlight_yellow","Chemlight_blue","Chemlight_green","SmokeShellBlue","SmokeShellGreen","SmokeShell","ClaymoreDirectionalMine_Remote_Mag","DemoCharge_Remote_Mag","SatchelCharge_Remote_Mag"]
#define B_ARMA_BAGS	["B_UAV_01_backpack_F","B_Respawn_TentA_F","B_TacticalPack_mcamo","B_Kitbag_mcamo","B_FieldPack_mcamo","B_AssaultPack_mcamo","B_Carryall_mcamo","B_Respawn_Sleeping_bag_brown_F"]
#define B_ARMA_ITEM	["MineDetector","optic_Aco","optic_Holosight","optic_Hamr","optic_KHS_hex","optic_AMS_snd","optic_Arco","optic_DMS","optic_SOS","bipod_01_F_snd","acc_pointer_IR","muzzle_snds_acp","muzzle_snds_H","G_Aviator","G_Tactical_Clear","G_Combat","H_Bandanna_khk","G_Bandanna_khk","H_MilCap_mcamo","H_Cap_tan_specops_US","H_HelmetB_snakeskin","H_Watchcap_camo","V_PlateCarrier1_rgr","V_HarnessO_brn","V_PlateCarrierGL_mtp","V_Rangemaster_belt","U_B_GhillieSuit","U_B_FullGhillie_sard","U_B_FullGhillie_lsh","U_B_FullGhillie_ard","U_B_CombatUniform_mcam_vest","U_B_CombatUniform_mcam_tshirt","U_B_CombatUniform_mcam","ToolKit","Medikit","NVGoggles","Laserdesignator","Rangefinder","Binocular","ItemRadio","ItemMap","ItemCompass","ItemWatch","ItemGPS","B_UavTerminal"]

#define LOADOUT_NAM	[\
	"SOG_HQ",[["UNS_ARMY_BDU_SF_EarlyWarsgm",[]],["",[]],["",[]],"","","",["",["","","",""],""],["",["","","",""],""],["",["","","",""],""],[],[]],\
	"O_officer_F",[["U_I_OfficerUniform",["NAM_Makarov","Makarov_Magazine","Makarov_Magazine"]],["",[]],["",[]],"H_Beret_blk","G_Aviator","",["",["","","",""],""],["",["","","",""],""],["",["","","",""],""],["ItemMap","ItemCompass","ItemWatch","ItemRadio"],[]],\
	"O_soldier_PG_F",[["U_BG_Guerilla2_3",["FirstAidKit","FirstAidKit","FirstAidKit"]],["V_BandollierB_oli",["AK_Magazine","AK_Magazine","AK_Magazine","AK_Magazine","MiniGrenade","MiniGrenade","MiniGrenade","MiniGrenade","AK_Magazine","MiniGrenade","MiniGrenade","SmokeShellRed"]],["",[]],"H_Beret_blk","G_Bandanna_blk","",["NAM_AK47S",["","","",""],"AK_Magazine"],["",["","","",""],""],["",["","","",""],""],["ItemMap","ItemCompass","ItemWatch","ItemRadio"],[]]\
]

params [["_mode", ""], ["_args",[]]];

["_mode(%1) _args(%2)", _mode, _args] call BIS_fnc_logFormat;

switch (_mode) do {
	/* Add weapons and items to Arsenal
	*/
	case "AddCargo" : {
		_args params [
			["_ammo", objNull, [objNull]],
			["_guns", [], [[]]],
			["_mags", [], [[]]],
			["_bags", [], [[]]],
			["_item", [], [[]]]
		];

		[_ammo, _guns, false, false] call BIS_fnc_addVirtualWeaponCargo;
		[_ammo, _mags, false, false] call BIS_fnc_addVirtualMagazineCargo;
		[_ammo, _bags, false, false] call BIS_fnc_addVirtualBackpackCargo;
		[_ammo, _item, false, false] call BIS_fnc_addVirtualItemCargo;

		true
	};

	case "Arsenal" : {
		_args params [
			["_crate", objNull, [objNull]],
			["_setup", "", [""]]
		];

		if (_setup isEqualTo "B_UNSG") then {
			["AddCargo",[_crate, B_UNSG_GUNS, B_UNSG_MAGS, B_UNSG_BAGS, B_UNSG_ITEM]] call SELF;
		};

		if (_setup isEqualTo "B_ARMA") then {
			["AddCargo",[_crate, B_ARMA_GUNS, B_ARMA_MAGS, B_ARMA_BAGS, B_ARMA_ITEM]] call SELF;
		};

		private "_trig"; // Arsenal 3D Icon
		_trig = createTrigger ["EmptyDetector",[0, 0, 0], false];
		_trig setTriggerStatements [
			"player in list fn_support_trig",
			"['ShowIcons', []] call VG_fnc_support",
			"['HideIcons', []] call VG_fnc_support"
		];
	};

	case "Loadout" : {
		_args params [
			["_unit", objNull],
			["_gear", ""]
		];

		if (_gear in LOADOUT_NAM) exitWith {
			// Define inventory loadout
			missionNamespace setVariable ["bis_fnc_saveInventory_data", LOADOUT_NAM];

			// Apply inventory loadout
			[_unit, [missionNamespace, _gear]] call BIS_fnc_loadInventory;
		};

		[_unit, configfile >> "CfgVehicles" >> "uns_army_8e"] call BIS_fnc_loadInventory;
	};

	case default {
		false
	};
};