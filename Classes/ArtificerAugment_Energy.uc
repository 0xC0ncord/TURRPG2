//=============================================================================
// ArtificerAugment_Energy.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Energy extends ArtificerAugmentBase;

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local float AdrenalineBonus;

    if(Instigator != InstigatedBy || Instigator == Injured || class'Util'.static.SameTeamP(Injured, InstigatedBy))
        return;

    if(OriginalDamage > Injured.Health)
        AdrenalineBonus = Injured.Health * BonusPerLevel * Modifier;
    else
        AdrenalineBonus = OriginalDamage * BonusPerLevel * Modifier;

    if(
        UnrealPlayer(Instigator.Controller) != None
        && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax
        && Instigator.Controller.Adrenaline + AdrenalineBonus >= Instigator.Controller.AdrenalineMax
        && !Instigator.InCurrentCombo()
    )
        UnrealPlayer(Instigator.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);

    Instigator.Controller.Adrenaline = FMin(Instigator.Controller.Adrenaline + AdrenalineBonus, Instigator.Controller.AdrenalineMax);
}

defaultproperties
{
    MaxLevel=10
    BonusPerLevel=0.02
    ModifierName="Energy"
    Description="$1 adrenaline gain"
    LongDescription="Adds $1 adrenaline gain from weapon damage per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.EnergyIcon'
    ModifierOverlay=Shader'RPGWeapons.EnergyShader'
    ModifierColor=(R=255,G=255,B=255)
}
