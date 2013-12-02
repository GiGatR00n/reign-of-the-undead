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

#include scripts\include\utility;


/**
 * @brief Creates a bot
 *
 * @returns boolean Whether the bot was instantiated
 */
instantiate()
{
    debugPrint("in bot::instantiate()", "fn", level.nonVerbose);

    bot = addTestClient();

    if (!isDefined(bot)) {
        warnPrint("Failed to instatiate a bot!");
        wait 0.5;
        return false;
    }

    bot.isBot = true;
    bot.hasSpawned = false;
    bot.readyToBeKilled = false;
    bot.spawnPoint = undefined;

    // Wait until the bot is properly connected
    while(!isDefined(bot.pers["team"])) {wait .05;}

    bot.sessionteam = "axis";
    bot.pers["team"] = "axis";
    wait 0.1;

    bot setStat(512, 100); // Yes we are indeed a bot
    bot setrank(255, 0);

    // when we want to move the bot, we link it to this entity, then move the
    // entity, and the bot gets taken along for the ride.
    bot.mover = spawn("script_model", (0,0,0));
    // [un]filled circular queue of movement orders, i.e. params for the moveTo() function
    bot.movement = spawnStruct();
    bot.movement.first = 0;
    bot.movement.next = 0;
    bot.movement.last = 0;
    bot.movement.orders = [];
    // we assume one order every 0.05s, for 0.2s until we reevaluate movement
    for (i=0; i<4; i++) {
        order = spawnStruct();
        order.origin = (0,0,0);
        order.time = 0; //s
        bot.movement.orders[i] = order;
    }
    bot.isFollowingWapypoints = false;

    bot.index = level.bots.size;

    makeBotAvailable(bot);

    level.bots[bot.index] = bot;
    return true;
}

/**
 * @brief Removes bots from the game
 *
 * @param botsToRemove array Indices of bots to remove from the game
 *
 * @returns nothing
 */
remove(botsToRemove)
{
    debugPrint("in bot::remove()", "fn", level.nonVerbose);

    // move the bots to be removed to the end of the array
    for (i=0; i<botsToRemove.size; i++) {
        if (botsToRemove[i] == level.bots.size - 1) {
            // bot is already the last element, just undefine it
            level.bots[level.bots.size - 1] = undefined;
            continue;
        } else {
            // copy last bot into botToBeRemoved's index, then undefine the last element
            level.bots[botsToRemove[i]] = level.bots[level.bots.size - 1];
            level.bots[botsToRemove[i]].index = botsToRemove[i]; // update the bot's index
            level.bots[level.bots.size - 1] = undefined;         // undefine the last element
        }
    }
    // now update availableBots to ensure their indices are correct
    for (i=0; i<level.availableBots.size; i++) {
        level.availableBots[i] = level.bots[level.availableBots[i]].index;
    }
}

/**
 * @brief Makes a bot available for use as a zombie
 *
 * @param bot struct The bot to make available for use
 *
 * @returns nothing
 */
makeBotAvailable(bot)
{
    debugPrint("in bot::makeBotAvailable()", "fn", level.fullVerbosity);

    // push the bot's index onto the availableBots stack
    level.availableBots[level.availableBots.size] = bot.index;
}

/**
 * @brief Plays a sound on a bot, such as death and attack sounds
 *
 * @param delay float The time, in seconds, to wait before playing the sound
 * @param sound string The base name of the sound, xom_death, zom_attack, etc
 * @param random integer The integer to concatenate with \c sound to determine the sound to play
 *
 * @returns nothing
 */
playSoundOnBot(delay, sound, random)
{
    debugPrint("in bot::playSoundOnBot()", "fn", level.fullVerbosity);

    if (delay > 0) {
        self endon("death");
        wait delay;
    }
    // concatenate sound name: zom_death1, zom_attack6, etc
    sound = sound + random;
    if (isalive(self)) {self playSound(sound);}
}

/**
 * @brief Give rank and upgrade points to players that damaged a zombie but didn't kill it
 *
 * @param killer entity The player that finally killed the zombie
 *
 * @returns nothing
 */
giveAssists(killer)
{
    debugPrint("in bot::giveAssists()", "fn", level.highVerbosity);

    for (i=0; i<self.damagedBy.size; i++) {
        struct = self.damagedBy[i];
        if (isdefined(struct.player)) {
            if (struct.player.isActive && struct.player != killer) {
                struct.player.assists ++;
                if (struct.damage > 400) {
                    struct.player thread scripts\players\_rank::giveRankXP("assist5");
                    struct.player thread scripts\players\_players::incUpgradePoints(10*level.rewardScale);
                } else if (struct.damage > 200) {
                    struct.player thread scripts\players\_rank::giveRankXP("assist4");
                    struct.player thread scripts\players\_players::incUpgradePoints(7*level.rewardScale);
                } else if (struct.damage > 100) {
                    struct.player thread scripts\players\_rank::giveRankXP("assist3");
                    struct.player thread scripts\players\_players::incUpgradePoints(5*level.rewardScale);
                } else if (struct.damage > 50) {
                    struct.player thread scripts\players\_rank::giveRankXP("assist2");
                    struct.player thread scripts\players\_players::incUpgradePoints(3*level.rewardScale);
                } else if (struct.damage > 25) {
                    struct.player thread scripts\players\_rank::giveRankXP("assist1");
                    struct.player thread scripts\players\_players::incUpgradePoints(3*level.rewardScale);
                } else if (struct.damage > 0) {
                    struct.player thread scripts\players\_rank::giveRankXP("assist0");
                    struct.player thread scripts\players\_players::incUpgradePoints(2*level.rewardScale);
                }
            }
        }
    }
    self.damagedBy = undefined;
}

/**
 * @brief Sets the animation for a zombie by changing the zombie's weapon
 *
 * @param type string The name of the animation type
 *
 * @returns nothing
 */
setAnimation(type)
{
    // 6th most-called function (2% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    if (isDefined(self.animation[type])) {
        self.animWeapon = self.animation[type];
        self TakeAllWeapons();
        self.pers["weapon"] = self.animWeapon;
        self giveweapon(self.pers["weapon"]);
        self givemaxammo(self.pers["weapon"]);
        self setspawnweapon(self.pers["weapon"]);
        self switchtoweapon(self.pers["weapon"]);
    }
}

/**
 * @brief Puts a zombie in idle mode, i.e. just standing there
 *
 * @returns nothing
 */
idle()
{
    debugPrint("in bot::idle()", "fn", level.fullVerbosity);

    self setAnimation("stand");
    self.cur_speed = 0;
    self.alertLevel = 0;
    self.status = "idle";
    //iprintlnbold("IDLE!");
}

/**
 * @brief Stuns a zombie
 *
 * An effect of the thundergun
 *
 * @returns nothing
 */
stun()
{
    debugPrint("in bot::stun()", "fn", level.fullVerbosity);

    // no stunning in final wave!
    if (level.currentWave < level.totalWaves) {
        self setAnimation("stand");
        self.cur_speed = 0;
        self.alertLevel = 0;
        self.status = "stunned";
        //iprintlnbold("STUNNED!");
    }
}

groan()
{
    debugPrint("in bot::groan()", "fn", level.veryHighVerbosity);

    self endon("death");
    self endon("disconnect");

    if (self.soundType == "dog") {return;}

    while (1) {
        if (self.isDoingMelee == false) {
            if (self.alertLevel == 0) {
                // Do nothing
            } else if (self.alertLevel < 200) {
                self playSoundOnBot(randomfloat(.5), "zom_walk", randomint(7));
            } else {
                self playSoundOnBot(randomfloat(.5), "zom_run", randomint(6));
            }
        }
        wait 3 + randomfloat(3);
    }
}

canSeeTarget(target)
{
    // 4th most-called function (6% of all function calls).
    // Do *not* put a function entrance debugPrint statement here!

    if (!isDefined(target)) {return false;}
    if (!target.isObj) {
        if (!target.isAlive) {return false;}
        if (!target.isTargetable) {return false;}
    }

    if (!target.visible) {return false;}

    distance = distance(self.origin, target.origin);
    if (distance > level.zombieSightDistance) {return false;}

    // unit vectors
    forwardVector = anglesToForward(self getplayerangles());
    targetVector = vectorNormalize(target.origin-self.origin);
    dot = vectorDot(forwardVector, targetVector);

    // target is in the area we can see by turning our head
    if(dot > -0.5) {
        // do a trace to see if we can see the target
        if (!target.isObj) {
            // player
            trace = bullettrace(self getEye(), target getEye(), false, self);
        } else {
            trace = bullettrace(self getEye(), target.origin + (0,0,20), false, self);
        }
        if (trace["fraction"] == 1) {
            // no obstructions
            return true;
        } else {
            if (isDefined(trace["entity"])) {
                if (trace["entity"] == target) {
                    // we hit something, but it was our target, so no problem
                    return true;
                }
            }
            //line(self.origin + (0,0,68), trace["position"], (1,0,0));
            return false;
        }
    }
    return false;
}

isPathNavigable(destination)
{
    debugPrint("in bot::isPathNavigable()", "fn", level.highVerbosity);

    // assume the mapmaker didn't put a waypoint link through a solid object
    if (self.isFollowingWapypoints) {return true;}

    /// @todo implement isPathNavigable()
    return true;
}

bestTarget()
{
    debugPrint("in bot::bestTarget()", "fn", level.highVerbosity);

    // the best target is the closest player the bot can see
    targets = self sortTargetsByDistance();
    for (i=0; i<targets.size; i++) {
        if (self canSeeTarget(targets[i].player)) {
            return targets[i].player;
        }
    }
    // if the bot can't see any of the players, just use the closest player
    return targets[0].player;
}

closestTarget()
{
    debugPrint("in bot::closestTarget()", "fn", level.highVerbosity);

    return self sortTargetsByDistance()[0].player;
}

sortTargetsByDistance()
{
    debugPrint("in bot::sortTargetsByDistance()", "fn", level.highVerbosity);

    players = level.players;
    data = [];
    temp = spawnStruct();
    for (i=0; i<players.size; i++) {
        player = players[i];
        if (!isDefined(player)) {continue;}
        if (!player.isTargetable) {continue;}
        if (player.isAlive) {
            temp.player = player;
            temp.distance = distanceSquared(self.origin, player.origin);
            // ordered insert by distance
            first = 0;
            i = data.size;
            while ((i > first) && (temp.distance < data[i-1].distance)) {
                data[i] = data[i-1];
                i--;
            }
            data[i] = temp;
        }
    }
    return data;
}

main()
{
    debugPrint("in bot::main()", "fn", level.highVerbosity);

    target = bestTarget();
    self.targetedPlayer = target;
    self watchTargetedPlayer();
    iPrintLnBold("Targeting " + self.targetedPlayer.name);
}

/**
 * @brief Watch targeted player for events that should make us find a new target
 *
 * @returns nothing
 */
watchTargetedPlayer()
{
    debugPrint("in bot::watchTargetedPlayer()", "fn", level.highVerbosity);

    self endon("death");

    self thread onTargetedPlayerDeath();
    /// @todo also on disconnect, change class, death (boom), join spectator

}

/**
 * @brief When a targeted player goes down, invalidate the target so we can get a new one
 *
 * @returns nothing
 */
onTargetedPlayerDeath()
{
    debugPrint("in bot::onTargetedPlayerDeath()", "fn", level.highVerbosity);

    self endon("death");
    self endon("target_invalidated");

    self.targetedPlayer waittill("downed");
    self notify("target_invalidated");
}

/**
 * @brief When a targeted player is invalidated, find a new target
 *
 * @returns nothing
 */
newTarget()
{
    debugPrint("in bot::newTarget()", "fn", level.highVerbosity);

    self endon("death");

    while (1) {
        self waittill("target_invalidated");

        target = bestTarget();
        self.targetedPlayer = target;
        self watchTargetedPlayer();
    }
}
