//=============================================================================
// ArtificerAugment_RockShield.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_RockShield extends ArtificerAugmentBase;

static function float GetBonusAtLevel(int Level)
{
    local float Bonus;
    local int i;

    for(i = 1; i <= Level; i++)
        Bonus += default.BonusPerLevel / i;

    return Bonus;
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(string(DamageType) == "SMPDamTypeTitanRock")
        Damage -= Damage * GetBonusAtLevel(Modifier);
}

function string GetDescription()
{
    return Repl(Description, "$1", class'Util'.static.FormatPercent(GetBonusAtLevel(Modifier)));
}

static function string StaticGetDescription(optional int Modifier)
{
    return Repl(default.Description, "$1", class'Util'.static.FormatPercent(static.GetBonusAtLevel(Modifier)));
}

static function string StaticGetLongDescription(optional int Modifier)
{
    return Repl(default.Description, "$1", class'Util'.static.FormatPercent(static.GetBonusAtLevel(Modifier)));
}

defaultproperties
{
    MaxLevel=2
    BonusPerLevel=0.6
    ModifierName="Titan Rock Shield"
    Description="$1 titan rock dmg reduction"
    LongDescription="Reduces Titan rock damage by $1 per level, with 50% diminishing returns for additional levels."
    IconMaterial=Texture'TURRPG2.WOPIcons.RockShieldIcon'
    ModifierOverlay=Combiner'WOPWeapons.RockShieldShader'
    ModifierColor=(R=255,G=128)
}
