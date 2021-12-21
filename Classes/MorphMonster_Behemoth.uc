//=============================================================================
// MorphMonster_Behemoth.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_Behemoth extends MorphMonster_Brute;

function RangedAttack(Actor A)
{
    if(bShotAnim)
        return;

    if(VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        PlaySound(sound'pwhip1br', SLOT_Talk);
        SetAnimAction(MeleeAttack[Rand(4)]);
    }
    else if(Acceleration == vect(0, 0, 0))
        SetAnimAction('StillFire');
    else
    {
        SetAnimAction('WalkFire');
        bShotAnim = true;
        return;
    }

    Controller.bPreparingMove = true;
    Acceleration = vect(0, 0, 0);
    bShotAnim = true;
}

defaultproperties
{
    ScoringValue=6
    bCanStrafe=True
    Health=260
    Skins(0)=Texture'SkaarjPackSkins.Skins.jBrute2'
}
