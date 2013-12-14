// =============================================================================
// File Name = 'mp_nuketown_tradespawns.gsc'
// Map Name = 'mp_nuketown'
// =============================================================================
//
// This file was generated by the RotU admin development command 'Save Tradespawns'
//
// =============================================================================
//
// This file contains the tradespawns (equipment & weapon shop locations) for
// the map 'mp_nuketown'
load_tradespawns()
{
    level.tradespawns = [];

    level.tradespawns[0] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[0].origin = (-1695.83,634.543,16.001);
    level.tradespawns[0].angles = (0,158.577,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (-1796.91,-158.985,16);
    level.tradespawns[1].angles = (0,161.691,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (271.161,-348.389,16);
    level.tradespawns[2].angles = (0,11.0797,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (483.287,667.354,23);
    level.tradespawns[3].angles = (0,246.006,0);
    level.tradespawns[4] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[4].origin = (1303.09,81.2915,24.125);
    level.tradespawns[4].angles = (0,105.342,0);
    level.tradespawns[5] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[5].origin = (1178.1,347.876,24.125);
    level.tradespawns[5].angles = (0,105.051,0);

    level.tradeSpawnCount = level.tradespawns.size;
}