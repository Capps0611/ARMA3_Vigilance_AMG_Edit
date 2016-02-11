
_veh = (_this select 0);

_veh addEventHandler ["GetIn", {player ropeDetach (ropes vehicle player select 0); removeAllActions player}];
_veh addAction["<t color=""#00FF33"">"+"Lower Rope", "fn_rope_lower.sqf",_veh,0,false,false,""," driver  _target == _this"];
_veh addAction["<t color=""#FCC200"">"+"Raise Rope", "fn_rope_raise.sqf",_veh,0,false,false,""," driver  _target == _this"];
_veh addAction["<t color=""#00F2FF"">"+"Attach To Rope", "fn_rope_attachFromHeli.sqf",_veh,0,false,true,""," driver  _target != _this"];
_veh addAction["<t color=""#F71919"">"+"Detach Rope", "fn_rope_detachFromHeli.sqf",_veh,0,false,true,""," driver  _target == _this"];


//"<t color="#F71919">"+