//=============================================================================
// Artifact_ConjurerSize.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Artifact_ConjurerSize extends RPGArtifact;

var float OldCollisionHeight, OldCollisionRadius;
var float OldDrawScale;

const MSG_MustBeMonster = 0x0001;
var localized string MSG_Text_MustBeMonster;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case(MSG_MustBeMonster):
            return default.MSG_Text_MustBeMonster;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

function bool CanActivate()
{
    if(Monster(Instigator) == None)
    {
        Msg(MSG_MustBeMonster);
        return false;
    }
    return Super.CanActivate();
}

function bool CheckSpace(Pawn Instigator,vector SpawnLocation, int HorizontalSpaceReqd, int VerticalSpaceReqd)
{
    local Controller C;

    // check to see that we have the required space around and up
    if (!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 0, 1) * VerticalSpaceReqd)))
        return false;

    if (!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 1, 0) * HorizontalSpaceReqd))
        && !FastTrace(SpawnLocation, SpawnLocation - (vect(0, 1, 0) * HorizontalSpaceReqd) ))
        return false;

    if (!FastTrace(SpawnLocation, SpawnLocation + (vect(1, 0, 0) * HorizontalSpaceReqd))
        && !FastTrace(SpawnLocation, SpawnLocation - (vect(1, 0, 0) * HorizontalSpaceReqd) ))
        return false;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(
            C.Pawn != None &&
            VSize((C.Pawn.Location - Instigator.Location) * vect(1, 1, 0)) + C.Pawn.CollisionRadius + Instigator.CollisionRadius <= HorizontalSpaceReqd &&
            VSize((C.Pawn.Location - Instigator.Location) * vect(0, 0, 1)) + C.Pawn.CollisionHeight + Instigator.CollisionHeight <= VerticalSpaceReqd
        )
            return false;
    }

    // should be room
    return true;
}

state Activated
{
    function BeginState()
    {
        Super.BeginState();

        OldDrawScale = Instigator.DrawScale;
        OldCollisionHeight = Instigator.CollisionHeight;
        OldCollisionRadius = Instigator.CollisionRadius;
        Instigator.SetDrawScale(OldDrawScale * 0.5f);
        Instigator.SetCollisionSize(OldCollisionRadius * 0.5f, OldCollisionHeight * 0.5f);

        if(Instigator.Physics != PHYS_Flying)
            Instigator.SetPhysics(PHYS_Falling);
    }

    function EndState()
    {
        local vector HitLocation;
        local vector HitNormal;

        if(Instigator != None && Instigator.DrivenVehicle == None)
        {
            if(Trace(HitLocation, HitNormal, Instigator.Location, Instigator.Location - (vect(0, 0, 1) * OldCollisionHeight)) == None)
            {
                //use old collision height in order to account for the size increase
                Instigator.SetLocation(HitLocation + (vect(0, 0, 1) * OldCollisionHeight));
            }
            Instigator.SetDrawScale(OldDrawScale);
            Instigator.SetCollisionSize(OldCollisionRadius, OldCollisionHeight);

            if(Instigator == None || !CheckSpace(Instigator, Instigator.Location, OldCollisionRadius, OldCollisionHeight))
            {
                // such a shame... many such cases
                if(Instigator != None)
                    Instigator.Died(Instigator.Controller, class'DamTypeMetamorphosisFail', Instigator.Location);
                else
                    Level.Game.Killed(Instigator.Controller, Instigator.Controller, None, class'DamTypeMetamorphosisFail');
            }
        }

        Super.EndState();
    }
}

defaultproperties
{
    MSG_Text_MustBeMonster="You must be a monster to use this artifact."
    CostPerSec=1
    bCanBeTossed=False
    MinActivationTime=0.100000
    HudColor=(B=128,G=255,R=128)
    bAllowInVehicle=False
    ArtifactID="Compression"
    Description="Halves your size as a monster."
    IconMaterial=Texture'CompressionCharmIcon'
    ItemName="Compression Charm"
}
