//=============================================================================
// ComboHuntersRage.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboHuntersRage extends RPGComboBerserk;

var float MarkRange;

var float NextMarkTime;
var FX_HuntersMarkSight EyesEffect;

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(!bPendingDelete && Level.TimeSeconds <= NextMarkTime)
        MarkPawns();
}

function CreateEffects(Pawn P)
{
    local coords C;

    Super.CreateEffects(P);

    C = P.GetBoneCoords(P.HeadBone);

    EyesEffect = Spawn(class'FX_HuntersMarkSight', P,, C.Origin, rotator(C.XAxis));
    EyesEffect.PawnOwner = P;
    P.AttachToBone(EyesEffect, P.HeadBone);
}

function DestroyEffects(Pawn P)
{
    Super.DestroyEffects(P);

    if(EyesEffect != None)
    {
        EyesEffect.Kill();
        EyesEffect.PawnOwner = None;
        EyesEffect.bTearOff = true;
    }
}

function StartEffect(xPawn P)
{
    Super.StartEffect(P);
    MarkPawns();
}

function MarkPawns()
{
    local Controller C;
    local RPGEffect RPGEffect;

    NextMarkTime = Level.TimeSeconds + 1;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.Pawn != None && VSize(C.Pawn.Location - Owner.Location) <= MarkRange && class'Effect_HuntersMark'.static.CanBeApplied(C.Pawn, Pawn(Owner).Controller))
        {
            RPGEffect = class'Effect_HuntersMark'.static.Create(C.Pawn, Pawn(Owner).Controller, class'Effect_HuntersMark'.default.Duration);
            if(RPGEffect != None)
                RPGEffect.Start();
        }
    }
}

defaultproperties
{
    MarkRange=3200
    ExecMessage="Hunter's Rage!"
}
