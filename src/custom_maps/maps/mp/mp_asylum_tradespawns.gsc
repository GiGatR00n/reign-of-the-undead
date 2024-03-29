// =============================================================================
// File Name = 'mp_asylum_tradespawns.gsc'
// Map Name = 'mp_asylum'
// =============================================================================
//
// This file was generated by the RotU admin development command 'Save Tradespawns'
//
// =============================================================================
//
// This file contains the tradespawns (equipment & weapon shop locations) for
// the map 'mp_asylum'
load_tradespawns()
{
    level.tradespawns = [];

    level.tradespawns[0] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[0].origin = (1063.75,797.383,-24.875);
    level.tradespawns[0].angles = (0,91.1866,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (1059.89,1126.42,-24.875);
    level.tradespawns[1].angles = (0,4.13097,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (-926.178,573.485,106.125);
    level.tradespawns[2].angles = (0,90.9888,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (-613.741,971.706,106.125);
    level.tradespawns[3].angles = (0,0.961302,0);
    level.tradespawns[4] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[4].origin = (-254.189,-396.902,106.125);
    level.tradespawns[4].angles = (0,0.499911,0);
    level.tradespawns[5] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[5].origin = (-1255.78,-48.1974,106.625);
    level.tradespawns[5].angles = (0,2.12036,0);
    level.tradespawns[6] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[6].origin = (368.219,-71.5875,-21.4366);
    level.tradespawns[6].angles = (0.00723454,180.538,0);
    level.tradespawns[7] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[7].origin = (681.003,-314.098,-21.131);
    level.tradespawns[7].angles = (359.907,359.434,0);

    level.tradeSpawnCount = level.tradespawns.size;
}
