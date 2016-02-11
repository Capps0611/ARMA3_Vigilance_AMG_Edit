
_veh = _this select 3;
_rope = (ropes _veh) select 0;
_anyRopes = (ropes _veh);

if(count _anyRopes > 0 ) then
{
	ropeDestroy _rope;
};