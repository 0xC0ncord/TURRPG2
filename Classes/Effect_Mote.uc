//=============================================================================
// Effect_Mote.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Effect_Mote extends RPGEffect;

var float EffectRadius; //radius to create new instances of myself

var Effect_Mote Source;
var bool bIsSource; //if this is a source effect and not an instance created by a source
var bool bConvertToSource;
var int Stacks;

var class<Actor> DoubleEffectClass;
var class<Actor> TripleEffectClass;
var class<RPGStatusIcon> DoubleStatusIconClass;
var class<RPGStatusIcon> TripleStatusIconClass;

state Activated
{
    function BeginState()
    {
        local int OldStacks;

        OldStacks = Stacks;

        if(bIsSource && bRestarting)
        {
            //don't add a stack for a copy newly converted to a source
            if(!bConvertToSource)
                Stacks = Min(Stacks + 1, 3);
            else
                bConvertToSource = false;
        }

        Super.BeginState();

        if(Stacks != OldStacks)
        {
            RestartStatusIcon();
            RestartEmitters();
        }
    }

    function Tick(float dt)
    {
        local Controller C;
        local Effect_Mote Effect;

        if(Stacks > 1 && Duration - dt <= 0)
        {
            Stacks--;
            Duration = default.Duration;
            RestartStatusIcon();
            RestartEmitters();
        }

        Super.Tick(dt);

        if(!bIsSource)
        {
            if(
                Source == None
                || Source.Instigator == None
                || VSize(Instigator.Location - Source.Instigator.Location) > Source.EffectRadius
            )
            {
                Destroy();
                return;
            }
        }

        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(
                C.Pawn != None
                && C.Pawn != Instigator
                && C.Pawn.Health > 0
                && class'Util'.static.SameTeamC(C, EffectCauser)
                && VSize(C.Pawn.Location - Instigator.Location) <= EffectRadius
                && FastTrace(C.Pawn.Location, Instigator.Location)
            )
            {
                Effect = Effect_Mote(Class.static.GetFor(C.Pawn));
                if(
                    Effect == None
                    || (
                        !Effect.bIsSource
                        && Effect.Source != Self
                        && (
                            Effect.Duration < Duration
                            || Effect.Modifier < Modifier
                        )
                    )
                )
                {
                    Effect = Effect_Mote(Class.static.Create(C.Pawn, EffectCauser, Duration, Modifier));
                    if(Effect != None)
                    {
                        Effect.Start();
                    }
                }
            }
        }
    }
}

function RestartStatusIcon()
{
    if(InstigatorRPRI == None)
        return;

    InstigatorRPRI.ClientRemoveStatusIcon(StatusIconClass);

    switch(Stacks)
    {
        case 3:
            StatusIconClass = TripleStatusIconClass;
            break;
        case 2:
            StatusIconClass = DoubleStatusIconClass;
            break;
        default:
            StatusIconClass = default.StatusIconClass;
            break;
    }

    InstigatorRPRI.ClientCreateStatusIcon(StatusIconClass);
}

function RestartEmitters()
{
    local Controller C;
    local RPGPlayerReplicationInfo RPRI;

    switch(Stacks)
    {
        case 3:
            EffectClass = TripleEffectClass;
            break;
        case 2:
            EffectClass = DoubleEffectClass;
            break;
        default:
            EffectClass = default.EffectClass;
            break;
    }

    //if we gained or lost a stack, restart the effect
    if(SpawnedEffect != None)
    {
        if(Level.NetMode == NM_Standalone)
            Emitter(SpawnedEffect).Kill();
        else
        {
            for(C = Level.ControllerList; C != None; C = C.NextController)
            {
                if(PlayerController(C) != None)
                {
                    RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(C);
                    if(RPRI != None)
                        RPRI.ClientKillEmitter(Emitter(SpawnedEffect));
                }
            }
        }
    }
    if(ShouldDisplayEffect() && EffectClass != None)
            SpawnedEffect = Instigator.Spawn(EffectClass, Instigator);
}

defaultproperties
{
    EffectRadius=512.0
    Duration=8.0
    Stacks=1
    bEffectNeedsKill=True
    bSpawnEffectEveryInterval=False
    bHarmful=False
    bAllowOnEnemies=False
}
