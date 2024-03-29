// =============================================================================
// File Name = 'mp_d2c_tradespawns.gsc'
// Map Name = 'mp_d2c'
// =============================================================================
//
// This file was generated by the RotU admin development command 'Save Tradespawns'
//
// =============================================================================
//
// This file contains the tradespawns (equipment & weapon shop locations) for
// the map 'mp_d2c'
load_tradespawns()
{
    level.tradespawns = [];

    level.tradespawns[0] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[0].origin = (150.336,91.9626,-0.001);
    level.tradespawns[0].angles = (0,90.9064,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (386.102,-513.403,0.124999);
    level.tradespawns[1].angles = (0,272.807,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (-546.07,2013.18,-127.875);
    level.tradespawns[2].angles = (0,134.258,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (-257.581,1891.09,-128.001);
    level.tradespawns[3].angles = (0,272.972,0);
    level.tradespawns[4] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[4].origin = (1247.05,2433.74,96.125);
    level.tradespawns[4].angles = (0,269.247,0);
    level.tradespawns[5] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[5].origin = (1273.53,2082.42,-0.001);
    level.tradespawns[5].angles = (0,182.752,0);
    level.tradespawns[6] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[6].origin = (1228.16,736.503,0.058596);
    level.tradespawns[6].angles = (0,270.599,0);
    level.tradespawns[7] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[7].origin = (383.954,1408.87,-0.001);
    level.tradespawns[7].angles = (0,180.577,0);
    level.tradespawns[8] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[8].origin = (-664.643,1298.23,-111.875);
    level.tradespawns[8].angles = (0,180.577,0);
    level.tradespawns[9] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[9].origin = (1789.47,840.631,64.125);
    level.tradespawns[9].angles = (0,269.808,0);
    level.tradespawns[10] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[10].origin = (-1912.02,1169.12,32.125);
    level.tradespawns[10].angles = (0,179.231,0);
    level.tradespawns[11] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[11].origin = (-637.742,507.521,-0.001);
    level.tradespawns[11].angles = (0,48.3948,0);

    level.tradeSpawnCount = level.tradespawns.size;
}