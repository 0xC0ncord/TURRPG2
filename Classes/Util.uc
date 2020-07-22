//=============================================================================
// Util.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    class holding static utility functions
*/

class Util extends Object abstract;

var Color HighlightColor;

static function vector ReflectVector(vector v, vector normal)
{
    return (v - 2.0 * normal * (v dot normal));
}

static function bool InVehicle(Pawn P, Vehicle V) {
    if(P.DrivenVehicle != None) {
        if(P.DrivenVehicle == V) {
            return true;
        } else if(ONSWeaponPawn(P.DrivenVehicle) != None && ONSWeaponPawn(P.DrivenVehicle).VehicleBase == V) {
            return true;
        }
    }

    return false;
}

static function array<Pawn> GetAllPassengers(Vehicle V)
{
    local array<Pawn> Passengers;
    local int x;
    local ONSVehicle OV;
    local ONSWeaponPawn WP;

    if(ONSVehicle(V) != None)
        OV = ONSVehicle(V);
    else if(ONSWeaponPawn(V) != None)
        OV = ONSWeaponPawn(V).VehicleBase;

    if(OV != None)
    {
        if(OV.Driver != None)
            Passengers[Passengers.Length] = OV.Driver;

        for(x = 0; x < OV.WeaponPawns.Length; x++)
        {
            WP = OV.WeaponPawns[x];

            if(WP.Driver != None)
                Passengers[Passengers.Length] = WP.Driver;
        }
    }
    else
    {
        if(V.Driver != None)
            Passengers[Passengers.Length] = V.Driver;
    }

    return Passengers;
}

static function array<Controller> GetAllPassengerControllers(Vehicle V)
{
    local array<Controller> Passengers;
    local int x;
    local ONSVehicle OV;
    local ONSWeaponPawn WP;

    if(V.Controller != None)
        Passengers[Passengers.Length] = V.Controller;

    if(ONSVehicle(V) != None)
        OV = ONSVehicle(V);
    else if(ONSWeaponPawn(V) != None)
        OV = ONSWeaponPawn(V).VehicleBase;

    if(OV != None)
    {
        for(x = 0; x < OV.WeaponPawns.Length; x++)
        {
            WP = OV.WeaponPawns[x];

            if(WP.Controller != None)
                Passengers[Passengers.Length] = WP.Controller;
        }
    }

    return Passengers;
}

static final function EjectAllDrivers(Vehicle V)
{
    local int x;
    local ONSVehicle OV;
    local ONSWeaponPawn WP;

    if(ONSVehicle(V) != None)
        OV = ONSVehicle(V);
    else if(ONSWeaponPawn(V) != None)
        OV = ONSWeaponPawn(V).VehicleBase;

    if(OV != None)
    {
        for(x = 0; x < OV.WeaponPawns.Length; x++)
        {
            WP = OV.WeaponPawns[x];

            if(WP.Driver != None)
                WP.EjectDriver();
        }

        if(OV.Driver != None)
            OV.EjectDriver();
    }
    else
    {
        if(V.Driver != None)
            V.EjectDriver();
    }
}

static final function Vehicle GetRootVehicle(Vehicle V)
{
    if(ONSWeaponPawn(V) != None && ONSWeaponPawn(V).VehicleBase != None)
        return ONSWeaponPawn(V).VehicleBase;
    return V;
}

static function string HighlightText(string Text, Color Highlight, Color Old)
{
    return class'GameInfo'.static.MakeColorCode(Highlight) $ Text $ class'GameInfo'.static.MakeColorCode(Old);
}

static function string FormatPercent(float p)
{
    return FormatFloat(p * 100.0) $ "%";
}

static function string FormatFloat(float p)
{
    //~= to avoid evil floating point magic
    if(float(int(p)) ~= p)
        return string(int(p));
    else
        return string(p);
}

static function int InArray(Object x, array<Object> a)
{
    local int i;

    for(i = 0; i < a.Length; i++)
    {
        if(a[i] == x)
            return i;
    }

    return -1;
}

static function PawnScaleSpeed(Pawn P, float Multiplier)
{
    P.GroundSpeed *= Multiplier;
    P.WaterSpeed *= Multiplier;
    P.AirSpeed *= Multiplier;
}

static function Inventory GiveInventory(Pawn P, class<Inventory> InventoryClass, optional bool bRemoveIfExists)
{
    local Inventory Inv;

    if(InventoryClass == None)
        return None;

    Inv = P.FindInventoryType(InventoryClass);
    if(Inv != None && bRemoveIfExists)
    {
        Inv.Destroy();
        Inv = None;
    }

    if(Inv == None)
    {
        Inv = P.Spawn(InventoryClass, P);
        if( Inv != None )
        {
            Inv.GiveTo(P);
            if ( Inv != None )
                Inv.PickupFunction(P);
        }
    }

    return Inv;
}

static function SetWeaponFireRate(Weapon W, float Scale)
{
    local int i;
    local WeaponFire WF;
    local float BarrelRotationsPerSec;

    if(W == None)
        return;

    for(i = 0; i < W.NUM_FIRE_MODES; i++)
    {
        WF = W.GetFireMode(i);
        if(WF != None)
        {
            if(MinigunFire(WF) != None) //minigun needs a hack because it fires differently than normal weapons
            {
                MinigunFire(WF).BarrelRotationsPerSec = MinigunFire(WF).default.BarrelRotationsPerSec * Scale;
                WF.FireRate = 1.f / (MinigunFire(WF).RoundsPerRotation * MinigunFire(WF).BarrelRotationsPerSec);
                MinigunFire(WF).MaxRollSpeed = 65536.f * MinigunFire(WF).BarrelRotationsPerSec;
            }
            else if(WF.IsA('TURMinigunFire'))
            {
                BarrelRotationsPerSec = class'MinigunFire'.default.BarrelRotationsPerSec * Scale;
                WF.SetPropertyText("BarrelRotationsPerSec", string(BarrelRotationsPerSec));
                WF.FireRate = 1.f / (float(WF.GetPropertyText("RoundsPerRotation")) * BarrelRotationsPerSec);
                WF.SetPropertyText("MaxRollSpeed", string(65536.f * BarrelRotationsPerSec));
            }
            else if(TransFire(WF) == None && BallShoot(WF) == None)
            {
                WF.FireRate = WF.default.FireRate / Scale;
                WF.FireAnimRate = WF.default.FireAnimRate * Scale;
                WF.ReloadAnimRate = WF.default.ReloadAnimRate * Scale;

                if(RocketMultiFire(WF) != None) {
                    WF.MaxHoldTime = WF.FireRate * (RocketMultiFire(WF).MaxLoad - 1) + 0.5;
                } else {
                    WF.MaxHoldTime = WF.default.MaxHoldTime / Scale;
                }

                if(ShieldFire(WF) != None)
                    ShieldFire(WF).FullyChargedTime = ShieldFire(WF).default.FullyChargedTime / Scale;

                if(BioChargedFire(WF) != None)
                    BioChargedFire(WF).GoopUpRate = BioChargedFire(WF).default.GoopUpRate / Scale;

                if(PainterFire(WF) != None)
                    PainterFire(WF).PaintDuration = PainterFire(WF).default.PaintDuration / Scale;
            }
        }
    }
}

static function AdjustWeaponFireRate(Weapon W, float Scale)
{
    local int i;
    local WeaponFire WF;
    local float BarrelRotationsPerSec;

    if(W == None)
        return;

    for(i = 0; i < W.NUM_FIRE_MODES; i++)
    {
        WF = W.GetFireMode(i);
        if(WF != None)
        {
            if(MinigunFire(WF) != None)
            {
                MinigunFire(WF).BarrelRotationsPerSec *= Scale;
                WF.FireRate = 1.f / (MinigunFire(WF).RoundsPerRotation * MinigunFire(WF).BarrelRotationsPerSec);
                MinigunFire(WF).MaxRollSpeed = 65536.f * MinigunFire(WF).BarrelRotationsPerSec;
            }
            else if(WF.IsA('TURMinigunFire'))
            {
                BarrelRotationsPerSec = float(WF.GetPropertyText("BarrelRotationsPerSec")) * Scale;
                WF.SetPropertyText("BarrelRotationsPerSec", string(BarrelRotationsPerSec));
                WF.FireRate = 1.f / (float(WF.GetPropertyText("RoundsPerRotation")) * BarrelRotationsPerSec);
                WF.SetPropertyText("MaxRollSpeed", string(65536.f * BarrelRotationsPerSec));
            }
            else if(TransFire(WF) == None && BallShoot(WF) == None)
            {
                WF.FireRate /= Scale;
                WF.FireAnimRate *= Scale;
                WF.ReloadAnimRate *= Scale;

                if(RocketMultiFire(WF) != None) {
                    WF.MaxHoldTime = WF.FireRate * (RocketMultiFire(WF).MaxLoad - 1) + 0.5;
                } else {
                    WF.MaxHoldTime = WF.default.MaxHoldTime / Scale;
                }

                if(ShieldFire(WF) != None)
                    ShieldFire(WF).FullyChargedTime /= Scale;

                if(BioChargedFire(WF) != None)
                    BioChargedFire(WF).GoopUpRate /= Scale;

                if(PainterFire(WF) != None)
                    PainterFire(WF).PaintDuration /= Scale;
            }
        }
    }
}

static function SetVehicleWeaponFireRate(Actor W, float Modifier)
{
    if(W != None)
    {
        if(ONSWeapon(W) != None)
        {
            ONSWeapon(W).SetFireRateModifier(Modifier);
            return;
        }
        else if(Weapon(W) != None)
        {
            SetWeaponFireRate(Weapon(W), Modifier);
            return;
        }
        else
        {
            Warn("Could not set fire rate for " $ W $ "!");
        }
    }
}

static function function SetVehicleFireRate(Vehicle V, float Modifier)
{
    local int i;
    local ONSVehicle OV;
    local ONSWeaponPawn WP;
    local Inventory Inv;

    OV = ONSVehicle(V);
    if (OV != None)
    {
        for(i = 0; i < OV.Weapons.length; i++)
        {
            SetVehicleWeaponFireRate(OV.Weapons[i], Modifier);
        }
    }
    else
    {
        WP = ONSWeaponPawn(V);
        if (WP != None)
        {
            SetVehicleWeaponFireRate(WP.Gun, Modifier);
        }
        else //some other type of vehicle (usually ASVehicle) using standard weapon system
        {
            //at this point, the vehicle's Weapon is not yet set, but it should be its only inventory
            for(Inv = V.Inventory; Inv != None; Inv = Inv.Inventory)
            {
                if(Weapon(Inv) != None)
                {
                    SetVehicleWeaponFireRate(Weapon(Inv), Modifier);
                }
            }
        }
    }
}

static function AdjustVehicleSpeed(Vehicle V, float Factor)
{
    local int i;

    if(ONSWheeledCraft(V) != None) //HellBender, Scorpion, Paladin, SPMA, MAS, Toilet Car, you name it
    {
        ONSWheeledCraft(V).TorqueCurve.Points[0].OutVal *= Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[1].OutVal *= Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[2].OutVal *= Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[2].InVal *= Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[3].InVal *= Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[3].OutVal *= Factor;

        for (i = 0; i < 5; i++)
            ONSWheeledCraft(V).GearRatios[i] *= Factor;
    }
    else if(ONSHoverCraft(V) != None) //Manta
    {
        ONSHoverCraft(V).MaxThrustForce *= Factor;
        ONSHoverCraft(V).MaxStrafeForce *= Factor;
        ONSHoverCraft(V).LatDamping *= Factor;
        ONSHoverCraft(V).LongDamping *= Factor;
        ONSHoverCraft(V).MaxRiseForce *= Factor;
    }
    else if(ONSChopperCraft(V) != None) //Raptor, Cicada
    {
        ONSChopperCraft(V).MaxThrustForce *= Factor;
        ONSChopperCraft(V).MaxStrafeForce *= Factor;
        ONSChopperCraft(V).LatDamping *= Factor;
        ONSChopperCraft(V).LongDamping *= Factor;
    }
    else if(ONSTreadCraft(V) != None) //Goliath, Ion Plasma Tank
    {
        ONSTreadCraft(V).MaxThrust *= Factor;
    }
}

static function SetVehicleSpeed(Vehicle V, float Factor)
{
    local int i;

    if(ONSWheeledCraft(V) != None) //HellBender, Scorpion, Paladin, SPMA, MAS, Toilet Car, you name it
    {
        ONSWheeledCraft(V).TorqueCurve.Points[0].OutVal = ONSWheeledCraft(V).default.TorqueCurve.Points[0].OutVal * Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[1].OutVal = ONSWheeledCraft(V).default.TorqueCurve.Points[1].OutVal * Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[2].OutVal = ONSWheeledCraft(V).default.TorqueCurve.Points[2].OutVal * Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[2].InVal = ONSWheeledCraft(V).default.TorqueCurve.Points[2].InVal * Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[3].InVal = ONSWheeledCraft(V).default.TorqueCurve.Points[3].InVal * Factor;
        ONSWheeledCraft(V).TorqueCurve.Points[3].OutVal = ONSWheeledCraft(V).default.TorqueCurve.Points[3].OutVal * Factor;

        for (i = 0; i < 5; i++)
            ONSWheeledCraft(V).GearRatios[i] = ONSWheeledCraft(V).Default.GearRatios[i] * Factor;
    }
    else if(ONSHoverCraft(V) != None) //Manta
    {
        ONSHoverCraft(V).MaxThrustForce = ONSHoverCraft(V).default.MaxThrustForce * Factor;
        ONSHoverCraft(V).MaxStrafeForce = ONSHoverCraft(V).default.MaxStrafeForce * Factor;
        ONSHoverCraft(V).LatDamping = ONSHoverCraft(V).default.LatDamping * Factor;
        ONSHoverCraft(V).LongDamping = ONSHoverCraft(V).default.LongDamping * Factor;
        ONSHoverCraft(V).MaxRiseForce = ONSHoverCraft(V).default.MaxRiseForce * Factor;
    }
    else if(ONSChopperCraft(V) != None) //Raptor, Cicada
    {
        ONSChopperCraft(V).MaxThrustForce = ONSChopperCraft(V).default.MaxThrustForce * Factor;
        ONSChopperCraft(V).MaxStrafeForce = ONSChopperCraft(V).default.MaxStrafeForce * Factor;
        ONSChopperCraft(V).LatDamping = ONSChopperCraft(V).default.LatDamping * Factor;
        ONSChopperCraft(V).LongDamping = ONSChopperCraft(V).default.LongDamping * Factor;
    }
    else if(ONSTreadCraft(V) != None) //Goliath, Ion Plasma Tank
    {
        ONSTreadCraft(V).MaxThrust = ONSTreadCraft(V).default.MaxThrust * Factor;
    }
}

static function SetVehicleOverlay(Vehicle V, Material Mat, float Duration, bool bOverride)
{
    local int i;
    local ONSVehicle OV;
    local ASTurret AT;

    if(ONSWeaponPawn(V) != None)
        V = ONSWeaponPawn(V).VehicleBase;

    OV = ONSVehicle(V);
    if(OV != None)
    {
        for(i = 0; i < OV.Weapons.Length; i++)
            class'Sync_OverlayMaterial'.static.Sync(OV.Weapons[i], Mat, Duration, bOverride);

        for(i = 0; i < OV.WeaponPawns.Length; i++)
            class'Sync_OverlayMaterial'.static.Sync(OV.WeaponPawns[i].Gun, Mat, Duration, bOverride);
    }

    AT = ASTurret(V);
    if(AT != None)
    {
        if(AT.TurretBase != None)
            class'Sync_OverlayMaterial'.static.Sync(AT.TurretBase, Mat, Duration, bOverride);

        if(AT.TurretSwivel != None)
            class'Sync_OverlayMaterial'.static.Sync(AT.TurretSwivel, Mat, Duration, bOverride);
    }

    class'Sync_OverlayMaterial'.static.Sync(V, Mat, Duration, bOverride);
}


//TAM support
static function IncreaseTAMWeaponFireStats(PlayerReplicationInfo PRI, string HitStatName, string Mode)
{
    local string HitStatStr;
    local Object HitStat;

    if(PRI == None || !PRI.IsA('Misc_PRI'))
        return;

    HitStatStr = PRI.GetPropertyText(HitStatName);
    HitStat = DynamicLoadObject(HitStatStr, class'Object', true);

    //Log("HitStatStr =" @ HitStatStr @ "=>" @ HitStat, 'TURRPG2');
}

//Forces the weapon to be given to the pawn - even if he has a weapon of the same type already
static function Weapon ForceGiveTo(Pawn Other, Weapon W, optional WeaponPickup Pickup) {
    local Weapon Pivot, First;
    local class<Weapon> WeaponClass;
    local Actor Inv, Prev;

    if(W != None) {
        WeaponClass = W.class;
    } else if(Pickup != None) {
        WeaponClass = class<Weapon>(Pickup.InventoryType);
    } else {
        Warn("Insufficient parameters:" @ Other @ W @ Pickup);
    }

    Prev = Other;
    Inv = Other.Inventory;
    while(Inv != None) {
        if(First == None && Weapon(Inv) != None) {
            First = Weapon(Inv);
        }

        if(Inv.class == WeaponClass) {
            //found one
            Pivot = Weapon(Inv);
            break;
        }

        Prev = Inv;
        Inv = Inv.Inventory;
    }

    if(Pivot != None) {
        //cut of linked list (we assume that weapons are ordered and that the new weapon will be added here)
        Prev.Inventory = None;

        //Give weapon to pawn or spawn copy
        if(W != None) {
            W.GiveTo(Other, Pickup);
        } else {
            W = Weapon(Pickup.SpawnCopy(Other));
        }

        //re-add
        if(Pivot == First && Prev.Inventory == W && W.Inventory == None) {
            //put to end of the chain
            W.Inventory = Pivot.Inventory;

            for(Inv = Pivot.Inventory; Inv != None; Inv = Inv.Inventory) {
                Prev = Inv;
            }

            Pivot.Inventory = None;
            Prev.Inventory = Pivot;
        } else {
            if(W.Inventory != None) {
                //shouldn't happen, but who knows...
                Warn("Item order changed - putting Pivot to end of list!");

                Prev = W;
                for(Inv = W.Inventory; Inv != None; Inv = Inv.Inventory) {
                    Prev = Inv;
                }

                Prev.Inventory = Pivot;
            } else {
                W.Inventory = Pivot;
                W.NetUpdateTime = W.Level.TimeSeconds - 1;
            }
        }
    } else {
        //simply give to pawn
        if(W != None) {
            W.GiveTo(Other, Pickup);
        } else {
            W = Weapon(Pickup.SpawnCopy(Other));
        }
    }

    return W;
}

static function SetWeaponAmmo(Weapon W, int Mode, int Ammo) {
    local int Diff;

    Diff = Ammo - W.AmmoAmount(Mode);
    if(Diff > 0) {
        W.AddAmmo(Diff, Mode);
    } else if(Diff < 0) {
        W.ConsumeAmmo(Mode, -Diff);
    }
}

//Grants experience for healing
static function DoHealableDamage(Pawn Healer, Pawn Healed, int Amount, optional float Factor) {
    local RPGPlayerReplicationInfo RPRI;
    local Inv_HealableDamage Healable;
    local int Adjusted;

    if(Healer != None && Healed != None && Amount > 0) {
        RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(Healer.Controller);
        if(RPRI != None) {
            if(Factor == 0) {
                Factor = RPRI.HealingExpMultiplier;
            }

            Healable = Inv_HealableDamage(Healed.FindInventoryType(class'Inv_HealableDamage'));
            if(Healable != None && Healable.Damage > 0) {
                Adjusted = Min(Amount, Healable.Damage);

                if(Adjusted > 0) {
                    Healable.Damage = Max(0, Healable.Damage - Adjusted);
                    class'RPGRules'.static.ShareExperience(RPRI, float(Adjusted) * Factor);
                }
            }
        }
    }
}

//Check if two controllers are on the same team
static function bool SameTeamC(Controller A, Controller B) {
    local int TeamA, TeamB;

    if(A == None || B == None) {
        return false;
    }

    TeamA = A.GetTeamNum();
    TeamB = B.GetTeamNum();

    return
        (TeamA != 255 && TeamA == TeamB) ||
        (FriendlyMonsterController(A) != None && FriendlyMonsterController(A).Master == B) ||
        (FriendlyMonsterController(B) != None && FriendlyMonsterController(B).Master == A);
}

//Gets the team a certain pawn is on
static function int GetPawnTeam(Pawn P) {
    if(P != None) {
        if(P.Controller != None) {
            return P.Controller.GetTeamNum();
        } else if(P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != None) {
            return P.PlayerReplicationInfo.Team.TeamIndex;
        } else if(Vehicle(P) != None) {
            return Vehicle(P).Team;
        } else if(P.DrivenVehicle != None) {
            return GetPawnTeam(P.DrivenVehicle);
        } else {
            return 255;
        }
    } else {
        return 255;
    }
}

//Check if a controller and a pawn are on the same team
static function bool SameTeamCP(Controller C, Pawn P) {
    local int TeamC, TeamP;

    if(C == None || P == None) {
        return false;
    }

    if(SameTeamC(C, P.Controller)) {
        return true;
    }

    TeamC = C.GetTeamNum();
    TeamP = GetPawnTeam(P);

    return (TeamC != 255 && TeamC == TeamP);
}

//Check if two pawns are on the same team
static function bool SameTeamP(Pawn A, Pawn B) {
    local int TeamA, TeamB;

    if(A == None || B == None) {
        return false;
    }

    if(A == B) {
        return true;
    }

    if(SameTeamC(A.Controller, B.Controller)) {
        return true;
    }

    TeamA = GetPawnTeam(A);
    TeamB = GetPawnTeam(B);

    return (TeamA != 255 && TeamA == TeamB);
}

//Check if a projectile belongs to the same team as a controller
static final function bool ProjectileSameTeamC(Projectile P, Controller C)
{
    return (P.InstigatorController != None && static.SameTeamC(P.InstigatorController, C) || (P.Instigator != None && static.SameTeamCP(C, P.Instigator)));
}

//
static function ModifyProjectileSpeed(Projectile Proj, float Multiplier, name Flag, optional class<Emitter> FXClass) {
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;
    local vector ClientLocation;

    Proj.Speed *= Multiplier;
    Proj.MaxSpeed *= Multiplier;
    Proj.Velocity *= Multiplier;
    Proj.Acceleration *= Multiplier;

    if(Multiplier < 1) {
        Proj.LifeSpan /= Multiplier;
    }

    if(RocketProj(Proj) != None) {
        RocketProj(Proj).FlockMaxForce *= Multiplier;
    } else if(ONSMineProjectile(Proj) != None) {
        //ONSMineProjectile(Proj).ScurrySpeed *= Multiplier;
    }

    if(Proj.Role == ROLE_Authority) {
        ClientLocation = Proj.Location + Proj.Velocity * 0.05f;
        if(Proj.Physics == PHYS_Falling) {
            ClientLocation += vect(0, 0, -0.00125f) * Proj.Level.DefaultGravity;
        }

        for(C = Proj.Level.ControllerList; C != None; C = C.NextController) {
            if(PlayerController(C) != None) {
                RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
                if(RPRI != None) {
                    RPRI.ClientSyncProjectile(ClientLocation, Proj.class, Proj.Instigator,
                        VSize(Proj.Velocity), Flag, FXClass);
                }
            }
        }
    } else if(Proj.Role < ROLE_Authority && FXClass != None) {
        Proj.Spawn(FXClass, Proj,, Proj.Location, Proj.Rotation).SetBase(Proj);
    }
}

static final function string Trim(string S)
{
    while (Left(S, 1) == " " || Left(S, 1) == "  ")
        S = Mid(S, 1);
    while (Right(S, 1) == " " || Right(S, 1) == "  ")
        S = Left(S, Len(S) - 1);
    return S;
}

static final function bool KeyHasBinding(string TestBinding, string Binding)
{
    local array<string> Parts;
    local int i;

    Split(Caps(TestBinding), "|", Parts);
    Binding = Caps(Binding);
    for(i = 0; i < Parts.Length; i++)
        if(Parts[i] == Binding)
            return true;
    return false;
}

static function Color InterpolateColor(Color C1, Color C2, float Fraction)
{
    local Color Result;

    Result.R = (int(C2.R) - C1.R) * Fraction + C1.R;
    Result.G = (int(C2.G) - C1.G) * Fraction + C1.G;
    Result.B = (int(C2.B) - C1.B) * Fraction + C1.B;
    Result.A = (int(C2.A) - C1.A) * Fraction + C1.A;
    return Result;
}

static final function vector SpreadVector(vector A, float Angle)
{
    local rotator R;

    R = rotator(A);
    R.Yaw = Angle * (FRand() - 0.5);
    R.Pitch = Angle * (FRand() - 0.5);
    R.Roll = Angle * (FRand() - 0.5);

    return (A >> R);
}

defaultproperties {
    HighlightColor=(R=255,G=255,B=255,A=255);
}
