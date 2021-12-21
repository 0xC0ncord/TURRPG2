//=============================================================================
// MorphMonster_QueenChildPupae.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_QueenChildPupae extends SMPChildPupae;

var MorphMonster_Queen PQueen;

simulated function PreBeginPlay()
{
    PQueen=MorphMonster_Queen(Owner);
    if(PQueen==none)
        Destroy();
    Super(SkaarjPupae).PreBeginPlay();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    super(SkaarjPupae).TakeDamage( Damage,EventInstigator,HitLocation, Momentum, DamageType);
}

function Tick(float DeltaTime)
{
    local Actor A;

    Super(SkaarjPupae).Tick(DeltaTime);
    if(PQueen==none || PQueen.Controller==none || PQueen.Controller.Enemy==self)
    {
        Destroy();
        return;
    }

    if(PQueen.Controller!=none && Controller!=none && Health>=0)
    {
        A = class'Util'.static.GetClosestPawn(PQueen.Controller);
        if( A!=None )
        {
            Controller.Target = A;
            Controller.Enemy = Pawn(A);
        }
    }
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
    local vector HitLocation, HitNormal;
    local actor HitActor;

    if(PQueen==none)
        return false;

    // check if still in melee range
    If ( (Controller.target != None) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)
        && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Controller.Target.Location.Z)
            <= FMax(CollisionHeight, Controller.Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Controller.Target.CollisionHeight))) )
    {
        HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
        if ( HitActor != None )
            return false;
        Controller.Target.TakeDamage(hitdamage, PQueen,HitLocation, pushdir, class'MeleeDamage');
        return true;
    }
    return false;
}

function Destroyed()
{
    if ( PQueen != None && PQueen.numChildren > 0 )
        PQueen.numChildren--;
    Super(SkaarjPupae).Destroyed();
}

defaultproperties
{
}
