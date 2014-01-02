/******************************************************************************
 *    Reign of the Undead, v2.x
 *
 *    Copyright (c) 2010-2014 Reign of the Undead Team.
 *    See AUTHORS.txt for a listing.
 *
 *    Permission is hereby granted, free of charge, to any person obtaining a copy
 *    of this software and associated documentation files (the "Software"), to
 *    deal in the Software without restriction, including without limitation the
 *    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *    sell copies of the Software, and to permit persons to whom the Software is
 *    furnished to do so, subject to the following conditions:
 *
 *    The above copyright notice and this permission notice shall be included in
 *    all copies or substantial portions of the Software.
 *
 *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *    SOFTWARE.
 *
 *    The contents of the end-game credits must be kept, and no modification of its
 *    appearance may have the effect of failing to give credit to the Reign of the
 *    Undead creators.
 *
 *    Some assets in this mod are owned by Activision/Infinity Ward, so any use of
 *    Reign of the Undead must also comply with Activision/Infinity Ward's modtools
 *    EULA.
 ******************************************************************************/
/// @file _map_util.gsc Catches some ROZO map calls and hands them off to _umi.gsc

#include scripts\include\utility;

placeShops(weapon, shop)
{
    debugPrint("in _map_utils::placeShops()", "fn", level.lowVerbosity);

    maps\mp\_umi::placeShops(weapon, shop);
}

addDefaultZombieSpawns()
{
    debugPrint("in _map_utils::addDefaultZombieSpawns()", "fn", level.lowVerbosity);

    maps\mp\_umi::addDefaultZombieSpawns();
}

addDefaultPlayerSpawns()
{
    debugPrint("in _map_utils::addDefaultPlayerSpawns()", "fn", level.lowVerbosity);

    // Do nothing
}

zombieDefaultTarget(position)
{
    debugPrint("in _map_utils::zombieDefaultTarget()", "fn", level.lowVerbosity);

    // Do Nothing
}

convertWaypoints()
{
    debugPrint("in _map_utils::convertWaypoints()", "fn", level.lowVerbosity);

    maps\mp\_umi::convertWaypoints();
}

setPlayerModels()
{
    debugPrint("in _map_utils::setPlayerModels()", "fn", level.lowVerbosity);

    // Do Nothing
}

mapThink()
{
    debugPrint("in _map_utils::mapThink()", "fn", level.lowVerbosity);

    // Do Nothing
}
