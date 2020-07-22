//=============================================================================
// ArtifactBase_RemoteEffect.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ArtifactBase_RemoteEffect extends ArtifactBase_Beam
    abstract;

var class<RPGEffect> EffectClass;
var int XPforUse;

const MSG_CannotAccept = 0x0005;
var localized string Msg_Text_CannotAccept;

function BotWhatNext(Bot Bot); //too complicated for them

function bool DoEffect()
{
    if(!Super.DoEffect())
        return false;

    if(XPforUse > 0)
        class'RPGRules'.static.ShareExperience(InstigatorRPRI,XPForUse);

    return true;
}

function bool CanAffectTarget(Pawn Other)
{
    if(EffectClass != None)
        return (ValidTarget(Other) && EffectClass.static.CanBeApplied(Other, Instigator.Controller));

    return Super.CanAffectTarget(Other);
}

function HitTarget(Pawn Other)
{
    local RPGEffect Effect;

    SpawnEffects(Other);

    Effect = ApplyEffect(Other);
    if(Effect != None)
    {
        ModifyEffect(Effect);
        Effect.Start();
    }

    InstigatorRPRI.DrainAdrenaline(CostPerSec * AdrenalineUsage, Self);
}

function RPGEffect ApplyEffect(Pawn Other)
{
    if(EffectClass != None)
        return EffectClass.static.Create(Other, Instigator.Controller);
}

function ModifyEffect(RPGEffect Effect);

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_CannotAccept:
            return default.Msg_Text_CannotAccept;
    }
    return Super.GetMessageString(Msg,Value,Obj);
}

defaultproperties
{
    bHarmful=False
    bAllowOnEnemies=False
    bAllowOnTeammates=True
    bAllowOnGodMode=True
    Msg_Text_CannotAccept="That person cannot accept the powerup."
    HitEmitterClass=Class'FX_Bolt_Cyan'
    MaxRange=3000.000000
    MinAdrenaline=100
    CostPerSec=100
    XPforUse=10
    bCanBeTossed=False
}
