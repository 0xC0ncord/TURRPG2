class RPGDefenseSentinelController extends Controller;

var Controller PlayerSpawner;
var RPGPlayerReplicationInfo RPRI;
var FriendlyPawnReplicationInfo FPRI;

var float TimeBetweenShots;
var float TargetRadius;
var float XPPerHit;         // the amount of xp the summoner gets per projectile taken out
var float XPPerHealing;     // the amount of xp the summoner gets per projectile taken out
var int HealFreq;           // how often to go through the healing loop. 2 means every other time.

var float DamageAdjust;     // set by AbilityLoadedEngineer

var class<xEmitter> HitEmitterClass; // for standard defense sentinel
var class<xEmitter> ShieldEmitterClass;
var class<xEmitter> HealthEmitterClass;
var class<xEmitter> AdrenalineEmitterClass;
var class<xEmitter> ResupplyEmitterClass;
var class<xEmitter> ArmorEmitterClass;

var Material HealingOverlay;

var bool bHealing;
var int DoHealCount;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    FPRI = Spawn(class'FriendlyPawnReplicationInfo');
}

function Possess(Pawn aPawn)
{
    Super.Possess(aPawn);
    FPRI.Pawn = aPawn;
}

function SetPlayerSpawner(Controller PlayerC)
{
    local Ability_WeaponSpeed Ability;

    PlayerSpawner = PlayerC;
    FPRI.Master = PlayerSpawner.PlayerReplicationInfo;
    if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None )
    {
        PlayerReplicationInfo = spawn(class'FriendlyPawnPlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
        PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
        if(Pawn!=None)
            Pawn.PlayerReplicationInfo = PlayerReplicationInfo;

        // adjust the fire rate according to weapon speed
        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(PlayerSpawner);
        if (RPRI != None)
        {
            Ability = Ability_WeaponSpeed(RPRI.GetAbility(class'Ability_WeaponSpeed'));
            if(Ability != None)
                TimeBetweenShots = (default.TimeBetweenShots * 100) / (100 + Ability.AbilityLevel * int(Ability.BonusPerLevel * 100.0));
        }
        if (DamageAdjust > 0.1)
            TimeBetweenShots = TimeBetweenShots / DamageAdjust;     // cant adjust damage for DamageAdjust, so update fire frequency
    }
    SetTimer(TimeBetweenShots, true);
}

function DoHealing()
{
    local Controller C;
    local xEmitter HitEmitter;
    Local Pawn LoopP, RealP;
    Local RPGDefenseSentinel DefPawn;
    Local float NumHelped;
    Local Inv_HealableDamage HDInv;
    local Effect_ShieldBoost Shield;
    local Effect_Heal Heal;
    local Effect_Adrenaline Adren;
    local Effect_Ammo Ammo;

    if (Pawn == None || Pawn.Health <= 0 || RPGDefenseSentinel(Pawn) == None)
        return;
    DefPawn = RPGDefenseSentinel(Pawn);

    if (DefPawn.ShieldHealingLevel==0 && DefPawn.HealthHealingLevel==0 && DefPawn.AdrenalineHealingLevel==0 && DefPawn.ResupplyLevel==0 && DefPawn.ArmorHealingLevel == 0)
        return;

    NumHelped = 0.0;

    if (bHealing)
    {
//      Log("=================!!!!! bHealing still set ");      // just in case the cpu gets too busy
        return;
    }
    bHealing = true;

   // loop through all the pawns in range. Can't use controllers as blocks and unmanned turrets/vehicles do not have controllers.
    foreach DynamicActors(class'Pawn', LoopP)
    {
    // first check if the pawn is anywhere near
        if (LoopP != None && VSize(LoopP.Location - DefPawn.Location) < TargetRadius && FastTrace(LoopP.Location, DefPawn.Location))
        {
            // ok, let's go for it
            C = LoopP.Controller;

            if ( C != None && DefPawn != None && LoopP != DefPawn && LoopP.Health > 0 && C.SameTeamAs(self) )
            {
                //ok lets see if we can help.
                RealP = LoopP;
                if (LoopP != None && Vehicle(LoopP)!=None)
                    RealP = Vehicle(LoopP).Driver;

                if (RealP != None && XPawn(RealP) != None)  // only interested in health/shields/ammo/adren for player pawns
                {
                    //see if they have hardcore. assume they dont if cant get RPRI
                    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(RealP.Controller);
                    if(RPRI == None || RPRI.HasAbility(class'Ability_Hardcore') == 0)
                    {
                        //first check shield healing
                        if (DefPawn.ShieldHealingLevel > 0 && RealP.GetShieldStrength() < RealP.GetShieldStrengthMax())
                        {
                            // can add some shield
                            Shield=Effect_ShieldBoost(class'Effect_ShieldBoost'.static.Create(RealP,PlayerSpawner));
                            if(Shield!=None)
                            {
                                Shield.ShieldAmount=DefPawn.ShieldHealingAmount * DefPawn.ShieldHealingLevel;
                                Shield.Start();
                            }

                            HitEmitter = spawn(ShieldEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
                            if (HitEmitter != None)
                                HitEmitter.mSpawnVecA = RealP.Location;

                            HDInv = Inv_HealableDamage(RealP.FindInventoryType(class'Inv_HealableDamage'));
                            if(HDInv != None)
                            {
                                //help keep things in check so a player never has surplus damage in storage. But don't claim any for this.
                                if(HDInv.Damage > (RealP.HealthMax + Class'GameRules_HealableDamage'.default.MaxHealthBonus) - RealP.Health)
                                    HDInv.Damage = Max(0, (RealP.HealthMax + Class'GameRules_HealableDamage'.default.MaxHealthBonus) - RealP.Health); //never let it go negative.
                            }
                            if (PlayerSpawner != C)
                                NumHelped += (DefPawn.ShieldHealingLevel * 2);  // score double for shields
                        }
                        else    // try health healing

                        if (DefPawn.HealthHealingLevel > 0 && RealP.Health < (RealP.HealthMax + 100))
                        {
                            // can add some health
                            Heal=Effect_Heal(class'Effect_Heal'.static.Create(RealP,PlayerSpawner));
                            if(Heal!=None)
                            {
                                Heal.HealAmount=Max(1,(DefPawn.HealthHealingAmount * DefPawn.HealthHealingLevel));
                                Heal.Start();
                            }

                            HitEmitter = spawn(HealthEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
                            if (HitEmitter != None)
                                HitEmitter.mSpawnVecA = RealP.Location;

                            HDInv = Inv_HealableDamage(RealP.FindInventoryType(class'Inv_HealableDamage'));
                            if(HDInv != None)
                            {
                                //help keep things in check so a player never has surplus damage in storage. But don't use any for this healing
                                if(HDInv.Damage > (RealP.HealthMax + Class'GameRules_HealableDamage'.default.MaxHealthBonus) - RealP.Health)
                                    HDInv.Damage = Max(0, (RealP.HealthMax + Class'GameRules_HealableDamage'.default.MaxHealthBonus) - RealP.Health); //never let it go negative.
                            }
                            if(PlayerSpawner != C)
                                NumHelped += (DefPawn.HealthHealingLevel * 3);  // score triple for health;
                        }
                        else    // try adding adrenaline
                        if (DefPawn.AdrenalineHealingLevel > 0 && C.Adrenaline < C.AdrenalineMax && !RealP.InCurrentCombo() && !class'RPGArtifact'.static.HasActiveArtifact(RealP))
                        {
                            // can add some adrenaline
                            Adren=Effect_Adrenaline(class'Effect_Adrenaline'.static.Create(RealP,PlayerSpawner));
                            if(Adren!=None)
                            {
                                Adren.AdrenalineAmount=DefPawn.AdrenalineHealingAmount * DefPawn.AdrenalineHealingLevel;
                                Adren.Start();
                            }

                            HitEmitter = spawn(AdrenalineEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
                            if (HitEmitter != None)
                                HitEmitter.mSpawnVecA = RealP.Location;

                            if(PlayerSpawner != C)
                                NumHelped += DefPawn.AdrenalineHealingLevel;
                        }
                        else    // try resupply
                        if (DefPawn.ResupplyLevel > 0 && RealP.Weapon != None && RealP.Weapon.AmmoClass[0] != None && class'Util'.static.InArray(RealP.Weapon.AmmoClass[0], class'MutTURRPG'.default.SuperAmmoClasses)==0
                            && !RealP.Weapon.AmmoMaxed(0))
                        {
                            // can add some ammo
                            Ammo=Effect_Ammo(class'Effect_Ammo'.static.Create(RealP,PlayerSpawner));
                            if(Ammo!=None)
                            {
                                Ammo.AmmoAmount=Max(1,(DefPawn.ResupplyAmount * DefPawn.ResupplyLevel));
                                Ammo.Start();
                            }

                            HitEmitter = spawn(ResupplyEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
                            if (HitEmitter != None)
                                HitEmitter.mSpawnVecA = RealP.Location;

                            if(PlayerSpawner != C)
                                NumHelped += DefPawn.ResupplyLevel;
                        }
                    }
                }
            }

            // ok now lets see if we are healing armor (and buildings). But no xp for this. (xp for healing blocks of concrete?)
            if (DefPawn != None && DefPawn.ArmorHealingLevel > 0)
            {
                // check for what the pawn is
                if (LoopP != None && LoopP != DefPawn && LoopP.Health > 0)
                {
                    // can heal virtually anything except for ONS weapon pawns... some don't get health updates properly and the sentinel will infinitely try to heal it
                    if ((Vehicle(LoopP) != None || RPGBlock(LoopP) != None || RPGExplosive(LoopP) != None || RPGEnergyWall(LoopP) != None) && ONSWeaponPawn(LoopP) == None)
                    {
                        // looking good so far. Now let's check if on same team
                        if (LoopP.GetTeamNum() == DefPawn.GetTeamNum() && LoopP.Health < LoopP.HealthMax)
                        {
                            // can add some health
                            LoopP.GiveHealth(max(1,(DefPawn.ArmorHealingAmount * DefPawn.ArmorHealingLevel * LoopP.HealthMax)*0.01f), LoopP.HealthMax);
                            HitEmitter = spawn(ArmorEmitterClass,,, DefPawn.Location, rotator(LoopP.Location - DefPawn.Location));
                            if (HitEmitter != None)
                                HitEmitter.mSpawnVecA = LoopP.Location;

                        }
                    }
                }
            }
        }
    }

    if ((XPPerHealing > 0) && (NumHelped > 0) && PlayerSpawner != None && PlayerSpawner.Pawn != None)
    {
        // now give xp according to number healped.
        if (RPRI == None)
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(PlayerSpawner);
        if (RPRI != None)
        {
            class'RPGRules'.static.ShareExperience(RPRI,XPPerHealing * NumHelped);
        }
    }

    bHealing = false;

}

function Timer()
{
    // lets target some enemies
    local Projectile P;
    local xEmitter HitEmitter;
    local Projectile ClosestP;
    local Projectile BestGuidedP;
    local Projectile BestP;
    local int ClosestPdist;
    local int BestGuidedPdist;
    Local RPGDefenseSentinel DefPawn;
    local Sync_ProjectileDestroy DSync;

    if (PlayerSpawner == None || PlayerSpawner.Pawn == None || Pawn == None || Pawn.Health <= 0 || RPGDefenseSentinel(Pawn) == None)
        return;     // going to die soon.

    DefPawn = RPGDefenseSentinel(Pawn);

    // look for projectiles in range
    ClosestP = None;
    BestGuidedP = None;
    ClosestPdist = TargetRadius+1;
    BestGuidedPdist = TargetRadius+1;
    ForEach DynamicActors(class'Projectile',P)
    {
        if (P != None && VSize(Pawn.Location - P.Location) <= TargetRadius && FastTrace(P.Location, Pawn.Location))
        {
            if (P.Physics == PHYS_None || P.IsInState('Dying') || P.bDeleteMe || P.IsA('LenPlamsaBall') || P.IsA('BHProjectile'))   // to stop attacking an exploding redeemer or whatever else
                continue;

            if (TranslocatorBeacon(P) == None && (P.InstigatorController == None ||
                (P.InstigatorController != None &&
                    ((TeamGame(Level.Game) != None && !P.InstigatorController.SameTeamAs(PlayerSpawner) && !ProjInstigatorSameTeam(P))  // not same team
                     || (TeamGame(Level.Game) == None && P.InstigatorController != PlayerSpawner)))))   // or just not me
            {
              // its an enemy projectile
                // target closest projectiles only. we now have a sync actor to deal with blowing things up clientside
                if ( BestGuidedPdist > VSize(Pawn.Location - P.Location))
                {
                    BestGuidedP = P;
                    BestGuidedPdist = VSize(Pawn.Location - P.Location);
                }
                if ( ClosestPdist > VSize(Pawn.Location - P.Location) && !P.bDeleteMe)
                {
                    ClosestP = P;
                    ClosestPdist = VSize(Pawn.Location - P.Location);
                }
            }
        }
    }
    if (BestGuidedP != None)
        BestP = BestGuidedP;
    else
        BestP = ClosestP;

    if (BestP != None)
    {
        HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(BestP.Location - Pawn.Location));
        if (HitEmitter != None)
            HitEmitter.mSpawnVecA = BestP.Location;

      // destroy it
        if(BestP.bNetTemporary)
        {
            DSync = Instigator.Spawn(class'Sync_ProjectileDestroy');
            DSync.Proj = BestP;
            DSync.ProjClass = BestP.class;
            DSync.ProjLoc = BestP.Location;
            DSync.ProjInstigator = BestP.Instigator;
        }
        else
            BestP.NetUpdateTime = Level.TimeSeconds - 1;
        BestP.Destroy();

        // ok, lets see if the initiator gets any xp
            if (RPRI == None && PlayerSpawner != None)
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(PlayerSpawner);
        // quick check to make sure we got the RPGMut set
        if ((XPPerHit > 0) && (RPRI != None))
        {
            class'RPGRules'.static.ShareExperience(RPRI,XPPerHit);
        }
    }
    else
    {
        // no projectile to shoot down. Let's see if there is anything else we can do. Try healing - but only in teamgames
        if ((TeamGame(Level.Game) != None))
        {
            DoHealCount++;
            if (DoHealCount >= HealFreq)
            {
                DoHealCount = 0;    // reset
                DoHealing();
            }
        }
    }
}

function bool ProjInstigatorSameTeam(Projectile P) //for projectiles that don't call Super.PostBeginPlay() (i.e. Titan rocks)
{
    if(PlayerSpawner!=None && P.Instigator!=None && P.Instigator.Controller!=None && P.Instigator.Controller.SameTeamAs(PlayerSpawner))
        return true;
}

function Destroyed()
{
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();

    Super.Destroyed();
}

defaultproperties
{
     TimeBetweenShots=0.600000
     TargetRadius=700.000000
     XPPerHit=0.066000
     XPPerHealing=0.020000
     HealFreq=4
     DamageAdjust=1.000000
     HitEmitterClass=Class'FX_Bolt_Green'
     ShieldEmitterClass=Class'FX_Bolt_Gold'
     HealthEmitterClass=Class'FX_Bolt_Cyan'
     AdrenalineEmitterClass=Class'FX_Bolt_White'
     ResupplyEmitterClass=Class'FX_Bolt_Red'
     ArmorEmitterClass=Class'FX_Bolt_Bronze'
     HealingOverlay=Shader'PulseBlueShader'
}
