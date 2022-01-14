//=============================================================================
// RPGComboInvis.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGComboInvis extends RPGCombo;

//special handling for effects; if this combo is started,
//destroy the effects from other combos so as to not blow
//the player's cover!
function StartEffect(xPawn P)
{
    local int i;

    P.SetInvisibility(60.0);
    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);

    if(RPGPawn(P)!=None)
    {
        for(i = 0; i < RPGPawn(P).ActiveCombos.Length; i++)
        {
            if(RPGCombo(RPGPawn(P).ActiveCombos[i]) != None)
                RPGCombo(RPGPawn(P).ActiveCombos[i]).DestroyEffects(P);
        }
    }
}

function StopEffect(xPawn P)
{
    local int i;

    P.SetInvisibility(0.0);
    if(RPGPawn(P) != None)
    {
        for(i = 0; i < RPGPawn(P).ActiveCombos.Length; i++)
        {
            if(RPGCombo(RPGPawn(P).ActiveCombos[i]) != None)
                RPGCombo(RPGPawn(P).ActiveCombos[i]).CreateEffects(P);
        }
    }
}

defaultproperties
{
     ExecMessage="Invisible!"
     ComboAnnouncementName="Invisible"
     keys(0)=8
     keys(1)=8
     keys(2)=4
     keys(3)=4
}
