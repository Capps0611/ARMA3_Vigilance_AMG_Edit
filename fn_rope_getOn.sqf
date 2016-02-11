
_rope = (_this select 3 select 0);
_a2 = (_this select 3 select 1);
 _meters = player distance2D _rope;
if(_meters <= 10)then
{
	[player,[0,0,0],[0,0,-1]] ropeAttachTo _rope;
	removeAllActions player;
	_a1 = player addAction["Get Off Rope","fn_rope_getOff.sqf",[_rope,_a1],0,false,true,"","_target == player"];
}
