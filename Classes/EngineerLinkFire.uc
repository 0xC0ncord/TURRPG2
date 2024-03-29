//=============================================================================
// EngineerLinkFire.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

// increased link beam for Engineers, but shorter range
class EngineerLinkFire extends RPGLinkFire;

var WeaponModifier_EngineerLink EGun;

function WeaponModifier_EngineerLink GetEngineerLinkWeaponModifier()
{
    return WeaponModifier_EngineerLink(class'WeaponModifier_EngineerLink'.static.GetFor(Weapon));
}

simulated function ModeTick(float dt)
{
    local Vector StartTrace, EndTrace, V, X, Y, Z;
    local Vector HitLocation, HitNormal, EndEffect;
    local Actor Other;
    local Rotator Aim;
    local LinkGun LinkGun;
    local float Step, ls;
    local bot B;
    local bool bShouldStop, bIsHealingObjective;
    local int AdjustedDamage, OldHealth;
    local LinkBeamEffect LB;
    local DestroyableObjective HealObjective;
    local RPGGameObjectiveObserver Observer;
    local Vehicle LinkedVehicle;
    local ONSMineProjectile Mine;
    local TransBeacon Beacon;
    local Sync_TransBeaconRepair Sync;
    local vector Momentum; //technically not even used

    if(!bIsFiring)
    {
        bInitAimError = true;
        return;
    }

    LinkGun = LinkGun(Weapon);

    if(EGun == None)
        EGun = GetEngineerLinkWeaponModifier();

    if(LinkGun.Links < 0)
    {
        Warn(Instigator@"linkgun had"@LinkGun.Links@"links");
        LinkGun.Links = 0;
    }

    ls = LinkScale[Min(LinkGun.Links,5)];

    if(myHasAmmo(LinkGun) && (UpTime > 0.0 || Instigator.Role < ROLE_Authority))
    {
        UpTime -= dt;

        // the to-hit trace always starts right in front of the eye
        LinkGun.GetViewAxes(X, Y, Z);
        StartTrace = GetFireStart( X, Y, Z);
        TraceRange = default.TraceRange + LinkGun.Links*250;

        if(Instigator.Role < ROLE_Authority)
        {
            if(Beam == None)
            {
                foreach Weapon.DynamicActors(class'LinkBeamEffect', LB)
                {
                    if(!LB.bDeleteMe && LB.Instigator != None && LB.Instigator == Instigator)
                    {
                        Beam = LB;
                        break;
                    }
                }
            }

            if(Beam != None)
                LockedPawn = Beam.LinkedPawn;
        }

        if(LockedPawn != None)
            TraceRange *= 1.5;

        if(Instigator.Role == ROLE_Authority)
        {
            if(bDoHit)
                LinkGun.ConsumeAmmo(ThisModeNum, AmmoPerFire);

            B = Bot(Instigator.Controller);
            if(B != None && PlayerController(B.Squad.SquadLeader) != None && B.Squad.SquadLeader.Pawn != None)
            {
                if(IsLinkable(B.Squad.SquadLeader.Pawn)
                    && B.Squad.SquadLeader.Pawn.Weapon != None
                    && B.Squad.SquadLeader.Pawn.Weapon.GetFireMode(1).bIsFiring
                    && VSize(B.Squad.SquadLeader.Pawn.Location - StartTrace) < TraceRange
                )
                {
                    Other = Weapon.Trace(HitLocation, HitNormal, B.Squad.SquadLeader.Pawn.Location, StartTrace, true);
                    if(Other == B.Squad.SquadLeader.Pawn)
                    {
                        B.Focus = B.Squad.SquadLeader.Pawn;
                        if(B.Focus != LockedPawn)
                            SetLinkTo(B.Squad.SquadLeader.Pawn);
                        B.SetRotation(Rotator(B.Focus.Location - StartTrace));
                        X = Normal(B.Focus.Location - StartTrace);
                    }
                    else if(B.Focus == B.Squad.SquadLeader.Pawn)
                        bShouldStop = true;
                }
                else if(B.Focus == B.Squad.SquadLeader.Pawn)
                    bShouldStop = true;
            }
        }

        if(LockedPawn != None)
        {
            EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight * vect(0, 0, 0.5); // beam ends at approx gun height
            if(Instigator.Role == ROLE_Authority)
            {
                V = Normal(EndTrace - StartTrace);
                if(V dot X < LinkFlexibility
                    || LockedPawn.Health <= 0
                    || LockedPawn.bDeleteMe
                    || VSize(EndTrace - StartTrace) > 1.5 * TraceRange
                )
                {
                    SetLinkTo( None );
                }
            }
        }

        if(LockedPawn == None)
        {
            if(Bot(Instigator.Controller) != None)
            {
                if(bInitAimError)
                {
                    CurrentAimError = AdjustAim(StartTrace, AimError);
                    bInitAimError = false;
                }
                else
                {
                    BoundError();
                    CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;
                }

                // smooth aim error changes
                Step = 7500.0 * dt;
                if(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw)
                {
                    CurrentAimError.Yaw += Step;
                    if(!(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw))
                    {
                        CurrentAimError.Yaw = DesiredAimError.Yaw;
                        DesiredAimError = AdjustAim(StartTrace, AimError);
                    }
                }
                else
                {
                    CurrentAimError.Yaw -= Step;
                    if(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw)
                    {
                        CurrentAimError.Yaw = DesiredAimError.Yaw;
                        DesiredAimError = AdjustAim(StartTrace, AimError);
                    }
                }
                CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
                if(BoundError())
                    DesiredAimError = AdjustAim(StartTrace, AimError);
                CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;

                if(Instigator.Controller.Target == None)
                    Aim = Rotator(Instigator.Controller.FocalPoint - StartTrace);
                else
                    Aim = Rotator(Instigator.Controller.Target.Location - StartTrace);

                Aim.Yaw = CurrentAimError.Yaw;

                // save difference
                CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
            }
            else
                Aim = GetPlayerAim(StartTrace, AimError);

            X = Vector(Aim);
            EndTrace = StartTrace + TraceRange * X;
        }

        Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if(Other != None && Other != Instigator)
            EndEffect = HitLocation;
        else
            EndEffect = EndTrace;

        if(Beam != None)
            Beam.EndEffect = EndEffect;

        if(Instigator.Role < ROLE_Authority)
        {
            if(LinkGun.ThirdPersonActor != None)
            {
                if(LinkGun.Linking
                    || (Other != None && Instigator.PlayerReplicationInfo.Team != None && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex))
                )
                {
                    if(Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
                        LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Red);
                    else
                        LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Blue);
                }
                else
                {
                    if(LinkGun.Links > 0)
                        LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Gold);
                    else
                        LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Green);
                }
            }
            return;
        }
        if(Other != None && Other != Instigator)
        {
            // target can be linked to
            if(IsLinkable(Other))
            {
                if(Other != LockedPawn)
                    SetLinkTo( Pawn(Other) );

                if(LockedPawn != None)
                    LinkBreakTime = LinkBreakDelay;
            }
            else
            {
                // stop linking
                if(LockedPawn != None)
                {
                    if(LinkBreakTime <= 0.0)
                        SetLinkTo(None);
                    else
                        LinkBreakTime -= dt;
                }

                // beam is updated every frame, but damage is only done based on the firing rate
                if(bDoHit)
                {
                    if(Beam != None)
                        Beam.bLockedOn = false;

                    Instigator.MakeNoise(1.0);

                    AdjustedDamage = AdjustLinkDamage(LinkGun, Other, Damage);

                    if(!Other.bWorldGeometry)
                    {
                        if(Level.Game.bTeamGame
                            && Pawn(Other) != None
                            && Pawn(Other).PlayerReplicationInfo != None
                            && Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team
                        ) // so even if friendly fire is on you can't hurt teammates
                        {
                            AdjustedDamage = 0;
                        }

                        HealObjective = DestroyableObjective(Other);
                        if(HealObjective == None)
                            HealObjective = DestroyableObjective(Other.Owner);
                        if(HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()))
                        {
                            SetLinkTo(None);
                            bIsHealingObjective = true;
/*                          if (!HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
                                LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);*/
                            OldHealth = HealObjective.Health;
                            if(HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
                            {
                                if(HealObjective.Health - OldHealth > 0)
                                {
                                    Observer = class'RPGGameObjectiveObserver'.static.GetFor(HealObjective);
                                    if(Observer != None)
                                        Observer.Healed(Instigator.Controller, HealObjective.Health - OldHealth);
                                }
                            }
                            else
                                LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
                        }
                        else
                        {
                            if(EGun != None)
                            {
                                if(ONSMineProjectile(Other) != None)
                                {
                                    Mine = ONSMineProjectile(Other);
                                    if(EGun.SpiderBoostLevel > 0 && Mine.Damage < (1f * EGun.SpiderBoostLevel) * Mine.default.Damage)
                                        EGun.BoostMine(Mine, EGun.SpiderGrowthRate);
                                }
                                else if(TransBeacon(Other) != None && TransBeacon(Other).Disrupted())
                                {
                                    Beacon = TransBeacon(Other);
                                    if(EGun.bHasTransRepair
                                        && Level.Game.bTeamGame
                                        && Instigator != None
                                        && Instigator.Controller != None
                                        && Beacon.Instigator != None
                                        && Instigator.Controller.SameTeamAs(Beacon.Instigator.Controller)
                                    )
                                    {
                                        Beacon.Disruptor = None;
                                        Beacon.Disruption = 0;
                                        if(Beacon.Sparks != None)
                                        {
                                            Beacon.Sparks.Detach(Beacon);
                                            Beacon.Sparks.Destroy();
                                            Beacon.SetTimer(0.3, false); // so it may do sparks again if it gets damaged
                                        }
                                        if(Beacon.Flare == None)
                                        {
                                            Beacon.Flare = Beacon.Spawn(Beacon.TransFlareClass, Beacon,, Beacon.Location - vect(0, 0, 5), rot(16384, 0, 0));
                                            Beacon.Flare.SetBase(Beacon);
                                        }
                                        if(Level.NetMode != NM_Standalone)
                                        {
                                            Sync = Instigator.Spawn(class'Sync_TransBeaconRepair');
                                            Sync.Beacon = Beacon;
                                            Sync.ProjLoc = Other.Location;
                                        }
                                    }
                                }
                                else
                                    Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer*X, DamageType);
                            }
                            else
                                Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer*X, DamageType);
                        }

                        if(Beam != None)
                            Beam.bLockedOn = true;
                    }
                }
            }
        }

        if(LockedPawn != None) //giving shields or health to someone we are linking to
        {
            AdjustedDamage = Damage * (1.5 * Linkgun.Links + 1) * Instigator.DamageScaling;
            if(EGun != None)
            {
                EGun.AdjustTargetDamage(
                    AdjustedDamage,
                    AdjustedDamage,
                    LockedPawn,
                    Instigator,
                    LockedPawn.Location,
                    Momentum,
                    class'DamTypeLinkShaft'
                );
            }
        }

        // vehicle healing
        LinkedVehicle = Vehicle(LockedPawn);
        if(LinkedVehicle != None && bDoHit)
        {
            AdjustedDamage = Damage * (1.5 * Linkgun.Links + 1) * Instigator.DamageScaling;
            if(Instigator.HasUDamage())
                AdjustedDamage *= 2;
            if(!LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
                LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
        }
        LinkGun(Weapon).Linking = (LockedPawn != None) || bIsHealingObjective;

        if(bShouldStop)
            B.StopFiring();
        else
        {
            // beam effect is created and destroyed when firing starts and stops
            if(Beam == None && bIsFiring)
            {
                Beam = Weapon.Spawn(BeamEffectClass, Instigator);
                // vary link volume to make sure it gets replicated (in case owning player changed it client side)
                if(SentLinkVolume == Default.LinkVolume)
                    SentLinkVolume = Default.LinkVolume + 1;
                else
                    SentLinkVolume = Default.LinkVolume;
            }

            if(Beam != None)
            {
                if(LinkGun.Linking
                    || (Other != None && Instigator.PlayerReplicationInfo.Team != None && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex))
                )
                {
                    Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
                    if(LinkGun.ThirdPersonActor != None)
                    {
                        if(Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
                            LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Red);
                        else
                            LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Blue);
                    }
                }
                else
                {
                    Beam.LinkColor = 0;
                    if (LinkGun.ThirdPersonActor != None)
                    {
                        if(LinkGun.Links > 0)
                            LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Gold);
                        else
                            LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Green);
                    }
                }

                Beam.Links = LinkGun.Links;
                Instigator.AmbientSound = BeamSounds[Min(Beam.Links, 3)];
                Instigator.SoundVolume = SentLinkVolume;
                Beam.LinkedPawn = LockedPawn;
                Beam.bHitSomething = (Other != None);
                Beam.EndEffect = EndEffect;
            }
        }
    }
    else
        StopFiring();

    bStartFire = false;
    bDoHit = false;
}

defaultproperties
{
     Damage=35
     TraceRange=400.000000
     FireRate=0.240000
}
