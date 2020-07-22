//=============================================================================
// Info_TripleDamageTimer.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//UDamageTimer without any expiration sounds
class Info_TripleDamageTimer extends UDamageTimer;

function Timer()
{
    if ( Pawn(Owner) == None )
    {
        Destroy();
        return;
    }
    if ( SoundCount < 4 )
    {
        SoundCount++;
        //Pawn(Owner).PlaySound(Sound'PickupSounds.UDamagePickUp', SLOT_None, 1.5*Pawn(Owner).TransientSoundVolume,,1000,1.0);
        SetTimer(0.75,false);
        return;
    }
    Pawn(Owner).DisableUDamage();
    Destroy();
}

defaultproperties
{
}
