//=============================================================================
// Effect_Burn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Burn extends RPGEffect;

var float BurnFraction; // fraction taken off per second

state Activated
{
    function Timer()
    {
        local RPGPlayerReplicationInfo CauserRPRI;
        local int BurnDamage;

        Super.Timer();

        BurnDamage = Max(1,Instigator.HealthMax * BurnFraction * 0.5); // since twice a second only do half the damage, minimum 1

        if(BurnDamage > 0 && (Instigator.Controller == None || !Instigator.Controller.bGodMode))
        {
            if(BurnDamage >= Instigator.Health)
            {
                // Kill
                if(EffectCauser != None)
                    Instigator.TakeDamage(BurnDamage, EffectCauser.Pawn, Instigator.Location, vect(0, 0, 0), class'DamTypeBurn');
                else
                    Instigator.TakeDamage(BurnDamage, None, Instigator.Location, vect(0, 0, 0), class'DamTypeBurn');
            }
            else
            {
                Instigator.Health -= BurnDamage;
            }

            if(EffectCauser != None && EffectCauser != Instigator.Controller)
            {
                CauserRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(EffectCauser);
                if(CauserRPRI != None)
                {
                    CauserRPRI.AwardExperience(class'RPGRules'.static.Instance(Level).GetDamageEXP(
                        BurnDamage, EffectCauser.Pawn, Instigator));
                }
            }
        }
    }
}

defaultproperties
{
    TimerInterval=0.500000
    bAllowOnVehicles=True
    BurnFraction=0.100000
    EffectClass=Class'FX_Burn'
    EffectOverlay=Shader'BurnedShader'
    EffectMessageClass=Class'EffectMessage_Burn'
    StatusIconClass=Class'StatusIcon_Burn'
}
