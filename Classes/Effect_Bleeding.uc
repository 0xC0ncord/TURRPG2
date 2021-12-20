//=============================================================================
// Effect_Bleeding.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Bleeding extends RPGEffect;

function bool OverridePickupQuery(Pawn Other, Pickup Item, out byte bAllowPickup)
{
    // no health pickups allowed
    if(TournamentHealth(Item) != None)
        return true;
}

defaultproperties
{
    EffectClass=class'FX_Bleeding'
    EffectMessageClass=class'EffectMessage_Bleeding'
    StatusIconClass=class'StatusIcon_Bleeding'
}
