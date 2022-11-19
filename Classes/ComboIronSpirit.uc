//=============================================================================
// ComboIronSpirit.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboIronSpirit extends RPGCombo;

var FX_ComboIronSpirit FX;
var FX_ComboIronSpirit_FP FX_FP;

function CreateEffects(Pawn P)
{
    FX = Spawn(class'FX_ComboIronSpirit', P,, P.Location);
    FX_FP = Spawn(class'FX_ComboIronSpirit_FP', P,, P.Location);
}

function DestroyEffects(Pawn P)
{
    if(FX != None)
        FX.Die();
    if(FX_FP != None)
        FX_FP.Die();
}

defaultproperties
{
    ExecMessage="Iron Spirit!"
    Duration=20.000000
    ComboAnnouncementName="ComboIronSpirit"
    keys(0)=4
    keys(1)=4
    keys(2)=8
    keys(3)=8
}
