//=============================================================================
// RPGComboSpeed.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGComboSpeed extends RPGCombo;

var xEmitter LeftTrail, RightTrail;

function CreateEffects(Pawn P)
{
    local class<xEmitter> EmitterClass;
    local Ability_Speed SpeedAbility;

    if(RPRI != None)
    {
        SpeedAbility = Ability_Speed(RPRI.GetOwnedAbility(class'Ability_Speed'));

        //Colored trail
        if(SpeedAbility != None && SpeedAbility.ShouldColorSpeedTrail())
            EmitterClass = class'FX_SuperSpeedTrail';
        else
            EmitterClass = class'SpeedTrail';
    }

    LeftTrail = Spawn(EmitterClass, P,, P.Location, P.Rotation);
    P.AttachToBone(LeftTrail, 'lfoot');

    RightTrail = Spawn(EmitterClass, P,, P.Location, P.Rotation);
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
    P.AirControl *= 1.4;
    P.GroundSpeed *= 1.4;
    P.WaterSpeed *= 1.4;
    P.AirSpeed *= 1.4;
    P.JumpZ *= 1.5;
}

function StopEffect(xPawn P)
{
    Super.StopEffect(P);

    // Our replacement: the opposite of what happens in ComboSpeed.StartEffect().
    P.AirControl  /= 1.4;
    P.GroundSpeed /= 1.4;
    P.WaterSpeed  /= 1.4;
    P.AirSpeed    /= 1.4;
    P.JumpZ       /= 1.5;
}

defaultproperties
{
    bFlagSensitive=True
    ExecMessage="Speed!"
    Duration=16.000000
    ComboAnnouncementName="Speed"
    keys(0)=1
    keys(1)=1
    keys(2)=1
    keys(3)=1
}
