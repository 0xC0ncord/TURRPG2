//=============================================================================
// ArtificerAugment_Regen.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Regen extends ArtificerAugmentBase;

var float NextEffectTime;

function RPGTick(float dt)
{
    NextEffectTime -= dt;

    if(NextEffectTime > 0)
        return;

    Instigator.GiveHealth(BonusPerLevel * Modifier, Instigator.HealthMax);

    NextEffectTime += 1f;
}

function StartEffect()
{
    NextEffectTime = 1f;
}

function string GetDescription()
{
    return Repl(Description, "$1", int(BonusPerLevel * Modifier));
}

static function string StaticGetDescription(optional int Modifier)
{
    return Repl(default.Description, "$1", int(default.BonusPerLevel * Modifier));
}

static function string StaticGetLongDescription(optional int Modifier)
{
    return Repl(default.LongDescription, "$1", int(default.BonusPerLevel * Modifier));
}

defaultproperties
{
    MaxLevel=3
    BonusPerLevel=3.0
    ModifierName="Regeneration"
    Description="$1 health regen/s"
    LongDescription="Causes you to regenerate $1 health every second per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.HealthRegenIcon'
    ModifierOverlay=Combiner'WOPWeapons.HealthRegenShader'
    ModifierColor=(G=255,B=212)
}
