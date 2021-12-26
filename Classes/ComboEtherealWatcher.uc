//=============================================================================
// ComboEtherealWatcher.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ComboEtherealWatcher extends Info;

var Pawn PawnOwner;

function PostBeginPlay()
{
    PawnOwner = Pawn(Owner);
    if(PawnOwner == None)
        Destroy();
}

function Tick(float dt)
{
    local Pawn P;

    if(PawnOwner == None || PawnOwner.Health <= 0)
    {
        Destroy();
        return;
    }

    PawnOwner.bBlockNonZeroExtentTraces = true;
    foreach PawnOwner.CollidingActors(class'Pawn', P, PawnOwner.CollisionRadius)
    {
        if(P != None)
        {
            PawnOwner.bBlockNonZeroExtentTraces = false;
            return;
        }
    }

    Destroy();
}

defaultproperties
{
}
