//=============================================================================
// RPGMatrixField.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Causes a Matrix effect in a certain area
class RPGMatrixField extends Info placeable;

var Controller Creator;
var float Radius, Multiplier;
var array<name> Ignore;

delegate OnMatrix(RPGMatrixField Field, Projectile Proj, float Multiplier);

event PostBeginPlay()
{
    Creator = Controller(Owner);
}

function bool IgnoreProjectile(Projectile Proj)
{
    local int i;

    for(i = 0; i < Ignore.Length; i++)
        if(Proj.IsA(Ignore[i]))
            return true;

    return false;
}

event Tick(float dt)
{
    local Projectile Proj;

    foreach CollidingActors(class'Projectile', Proj, Radius)
    {
        if(
            bool(int(string(Proj.Tag)) & F_PROJMOD_MATRIX)
            || bool(int(string(Proj.Tag)) & F_PROJMOD_FORCE)
        )
        {
            continue;
        }

        if(IgnoreProjectile(Proj))
            continue;

        if(
            Proj.Instigator != None
            || !class'DevoidEffect_Matrix'.static.CanBeApplied(Proj.Instigator, Creator)
        )
        {
            continue;
        }

        OnMatrix(Self, Proj, Multiplier);

        Proj.SetPropertyText("Tag", string(int(string(Proj.Tag)) | F_PROJMOD_MATRIX));
        class'Util'.static.ModifyProjectileSpeed(Proj, Multiplier, F_PROJMOD_MATRIX, class'FX_MatrixTrail');
    }
}

defaultproperties {
    Radius=768
    Multiplier=0.5
}
