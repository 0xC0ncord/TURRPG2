//=============================================================================
// ComboSuperSpeed.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboSuperSpeed extends RPGCombo;

var xEmitter LeftTrail, RightTrail;
var float SpeedBonus, JumpZBonus;

function CreateEffects(Pawn P)
{
    LeftTrail = Spawn(class'FX_SuperSpeedTrail', P,, P.Location, P.Rotation);
    P.AttachToBone(LeftTrail, 'lfoot');

    RightTrail = Spawn(class'FX_SuperSpeedTrail', P,, P.Location, P.Rotation);
    P.AttachToBone(RightTrail, 'rfoot');
}

function DestroyEffects(Pawn P)
{
    if (LeftTrail != None)
        LeftTrail.Destroy();

    if (RightTrail != None)
        RightTrail.Destroy();
}

function StartEffect(xPawn P)
{
    Super.StartEffect(P);

    P.AirControl  *= (1.0 + SpeedBonus);
    P.GroundSpeed *= (1.0 + SpeedBonus);
    P.WaterSpeed  *= (1.0 + SpeedBonus);
    P.AirSpeed    *= (1.0 + SpeedBonus);
    P.JumpZ       *= (1.0 + JumpZBonus);
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    // Our replacement: the opposite of what happens in ComboSpeed.StartEffect().
    P.AirControl  /= (1.0 + SpeedBonus);
    P.GroundSpeed /= (1.0 + SpeedBonus);
    P.WaterSpeed  /= (1.0 + SpeedBonus);
    P.AirSpeed    /= (1.0 + SpeedBonus);
    P.JumpZ       /= (1.0 + JumpZBonus);
}

defaultproperties
{
     SpeedBonus=0.600000
     JumpZBonus=0.500000
     ExecMessage="Super Speed!"
     Duration=16.000000
     ComboAnnouncementName="Speed"
     keys(0)=1
     keys(1)=1
     keys(2)=1
     keys(3)=1
}
