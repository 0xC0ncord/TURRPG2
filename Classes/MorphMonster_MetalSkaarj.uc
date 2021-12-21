//=============================================================================
// MorphMonster_MetalSkaarj.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_MetalSkaarj extends MorphMonster_IceSkaarj;

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    RefNormal=normal(HitLocation-Location);
    if(Frand()>0.2)
        return true;
    else
        return false;
}

defaultproperties
{
     ScoringValue=7
     GibGroupClass=Class'XEffects.xBotGibGroup'
     DodgeAnims(2)="DodgeR"
     DodgeAnims(3)="DodgeL"
     Skins(0)=FinalBlend'satoreMonsterPackv120.SMPMetalSkaarj.MetalSkinFinal'
     Skins(1)=None
     Mass=500.000000
}
