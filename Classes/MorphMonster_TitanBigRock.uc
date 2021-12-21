//=============================================================================
// MorphMonster_TitanBigRock.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class   MorphMonster_TitanBigRock   extends SMPTitanBigRock;

function ProcessTouch (Actor Other, Vector HitLocation)
{
    local int hitdamage;

    if (Other==none || Other == instigator )
        return;
    PlaySound(ImpactSound, SLOT_Interact, DrawScale*0.1f);
    if(Projectile(Other)!=none)
        Other.Destroy();
    else if (SMPTitanBigRock(Other)==None)
    {
        Hitdamage = Damage * 0.00002 * (DrawScale**3) * speed;
        if ( (HitDamage > 3) && (speed > 150) && ( Role == ROLE_Authority ))
            Other.TakeDamage(hitdamage, instigator,HitLocation,
                (MomentumTransfer * Normal(Velocity)*DrawScale), MyDamageType );
    }
}

defaultproperties
{
     Damage=50.000000
     MomentumTransfer=11500.000000
     DrawScale=3.500000
}
