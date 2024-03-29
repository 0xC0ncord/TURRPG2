//=============================================================================
// Effect_Poison.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Poison extends RPGEffect;

enum EPoisonMode
{
    PM_Absolute, //drain an absolute amount of health per time unit (AbsDrainPerLevel)
    PM_Percentage, //drain a percentage of the current health per time unit (PercDrainPerLevel)
    PM_Curve //use the TitanRPG curve (BasePercentage and Curve)
};
var EPoisonMode PoisonMode;
var class<DamageType> PoisonDamageType;

var float BasePercentage;
var float Curve;

var int AbsDrainPerLevel;
var float PercDrainPerLevel;

var int MinHealth; //cannot drain below this

var bool bAbsoluteDamage;

state Activated
{
    function Timer()
    {
        local RPGPlayerReplicationInfo CauserRPRI;
        local int PoisonDamage;

        Super.Timer();

        switch(PoisonMode)
        {
            case PM_Absolute:
                PoisonDamage = AbsDrainPerLevel * Modifier;
                break;

            case PM_Percentage:
                PoisonDamage = Modifier * PercDrainPerLevel * Instigator.Health;
                break;

            case PM_Curve:
                PoisonDamage = float(Instigator.Health) * (Curve ** (Modifier - 1.0f) * BasePercentage);
                break;
        }

        if(PoisonDamage > 0 && !(Instigator.Controller != None && Instigator.Controller.bGodMode))
        {
            if(MinHealth > 0)
            {
                Instigator.Health = Max(MinHealth, Instigator.Health - PoisonDamage);
            }
            else if(PoisonDamage >= Instigator.Health)
            {
                //Kill
                Instigator.TakeDamage(PoisonDamage, EffectCauser.Pawn, Instigator.Location, vect(0, 0, 0), PoisonDamageType);
            }
            else
            {
                Instigator.Health -= PoisonDamage;
            }

            if(EffectCauser != None && EffectCauser != Instigator.Controller)
            {
                CauserRPRI = class'RPGPlayerReplicationInfo'.static.GetFor(EffectCauser);
                if(CauserRPRI != None)
                {
                    CauserRPRI.AwardExperience(class'RPGRules'.static.Instance(Level).GetDamageEXP(
                        PoisonDamage, EffectCauser.Pawn, Instigator));
                }
            }
        }
    }
}

defaultproperties
{
    EffectClass=class'FX_PoisonSmoke'
    EffectMessageClass=class'EffectMessage_Poison'
    StatusIconClass=class'StatusIcon_Poison'

    PoisonMode=PM_Curve
    PoisonDamageType=Class'DamTypePoison'
}
