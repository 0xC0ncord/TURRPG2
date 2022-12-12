//=============================================================================
// RPGForceField.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGForceField extends RPGMatrixField;

event Tick(float dt)
{
    local Projectile Proj;

    foreach CollidingActors(class'Projectile', Proj, Radius)
    {
        if(
            bool(int(string(Proj.Tag)) & F_PROJMOD_FORCE)
            || bool(int(string(Proj.Tag)) & F_PROJMOD_MATRIX)
        )
        {
            continue;
        }

        if(!class'Util'.static.ProjectileSameTeamC(Proj, Instigator.Controller))
            continue;

        Proj.SetPropertyText("Tag", string(int(string(Proj.Tag)) | F_PROJMOD_FORCE));
        class'Util'.static.ModifyProjectileSpeed(Proj, Multiplier, F_PROJMOD_FORCE);
    }
}

defaultproperties {
    Radius=768
    Multiplier=0.5
}
