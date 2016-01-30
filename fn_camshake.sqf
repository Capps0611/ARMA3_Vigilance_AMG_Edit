/*	Camshake
		by Nikander

	Description:
		Camera shaking near explosion

	Parameter(s):
		0: ARRAY - position

	Returns:
		none
*/

if (_this distance2D player > 200) exitWith {false};

enableCamShake true;
addCamShake [2, 40, 5];