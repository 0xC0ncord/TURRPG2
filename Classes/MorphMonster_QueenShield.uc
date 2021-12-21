//=============================================================================
// MorphMonster_QueenShield.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class MorphMonster_QueenShield extends SMPQueenShield;

function Touch( actor Other )
{
    if(Monster(Other)!=None && MorphMonster(Other)==None && FriendlyMonsterController(Monster(Other).Controller)==None && Monster(Other).Health>0)
        Destroy();
}

defaultproperties
{
}
