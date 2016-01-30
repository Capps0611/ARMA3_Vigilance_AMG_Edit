// Prevent script running at mission start in editor single player mode
if (!isMultiplayer) exitWith {"onPlayerRespawn.sqf exit on single player" call BIS_fnc_error; false};

// Don't execute script if player is waiting to be revived
if (player getVariable ["BIS_revive_incapacitated", false]) exitWith {
	"onPlayerRespawn exit on incapacitated" call BIS_fnc_log;
	false
};

playMusic "EventTrack02_F_Curator";

[["Vigilance","Orders"], nil, nil, nil, nil, nil, nil, true] call BIS_fnc_advHint;

// Load gear inventory
[player, [player, ""]] call BIS_fnc_loadInventory;

if (player getVariable ["_boss", false]) then { // Restore group leader
	[group player, player] remoteExec ["selectLeader", group player];
};