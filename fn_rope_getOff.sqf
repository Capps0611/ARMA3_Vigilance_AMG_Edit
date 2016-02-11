//
_rope = (_this select 3 select 0);
_a1 = (_this select 3 select 1);
player ropeDetach _rope; 
removeAllActions player;

_a2 = player addAction["Get On Rope","fn_rope_getOn.sqf",[_rope,_a2],0,false,true,"","_target == player"];