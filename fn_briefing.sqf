/*	Briefing
		by Nikander

	Description:
		Display mission briefing on map display

	Parameter(s):
		NONE
	Returns:
		NONE
*/
player createDiaryRecord ["Diary", [
	"About",
	format["<img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\defend_ca.paa' width='24' height='24'/> Vigilance v0.26 by Nikander <marker name=''>www.cybercorps.org/vigilance</marker><br/><br/>FEATURES<br/><img image='\A3\ui_f\data\igui\cfg\picturem\command_ca.paa' width='24' height='24'/> Difficulty - adjustable enemy skill and speed of advance<br/><img image='\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa' width='24' height='24'/> Cache - destroy supplies to slow down enemy advance<br/><img image='\a3\Ui_f\data\GUI\Cfg\Notifications\tridentEnemy_ca.paa' width='24' height='24'/> Specop - assign to special covert operations<br/><img image='\A3\ui_f\data\map\vehicleicons\iconVehicle_ca.paa' width='24' height='24'/> Intel - look for intel files on the ground near killed enemy<br/><img image='\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\instructor_ca.paa' width='24' height='24'/> Talk - civilians near area of operations may have intel<br/><img image='\A3\UI_F\data\IGUI\Cfg\Actions\settimer_ca.paa' width='24' height='24'/> Sitrep - press %1 for estimated time of enemy attack<br/><img image='\A3\ui_f\data\map\vehicleicons\iconBackpack_ca.paa' width='24' height='24'/> Arsenal - manage custom weapon loadouts<br/><img image='\A3\ui_f\data\map\vehicleicons\pictureHeal_ca.paa' width='24' height='24'/> Revive - press ""SPACE"" to revive injured team members<br/><img image='\A3\Ui_f\data\GUI\Rsc\RscDisplayArsenal\Face_ca.paa' width='24' height='24'/> Groups - press %2 to form your own dynamic groups<br/><img image='\A3\ui_f\data\map\vehicleicons\iconSound_ca.paa' width='24' height='24' />Earplugs - press ""F1"" to use", actionKeysNames 'Watch', actionKeysNames 'TeamSwitch']
]];

player createDiaryRecord ["Diary",[
	"Mission",
	format["Enemy is occupying territory one square-kilometer grid in every <marker name='blufor_base'>%1 minutes.</marker> Your mission is to stop their advance.<br/><br/>* Talk to civilians for intel<br/>* Find intel around killed officers<br/>* <marker name='blufor_base'>Search and destroy</marker> enemy weapons cache", 5 * (paramsArray select 1) + 10]
]];

true