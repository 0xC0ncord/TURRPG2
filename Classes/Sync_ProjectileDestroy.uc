//=============================================================================
// Sync_ProjectileDestroy.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Sync_ProjectileDestroy extends Sync;

var Projectile Proj;

//Identifiers
var class<Projectile> ProjClass;
var vector ProjLoc;
var Pawn ProjInstigator;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Proj, ProjLoc, ProjClass, ProjInstigator;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(Role < Role_Authority)
        ClientFunction();
}

simulated function bool ClientFunction()
{
    local Projectile P;

    if(Proj == None)
    {
        foreach DynamicActors(class'Projectile', P)
        {
            if(P.Class == ProjClass && VSize(P.Location - ProjLoc) < 256 && P.Instigator == ProjInstigator)
            {
                Proj = P;
                break;
            }
        }
    }
    if(Proj != None)
        Proj.Destroy();

    return true;
}

defaultproperties
{
}
