//=============================================================================
// RPGAssaultRiflePickup.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Fixes dropped dual assault rifles not staying dual
class RPGAssaultRiflePickup extends AssaultRiflePickup;

var bool bDualMode;

function InitDroppedPickupFor(Inventory Inv) {
    local AssaultRifle Ass;

    Ass = AssaultRifle(Inv);
    if(Ass != None) {
        bDualMode = Ass.bDualMode;
    }

    Super.InitDroppedPickupFor(Inv);
}

function Inventory SpawnCopy(Pawn Other) {
    local AssaultRifle Ass;

    Ass = AssaultRifle(Super.SpawnCopy(Other));
    if(Ass != None) {
        Ass.bDualMode = bDualMode;
    }

    return Ass;
}

defaultproperties {
}
