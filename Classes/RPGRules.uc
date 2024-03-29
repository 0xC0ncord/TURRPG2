//=============================================================================
// RPGRules.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGRules extends GameRules
    config(TURRPG2);

//for debugging, cba to code these up everytime, FALSE by default, can be toggled by "mutate damagelog"
var bool bDamageLog;

var Sound DisgraceAnnouncement, EagleEyeAnnouncement;

var MutTURRPG RPGMut;
var float LevelDiffExpGainDiv;
var bool bAwardedFirstBlood;

var bool bGameEnded;

//Kills
var class<DamageType> KillDamageType;

//These damage types are simply passed through without any ability, weapon magic or similar being able to scale it
var array<class<DamageType> > DirectDamageTypes;

//These damage types should not have UDamage applied
var array<class<DamageType> > NoUDamageTypes;

/*
    Experience Awards
*/

//Kills
var config float EXP_Frag, EXP_SelfFrag, EXP_TeamFrag, EXP_TypeKill;
var config float EXP_FirstBlood, EXP_KillingSpree[6], EXP_MultiKill[7];
var config float EXP_EndSpree, EXP_CriticalFrag;

//Special kills
var config float EXP_Telefrag, EXP_Headshot;

//Game events
var config float EXP_Win;

/*
    CTF
    EXP_FlagCapFirstTouch - EXP for whomever touched the flag first for the cap.
    EXP_FlagCapAssist - EXP for everyone who held the flag at a point during the cap.
    EXP_FlagCapFinal - EXP for whomever does the actual cap.

    EXP_ReturnFriendlyFlag - Return flag which was close to the own base.
    EXP_ReturnEnemyFlag - Return flag which was far from the own base.
    EXP_FlagDenial - Return flag which was very close to the enemy base.
*/
var config float EXP_FlagCapFirstTouch, EXP_FlagCapAssist, EXP_FlagCapFinal;
var config float EXP_ReturnFriendlyFlag, EXP_ReturnEnemyFlag, EXP_FlagDenial;

/*
    BR
    EXP_BallScoreAssist - EXP for everyone who held the ball at a point during the score.
    EXP_BallThrownFinal - EXP for whomever fired the ball into the goal.
    EXP_BallCapFinal - EXP for whomever jumps through the goal.
*/
var config float EXP_BallThrownFinal, EXP_BallCapFinal, EXP_BallScoreAssist;

/*
    DOM
    EXP_DOMScore - EXP for whomever touched the point in the first place.
*/
var config float EXP_DOMScore;

//ONS
var config float EXP_HealPowernode, EXP_ConstructPowernode;
var config float EXP_DestroyPowercore;
var config float EXP_DestroyPowernode, EXP_DestroyConstructingPowernode;

//AS
var config float EXP_ObjectiveCompleted;

//TODO: AS events, DOM events

//Misc
var config float EXP_VehicleRepair; //EXP for repairing 1 "HP"

/*
    EXP_Assist - Will be multiplied by the relative time assisted.
*/
var config float EXP_Assist;

//TitanRPG
var config float EXP_Healing; //default damage multiplier for healing teammates (LM will scale this)
var config float EXP_TeamBooster; //EXP per second per healed player

//Multipliers
var config float EXPMul_DestroyVehicle; //you get the XP of a normal kill multiplied by this value
var config float EXPMul_SummonKill; //you get the XP of a normal kill multiplied by this value

//Awards
var config float EXP_HeadHunter, EXP_ComboWhore, EXP_FlakMonkey, EXP_RoadRampage;
var config float EXP_Daredevil;

//Combos
struct ComboReward {
    var string ComboClass;
    var float Exp;
};

var config array<ComboReward> EXP_Combo;

static function RPGRules Instance(LevelInfo Level)
{
    local GameRules Rules;

    for(Rules = Level.Game.GameRulesModifiers; Rules != None; Rules = Rules.NextGameRules)
    {
        if(RPGRules(Rules) != None)
            return RPGRules(Rules);
    }
    return None;
}

event PostBeginPlay()
{
    bGameEnded = false;
    SetTimer(Level.TimeDilation, true);

    Super.PostBeginPlay();
}

//checks if the player that owns the specified RPGStatsInv is linked up to anybody and if so shares Amount EXP
//equally between them, otherwise gives it all to the lone player
static function ShareExperience(RPGPlayerReplicationInfo InstigatorRPRI, float Amount)
{
    local LinkGun Head, Link;
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;
    local array<RPGPlayerReplicationInfo> Links;
    local int i;

    if(Amount == 0)
        return;

    if(InstigatorRPRI.Controller.Pawn == None || InstigatorRPRI.Controller.Pawn.Weapon == None)
    {
        //dead or has no weapon, so can't be linked up
        InstigatorRPRI.AwardExperience(Amount);
    }
    else
    {
        Head = LinkGun(InstigatorRPRI.Controller.Pawn.Weapon);
        if(Head == None)
        {
            // Instigator is not using a Link Gun
            InstigatorRPRI.AwardExperience(Amount);
        }
        else
        {
            //create a list of everyone that should share the EXP
            Links[0] = InstigatorRPRI;
            for(C = InstigatorRPRI.Level.ControllerList; C != None; C = C.NextController)
            {
                if(C.Pawn != None && C.Pawn.Weapon != None)
                {
                    Link = LinkGun(C.Pawn.Weapon);
                    if(Link != None && Link.LinkedTo(Head))
                    {
                        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
                        if(RPRI != None)
                            Links[Links.length] = RPRI;
                    }
                }
            }

            // share the experience among the linked players
            Amount /= float(Links.Length);
            for(i = 0; i < Links.Length; i++)
                Links[i].AwardExperience(Amount);
        }
    }
}

/**
    SCORE OBJECTIVE
*/
function ScoreObjective(PlayerReplicationInfo Scorer, int Score) {
    Super.ScoreObjective(Scorer, Score);
}

// calculate how much exp does a player get for killing another player 1of a certain level
function float GetKillEXP(RPGPlayerReplicationInfo KillerRPRI, RPGPlayerReplicationInfo KilledRPRI, optional float Multiplier)
{
    local float XP;
    local float Diff;

    if(KilledRPRI != None)
    {
        Diff = FMax(0, KilledRPRI.RPGLevel - KillerRPRI.RPGLevel);
        //Log("Level difference is" @ Diff, 'GetKillEXP');

        if(Diff > 0)
        {
            Diff = (Diff * Diff) / LevelDiffExpGainDiv;
            //Log("Post processed difference value is" @ Diff, 'GetKillEXP');
        }

        //cap gained exp to enough to get to Killed's level
        if(KilledRPRI.RPGLevel - KillerRPRI.RPGLevel > 0 && Diff > (KilledRPRI.RPGLevel - KillerRPRI.RPGLevel) * KilledRPRI.NeededExp)
        {
            Diff = (KilledRPRI.RPGLevel - KillerRPRI.RPGLevel) * KilledRPRI.NeededExp;
            //Log("Capped difference value is" @ Diff, 'GetKillEXP');
        }

        Diff = float(int(Diff)); //round

        if(Multiplier > 0)
        {
            Diff *= Multiplier;
            //Log("Difference value multiplied by" @ Multiplier @ "is" @ Diff, 'GetKillEXP');
        }
    }

    XP = FMax(EXP_Frag, Diff); //at least EXP_Frag

    //Log("Final XP:" @ XP, 'GetKillEXP');
    return XP;
}

/***************************************************
****************** SCORE KILL **********************
***************************************************/
function ScoreKill(Controller Killer, Controller Killed)
{
    local int x;
    local Inventory Inv, NextInv;
    local vector TossVel, U, V, W;
    local Pawn KillerPawn, KilledPawn;
    local RPGPlayerReplicationInfo KillerRPRI, KilledRPRI;
    local TeamPlayerReplicationInfo KillerPRI;
    local class<Weapon> KillWeaponType;

    Super.ScoreKill(Killer, Killed);

    //Nobody was killed...
    if(Killed == None)
        return;

    //Get Pawns
    if(Killer != None)
        KillerPawn = Killer.Pawn;

    KilledPawn = Killed.Pawn;

    //Drop artifacts
    if(KilledPawn != None)
    {
        Inv = KilledPawn.Inventory;
        while(Inv != None)
        {
            NextInv = Inv.Inventory;
            if(RPGArtifact(Inv) != None)
            {
                TossVel = Vector(KilledPawn.GetViewRotation());
                TossVel = TossVel * ((KilledPawn.Velocity dot TossVel) + 500) + Vect(0,0,200);
                TossVel += VRand() * (100 + Rand(250));
                Inv.Velocity = TossVel;
                KilledPawn.GetAxes(KilledPawn.Rotation, U, V, W);
                Inv.DropFrom(KilledPawn.Location + 0.8 * KilledPawn.CollisionRadius * U - 0.5 * KilledPawn.CollisionRadius * V);
            }
            Inv = NextInv;
        }
    }

    //Get RPRIs
    if(Killer != None) {
        KillerPRI = TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo);
    }

    KillerRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Killer);
    KilledRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Killed);

    //Suicide / Self Kill
    if(Killer == Killed)
    {
        if(KillerRPRI != None)
            KillerRPRI.AwardExperience(EXP_SelfFrag);

        return;
    }

    //Team kill
    if(Killed.SameTeamAs(Killer))
    {
        if(KillerRPRI != None)
            KillerRPRI.AwardExperience(EXP_TeamFrag);

        return;
    }

    if(Killer != None)
    {
        if(
            FriendlyMonsterController(Killer) != None
            || RPGBaseSentinelController(Killer) != None
            || RPGSentinelController(Killer) != None
            || RPGLightningSentinelController(Killer) != None
            || RPGAutoGunController(Killer) != None
            || RPGEnergyWallController(Killer) != None
        )
        {
            //A summoned monster or construction killed something
            if(FriendlyMonsterController(Killer) != None)
            {
                Killer = FriendlyMonsterController(Killer).Master;
                RegisterWeaponKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, class'DummyWeapon_Monster');

                if(PlayerController(Killer) != None && Killed.PlayerReplicationInfo != None)
                    PlayerController(Killer).ReceiveLocalizedMessage(class'LocalMessage_FriendlyMonsterKiller',, Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillerPawn);
            }
            else if(RPGBaseSentinelController(Killer) != None)
            {
                Killer = RPGBaseSentinelController(Killer).PlayerSpawner;
                RegisterVehicleKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, class<Vehicle>(KillerPawn.Class));

                if(PlayerController(Killer) != None && Killed.PlayerReplicationInfo != None)
                    PlayerController(Killer).ReceiveLocalizedMessage(class'LocalMessage_SentinelKiller',, Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillerPawn);
            }
            else if(RPGSentinelController(Killer) != None)
            {
                Killer = RPGSentinelController(Killer).PlayerSpawner;
                RegisterVehicleKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, class<Vehicle>(KillerPawn.Class));

                if(PlayerController(Killer) != None && Killed.PlayerReplicationInfo != None)
                    PlayerController(Killer).ReceiveLocalizedMessage(class'LocalMessage_SentinelKiller',, Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillerPawn);
            }
            else if(RPGLightningSentinelController(Killer) != None)
            {
                Killer = RPGLightningSentinelController(Killer).PlayerSpawner;
                RegisterVehicleKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, class<Vehicle>(KillerPawn.Class));

                if(PlayerController(Killer) != None && Killed.PlayerReplicationInfo != None)
                    PlayerController(Killer).ReceiveLocalizedMessage(class'LocalMessage_SentinelKiller',, Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillerPawn);
            }
            else if(RPGAutoGunController(Killer) != None)
            {
                Killer = RPGAutoGunController(Killer).PlayerSpawner;
                RegisterVehicleKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, class<Vehicle>(KillerPawn.Class));

                if(PlayerController(Killer) != None && Killed.PlayerReplicationInfo != None)
                    PlayerController(Killer).ReceiveLocalizedMessage(class'LocalMessage_SentinelKiller',, Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillerPawn);
            }
            else if(RPGEnergyWallController(Killer) != None)
            {
                Killer = RPGEnergyWallController(Killer).PlayerSpawner;
                RegisterVehicleKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, class<Vehicle>(KillerPawn.Class));

                if(PlayerController(Killer) != None && Killed.PlayerReplicationInfo != None)
                    PlayerController(Killer).ReceiveLocalizedMessage(class'LocalMessage_SentinelKiller',, Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillerPawn);
            }

            //Award experience
            KillerRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Killer);
            if(KillerRPRI != None)
                KillerRPRI.AwardExperience(GetKillEXP(KillerRPRI, KilledRPRI, EXPMul_SummonKill));

            //Add legitimate score
            if(Killer.PlayerReplicationInfo != None)
            {
                //If this is invasion, don't do score checking!!!
                if(Invasion(Level.Game) == None)
                {
                    Killer.PlayerReplicationInfo.Score += 1.0f;

                    //If this is TDM, give the team a point too
                    if(
                        TeamGame(Level.Game) != None &&
                        TeamGame(Level.Game).bScoreTeamKills &&
                        Killer.PlayerReplicationInfo.Team != None
                    ) {
                        Killer.PlayerReplicationInfo.Team.Score += 1.0f;
                    }

                    if(Level.Game.MaxLives > 0)
                        Level.Game.CheckScore(Killer.PlayerReplicationInfo); //possibly win the match
                }
                else if(Monster(KilledPawn) != None)
                {
                    Killer.PlayerReplicationInfo.Score += Monster(KilledPawn).ScoringValue;
                    KillerRPRI.AwardAdrenaline(Monster(KilledPawn).ScoringValue, Self);
                }
            }

            return;
        }
        else
        {
            if(Killer.PlayerReplicationInfo != None && ClassIsChildOf(KillDamageType, class'RPGDamageType')) {
                KillWeaponType = class<RPGDamageType>(KillDamageType).default.StatWeapon;
                if(KillWeaponType != None)
                    RegisterWeaponKill(Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, KillWeaponType);
            }

            if(KillerRPRI != None)
            {
                /*
                    ADRENALINE ADJUSTMENT
                */
                if(ClassIsChildOf(KillDamageType, class'RPGAdrenalineDamageType'))
                    Killer.Adrenaline = KillerRPRI.AdrenalineBeforeKill;

                /*
                    EXPERIENCE
                */

                //Kill
                if(Bot(Killed) == None || RPGMut.GameSettings.bExpForKillingBots)
                    ShareExperience(KillerRPRI, GetKillEXP(KillerRPRI, KilledRPRI));

                //Type kill
                if(PlayerController(Killed) != None && PlayerController(Killed).bIsTyping)
                {
                    KillerRPRI.AwardExperience(EXP_TypeKill);
                }

                //Translocator kill
                if(KillDamageType == class'DamTypeTeleFrag')
                {
                    KillerRPRI.AwardExperience(EXP_Telefrag);
                }

                //Head shot
                if(ClassIsChildOf(KillDamageType, class'DamTypeSniperHeadShot') || ClassIsChildOf(KillDamageType, class'DamTypeClassicHeadshot'))
                {
                    KillerRPRI.AwardExperience(EXP_HeadShot);

                    if(KillerPRI.headcount == 15) {
                        KillerRPRI.AwardExperience(EXP_HeadHunter);
                    }
                }

                //Flak Money
                if(ClassIsChildOf(KillDamageType, class'DamTypeFlakChunk') && KillerPRI.flakcount == 15) {
                    KillerRPRI.AwardExperience(EXP_FlakMonkey);
                }

                //Combo Whore
                if(ClassIsChildOf(KillDamageType, class'DamTypeShockCombo') && KillerPRI.combocount == 15) {
                    KillerRPRI.AwardExperience(EXP_ComboWhore);
                }

                //Road Rampage
                if(ClassIsChildOf(KillDamageType, class'DamTypeRoadkill') && KillerPRI.ranovercount == 10) {
                    KillerRPRI.AwardExperience(EXP_RoadRampage);
                }

                //Multi kill
                if(UnrealPlayer(Killer) != None && UnrealPlayer(Killer).MultiKillLevel > 0)
                {
                    KillerRPRI.AwardExperience(EXP_MultiKill[Min(UnrealPlayer(Killer).MultiKillLevel, ArrayCount(EXP_MultiKill) - 1)]);
                }

                //Spree
                if(
                    UnrealPawn(Killer.Pawn) != None &&
                    UnrealPawn(Killer.Pawn).spree > 0 &&
                    UnrealPawn(Killer.Pawn).spree % 5 == 0
                )
                {
                    KillerRPRI.AwardExperience(EXP_KillingSpree[Min(UnrealPawn(Killer.Pawn).spree * 0.2, ArrayCount(EXP_KillingSpree) - 1)]);
                }

                //First blood
                if(
                    Killer.PlayerReplicationInfo.Kills == 1 &&
                    TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo).bFirstBlood
                )
                {
                    KillerRPRI.AwardExperience(EXP_FirstBlood);
                }

                //End spree
                if(
                    UnrealPawn(Killed.Pawn) != None &&
                    UnrealPawn(Killed.Pawn).spree > 4
                )
                {
                    KillerRPRI.AwardExperience(EXP_EndSpree);
                }

                //Kill flag carrier
                if(TeamGame(Level.Game) != None && TeamGame(Level.Game).CriticalPlayer(Killed)) {
                    KillerRPRI.AwardExperience(EXP_CriticalFrag);
                }

                //Notify killer's abilities
                for(x = 0; x < KillerRPRI.Abilities.length; x++)
                {
                    if(KillerRPRI.Abilities[x].bAllowed)
                        KillerRPRI.Abilities[x].ScoreKill(Killed, KillDamageType);
                }
            }
        }
    }

    if(KilledRPRI != None)
    {
        //Notify victim's abilities
        for(x = 0; x < KilledRPRI.Abilities.length; x++)
        {
            if(KilledRPRI.Abilities[x].bAllowed)
                KilledRPRI.Abilities[x].Killed(Killer, KillDamageType);
        }
    }
}

//Get exp for damage
function float GetDamageEXP(int Damage, Pawn InstigatedBy, Pawn Injured)
{
    Damage = Min(Damage, Injured.Health); //clamp to injured's health

    if(
        Damage <= 0 ||
        InstigatedBy == Injured ||
        InstigatedBy.Controller.SameTeamAs(Injured.Controller)
    )
    {
        return 0;
    }

    if(Monster(Injured) != None)
        return RPGMut.GameSettings.ExpForDamageScale * (float(Damage) / Injured.HealthMax) * float(Monster(Injured).ScoringValue);

    return 0;
}

//Get pawn's weapon for the given damage type
function Weapon GetDamageWeapon(Pawn Other, class<DamageType> DamageType)
{
    local class<Weapon> WClass;
    local Inventory Inv;

    if(ClassIsChildOf(DamageType, class'WeaponDamageType'))
    {
        if(Vehicle(Other) != None) {
            //whoever fired this might have just entered a vehicle
            Other = Vehicle(Other).Driver;
        }

        WClass = class<WeaponDamageType>(DamageType).default.WeaponClass;

        //for most cases, checking the currently held weapon will suffice
        if(Other.Weapon != None && ClassIsChildOf(Other.Weapon.class, WClass))
            return Other.Weapon;

        //if not, browse the inventory
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(Inv == Other.Weapon)
                continue; //already checked

            if(ClassIsChildOf(Inv.class, WClass))
                return Weapon(Inv);
        }
    }
    return None;
}

function bool CheckScore(PlayerReplicationInfo Scorer) {
    return Super.CheckScore(Scorer);
}

/***************************************************
****************** NET DAMAGE **********************
***************************************************/
function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local RPGWeaponModifier WM;
    local Controller injuredController, instigatorController;
    local RPGPlayerReplicationInfo injuredRPRI, instigatorRPRI;
    local Inventory Inv;
    local Weapon W;
    local int x;
    local float OldXP, CurXP, XPForEach, XPDiff, XPGiven;
    local int OldLevel;
    local RPGPlayerReplicationInfo HealerRPRI;

    if(bDamageLog)
    {
        Log("BEGIN", 'RPGDamage');
        Log("OriginalDamage =" @ OriginalDamage, 'RPGDamage');
        Log("Damage =" @ Damage, 'RPGDamage');
        Log("injured =" @ injured, 'RPGDamage');
        Log("instigatedBy =" @ instigatedBy, 'RPGDamage');
        Log("HitLocation =" @ HitLocation, 'RPGDamage');
        Log("Momentum =" @ Momentum, 'RPGDamage');
        Log("DamageType =" @ DamageType, 'RPGDamage');
        Log("---", 'RPGDamage');
    }

    //Filter UDamage
    if(
        class'Util'.static.InArray(DamageType, NoUDamageTypes) >= 0 &&
        instigatedBy != None &&
        instigatedBy.HasUDamage()
    )
    {
        OriginalDamage *= 0.5;
        Damage *= 0.5;

        if(bDamageLog)
        {
            Log("This damage type should not have UDamage applied!", 'RPGDamage');
            Log("-> OriginalDamage = " $ OriginalDamage, 'RPGDamage');
            Log("-> Damage = " $ Damage, 'RPGDamage');
        }
    }

    //Direct damage types
    if(class'Util'.static.InArray(DamageType, DirectDamageTypes) >= 0)
    {
        if(bDamageLog)
        {
            Log("This is a direct damage type and will not be processed further by RPG.", 'RPGDamage');
            Log("END", 'RPGDamage');
        }

        return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType); //pass-through
    }

    //Let other rules modify damage
    Damage = Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(bDamageLog)
        Log("After Super call: Damage =" @ Damage $ ", Momentum =" @ Momentum, 'RPGDamage');

    //Get info

    injuredController = injured.Controller;

    if(FriendlyMonsterController(injuredController) != None)
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(FriendlyMonsterController(injuredController).Master);
    else if(RPGBaseSentinelController(instigatorController) != None)
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(RPGBaseSentinelController(injuredController).PlayerSpawner);
    else if(RPGSentinelController(instigatorController) != None)
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(RPGSentinelController(injuredController).PlayerSpawner);
    else if(RPGLightningSentinelController(instigatorController) != None)
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(RPGLightningSentinelController(injuredController).PlayerSpawner);
    else if(RPGAutoGunController(instigatorController) != None)
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(RPGAutoGunController(injuredController).PlayerSpawner);
    else if(RPGEnergyWallController(instigatorController) != None)
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(RPGEnergyWallController(injuredController).PlayerSpawner);
    else
        injuredRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(injuredController);

    if(instigatedBy != None)
    {
        instigatorController = instigatedBy.Controller;

        if(FriendlyMonsterController(instigatorController) != None)
            instigatorController = FriendlyMonsterController(instigatorController).Master;
        else if(RPGBaseSentinelController(instigatorController) != None)
            instigatorController = RPGBaseSentinelController(instigatorController).PlayerSpawner;
        else if(RPGSentinelController(instigatorController) != None)
            instigatorController = RPGSentinelController(instigatorController).PlayerSpawner;
        else if(RPGLightningSentinelController(instigatorController) != None)
            instigatorController = RPGLightningSentinelController(instigatorController).PlayerSpawner;
        else if(RPGAutoGunController(instigatorController) != None)
            instigatorController = RPGAutoGunController(instigatorController).PlayerSpawner;
        else if(RPGEnergyWallController(instigatorController) != None)
            instigatorController = RPGEnergyWallController(instigatorController).PlayerSpawner;

        instigatorRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(instigatorController);
    }

    //Hack friendly fire checks
    if(TeamGame(Level.Game) != None && FriendlyMonsterController(injuredController) != None && class'Util'.static.SameTeamC(injuredController, instigatorController))
        Damage *= TeamGame(Level.Game).FriendlyFireScale;

    if(Vehicle(instigatedBy) != None && instigatorRPRI != None && instigatorRPRI.NumVehicleHealers > 0)
    {
        OldXP = instigatorRPRI.Experience;
        OldLevel = instigatorRPRI.RPGLevel;

        if(Level.TimeSeconds > instigatorRPRI.LastVehicleHealTime + class'EngineerLinkGun'.default.HealTimeDelay && instigatorRPRI.NumVehicleHealers > 0)
            Damage = Damage * class'WeaponModifier_EngineerLink'.static.DamageIncreasedByLinkers(instigatorRPRI.NumVehicleHealers);
    }

    if(bDamageLog)
    {
        Log("instigatorController =" @ instigatorController, 'RPGDamage');

        if(instigatorRPRI != None)
            Log("instigatorRPRI =" @ instigatorRPRI.RPGName, 'RPGDamage');
        else
            Log("instigatorRPRI = None");

        Log("injuredController =" @ injuredController, 'RPGDamage');

        if(injuredRPRI != None)
            Log("injuredRPRI =" @ injuredRPRI.RPGName, 'RPGDamage');
        else
            Log("injuredRPRI = None");
    }

    /*
        ACTIVE DAMAGE MODIFICATION
    */
    if(instigatedBy != None)
    {
        W = GetDamageWeapon(instigatedBy, DamageType);

        if(bDamageLog)
            Log("DamageWeapon =" @ W, 'RPGDamage');

        if(W != None)
        {
            //Weapon modifier
            WM = class'RPGWeaponModifier'.static.GetFor(W);
            if(WM != None)
                WM.AdjustTargetDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
        }

        //Active artifacts and effects
        for(Inv = instigatedBy.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(RPGArtifact(Inv) != None && RPGArtifact(Inv).bActive)
                RPGArtifact(Inv).AdjustTargetDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
            else if(RPGEffect(Inv) != None && Inv.IsInState('Activated'))
                RPGEffect(Inv).AdjustTargetDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
        }

        //Abilities
        if(instigatorRPRI != None)
        {
            for(x = 0; x < instigatorRPRI.Abilities.length; x++)
            {
                if(instigatorRPRI.Abilities[x].bAllowed)
                    instigatorRPRI.Abilities[x].AdjustTargetDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
            }
        }
    }

    /*
        PASSIVE DAMAGE MODIFICATION
    */

    //Weapon modifier
    WM = class'RPGWeaponModifier'.static.GetFor(injured.Weapon);
    if(WM != None)
        WM.AdjustPlayerDamage(Damage, OriginalDamage, instigatedBy, HitLocation, Momentum, DamageType);

    //Active artifacts and effects
    for(Inv = injured.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if(RPGArtifact(Inv) != None && RPGArtifact(Inv).bActive)
            RPGArtifact(Inv).AdjustPlayerDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
        else if(RPGEffect(Inv) != None && Inv.IsInState('Activated'))
            RPGEffect(Inv).AdjustPlayerDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
    }

    //Abilities
    if(injuredRPRI != None)
    {
        for(x = 0; x < injuredRPRI.Abilities.length; x++)
        {
            if(injuredRPRI.Abilities[x].bAllowed)
                injuredRPRI.Abilities[x].AdjustPlayerDamage(Damage, OriginalDamage, injured, instigatedBy, HitLocation, Momentum, DamageType);
        }
    }

    /*
    */

    //Experience
    if(instigatorRPRI != None)
    {
        ShareExperience(instigatorRPRI, GetDamageEXP(Damage, instigatedBy, Injured));

        //Possibly share experience with vehicle linkers
        if(OldLevel == instigatorRPRI.RPGLevel && instigatorRPRI.NumVehicleHealers > 0)
        {
            CurXP = instigatorRPRI.Experience;
            XPDiff = CurXP - OldXP;
            if(XPDiff > 0)
            {
                // split the xp amongst the healers
                XPForEach = class'WeaponModifier_EngineerLink'.static.XPForLinker(XPDiff, instigatorRPRI.VehicleHealers.Length);
                XPGiven = 0;

                for(x = 0; x < instigatorRPRI.VehicleHealers.Length; x++)
                {
                    if(instigatorRPRI.VehicleHealers[x].Pawn != None && instigatorRPRI.VehicleHealers[x].Pawn.Health >0)
                    {
                        if(RPGLinkSentinelController(instigatorRPRI.VehicleHealers[x]) != None)
                            HealerRPRI = RPGLinkSentinelController(instigatorRPRI.VehicleHealers[x]).RPRI;
                        else
                            HealerRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(instigatorRPRI.VehicleHealers[x]);
                        if(HealerRPRI != None)
                            class'RPGRules'.static.ShareExperience(HealerRPRI, XPForEach);
                        XPGiven += XPForEach;
                    }
                }
                if(XPGiven > 0) // now adjust the turret operator
                {
                    instigatorRPRI.Experience = Max(instigatorRPRI.Experience - XPGiven, 0); //don't go negative
                }
            }
        }
    }

    //Done
    if(bDamageLog)
    {
        Log("Final Damage =" @ Damage $ ", Momentum =" @ Momentum, 'RPGDamage');
        Log("END", 'RPGDamage');
    }
    return Damage;
}

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
    local RPGPlayerReplicationInfo RPRI;
    local RPGWeaponPickupModifier WPM;
    local class<Ammunition> AmmoClass;
    local Weapon W;
    local array<Weapon> Weapons;
    local Inventory Inv;
    local float AmmoAmount;
    local class<RPGWeaponModifier> ModifierClass;
    local int x, ModifierLevel;

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Other.Controller);

    //Modified weapon pickup
    if(WeaponPickup(item) != None) {
        WPM = class'RPGWeaponPickupModifier'.static.GetFor(WeaponPickup(item));
        if(WPM != None) {
            //Remove thrown weapon
            if(RPRI != None) {
                RPRI.RemoveThrownWeapon(class<Weapon>(item.InventoryType));
            }

            //Simulate using modifier
            class'RPGWeaponPickupModifier'.static.SimulateWeaponPickup(
                WeaponPickup(item),
                Other,
                WPM.ModifierClass,
                WPM.ModifierLevel,
                WPM.bIdentified,
                true);

            if(item == None || item.bDeleteMe || item.bPendingDelete) {
                WPM.Destroy();
            }

            bAllowPickup = 0;
            return true;
        } else if(RPGMut.CheckPDP(Other, class<Weapon>(item.InventoryType))) {
            if(RPRI != None) {
                for (x = 0; x < RPRI.Abilities.length; x++) {
                    if(RPRI.Abilities[x].bAllowed) {
                        if(RPRI.Abilities[x].OverridePickupQuery(Other, item, bAllowPickup)) {
                            //don't allow pickup
                            return true;
                        }
                    }
                }
            }

            if(ModifierClass == None) {
                ModifierClass = RPGMut.GetRandomWeaponModifier(class<Weapon>(item.InventoryType), Other);
                ModifierLevel = -100;
            }

            class'RPGWeaponPickupModifier'.static.SimulateWeaponPickup(
                WeaponPickup(item), Other, ModifierClass, ModifierLevel, RPGMut.GameSettings.bNoUnidentified);

            bAllowPickup = 0;
            return true;
        } else {
            //do nothing / normal pickup
        }
    }

    //Weapon Locker
    if(WeaponLocker(item) != None && RPGMut.CheckPDP(Other, class<Weapon>(item.InventoryType))) {
        if(RPRI != None) {
            for (x = 0; x < RPRI.Abilities.length; x++) {
                if(RPRI.Abilities[x].bAllowed) {
                    if(RPRI.Abilities[x].OverridePickupQuery(Other, item, bAllowPickup)) {
                        //don't allow pickup
                        return true;
                    }
                }
            }
        }

        if(ModifierClass == None) {
            ModifierClass = RPGMut.GetRandomWeaponModifier(class<Weapon>(item.InventoryType), Other);
            ModifierLevel = -100;
        }

        if(class'RPGWeaponPickupModifier'.static.SimulateWeaponLocker(
            WeaponLocker(item), Other, ModifierClass, ModifierLevel, RPGMut.GameSettings.bNoUnidentified))
        {

            bAllowPickup = 0;
            return true;
        }
    }

    //increase value of ammo pickups based on Max Ammo stat
    if (RPRI != None)
    {
        for (x = 0; x < RPRI.Abilities.length; x++)
        {
            if(RPRI.Abilities[x].bAllowed)
            {
                if(RPRI.Abilities[x].OverridePickupQuery(Other, item, bAllowPickup))
                    return true;
            }
        }
    }

    //effects that may have been applied
    for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
        if(RPGEffect(Inv) != None && Inv.IsInState('Activated') && RPGEffect(Inv).OverridePickupQuery(Other, item, bAllowPickup))
            return true;

    if(Ammo(item) != None) {
        //Handle ammo
        AmmoAmount = Ammo(item).AmmoAmount;
        AmmoClass = class<Ammunition>(item.InventoryType);

        //Find all weapons that can use this ammo type
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory) {
            W = Weapon(Inv);
            if(W != None && (W.GetAmmoClass(0) == AmmoClass || W.GetAmmoClass(1) == AmmoClass)) {
                Weapons[Weapons.Length] = W;
            }
        }

        if(Weapons.Length > 0) {
            //Equal share for everyone!
            AmmoAmount /= Weapons.Length;

            //Give ammo
            for(x = 0; x < Weapons.Length; x++) {
                if(Weapons[x].GetAmmoClass(0) == AmmoClass) {
                    Weapons[x].AddAmmo(int(AmmoAmount), 0);
                } else if(Weapons[x].GetAmmoClass(1) == AmmoClass) {
                    Weapons[x].AddAmmo(int(AmmoAmount), 1);
                }
            }

            //Simulate stuff
            item.AnnouncePickup(Other);
            item.SetRespawn();

            bAllowPickup = 0;
            return true;
        } else {
            //no weapons for this type of ammo, proceed with usual scavenger pickup
        }
    }

    return Super.OverridePickupQuery(Other, item, bAllowPickup);
}

function ComboSuccess(Controller Who, class<Combo> ComboClass) {
    local RPGPlayerReplicationInfo RPRI;
    local int i;

    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Who);
    if(RPRI != None) {
        for(i = 0; i < EXP_Combo.Length; i++) {
            if(string(ComboClass) ~= EXP_Combo[i].ComboClass) {
                RPRI.AwardExperience(EXP_Combo[i].Exp);
                break;
            }
        }
    }
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local bool bAlreadyPrevented;
    local int x;
    local Controller KilledController;
    local Pawn KilledVehicleDriver;
    local RPGPlayerReplicationInfo KillerRPRI, KilledRPRI;
    local Ability_VehicleEject EjectorSeat;
    local Artifact_DoubleModifier DoubleMod;

    KillDamageType = damageType;

    if(bGameEnded)
        return Super.PreventDeath(Killed, Killer, damageType, HitLocation);

    //FIXME hotfix, must find a better solution
    DoubleMod = Artifact_DoubleModifier(Killed.FindInventoryType(class'Artifact_DoubleModifier'));
    if(DoubleMod != None && DoubleMod.bActive)
        DoubleMod.GotoState('');

    bAlreadyPrevented = Super.PreventDeath(Killed, Killer, damageType, HitLocation);

    if (Killed.Controller != None)
        KilledController = Killed.Controller;
    else if (Killed.DrivenVehicle != None && Killed.DrivenVehicle.Controller != None)
        KilledController = Killed.DrivenVehicle.Controller;

    if (KilledController != None)
        KilledRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(KilledController);

    if(Vehicle(Killed) != None)
        KilledVehicleDriver = Vehicle(Killed).Driver;

    if (KilledRPRI != None)
    {
        if(Killed.SelectedItem != None)
            KilledRPRI.LastSelectedPowerupType = Killed.SelectedItem.class;
        else
            KilledRPRI.LastSelectedPowerupType = None;

        //detect whether this player switched teams
        if(Level.Game.bTeamGame && KilledRPRI.PRI.Team.TeamIndex != KilledRPRI.Team)
        {
            KilledRPRI.bTeamChanged = true; //allow RPRI to react on spawn
            return false; //cannot save from a team switch
        }
        else
        {
            //FIXME Pawn should probably still call PreventDeath() in cases like this, but it might be wiser to ignore the value
            if (!KilledController.bPendingDelete && (KilledController.PlayerReplicationInfo == None || !KilledController.PlayerReplicationInfo.bOnlySpectator))
            {
                for(x = 0; x < KilledRPRI.Abilities.length; x++)
                {
                    if(KilledRPRI.Abilities[x].bAllowed)
                    {
                        if(KilledRPRI.Abilities[x].PreventDeath(Killed, Killer, damageType, HitLocation, bAlreadyPrevented))
                            bAlreadyPrevented = true;
                    }
                }
            }
        }
    }

    // pawns that call Suicide() use damagetype Suicided and report death with a killer of themselves
    // PhysicsVolumes that deal damage report None for an instigator
    // this check should (hopefully) be enough to ensure we are dying when we really need to
    if(bAlreadyPrevented && DamageType != class'Suicided' && Killer != Killed)
    {
        return true;
    }
    else //yes, ELSE. because vehicle ejection doesn't actually save the victim (the vehicle)
    {
        if(
            Killer != None &&
            Killer != KilledController &&
            KilledVehicleDriver != None)
        {
            KilledRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(KilledController);
            if (KilledRPRI == None)
            {
                Log("KilledRPRI not found for " $ Killed.GetHumanReadableName(), 'TURRPG2');
                return true;
            }

            EjectorSeat = Ability_VehicleEject(KilledRPRI.GetOwnedAbility(class'Ability_VehicleEject'));
            if(EjectorSeat != None && EjectorSeat.HasJustEjected())
            {
                //get data
                KillerRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Killer);
                if (KillerRPRI == None)
                {
                    Log("KillerRPRI not found for " $ Killer.GetHumanReadableName(), 'TURRPG2');
                    return true;
                }

                ShareExperience(KillerRPRI,
                    GetKillEXP(KillerRPRI, KilledRPRI, EXPMul_DestroyVehicle));

                KillerRPRI.PRI.Score += 1.f; //add a game point

                //reset killing spree for ejected player
                if(KilledVehicleDriver.GetSpree() > 4)
                {
                    Killer.AwardAdrenaline(DeathMatch(Level.Game).ADR_MajorKill);
                    ShareExperience(KillerRPRI, EXP_EndSpree);
                    DeathMatch(Level.Game).EndSpree(Killer, KilledController);
                }

                if(UnrealPawn(KilledVehicleDriver) != None)
                    UnrealPawn(KilledVehicleDriver).spree = 0;
            }
        }
    }

    //Give experience and game stats (but NOT points) for killing someone else's monster
    if(FriendlyMonsterController(Killed.Controller) != None)
    {
        //don't count this monster as part of an Invasion wave
        if(Invasion(Level.Game) != None)
            Invasion(Level.Game).NumMonsters++;

        if(Killer != None && Killer != Killed && Killer.bIsPlayer)
        {
            if(FriendlyMonsterController(Killed.Controller).Master != Killer)
            {
                Level.Game.GameRulesModifiers.ScoreKill(Killer, Killed.Controller);
                if(ClassIsChildOf(DamageType, class'WeaponDamageType'))
                    RegisterWeaponKill(Killer.PlayerReplicationInfo, None, class<WeaponDamageType>(DamageType).default.WeaponClass);
                else if(ClassIsChildOf(DamageType, class'VehicleDamageType'))
                    RegisterVehicleKill(Killer.PlayerReplicationInfo, None, class<VehicleDamageType>(DamageType).default.VehicleClass);
            }
        }
    }

    if((damageType.default.bCausedByWorld || damageType == class'DamTypeTeleFrag') && Killed.Health > 0)
    {
        //if this damagetype is an instant kill that bypasses Pawn.TakeDamage() and calls Pawn.Died() directly
        //then we need to award EXP by damage for the rest of the monster's health
        //TODO: AwardEXPForDamage(Killer, class'RPGPlayerReplicationInfo'.static.GetFor(Killer), Killed, Killed.Health);
    }

#ifeq ENABLE_3190_BACK_COMPAT_PATCH 1
    //Yet Another Invasion Hack - Invasion doesn't call ScoreKill() on the GameRules if a monster kills something
    //This one's so bad I swear I'm fixing it for a patch
    if(int(Level.EngineVersion) < 3190 && Invasion(Level.Game) != None && KilledController != None && MonsterController(Killer) != None)
    {
        if (KilledController.PlayerReplicationInfo != None)
            KilledController.PlayerReplicationInfo.bOutOfLives = true;

        ScoreKill(Killer, KilledController);
    }
#endif

    //unless another GameRules decides to prevent death, this is certain death
    if(KillerRPRI == None)
        KillerRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Killer);

    if(KillerRPRI != None)
        KillerRPRI.AdrenalineBeforeKill = Killer.Adrenaline;

    // sort out UDamage for vehicles
    if(Killed.DrivenVehicle != None && Killed.DrivenVehicle.Weapon != None && xPawn(Killed) != None && Killed.HasUDamage())
        Killed.DrivenVehicle.Weapon.SetOverlayMaterial(xPawn(Killed).UDamageWeaponMaterial, 0, false);

    if(KilledRPRI != None)
        KilledRPRI.PlayerDied(false, Killer.Pawn, DamageType);

    return false;
}

function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType)
{
    local RPGPlayerReplicationInfo RPRI;
    local int x;

    if (Killed.Controller != None)
    {
        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Killed.Controller);
        if (RPRI != None)
        {
            for (x = 0; x < RPRI.Abilities.length; x++)
            {
                if(RPRI.Abilities[x].bAllowed)
                {
                    if(RPRI.Abilities[x].PreventSever(Killed, boneName, Damage, DamageType))
                        return true;
                }
            }
        }
    }

    return Super.PreventSever(Killed, boneName, Damage, DamageType);
}

function Timer()
{
    local RPGPlayerReplicationInfo RPRI;
    local Controller C;

    if(Level.Game.bGameEnded)
    {
        //Grant exp for win
        if(EXP_Win > 0)
        {
            if(TeamInfo(Level.Game.GameReplicationInfo.Winner) != None)
            {
                for (C = Level.ControllerList; C != None; C = C.NextController)
                {
                    if (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team == Level.Game.GameReplicationInfo.Winner)
                    {
                        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
                        if (RPRI != None)
                            RPRI.AwardExperience(EXP_Win);
                    }
                }
            }
            else if (PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner) != None
                  && Controller(PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner).Owner) != None )
            {
                RPRI = class'RPGPlayerReplicationInfo'.static.GetForPRI(PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner));
                if (RPRI != None)
                    RPRI.AwardExperience(EXP_Win);
            }
        }

        RPGMut.EndGame();
        SetTimer(0, false);
    }
}

function bool HandleRestartGame()
{
    return Super.HandleRestartGame();
}

static function RegisterWeaponKill(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<Weapon> WeaponClass)
{
    local int i;
    local bool bFound;
    local TeamPlayerReplicationInfo TPRI;
    local TeamPlayerReplicationInfo.WeaponStats NewWeaponStats;

    if(WeaponClass == None)
        return;

    //kill for the killer
    TPRI = TeamPlayerReplicationInfo(Killer);
    if(TPRI != None)
    {
        bFound = false;
        for (i = 0; i < TPRI.WeaponStatsArray.Length; i++ )
        {
            if(TPRI.WeaponStatsArray[i].WeaponClass == WeaponClass)
            {
                TPRI.WeaponStatsArray[i].Kills++;
                bFound = true;
                break;
            }
        }

        if(!bFound)
        {
            NewWeaponStats.WeaponClass = WeaponClass;
            NewWeaponStats.Kills = 1;
            TPRI.WeaponStatsArray[TPRI.WeaponStatsArray.Length] = NewWeaponStats;
        }
    }

    //death for the victim
    TPRI = TeamPlayerReplicationInfo(Victim);
    if(TPRI != None)
    {
        bFound = false;
        for (i = 0; i < TPRI.WeaponStatsArray.Length; i++ )
        {
            if(TPRI.WeaponStatsArray[i].WeaponClass == WeaponClass)
            {
                TPRI.WeaponStatsArray[i].Deaths++;
                bFound = true;
                break;
            }
        }

        if(!bFound)
        {
            NewWeaponStats.WeaponClass = WeaponClass;
            NewWeaponStats.Deaths = 1;
            TPRI.WeaponStatsArray[TPRI.WeaponStatsArray.Length] = NewWeaponStats;
        }
    }
}

static function RegisterVehicleKill(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<Vehicle> VehicleClass)
{
    local int i;
    local bool bFound;
    local TeamPlayerReplicationInfo TPRI;
    local TeamPlayerReplicationInfo.VehicleStats NewVehicleStats;

    if(VehicleClass == None)
        return;

    //kill for the killer
    TPRI = TeamPlayerReplicationInfo(Killer);
    if(TPRI != None)
    {
        bFound = false;
        for (i = 0; i < TPRI.VehicleStatsArray.Length; i++ )
        {
            if(TPRI.VehicleStatsArray[i].VehicleClass == VehicleClass)
            {
                TPRI.VehicleStatsArray[i].Kills++;
                bFound = true;
                break;
            }
        }

        if(!bFound)
        {
            NewVehicleStats.VehicleClass = VehicleClass;
            NewVehicleStats.Kills = 1;
            TPRI.VehicleStatsArray[TPRI.VehicleStatsArray.Length] = NewVehicleStats;
        }
    }

    //death for the victim
    TPRI = TeamPlayerReplicationInfo(Victim);
    if(TPRI != None)
    {
        bFound = false;
        for (i = 0; i < TPRI.VehicleStatsArray.Length; i++ )
        {
            if(TPRI.VehicleStatsArray[i].VehicleClass == VehicleClass)
            {
                TPRI.VehicleStatsArray[i].Deaths++;
                bFound = true;
                break;
            }
        }

        if(!bFound)
        {
            NewVehicleStats.VehicleClass = VehicleClass;
            NewVehicleStats.Deaths = 1;
            TPRI.VehicleStatsArray[TPRI.VehicleStatsArray.Length] = NewVehicleStats;
        }
    }
}

defaultproperties
{
    bDamageLog=False

    DisgraceAnnouncement=None
    EagleEyeAnnouncement=Sound'AnnouncerMale2K4.Generic.EagleEye'
    DirectDamageTypes(0)=class'DamTypeMasochism'
    DirectDamageTypes(1)=class'DamTypePoison'
    DirectDamageTypes(2)=class'DamTypeRetaliation'
    DirectDamageTypes(3)=class'DamTypeFatality'
    NoUDamageTypes(0)=class'DamTypeRetaliation'

    //Kills
    EXP_Frag=1.00
    EXP_SelfFrag=0.00 //-1.00 really, but we don't want to lose exp here
    EXP_TeamFrag=0.00
    EXP_TypeKill=0.00

    EXP_EndSpree=5.00
    EXP_CriticalFrag=3.00

    EXP_FirstBlood=5.00
    EXP_KillingSpree(0)=5.00
    EXP_KillingSpree(1)=5.00
    EXP_KillingSpree(2)=5.00
    EXP_KillingSpree(3)=5.00
    EXP_KillingSpree(4)=5.00
    EXP_KillingSpree(5)=5.00
    EXP_MultiKill(0)=5.00
    EXP_MultiKill(1)=5.00
    EXP_MultiKill(2)=5.00
    EXP_MultiKill(3)=5.00
    EXP_MultiKill(4)=5.00
    EXP_MultiKill(5)=5.00
    EXP_MultiKill(6)=5.00

    //Special kills
    EXP_Telefrag=1.00
    EXP_Headshot=1.00

    //Awards
    EXP_HeadHunter=15.00
    EXP_ComboWhore=15.00
    EXP_FlakMonkey=15.00
    EXP_RoadRampage=15.00
    EXP_Daredevil=0.01 //per daredevil point

    //Game events
    EXP_Win=30

    EXP_DestroyPowercore=50
    EXP_DestroyPowernode=5
    EXP_DestroyConstructingPowernode=2.50
    EXP_ConstructPowernode=2.50
    EXP_HealPowernode=0.01

    EXP_ReturnFriendlyFlag=3.00
    EXP_ReturnEnemyFlag=5.00
    EXP_FlagDenial=7.00

    EXP_FlagCapFirstTouch=5.00
    EXP_FlagCapAssist=5.00
    EXP_FlagCapFinal=5.00

    EXP_ObjectiveCompleted=1.00

    EXP_BallThrownFinal=5.00
    EXP_BallCapFinal=10.00
    EXP_BallScoreAssist=5.00

    EXP_DOMScore=5.00

    //TitanRPG
    EXP_Healing=0.01
    EXP_TeamBooster=0.10 //per second per healed player (excluding yourself)

    //Misc
    EXP_VehicleRepair=0.005 //experience for repairing one "health point"
    EXP_Assist=15.00 //Score Assist

    //Multipliers
    EXPMul_DestroyVehicle=0.67
    EXPMul_SummonKill=0.67
}
