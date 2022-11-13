//=============================================================================
// ComboNimble.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboNimble extends RPGCombo;

var int MultiJumpBonus;
var float AirControlBonus, AirSpeedBonus;
var float MultiJumpBoostBonus, JumpZBonus;

var FX_ComboNimble FX;
var FX_ComboNimble_FP FX_FP;
var FX_ComboNimbleFootTrail LeftTrail, RightTrail;

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboNimble', P,, P.Location);
    FX_FP = Spawn(class'FX_ComboNimble_FP', P,, P.Location);

    LeftTrail = Spawn(class'FX_ComboNimbleFootTrail', P,, P.Location, P.Rotation);
    P.AttachToBone(LeftTrail, 'lfoot');

    RightTrail = Spawn(class'FX_ComboNimbleFootTrail', P,, P.Location, P.Rotation);
    P.AttachToBone(RightTrail, 'rfoot');
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
    {
        FX.Kill();
        FX.ClientKill();
    }
    if(FX_FP != None)
    {
        FX_FP.Kill();
        FX_FP.ClientKill();
    }

    if (LeftTrail != None)
        LeftTrail.Destroy();

    if (RightTrail != None)
        RightTrail.Destroy();
}

function StartEffect(xPawn P)
{
    Super.StartEffect(P);

    P.AirControl  *= (1.0 + AirControlBonus);
    P.AirSpeed    *= (1.0 + AirSpeedBonus);
    P.JumpZ       *= (1.0 + JumpZBonus);

    P.MaxMultiJump       += MultiJumpBonus;
    P.MultiJumpRemaining += MultiJumpBonus;
    P.MultiJumpBoost     += MultiJumpBoostBonus;
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    P.AirControl  /= (1.0 + AirControlBonus);
    P.AirSpeed    /= (1.0 + AirSpeedBonus);
    P.JumpZ       /= (1.0 + JumpZBonus);

    P.MaxMultiJump       -= MultiJumpBonus;
    P.MultiJumpRemaining -= MultiJumpBonus;
    P.MultiJumpBoost     -= MultiJumpBoostBonus;
}

defaultproperties
{
     AirSpeedBonus=1.250000
     AirControlBonus=1.250000
     JumpZBonus=1.250000
     MultiJumpBonus=1
     MultiJumpBoostBonus=0.500000
     ExecMessage="Nimble!"
     Duration=20.000000
     ComboAnnouncementName="ComboNimble"
     keys(0)=8
     keys(1)=8
     keys(2)=1
     keys(3)=1
}
