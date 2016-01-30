// Save gear inventory
[(_this select 0), [player, ""]] call BIS_fnc_saveInventory;

private "_boss"; // Save group leader status
_boss = if (["PlayerIsLeader",[(_this select 0)]] call BIS_fnc_dynamicGroups) then {true} else {false};
player setVariable ["_boss", _boss];