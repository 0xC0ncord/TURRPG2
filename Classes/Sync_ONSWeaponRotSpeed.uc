//=============================================================================
// Sync_ONSWeaponRotSpeed.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Sync_ONSWeaponRotSpeed extends Sync;

var ONSWeapon Target;
var float RotationsPerSecond;

replication {
    reliable if(Role == ROLE_Authority && bNetInitial)
        Target, RotationsPerSecond;
}

simulated function bool ClientFunction() {
    if(Target != None) {
        Target.RotationsPerSecond = RotationsPerSecond;
    } else {
        return true;
    }
}

defaultproperties {
    LifeSpan=4.00
}
