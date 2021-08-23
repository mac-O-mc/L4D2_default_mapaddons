// The style I use here could be cool to inspect for people
// Oh also, have fun inspecting many iterating loops and enum blocks! I'll use setconsttable() / getconsttable() next time instead

Msg("VSCRIPT: Running c12m4_barn_scriptedmode SCRIPT; Orin's!\n")

const ADDON_PREFIX = "_ralimu_survival"
//------------------
//-    GLOBAL A    -
//  Player Movement
//------------------
enum MoveType
{
	Duck = "Duck",
	Walk = "Walk",
	Jump = "Jump"
}
// All mins must be negative while maxs must be positive
local trigmove_data =
[
	// Spawn - House's Insides
	//// Radio-side Residence
	{ movetype = MoveType.Duck, mins = "-6 -29 -38", maxs = "6 29 38", origin = Vector( 11044, -6000, -9 ).ToKVString() },
	//// GAMER SETUP
	{ movetype = MoveType.Duck, mins = "-6 -29 -38", maxs = "6 29 38", origin = Vector( 11044, -5720, -9 ).ToKVString() },
	// Spawn - House's Unders
	//// Supports of the Underneathes
	{ movetype = MoveType.Duck, mins = "-48 -284 -44", maxs = "48 284 44", origin = Vector( 10680, -5804, -132 ).ToKVString() },

	// Bridge - Worned Station
	{ movetype = MoveType.Duck, mins = "-60 -2 -58", maxs = "60 2 58", origin = Vector( 10784, -4032, -4 ).ToKVString() },
	{ movetype = MoveType.Duck, mins = "-2 -40 -58", maxs = "2 40 58", origin = Vector( 10718, -4076, -4 ).ToKVString() },

	// Bridge - Train Carts
	{ movetype = MoveType.Walk, mins = "-4 -24.5 -88", maxs = "29 24.5 0", origin = Vector( 10521.8, -4123.47, 26 ).ToKVString(), angles = QAngle(0, -32.5, 0) },
	{ movetype = MoveType.Walk, mins = "-29 -24.5 -88", maxs = "4 24.5 0", origin = Vector( 10403.1 -4045.48 24 ).ToKVString(), angles = QAngle(0, -32.5, 0) },

]
for (local i = 0; i < trigmove_data.len(); i++)
{
	local trigmove = trigmove_data[i]
	local trigmove_entname = ADDON_PREFIX+"_trigmove_global"+i
	make_trigmove( trigmove_entname, trigmove.movetype, trigmove.mins, trigmove.maxs, trigmove.origin)
	if( "angles" in trigmove )
	{
		// Scary Horrible Hack
		//// we can't do this the proper way cause the entity spawns in with a delay
		//// 'solid 3' also resets on new map
		//// (not like we desperately need this lol)
		EntFire(g_UpdateName+trigmove_entname, "AddOutput", "angles "+trigmove.angles.ToKVString(), 10)
		EntFire(g_UpdateName+trigmove_entname, "AddOutput", "solid 3", 10)
	}
}

//--------------
//-  GLOBAL B  -
//   Blockers
//--------------
// Why here and not in the survival EGroup script? To try out the library!
enum BlockerType
{
	Everyone = "Everyone",
	Survivors = "Survivors",
	SI_Players = "SI Players",
	SI_Players_and_AI = "SI Players and AI",
	All_and_Physics = "All and Physics"
}
// All mins must be negative while maxs must be positive if the blocktype isn't "BlockerType.All_and_Physics"
local blocker_data =
[
	// Spawn House - House's Insides
	//// Radio-side Residence
	{ blocktype = BlockerType.All_and_Physics, mins = "-1.5 -30 -12.5", maxs = "1.5 30 12.5", origin = Vector(11032, -6000, -56).ToKVString(), angles = "45 0 0" },
	//// GAMER SETUP
	{ blocktype = BlockerType.All_and_Physics, mins = "-1.5 -30 -12.5", maxs = "1.5 30 12.5", origin = Vector(11032, -6000, -56).ToKVString(), angles = "45 0 0" },

]
for (local i = 0; i < blocker_data.len(); i++)
{
	local blocker = blocker_data[i]
	if( "angles" in blocker )
		make_clip( ADDON_PREFIX+"_blocks_global"+i, blocker.blocktype, true, blocker.mins, blocker.maxs, blocker.origin, blocker.angles)
	else
		make_clip( ADDON_PREFIX+"_blocks_global"+i, blocker.blocktype, true, blocker.mins, blocker.maxs, blocker.origin)
}

//--------------
//-  GLOBAL C  -
//  Attr Region
//--------------
// First 4 attributes are only intuition references
//// Enums can't include bitshifts, or numbers wrapped in brackets, sadly
enum NavAttr
{
	CROUCH = 1,				// 1 << 1
	JUMP = 2,				// 1 << 2
	PRECISE = 4,			// 1 << 3
	NO_JUMP = 8,			// 1 << 4

	DONT_HIDE = 512,		// 1 << 9
	MOB_ONLY = 131072,		// 1 << 17
}
enum NavSpawnAttr
{
	UNKNOWN0 = 1,			// 1 << 1
	EMPTY = 2,				// 1 << 2
	STOP_SCAN = 4,			// 1 << 3
	UNKNOWN1 = 8,			// 1 << 4

	NOT_CLEARABLE = 1024,	// 1 << 10
	OBSCURED = 4096,		// 1 << 12
	NOTHREAT = 524288,		// 1 << 19
}
// All mins must be negative while maxs must be positive
local attrRegion_data =
[
	{
		attrbits = NavAttr.DONT_HIDE|NavAttr.MOB_ONLY,
		spawnattrbits = NavSpawnAttr.EMPTY|NavSpawnAttr.NOT_CLEARABLE|NavSpawnAttr.NOTHREAT,
		extent = Vector(720, 1732, 341),
		origin = Vector(9680, -4638, 789)
	},
/*	{
		spawnattrbits = NavSpawnAttr.OBSCURED,
		extent = Vector(720, 1732, 341),
		origin = Vector(9680, -4638, 789),
		removeattrs = true
	}, */
	{ damaging = true, extent = Vector(88, 90, 112), origin = Vector(11160, -3926, -464) }
]
for (local i = 0; i < attrRegion_data.len(); i++)
{
	local attrRegion = attrRegion_data[i]
	local attrRegion_ENT = SpawnEntityFromTable( "script_nav_attribute_region",
	{
		targetname = ADDON_PREFIX+"_attrregion_global"+i,

		extent = attrRegion.extent,
		origin = attrRegion.origin,
	})

	// Pre-processing variables
	local use_attrs = false
	local use_spawnattrs = false
	local do_damaging = false
	local do_removeattrs = false

	if( "attrbits" in attrRegion )
		use_attrs = true;
	if( "spawnattrbits" in attrRegion )
		use_spawnattrs = true;
	if( "damaging" in attrRegion )
		do_damaging = true;
	if( "removeattrs" in attrRegion )
		do_removeattrs = true;

	// Process them!
	local areas = {};
	NavMesh.GetNavAreasOverlappingEntityExtent(attrRegion_ENT, areas);
	//// Reminds me of parsers's workflow for some reason
	if( use_attrs )
	{
		if( do_removeattrs )
			foreach( area in areas )
				area.RemoveAttributes( attrRegion.attrbits );
		else
			foreach( area in areas )
				area.SetAttributes( attrRegion.attrbits );
	}
	if( use_spawnattrs )
	{
		if( do_removeattrs )
			foreach( area in areas )
				area.RemoveSpawnAttributes( attrRegion.spawnattrbits );
		else
			foreach( area in areas )
				area.SetSpawnAttributes( attrRegion.spawnattrbits );
	}
	if( do_damaging )
	{
		foreach( area in areas )
			area.MarkAsDamaging( 1 << 16 );
	}
}

//----------------
// -  GLOBAL D  -
// Ladder Normals
//----------------
// Find ladders and do stuff with it ('AddOutput' lmao)

local ladder_find_data =
[
	// Bridge - Train Carts
	{ VSSM = Vector(10521.8, -4123.47, 26).ToKVString(), normal = Vector(0, 1, 1) },
	{ VSSM = Vector(10403.1, -4045.48, 24).ToKVString(), normal = Vector(0, 1, 1) },
]
for (local i = 0; i < ladder_find_data.len(); i++)
{
	local ladderdata = ladder_find_data[i]
	local ladder = find_ladder( ladderdata.VSSM )
	NetProps.SetPropVector( ladder, "m_climbableNormal", ladderdata.normal )
}

if( Director.GetGameModeBase() != "survival" )
{
	//------------------
	//- Non-Survival A -
	//    Nav Block
	//------------------
	enum TeamNum
	{
		Everyone = "Everyone",
		Survivors = "Survivors",
		Infected = "Infected"
	}
	// All mins must be negative while maxs must be positive
	local navblock_data =
	[
		// Bridge - Barricades
		//// Barricade Beyondance
		{ teamToBlock = TeamNum.Everyone, mins = "-4 -4 -8", maxs = "4 4 8", origin = Vector( 10380, -3564, -64 ).ToKVString() },
		{ teamToBlock = TeamNum.Everyone, mins = "-4 -4 -8", maxs = "4 4 8", origin = Vector( 10508, -3508, -56 ).ToKVString() },
		//// Table Top
		{ teamToBlock = TeamNum.Everyone, mins = "-61 -16 -6", maxs = "61 16 6", origin = Vector( 10444, -3648, -18 ).ToKVString() },

		// Bridge - Worned Station
		//// Edged Cliffside Passage
		////// Side with no fence
		{ teamToBlock = TeamNum.Everyone, mins = "-4 -4 -8", maxs = "4 4 8", origin = Vector( 11272, -4513, -352 ).ToKVString() },
		////// Side with fences
		{ teamToBlock = TeamNum.Everyone, mins = "-4 -4 -8", maxs = "4 4 8", origin = Vector( 11272, -4582, -352 ).ToKVString() },
	]
	for (local i = 0; i < navblock_data.len(); i++)
	{
		local navblock = navblock_data[i]
		make_navblock( ADDON_PREFIX+"_navblocks_coop"+i, navblock.teamToBlock, "Apply", navblock.mins, navblock.maxs, navblock.origin)
	}

	// Scope BREAK
	return;
}
Msg("***********************************\n")
Msg("**  Ralimu's C12M4 Survival DLC  **\n")
Msg("**       scriptedmode_addon      **\n")
Msg("***********************************\n")

// Spawn our entity group!
IncludeScript("entitygroups/c12m4_ralimu_group")
IncludeScript("entitygroups/c12m4_ralimu_car_group")
SpawnSingle( C12M4RalimuSurvival.GetEntityGroup() )
SpawnSingle( C12M4RalimuSurvivalCar.GetEntityGroup() )

// Neat fade-in.. to hide the teleport
local FADE_ALPHA = 255
local FADE_TIME = 2
local FADE_HOLD = 1
local FADEFLAG_FADEIN = (1 << 0)

local player = null
while( player = Entities.FindByClassname(player,"player") )
{
	ScreenFade(player, 0, 0, 0, FADE_ALPHA, FADE_TIME, FADE_HOLD, FADEFLAG_FADEIN)
}
// OK, we just did the screenfade. Let's teleport the players now
TeleportPlayersToStartPoints("ralimu_survival_positions") // on mapspawn
TeleportPlayersToStartPoints("_1_ralimu_survival_positions") // on non-mapspawn... Thanks egroups for forcefully doing this :/

function OnScriptEvent_ralimu_survival_post_entity(params)
{
	Convars.SetValue("scavenge_item_respawn_delay", 20)
	//--------------
	//- Exihibit A -
	//   Removal
	//--------------
	local EntitiesIHate =
	[
		"anv_mapfixes_eventskip_commonhopa",
		"anv_mapfixes_eventskip_commonhopb",
		"anv_mapfixes_eventskip_fence_trigonce",
		"window_trigger",

		// These are minor
		"onslaught",
		"zombie_spawn_relay",
		"spawn_zombie_run",
		"spawn_zombie_end",
	]
	foreach(classname in EntitiesIHate)
	{
		local ent = null
		while( ent = Entities.FindByName(Entities.First(), classname) )
			ent != null ? ent.Kill() : 0
	}
	// Some have NO NAMES!!! Thus I must do this
	local radius = 20
	local ent = null
	if( ent = Entities.FindByClassnameNearest("trigger_once", Vector(10453, -3702, -16), radius) )
		ent.Kill()
	if( ent = Entities.FindByClassnameNearest("trigger_once", Vector(10456, -728, 80), radius) )
		ent.Kill()

	//--------------
	//- Exihibit B -
	//   Ladders
	//--------------
	// NetProps.GetPropVector(Ent(742),"m_vecSpecifiedSurroundingMaxs")
	//
	// anv_mapfixes does not use the above netprop for critial reasons, thus fetching this is unreliable even for us!
	//// It uses a custom math sequence instead. See 'anv_functions.nut' for more info!
	//
	/*
	**	Facing towards the ladder's "TOOLS/CLIMB_VERSUS" texture this is how
	**	the Normals work -- there is a rough tolerance of 0.2 on the "raycast"
	**	that determines the Normal, so 0.8 and 1.0 may yield identical results:
	**
	**	Orin: This does not mean which side will be climbable, but rather at which brush side it starts the trace at, seemingly
	*/
	enum LadderNormal
	{
		North = "0 1 0",
		South = "0 -1 0",
		West = "1 0 0",
		East = "-1 0 0"
	}
	enum TeamNumID
	{
		Everyone = 0,
		Survivors = 2,
		Infected = 3
	}
	// Clone ladders to make new ones

	local VSSM_1 = Vector(8357, -9218, 407)
	local VSSM_2 = Vector(8042, -9584, 338)

	local ladder_data =
	[
		// Pre-Train Station - Cliff Drop
		{ VSSM = "10528, -7510, 10", originoffset = Vector(-4, 3972, -32).ToKVString(), angles = "0 0 0", normal = LadderNormal.North, teamnum = TeamNumID.Infected },

		// Bridge - Worned Station
		//// Edged Cliffside Passage
		////// Side with no fence, from BOTTOM to TOP
		{ VSSM = VSSM_1.ToKVString(), originoffset = Vector(2916, 4705, -681).ToKVString(), angles = "0 0 0", normal = LadderNormal.West, teamnum = TeamNumID.Everyone },
		{ VSSM = VSSM_2.ToKVString(), originoffset = Vector(3212, 5074, -498).ToKVString(), angles = "0 0 0", normal = LadderNormal.West, teamnum = TeamNumID.Everyone },
		////// Side with fences, from BOTTOM to TOP
		{ VSSM = VSSM_1.ToKVString(), originoffset = Vector(2916, 4642, -681).ToKVString(), angles = "0 0 0", normal = LadderNormal.West, teamnum = TeamNumID.Everyone },
		{ VSSM = VSSM_2.ToKVString(), originoffset = Vector(3212, 5005, -498).ToKVString(), angles = "0 0 0", normal = LadderNormal.West, teamnum = TeamNumID.Everyone },
	]
	for (local i = 0; i < ladder_data.len(); i++)
	{
		local ladder = ladder_data[i]
		make_ladder( ADDON_PREFIX+"_ladders"+i, ladder.VSSM, ladder.originoffset, ladder.angles, ladder.normal, ladder.teamnum)
	}

	//--------------
	//- Exihibit C -
	//   Blockers
	//--------------
	// Why here and not in the survival EGroup script? To try out the library!
	enum BlockerType
	{
		Everyone = "Everyone",
		Survivors = "Survivors",
		SI_Players = "SI Players",
		SI_Players_and_AI = "SI Players and AI",
		All_and_Physics = "All and Physics"
	}
	// All mins must be negative while maxs must be positive if the blocktype isn't "BlockerType.All_and_Physics"
	local blocker_data =
	[
		// Pre-Train Station - Cliff Drop
		{ blocktype = BlockerType.Survivors, mins = "-32.0 -376.0 -800.0", maxs = "32.0 376.0 800.0", origin = Vector(10240, -8280, 928).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-26 -80 -784", maxs = "26 80 784", origin = Vector(10298, -8304, 944).ToKVString() },

		// Bridge - Barricade Beyondance
		{ blocktype = BlockerType.Survivors, mins = "-111 -424 -68", maxs = "111 424 68", origin = Vector(10453, -3290, 328).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-111 -352 -128", maxs = "111 352 128", origin = Vector(10455, -3216, 82).ToKVString() },

		// Train Station - Roof
		{ blocktype = BlockerType.Survivors, mins = "-256.0 -88.0 800.0", maxs = "256.0 88.0 800.0", origin = Vector(10880, -7648, 928).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-256.0 -680.0 -728.0", maxs = "256.0, 680.0, 728.0", origin = Vector(10880, -8416, 1000).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-232 -208 -780", maxs = "232 208 780", origin = Vector(11368, -8048, 948).ToKVString() },

		// Train Station - Station Checkpoint
		//// Cliffside
		{ blocktype = BlockerType.Survivors, mins = "-132 -196 -800", maxs = "132 196 800", origin = Vector(10140, -7708, 964).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-96 -76 -748", maxs = "96 76 748", origin = Vector(10104, -7436, 980).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-88 -64 -744", maxs = "88 64 744", origin = Vector(10096, -7296, 984).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-76 -96 -744", maxs = "76 96 744", origin = Vector(10084, -7136, 984).ToKVString() },

		//// Crosser Passer
		{ blocktype = BlockerType.Survivors, mins = "-232.0 -68.0 -748.0", maxs = "232.0 68.0 748.0", origin = Vector(10432, -7452, 980).ToKVString() },

		// Bridge - Worned Station
		//// Roof
		////// Pair #1
		{ blocktype = BlockerType.Survivors, mins = "-200.0 -12.0 -766.0", maxs = "200.0 12.0 766.0", origin = Vector(11048, -4020, 962).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-200.0 -12.0 -766.0", maxs = "200.0 12.0 766.0", origin = Vector(11048, -4644, 962).ToKVString() },
		////// Pair #2
		{ blocktype = BlockerType.Survivors, mins = "-12.0 -324.0 -766.0", maxs = "12.0 324.0 766.0", origin = Vector(10836, -4332, 962).ToKVString() },
		{ blocktype = BlockerType.Survivors, mins = "-12.0 -324.0 -766.0", maxs = "12.0 324.0 766.0", origin = Vector(11260, -4332, 962).ToKVString() },

		//// Edged Cliffside Passage
		{ blocktype = BlockerType.Survivors, mins = "-36.0 -20.0 -936.0", maxs = "36.0 20.0 936.0", origin = Vector(11430, -4524, 792).ToKVString() },
	]
	for (local i = 0; i < blocker_data.len(); i++)
	{
		local blocker = blocker_data[i]
		if( "angles" in blocker )
			make_clip( ADDON_PREFIX+"_blockers"+i, blocker.blocktype, true, blocker.mins, blocker.maxs, blocker.origin, blocker.angles)
		else
			make_clip( ADDON_PREFIX+"_blockers"+i, blocker.blocktype, true, blocker.mins, blocker.maxs, blocker.origin)
	}

	//--------------
	//- Exihibit D -
	//  FUNC_BRUSH
	//--------------
	local brush_data =
	[
		{ mins = "-46 -14 -61.5", maxs = "46 14 61.5", origin = Vector(10418, -3594, -9.65).ToKVString() }
		{ mins = "-46 -14 -61.5", maxs = "46 14 61.5", origin = Vector(10498, -3554, -9.65).ToKVString() }
	]
	for (local i = 0; i < brush_data.len(); i++)
	{
		local brush = brush_data[i]
		make_brush( ADDON_PREFIX+"_brushes"+i, brush.mins, brush.maxs, brush.origin)
	}

	//--------------
	//- Exihibit E -
	//  Nav Blocks
	//--------------
	// Why here and not in the survival EGroup script? To try out the library!
	enum TeamNum
	{
		Everyone = "Everyone",
		Survivors = "Survivors",
		Infected = "Infected"
	}
	// All mins must be negative while maxs must be positive
	local navblock_data =
	[
		// Bridge - Barricade
	//	{ teamToBlock = TeamNum.Everyone, mins = "-80 -36 -62.5", maxs = "80 36 62.5", origin = Vector( 10454, -3644, -10 ).ToKVString() },
		// Table Top's Bottom
		{ teamToBlock = TeamNum.Everyone, mins = "-56 -20 -24", maxs = "56 20 24", origin = Vector( 10444, -3648, -48 ).ToKVString() },
		//// FUNC_BRUSH's data (guess who)
		{ teamToBlock = TeamNum.Everyone, mins = "-46 -14 -61.5", maxs = "46 14 61.5", origin = Vector(10418, -3594, -9.65).ToKVString() },
		{ teamToBlock = TeamNum.Everyone, mins = "-46 -14 -61.5", maxs = "46 14 61.5", origin = Vector(10498, -3554, -9.65).ToKVString() },

		// Train Station - Cliffside
		{ teamToBlock = TeamNum.Survivors, mins = "-82.0 -376.0 -80.0", maxs = "82.0 376.0 80.0", origin = Vector( 10242, -8280, 176 ).ToKVString() },

		// Train Station - Wastelands Blocker
	//	{ teamToBlock = TeamNum.Everyone, mins = "-82.0 -376.0 -80.0", maxs = "82.0 376.0 80.0", origin = Vector( 10242, -8280, 176 ).ToKVString() },
	]
	for (local i = 0; i < navblock_data.len(); i++)
	{
		local navblock = navblock_data[i]
		make_navblock( ADDON_PREFIX+"_navblocks"+i, navblock.teamToBlock, "Apply", navblock.mins, navblock.maxs, navblock.origin)
	}

	/*
	//--------------
	//- Exihibit F -
	//   Trigpush
	//--------------
	enum ActivatorFilter
	{
		Everything = "Everything",
		Survivor = "Survivor",
		Infected = "Infected",
		Physics = "Physics"
	}
	// All mins must be negative while maxs must be positive
	local trigpush_data =
	[
		// Bridge - Barricade
		{ filter = ActivatorFilter.Survivor, pushdir = "0 270 0", speed = 250, mins = "-104 -56 -151.5", maxs = "104 56 151.5", origin = Vector( 10456, -3624, 80 ).ToKVString() },
	]
	for (local i = 0; i < trigpush_data.len(); i++)
	{
		local trigpush = trigpush_data[i]
		make_trigpush( ADDON_PREFIX+"_trigpush"+i, trigpush.filter, trigpush.speed, trigpush.pushdir, trigpush.mins, trigpush.maxs, trigpush.origin)
	}*/
}
