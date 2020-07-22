//=============================================================================
// Sync_ScorpionTurret.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    Synchronizer for switched scorpion turrets.
*/
class Sync_ScorpionTurret extends Sync;

var ONSRV Scorp;
var ONSWeapon NewWeapon;
var Artifact_ScorpionTurret Artifact;

replication {
    reliable if(Role == ROLE_Authority && bNetInitial)
        Scorp, NewWeapon;
}

static function Sync_ScorpionTurret Sync(ONSRV Scorp, ONSWeapon NewWeapon) {
    local Sync_ScorpionTurret Sync;

    Sync = Scorp.Spawn(class'Sync_ScorpionTurret');
    Sync.Scorp = Scorp;
    Sync.NewWeapon = NewWeapon;

    return Sync;
}

simulated function bool ClientFunction() {
    if(Scorp == None || NewWeapon == None) {
        return false;
    } else {
        Scorp.Weapons[0] = NewWeapon;
        Scorp.AttachToBone(NewWeapon, 'ChainGunAttachment');
        Scorp.TeamChanged(); //force a skin re-load
        return true;
    }
}

function bool ShouldDestroy() {
    if(Scorp == None) {
        return true;
    } else {
        return false;
    }
}

defaultproperties {
    LifeSpan=6.0
}
