/******************************************************************************
    Reign of the Undead, v2.x

    Copyright (c) 2010-2013 Reign of the Undead Team.
    See AUTHORS.txt for a listing.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    The contents of the end-game credits must be kept, and no modification of its
    appearance may have the effect of failing to give credit to the Reign of the
    Undead creators.

    Some assets in this mod are owned by Activision/Infinity Ward, so any use of
    Reign of the Undead must also comply with Activision/Infinity Ward's modtools
    EULA.
******************************************************************************/

#include scripts\include\data;
#include scripts\include\hud;
#include scripts\include\utility;

init()
{
    debugPrint("in _barricades::init()", "fn", level.nonVerbose);

    precachemodel("com_barrel_metal");
    precachemodel("com_barrel_biohazard");
    precachemodel("com_barrel_benzin");
    level.dynamic_barricades = [];

    PreCacheTurret("saw_bipod_stand_mp");
    precachemodel("weapon_saw_MG_setup");
    level.barrels[0] = 0;
    level.barrels[1] = 0; // MG + Barrel
    level.barrels[2] = 0;
    level.barricades = [];

    // Create the MG+Barrels for this game
    level.MgBarrels = [];
    thread createMgBarrels();
}

/**
 * @brief Gives a regular or exploding barrel to a player
 *
 * @param type integer The type of barrel. \c type 0 is regular barrel, \c type 2 is exploding barrel
 *
 * @returns nothing
 */
giveBarrel(type)
{
    debugPrint("in _barricades::giveBarrel()", "fn", level.nonVerbose);

    if (!isdefined(type)) {type = 0;}

    level.barrels[type]++;

    self.carryObj = spawn("script_model", (0,0,0));
    self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
    self.carryObj.master = self;

    self.carryObj linkto(self);
    self.carryObj.type = type;

    // track whether the barrel is currently being killed
    self.carryObj.isBeingKilled = false;

    self.carryObj.maxhp = 100;
    if (self.carryObj.type == 1) {
        // MG+Barrels are handled in createMgBarrel() now
    } else if (self.carryObj.type == 2) {// Exploding Barrel
        self.carryObj setmodel("com_barrel_benzin");
    } else { // regular Barrel
        self.carryObj setmodel("com_barrel_metal");
    }
    self.carryObj.hp = self.carryObj.maxhp;

    self.canUse = false;
    self disableweapons();
    self thread placeBarrel();
}

makeBarricade()
{
    debugPrint("in _barricades::makeBarricade()", "fn", level.lowVerbosity);

    self.bar_type = 0;
    self.workingPart = 0;
    self.isUsable = 0;
}

/**
 * @brief Places a barrel a player is carrying in an acceptable spot in the map
 *
 * @returns nothing
 */
placeBarrel()
{
    debugPrint("in _barricades::placeBarrel()", "fn", level.nonVerbose);

    self endon("death");
    self endon("disconnect");

    // self is player
    wait 1;
    while (1) {
        if (self attackbuttonpressed()) {
            newpos = PlayerPhysicsTrace(self.carryObj.origin, self.carryObj.origin - (0,0,1000));

            if ((BulletTrace(self GetEye(), newpos, false, self.carryObj)["fraction"] == 1) &&
                (BulletTrace(self GetEye(), newpos + (0,0,48), false, self.carryObj)["fraction"] == 1) &&
                (BulletTrace(newpos, newpos + (0,0,48), false, self.carryObj)["fraction"] == 1 ))
            {
                self.carryObj unlink();
                wait 0.1;

                self.carryObj.bar_type = 1;
                self.carryObj.origin = newpos;
                self.carryObj.angles = self.angles;
                level.dynamic_barricades[level.dynamic_barricades.size] = self.carryObj;

                if (self.carryObj.type == 1) {
                    self.carryObj thread watchMGBarrel();
                }
                self.carryObj = undefined;

                iprintln( "^2"+ self.name + " ^2placed an obstacle." );

                self.canUse = true;
                self enableweapons();
                return;
            } else {
                self iprintlnbold("^1Can not place obstacle here!");
                wait 1;
            }
        }
        wait .05;
    }
}


/**
 * @brief Creates one barrel-mounted machine gun
 *
 * @bug FIXED: ROTU 2.1 disconnected clients sometimes when MG+Barrels were placed.
 * When the clients were disconnected, there was no debug information written to
 * console_mp.log or to the chat log file, regardless of how many debugPrint()
 * statements I littered the code with.
 *
 * After exhaustive debugging, and reimplementing the MG+Barrels from scratch,
 * I think the original bug had to do with Bipo not link()'ing the turret to the
 * barrel, concurrent with an edge-case bug inside Activision's binary likely
 * dealing with the *exact* placement of the MG on the barrel.
 *
 * The original code created and destroyed barrels and machine guns on demand,
 * so when the error occurred, it happened mid-game and kicked all the players
 * out.  If you could rejoin the game before it detected everyone was gone, the
 * game could continue, and the MG+Barrel that it kicked everyone for would be in
 * the game as expected.
 *
 * In addition to fixing some logic errors and race conditions in the original
 * code, I also implemented new MG+Barrels.  The new approach creates the maximum
 * number of MG+Barrels during initialization.  It then hides them so they can't
 * be seen.  To make sure the 'Press F to Use' usable isn't seen by players when
 * the MG+Barrels are hidden, they are positioned -5,000 game distance units below
 * the game-world origin--kind of hackish, but it seems to work OK.
 *
 * When a MG+Barrel is purchased, the code finds a deployable MG+Barrel, shows it,
 * then gives it to the player so it can be placed quite similarly to the original
 * code. When the MG+Barrel is destroyed, the code hides it, moves it, and marks
 * it as deployable again.  This approach prevents any spawning calls mid-game, so
 * if there is an error, it will happen during game initialization, and it won't
 * kick any players.
 *
 * The downside is that the player must press F to drop the machine gun, even
 * after it has been destroyed.  That is less than ideal, but I'll happily take
 * that inconvenience to prevent players from being disconnected mid-game.
 *
 * @returns nothing
 */
createMgBarrel()
{
    debugPrint("in _barricades::createMgBarrel()", "fn", level.nonVerbose);

    // Put the MG+Barrel in an out-of-the-way spot to prevent the 'Press F to use'
    // usable from showing up
    origin = (0,0,-5000);

    // Spawn the barrel
    barrel = spawn("script_model", origin);
    barrel.origin = origin;
    barrel.type = 1;
    barrel setmodel("com_barrel_biohazard");
    barrel.maxhp = 120;
    barrel.hp = barrel.maxhp;

    // Spawn the MG
    barrel.turret = SpawnTurret("turret_mp", barrel.origin + (0,0,48) + anglestoforward(barrel.angles)*-6, "saw_bipod_stand_mp");
    barrel.turret LinkTo(barrel);
    barrel.turret setmodel("weapon_saw_MG_setup");
    barrel.turret.angles = barrel.angles;
    barrel.turret.usedTime = 0;

    // Hide the MG+Barrels
    barrel hide();
    barrel.turret hide();

    // Mark the mgbarrel as not being deployed
    barrel.isDeployed = false;

    // track whether the barrel is currently being killed
    barrel.isBeingKilled = false;

    // Add the MG+Barrel to the level array
    level.MgBarrels[level.MgBarrels.size] = barrel;
}

/**
 * @brief Creates the maximum number of MG+Barrels at startup
 *
 * @returns nothing
 */
createMgBarrels()
{
    debugPrint("in _barricades::createMgBarrels()", "fn", level.nonVerbose);

    for (i=0; i<level.dvar["game_max_mg_barrels"]; i++) {
        thread createMgBarrel();
        wait 0.5;
    }
}

/**
 * @brief Gives a deployable MG+Barrel to a player
 *
 * @returns nothing
 */
giveMgBarrel()
{
    debugPrint("in _barricades::giveMgBarrel()", "fn", level.nonVerbose);

    // Get a deployable MG+Barrel, if one is available
    mgBarrel = deployableMgBarrel();
    if (isDefined(mgBarrel)) {
        level.barrels[1]++;

        mgBarrel show();
        mgBarrel.turret show();

        // Make the player carry the MG+barrel
        self.carryObj = mgBarrel;
        self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
        self.carryObj.master = self;

        self.carryObj linkto(self);
        self.carryObj.type = 1;

        self.canUse = false;
        self disableweapons();

        // Let the player place the MG+Barrel
        self thread placeBarrel();

    } else {
        // There aren't any deployable MG+Barrels
        // We can't get here, since _shop.gsc prevents us from buying a MG+Barrel
        // unless there is less than the maximum deployed
        errorPrint("There isn't a deployable MG+Barrel, but level.barrels[1] says there is.");
    }
}

/**
 * @brief Removes a MG+barrel from game-play when it is destroyed or times out
 *
 * @returns nothing
 */
removeMgBarrel()
{
    debugPrint("in _barricades::removeMgBarrel()", "fn", level.nonVerbose);

    // If the barrel had a player when it died, free the player up to continue playing the game
    if (isdefined(self.turret.myPlayer)) {
        if (self.turret.myPlayer.onTurret) {
            self.turret.myPlayer.isBusy = false;
            self.turret.myPlayer.canUse = true;
            self.turret.myPlayer.onTurret = false;
            self.turret.myPlayer.isFiringTurret = false;
            self.turret.myPlayer destroyProgressBar();
            wait 0.05;
            self.turret.myPlayer = undefined;
        }
    }

    self hide();
    self.turret hide();
    self.origin = (0,0,-5000);
    level.barrels[1]--;

    // Reset initial properties to prepare for next deployment
    self.isBeingKilled = false;
    self.isDeployed = false;
    self.hp = self.maxhp;
    self.turret.usedTime = 0;
}

/**
 * @brief Finds the first available deployable MG+Barrel
 *
 * @returns the barrel if one is deployable, otherwise returns undefined
 */
deployableMgBarrel()
{
    debugPrint("in _barricades::deployableMgBarrel()", "fn", level.nonVerbose);

    // Iterate through the MG+Barrels and return the first one that
    // is deployable
    for (i=0; i<level.MgBarrels.size; i++) {
        if (!level.MgBarrels[i].isDeployed) {
            level.MgBarrels[i].isDeployed = true;
            return level.MgBarrels[i];
        }
    }
}

/**
 * @brief Watches machine gun temperature and firing time
 *
 * @returns nothing
 */
watchMGBarrel()
{
    debugPrint("in _barricades::watchMGBarrel()", "fn", level.nonVerbose);

    // Stop overheat/cooldown when MG dies
    self endon("death");

    // self is barrel
    mg = self.turret;
    mg.barrelMelted = false;
    mg.barrelTemperature = 0.01;
    mg.needsToCoolDown = false;
    while (!mg.barrelMelted) {
        mg waittill ("trigger", player);
        mg.myPlayer = player;
        player.onTurret = true;
        player.canUse  = false;
        player bar((0,1,0), 1, 128);
        while(player useButtonPressed()) {
            wait 0.05;
        }
        while (isdefined(player)) {
            if (player attackButtonPressed()) {
                // Player is firing
                player.isFiringTurret = true;
                player notify("is_firing_turret");
                mg.usedTime += 0.05;
                if (level.dvar["game_mg_overheat"]) {
                    // Don't let the mg fire if it is too hot
                    if (mg.barrelTemperature >= 100 || mg.needsToCoolDown) {
                        player scripts\players\_players::execClientCommand("-attack");
                        mg.needsToCoolDown = true;
                    } else {
                        mg.barrelTemperature += level.dvar["game_mg_overheat_speed"];
                    }
                }
            } else {
                // player is not firing
                player.isFiringTurret = false;
                if (level.dvar["game_mg_overheat"]) {
                    // Let the mg fire again if it has cooled enough
                    if (mg.needsToCoolDown) {
                        if (mg.barrelTemperature < 60) {
                            mg.needsToCoolDown = false;
                        }
                    }
                    // Cool the mg
                    if (mg.barrelTemperature > 0) {
                        mg.barrelTemperature -= level.dvar["game_mg_cooldown_speed"];
                        if (mg.barrelTemperature < 1) {mg.barrelTemperature = 1;}
                    }
                }
            }

            // Simulate a melted barrel. Used to force the player to drop a MG+Barrel
            // when it times out.
            if (mg.barrelMelted) {
                mg.barrelTemperature = 100;
            }

            //  update the UI
            delta = mg.barrelTemperature / 100;
            player bar_setscale(delta, (delta,1-delta,0));


            // Player has dropped the MG
            if (player useButtonPressed()) {
                mg.myPlayer = undefined;
                player.onTurret = false;
                player.isFiringTurret = false;
                player.canUse  = true;
                player destroyProgressBar();
                mg thread cooldown();
                break;
            }

            if (mg.usedTime >= level.dvar["game_mg_barrel_time"]) {
                mg.barrelMelted = true;
                delta = 100;
                player bar_setscale(delta, (delta,1-delta,0));
                if (!self.isBeingKilled) {
                    self.isBeingKilled = true;
                    self thread barrelDeath();
                    return;
                }
            }
            wait 0.05;
        }

    }
}

/**
 * @brief Cools down a MG while it isn't firing
 *
 * @returns nothing
 */
cooldown()
{
    debugPrint("in _barricades::cooldown()", "fn", level.nonVerbose);

    self endon("trigger");
    self endon("death");

    while (1) {
        if (self.barrelTemperature > 0) {
            self.barrelTemperature -= level.dvar["game_mg_cooldown_speed"];
            if (self.barrelTemperature < 0) {
                self.barrelTemperature = 0;
                break;
            }
        }
        wait 0.05;
    }
}

/**
 * @brief Removes a barrel from the game when it is destroyed
 *
 * @returns nothing
 */
barrelDeath()
{
    debugPrint("in _barricades::barrelDeath()", "fn", level.nonVerbose);

    // If a MG+Barrel
    if (self.type == 1) {
        // Remove MG+Barrel from dynamic barricades--everything elese is handled
        // in removeMgBarrel()
        level.dynamic_barricades = removeFromArray(level.dynamic_barricades, self);
        self thread removeMgBarrel();
        return;
    }

    // Decrement the number of this type of barrel, and update dynamic barricades array
    if (level.barrels[self.type] > 0) {
        level.barrels[self.type] -= 1;
    } else {debugPrint("Trying to set number of barrels to a negative number", "val");}
    level.dynamic_barricades = removeFromArray(level.dynamic_barricades, self);

    // Exploding Barrels
    if (self.type == 2) {
        PlayFX(level.explodeFX, self.origin);
        self PlaySound("explo_metal_rand");
        self thread scripts\players\_players::doAreaDamage(200, 1000, self.master);
    }
    wait .01;
    if (isDefined(self)) {
        self delete();
    }
}


doBarricadeDamage(damage)
{
    debugPrint("in _barricades::doBarricadeDamage()", "fn", level.nonVerbose);

    if (self.bar_type == 0) {
        self.hp -= damage;
        if (self.hp < 0) {self.hp = 0;}

        newPart = self.partsSize -  int(((self.hp -1)  / self.maxhp) * self.partsSize + 1);

        while (self.workingPart != newPart) {
            if (isdefined(self.deathFx)) {
                PlayFX(self.deathFx, self.parts[self.workingPart].origin);
            }

            if (!self.isUsable) {
                self.isUsable = true;
                level scripts\players\_usables::addUsable(self, "barricade", "Hold [Use] to rebuild", 96);
            }

            self.parts[self.workingPart] thread removePart();
            self.workingPart ++ ;
        }
    }

    // Barrel Damage
    if (self.bar_type == 1) {
        self.hp -= damage;
        if (self.hp <= 0) {
            if (!self.isBeingKilled) {
                self.isBeingKilled = true;
                self thread barrelDeath();
            } // else do nothing
        }
    }
}

restorePart()
{
    debugPrint("in _barricades::restorePart()", "fn", level.lowVerbosity);

    if (self.workingPart > 0) {
        self.workingPart -= 1;
        self.parts[self.workingPart].origin = self.parts[self.workingPart].startPosition;

        self.hp += self.maxhp / self.partsSize;

        if (isdefined(self.buildFx)) {
            PlayFX(self.buildFx, self.parts[self.workingPart].origin);
        }

        if (self.workingPart == 0) {
            self.isUsable = false;
            level scripts\players\_usables::removeUsable(self);
        }

        return 1;
    }
    return 0;
}



removePart()
{
    debugPrint("in _barricades::removePart()", "fn", level.lowVerbosity);

    self moveto(self.origin + (0, 0, -128), 1, .1, 0);
    wait 1;
}
