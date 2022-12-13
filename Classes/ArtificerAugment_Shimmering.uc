//=============================================================================
// ArtificerAugment_Shimmering.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtificerAugment_Shimmering extends ArtificerAugmentBase_ProjectileMod;

function ModifyProjectile(Projectile Proj)
{
    local float Multiplier;
    local RPGProjectileAugment A;
    local vector ClientLocation;
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;

    Multiplier = 1.0f + BonusPerLevel * float(Modifier);

    A = class'ProjAugment_Shimmering'.static.Create(Proj, Modifier, ModFlag);
    A.StartEffect();

    ClientLocation = Proj.Location + Proj.Velocity * 0.05f;
    if(Proj.Physics == PHYS_Falling)
        ClientLocation += vect(0, 0, -0.00125f) * Proj.Level.DefaultGravity;

    if(Proj.Level.NetMode != NM_DedicatedServer)
        Proj.Spawn(class'FX_ShimmeringTrail', Proj,, Proj.Location, Proj.Rotation).SetBase(Proj);

    for(C = Proj.Level.ControllerList; C != None; C = C.NextController)
    {
        if(PlayerController(C) != None)
        {
            RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
            if(RPRI != None)
            {
                RPRI.ClientSyncProjectile(
                    ClientLocation,
                    Proj.Class,
                    Proj.Instigator,
                    0,
                    F_PROJMOD_SHIMMERING,
                    class'FX_ShimmeringTrail');
            }
        }
    }
}

defaultproperties
{
    ModFlag=F_PROJMOD_SHIMMERING
    MaxLevel=5
    BonusPerLevel=0.03
    ModifierName="Shimmering"
    Description="$1 in-flight proj dmg"
    LongDescription="Increases in-flight projectile damage by $1 per level."
    IconMaterial=Texture'TURRPG2.WOPIcons.ForceIcon'
    ModifierOverlay=Combiner'WOPWeapons.ShimmeringShader'
    ModifierColor=(R=173,G=156,B=255)
}
