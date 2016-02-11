_veh = _this select 3;
_rope = (ropes _veh) select 0;
_anyRopes = (ropes _veh);

if(count _anyRopes > 0 ) then
{
	moveOut player;
	[player,[0,0,0],[0,0,-1]] ropeAttachTo _rope;
	_a1 = player addAction["Get Off Rope","fn_rope_getOff.sqf",[_rope,_a1],0,false,true,"","_target == player"];
}else
{
	moveOut player;
	_rope = ropeCreate [_veh, [-1.6,0,0], player, [0,0,0], 4];
	_a1 = player addAction["Get Off Rope","fn_rope_getOff.sqf",[_rope,_a1],0,false,true,"","_target == player"];
};