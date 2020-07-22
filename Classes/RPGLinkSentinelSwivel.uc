//=============================================================================
// RPGLinkSentinelSwivel.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGLinkSentinelSwivel extends ASTurret_Minigun_Swivel;

simulated event Timer()
{
    local rotator Rot;

    if ( bMovable )
    {
        Rot = Rotation;
        Rot.Yaw += 2000;
        if (Rot.Yaw > 65536)
            Rot.Yaw -= 65536;
        SetRotation( Rot );
    }

    SetTimer( 0.15, false );
}

// not a real swivel class - just a place holder for a globe

defaultproperties
{
     StaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
     DrawScale=0.430000
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamYellowFB'
     Skins(1)=FinalBlend'XEffectMat.Link.LinkBeamYellowFB'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
