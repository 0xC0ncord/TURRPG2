//=============================================================================
// Effect_NullEntropy.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_NullEntropy extends RPGEffect;

var EPhysics OriginalPhysics;

replication
{
    unreliable if(Role == ROLE_Authority)
        ClientFixLocation;
}

simulated function ClientFixLocation(vector NullLocation)
{
    if(Instigator != None)
    {
        Instigator.SetLocation(NullLocation);
        Instigator.SetPhysics(PHYS_NONE);
    }
}

state Activated
{
    function BeginState()
    {
        Super.BeginState();

        OriginalPhysics = Instigator.Physics;
        Instigator.SetPhysics(PHYS_None);
        if(PlayerController(Instigator.Controller) != None)
            Instigator.Controller.GotoState('PlayerWalking');
    }

    event Tick(float dt)
    {
        Super.Tick(dt);

        if(!bPendingDelete)
        {
            if(Instigator.Physics != PHYS_NONE)
                Instigator.SetPhysics(PHYS_NONE);
        }
    }

    function Timer()
    {
        Super.Timer();
        ClientFixLocation(Instigator.Location);
    }

    function EndState()
    {
        if(Instigator != None && Instigator.Physics == PHYS_None)
        {
            Instigator.SetPhysics(OriginalPhysics);
            if(PlayerController(Instigator.Controller) != None && OriginalPhysics == PHYS_Flying)
                Instigator.Controller.GotoState('PlayerFlying');
        }

        Super.EndState();
    }
}

defaultproperties
{
    bAllowOnFlagCarriers=False
    bAllowOnVehicles=False

    EffectSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
    EffectOverlay=Shader'MutantSkins.Shaders.MutantGlowShader'
    EffectMessageClass=class'EffectMessage_NullEntropy'
}
