//=============================================================================
// Ability_Hardcore.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_Hardcore extends RPGAbility;

var array<class<RPGEffect> > DisallowedEffectClasses;

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier)
{
    if(class'Util'.static.InArray(EffectClass, DisallowedEffectClasses) != -1 && ((AbilityLevel >= 2 && Causer == RPRI.Controller) || (class'Util'.static.SameTeamC(Causer, RPRI.Controller) && Causer != RPRI.Controller)))
        return false;
    return true;
}

defaultproperties
{
     DisallowedEffectClasses(0)=class'Effect_Heal'
     DisallowedEffectClasses(1)=class'Effect_ShieldBoost'
     DisallowedEffectClasses(2)=class'Effect_Adrenaline'
     DisallowedEffectClasses(3)=class'Effect_Ammo'
     DisallowedEffectClasses(4)=class'Effect_RemoteDamage'
     DisallowedEffectClasses(5)=class'Effect_RemoteInvulnerability'
     DisallowedEffectClasses(6)=class'Effect_SphereUDamage'
     DisallowedEffectClasses(7)=class'Effect_SphereInvulnerability'
     DisallowedEffectClasses(8)=class'Effect_HealingFlames'
     DisallowedEffectClasses(9)=class'Effect_HealingDefender'
     AbilityName="Hardcore"
     Description="Don't buy this skill. This skill will PREVENT others from healing you, giving you shields, or helping you.||Level 1 will prevent OTHERS from helping you.|Level 2 will further prevent YOURSELF from using beneficial effects."
     StartingCost=0
     CostAddPerLevel=0
     MaxLevel=2
     Category=Class'TURRPG2.AbilityCategory_Misc'
}
