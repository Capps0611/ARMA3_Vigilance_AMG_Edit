
_veh = _this select 3;
_rope = (ropes _veh) select 0;
_anyRopes = (ropes _veh);

if(count _anyRopes > 0 ) then
{
	ropeUnwind [ _rope, 1, ropeLength (_rope) + 5];
}else
{
	_rope = ropeCreate [_veh, [-1.6,0,0], 5]; 
};