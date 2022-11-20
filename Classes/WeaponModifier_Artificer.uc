//=============================================================================
// WeaponModifier_Artificer.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class WeaponModifier_Artificer extends RPGWeaponModifier
    DependsOn(RPGCharSettings);

var localized string PatternPoorQuality;
var localized string PatternLowQuality;
var localized string PatternMediumQuality;
var localized string PatternHighQuality;
var localized string PatternPristineQuality;

var ArtificerAugmentBase AugmentList, AugmentListTail;
var array<RPGCharSettings.ArtificerAugmentStruct> CurrentAugments;

var ArtificerFireModeBase PrimaryFireModes, AlternateFireModes;
var ArtificerFireModeBase LastPrimaryFireMode, LastAlternateFireMode;
var ArtificerFireModeBase CurrentPrimaryFireMode, CurrentAlternateFireMode;
var ArtificerFireModeDeathObserver DeathWatcher;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientAddAugment, ClientRemoveAugment, ClientSetAugmentLevel,
        ClientSortAugments, ClientUpdateDescription;
    reliable if(Role < ROLE_Authority)
        ServerNextPrimaryFireMode, ServerNextAlternateFireMode;
}

final function InitAugments(array<RPGCharSettings.ArtificerAugmentStruct> NewAugments)
{
    local int i, x;
    local array<RPGCharSettings.ArtificerAugmentStruct> ValidatedAugments;
    local int Slots;
    local ArtificerAugmentBase Augment;

    SetActive(false);

    //validate the augments first
    for(i = 0; i < NewAugments.Length; i++)
    {
        for(x = 0; x < NewAugments[i].Modifier; x++)
        {
            if(Slots >= Modifier)
            {
                i = NewAugments.Length;
                break;
            }
            NewAugments[i].AugmentClass.static.InsertInto(ValidatedAugments);
            Slots++;
        }
    }

    //FIXME if an augment ever has any functionality which involves a cooldown,
    //this will need to be rewritten later so that we don't also reset its cooldown
    //in order to avoid an unsealing/sealing exploit

    //remove old augments not in the new array
    for(i = 0; i < CurrentAugments.Length; i++)
    {
        for(x = 0; x < ValidatedAugments.Length; x++)
        {
            if(CurrentAugments[i].AugmentClass == ValidatedAugments[x].AugmentClass)
            {
                x = -1;
                break;
            }
        }
        if(x != -1)
        {
            RemoveAugment(CurrentAugments[i].AugmentClass);
            if(Level.NetMode != NM_Standalone)
                ClientRemoveAugment(CurrentAugments[i].AugmentClass);
        }
    }

    //add new augments not in the old array, or adjust levels
    for(i = 0; i < ValidatedAugments.Length; i++)
    {
        for(x = 0; x < CurrentAugments.Length; x++)
        {
            if(ValidatedAugments[i].AugmentClass == CurrentAugments[x].AugmentClass)
            {
                if(ValidatedAugments[i].Modifier != CurrentAugments[x].Modifier)
                {
                    SetAugmentLevel(ValidatedAugments[i].AugmentClass, ValidatedAugments[i].Modifier);
                    ClientSetAugmentLevel(ValidatedAugments[i].AugmentClass, ValidatedAugments[i].Modifier);
                }
                x = -1;
                break;
            }
        }
        if(x != -1)
        {
            AddAugment(ValidatedAugments[i].AugmentClass, ValidatedAugments[i].Modifier);
            ClientAddAugment(ValidatedAugments[i].AugmentClass, ValidatedAugments[i].Modifier);
        }
    }

    SortAugments();
    ClientSortAugments();

    //with the augment list potentially changed, tell them to check if they should disable themselves
    //can happen with penetrating and a new instant-hit fire mode that did not exist previously
    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Augment.CheckDisabled();

    SetOverlay();
    ClientUpdateDescription();

    SetActive(true);

    CurrentAugments = ValidatedAugments;
}

simulated function Destroyed()
{
    local ArtificerAugmentBase Augment, NextAugment;

    Super.Destroyed();

    DestroyFireModes();

    Augment = AugmentList;
    while(Augment != None)
    {
        NextAugment = Augment.NextAugment;

        if(Role == ROLE_Authority)
            Augment.StopEffect();
        else
            Augment.ClientStopEffect();
        Augment.Free();

        Augment = NextAugment;
    }
}

simulated final function AddAugment(class<ArtificerAugmentBase> AugmentClass, int NewLevel)
{
    local ArtificerAugmentBase Augment;

    Augment = ArtificerAugmentBase(Level.ObjectPool.AllocateObject(AugmentClass));

    if(AugmentList == None)
        AugmentList = Augment;
    else
    {
        Augment.PrevAugment = AugmentListTail;
        AugmentListTail.NextAugment = Augment;
    }

    AugmentListTail = Augment;

    Augment.Init(Self, NewLevel);
    Augment.Apply();
}

simulated final function RemoveAugment(class<ArtificerAugmentBase> AugmentClass)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
    {
        if(Augment.Class == AugmentClass)
        {
            Augment.Remove();
            return;
        }
    }
}

simulated final function SetAugmentLevel(class<ArtificerAugmentBase> AugmentClass, int NewLevel)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
    {
        if(Augment.Class == AugmentClass)
        {
            Augment.SetLevel(NewLevel);
            return;
        }
    }
}

simulated final function SortAugments()
{
    local ArtificerAugmentBase Augment, PrevAugment, NextAugment;
    local int Length;
    local int i, x;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        Length++;

    if(Length == 0)
        return;

    for(i = 1; i < Length; i++)
    {
        Augment = AugmentList;
        for(x = 0; x <= Length - i - 1; x++)
        {
            if(Augment.OrderIndex > Augment.NextAugment.OrderIndex)
            {
                PrevAugment = Augment.PrevAugment;
                NextAugment = Augment.NextAugment;

                if(PrevAugment != None)
                    PrevAugment.NextAugment = NextAugment;
                else
                    AugmentList = Augment.NextAugment;

                Augment.NextAugment = NextAugment.NextAugment;
                Augment.PrevAugment = NextAugment;

                if(NextAugment.NextAugment != None)
                    NextAugment.NextAugment.PrevAugment = Augment;
                else
                    AugmentListTail = Augment;

                NextAugment.NextAugment = Augment;
                NextAugment.PrevAugment = PrevAugment;
            }
            else
                Augment = Augment.NextAugment;
        }
    }
}

simulated final function ClientAddAugment(class<ArtificerAugmentBase> AugmentClass, int NewLevel)
{
    if(Role < ROLE_Authority)
        AddAugment(AugmentClass, NewLevel);
}

simulated final function ClientRemoveAugment(class<ArtificerAugmentBase> AugmentClass)
{
    if(Role < ROLE_Authority)
        RemoveAugment(AugmentClass);
}

simulated final function ClientSetAugmentLevel(class<ArtificerAugmentBase> AugmentClass, int NewLevel)
{
    if(Role < ROLE_Authority)
        SetAugmentLevel(AugmentClass, NewLevel);
}

simulated final function ClientSortAugments()
{
    if(Role < ROLE_Authority)
        SortAugments();
}

simulated final function ArtificerFireModeBase CreateFireMode(class<ArtificerFireModeBase> FireModeClass, int ModeNum)
{
    local ArtificerFireModeBase NewFireMode;

    NewFireMode = ArtificerFireModeBase(Level.ObjectPool.AllocateObject(FireModeClass));
    NewFireMode.WeaponModifier = Self;
    NewFireMode.Weapon = Weapon;
    NewFireMode.ModeNum = ModeNum;
    NewFireMode.Initialize();
    return NewFireMode;
}

simulated final function AddFireMode(ArtificerFireModeBase NewFireMode)
{
    //When adding a new fire mode, spawn a normal fire mode for the original
    //firing mode and put that as the first in the list
    switch(NewFireMode.ModeNum)
    {
        case 0:
            if(PrimaryFireModes == None)
            {
                PrimaryFireModes = CreateFireMode(class'ArtificerFireMode_Normal', 0);
                LastPrimaryFireMode = PrimaryFireModes;
                CurrentPrimaryFireMode = PrimaryFireModes;
            }

            LastPrimaryFireMode.NextFireMode = NewFireMode;
            LastPrimaryFireMode = NewFireMode;

            if(CurrentPrimaryFireMode == None)
                NextPrimaryFireMode();
            break;
        case 1:
            if(AlternateFireModes == None)
            {
                AlternateFireModes = CreateFireMode(class'ArtificerFireMode_Normal', 1);
                LastAlternateFireMode = AlternateFireModes;
                CurrentAlternateFireMode = AlternateFireModes;
            }

            LastAlternateFireMode.NextFireMode = NewFireMode;
            LastAlternateFireMode = NewFireMode;

            if(CurrentAlternateFireMode == None)
                NextAlternateFireMode();
            break;
    }

    if(DeathWatcher == None)
    {
        DeathWatcher = Spawn(class'ArtificerFireModeDeathObserver', Self);
        DeathWatcher.Setup(Self, Weapon);
    }
}

simulated final function RemoveFireMode(ArtificerFireModeBase FireMode)
{
    local ArtificerFireModeBase CurrentFireMode;
    local bool bRemoved;
    local byte ModeNum;

    if(FireMode == None)
        return;

    ModeNum = FireMode.ModeNum;

    switch(ModeNum)
    {
        case 0:
            CurrentFireMode = PrimaryFireModes;
            break;
        case 1:
            CurrentFireMode = AlternateFireModes;
            break;
        default:
            return;
    }

    // no fire mode or the desired one is already the current one
    if(CurrentFireMode == None || CurrentFireMode == FireMode)
        return;

    while(CurrentFireMode.NextFireMode != None)
    {
        if(CurrentFireMode.NextFireMode == FireMode)
        {
            CurrentFireMode.NextFireMode = CurrentFireMode.NextFireMode.NextFireMode;
            FireMode.NextFireMode = None;
            bRemoved = true;
            //Do not break here. We need to reach the end of the list
            //because we'll update the tail by finding the last one.
        }
        else
            CurrentFireMode = CurrentFireMode.NextFireMode;
    }

    switch(FireMode.ModeNum)
    {
        case 0:
            LastPrimaryFireMode = CurrentFireMode;
            break;
        case 1:
            LastAlternateFireMode = CurrentFireMode;
            break;
    }

    if(bRemoved)
    {
        if(FireMode.FireMode.bIsFiring)
        {
            Weapon.StopFire(ModeNum);
            if(FireMode.FireMode.bFireOnRelease)
                FireMode.FireMode.ModeDoFire();
        }

        switch(ModeNum)
        {
            case 0:
                if(PrimaryFireModes.NextFireMode == None)
                {
                    PrimaryFireModes.Deinitialize();
                    PrimaryFireModes.Free();
                    PrimaryFireModes = None;
                    LastPrimaryFireMode = None;
                    CurrentPrimaryFireMode = None;
                }
                else if(FireMode == CurrentPrimaryFireMode)
                    NextPrimaryFireMode();
                break;
            case 1:
                if(AlternateFireModes.NextFireMode == None)
                {
                    AlternateFireModes.Deinitialize();
                    AlternateFireModes.Free();
                    AlternateFireModes = None;
                    LastAlternateFireMode = None;
                    CurrentAlternateFireMode = None;
                }
                else if(FireMode == CurrentAlternateFireMode)
                    NextAlternateFireMode();
                break;
        }
        FireMode.Deinitialize();
        FireMode.Free();
    }
}

simulated final function SetFireMode(ArtificerFireModeBase NewFireMode)
{
    local bool bRestartFiring;
    local int i;

    if(Role < ROLE_Authority)
        ServerSetFireMode(NewFireMode);

    bRestartFiring = false;
    if(Instigator != None && NewFireMode != None && NewFireMode.FireMode != None && Weapon != None)
    {
        if(Weapon.GetFireMode(NewFireMode.ModeNum).bIsFiring)
        {
            Weapon.StopFire(NewFireMode.ModeNum);
            bRestartFiring = true;
        }

        NewFireMode.ReInitFireMode();
        class'DummyWeaponHack'.static.ModifyFireMode(Weapon, NewFireMode.ModeNum, NewFireMode.FireMode);
        //Weapon.bShowChargingBar = NewFireMode.bShowChargingBar;

        if(Instigator != None)
        {
            if(RPRI != None)
                for(i = 0; i < RPRI.Abilities.Length; i++)
                    if(RPRI.Abilities[i].bAllowed)
                        RPRI.Abilities[i].ModifyWeapon(Weapon);

            if(Role == ROLE_Authority)
                StartEffect();
            else
                ClientStartEffect();

            if(bRestartFiring)
            {
                if(Role == ROLE_Authority && Instigator.IsLocallyControlled())
                    Weapon.ServerStartFire(NewFireMode.ModeNum);
                else
                    Weapon.ClientStartFire(NewFireMode.ModeNum);
            }

            BuildDescription();
        }
    }
}

final function ServerSetFireMode(ArtificerFireModeBase NewFireMode)
{
    SetFireMode(NewFireMode);
}

final function ResetFireModes()
{
    if(PrimaryFireModes != None)
        SetFireMode(PrimaryFireModes);
    if(AlternateFireModes != None)
        SetFireMode(AlternateFireModes);
}

simulated final function DestroyFireModes()
{
    local ArtificerFireModeBase CurrentFireMode;
    local array<ArtificerFireModeBase> FireModes;
    local int i;

    for(CurrentFireMode = PrimaryFireModes; CurrentFireMode != None; CurrentFireMode = CurrentFireMode.NextFireMode)
        FireModes[FireModes.Length] = CurrentFireMode;
    for(CurrentFireMode = AlternateFireModes; CurrentFireMode != None; CurrentFireMode = CurrentFireMode.NextFireMode)
        FireModes[FireModes.Length] = CurrentFireMode;

    for(i = 0; i < FireModes.Length; i++)
    {
        FireModes[i].Deinitialize();
        FireModes[i].Free();
    }
}

simulated final function NextPrimaryFireMode()
{
    local ArtificerFireModeBase NextFireMode;

    if(PrimaryFireModes == None)
        return;

    if(Role < ROLE_Authority)
        ServerNextPrimaryFireMode();

    if(CurrentPrimaryFireMode == None)
        NextFireMode = PrimaryFireModes;
    else
    {
        NextFireMode = CurrentPrimaryFireMode.NextFireMode;
        if(NextFireMode == None)
            NextFireMode = PrimaryFireModes;
    }

    while(!NextFireMode.bEnabled)
    {
        NextFireMode = NextFireMode.NextFireMode;

        if(NextFireMode == None)
            NextFireMode = PrimaryFireModes;

        //if this triggers, we've looped without finding any firing mode to use
        if(NextFireMode == CurrentPrimaryFireMode)
        {
            NextFireMode = None;
            break;
        }
    }

    if(NextFireMode != CurrentPrimaryFireMode)
    {
        if(CurrentPrimaryFireMode != None)
            CurrentPrimaryFireMode.Deactivate();

        CurrentPrimaryFireMode = NextFireMode;

        if(NextFireMode != None)
        {
            NextFireMode.Activate();
            SetFireMode(NextFireMode);
        }
    }
}

simulated final function NextAlternateFireMode()
{
    local ArtificerFireModeBase NextFireMode;

    if(AlternateFireModes == None)
        return;

    if(Role < ROLE_Authority)
        ServerNextAlternateFireMode();

    if(CurrentAlternateFireMode == None)
        NextFireMode = AlternateFireModes;
    else
    {
        NextFireMode = CurrentAlternateFireMode.NextFireMode;
        if(NextFireMode == None)
            NextFireMode = AlternateFireModes;
    }

    while(!NextFireMode.bEnabled)
    {
        NextFireMode = NextFireMode.NextFireMode;

        if(NextFireMode == None)
            NextFireMode = AlternateFireModes;

        //if this triggers, we've looped without finding any firing mode to use
        if(NextFireMode == CurrentAlternateFireMode)
        {
            NextFireMode = None;
            break;
        }
    }

    if(NextFireMode != CurrentAlternateFireMode)
    {
        if(CurrentAlternateFireMode != None)
            CurrentAlternateFireMode.Deactivate();

        CurrentAlternateFireMode = NextFireMode;

        if(NextFireMode != None)
        {
            NextFireMode.Activate();
            SetFireMode(NextFireMode);
        }
    }
}

final function ServerNextPrimaryFireMode()
{
    NextPrimaryFireMode();
}

final function ServerNextAlternateFireMode()
{
    NextAlternateFireMode();
}

function StartEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.StartEffect();
}

function StopEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.StopEffect();
}

simulated function ClientStartEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.ClientStartEffect();
}

simulated function ClientStopEffect()
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.ClientStopEffect();
}

function RPGTick(float dt)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.RPGTick(dt);

    if(CurrentPrimaryFireMode != None)
        CurrentPrimaryFireMode.ModeTick(dt);
    if(CurrentAlternateFireMode != None)
        CurrentAlternateFireMode.ModeTick(dt);
}

simulated function ClientRPGTick(float dt)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.ClientRPGTick(dt);

    if(CurrentPrimaryFireMode != None)
        CurrentPrimaryFireMode.ModeTick(dt);
    if(CurrentAlternateFireMode != None)
        CurrentAlternateFireMode.ModeTick(dt);
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.AdjustTargetDamage(Damage, OriginalDamage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Augment.AdjustPlayerDamage(Damage, OriginalDamage, InstigatedBy, HitLocation, Momentum, DamageType);
}

function bool PreventDeath(Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    local ArtificerAugmentBase Augment;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled && Augment.PreventDeath(Killer, DamageType, HitLocation, bAlreadyPrevented))
            bAlreadyPrevented = true;

    if(bAlreadyPrevented && DamageType != class'Suicided' && Killer != Instigator.Controller)
        return true;
}

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier)
{
    local ArtificerAugmentBase Augment;
    local bool bAlreadyDenied;

    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled && !Augment.AllowEffect(EffectClass, Causer, Duration, Modifier))
            bAlreadyDenied = true;

    return !bAlreadyDenied;
}

function SetOverlay(optional Material Mat)
{
    local ArtificerAugmentBase Augment;
    local int MaxLevel;

    if(Mat != None)
    {
        Super.SetOverlay(Mat);
        return;
    }

    // determine which overlay to show, then show it
    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
    {
        if(!Augment.bDisabled && MaxLevel < Augment.Modifier && Augment.ModifierOverlay != None)
        {
            MaxLevel = Augment.Modifier;
            Mat = Augment.ModifierOverlay;
        }
    }
    Super.SetOverlay(Mat);
}

simulated function ClientUpdateDescription()
{
    BuildDescription();
}

simulated function BuildDescription()
{
    local ArtificerAugmentBase Augment;

    if(AugmentList == None)
    {
        Description = default.Description;
        return;
    }

    Description = AugmentList.GetDescription();

    for(Augment = AugmentList.NextAugment; Augment != None; Augment = Augment.NextAugment)
        if(!Augment.bDisabled)
            Description $= "," @ Augment.GetDescription();
}

simulated static function string StaticGetDescription(int Modifier)
{
    return default.Description;
}

static function string ConstructItemName(class<Weapon> WeaponClass, int Modifier)
{
    local string NewItemName;
    local string Pattern;

    if(default.PatternNeg == "")
        default.PatternNeg = default.PatternPos;

    if(Modifier >= 0)
    {
        if(Modifier > 10)
            Pattern = default.PatternPos;
        else
        {
            switch(Modifier)
            {
                case 0:
                case 1:
                case 2:
                    Pattern = default.PatternPoorQuality;
                    break;
                case 3:
                case 4:
                    Pattern = default.PatternLowQuality;
                    break;
                case 5:
                case 6:
                    Pattern = default.PatternMediumQuality;
                    break;
                case 7:
                case 8:
                    Pattern = default.PatternHighQuality;
                    break;
                case 9:
                case 10:
                    Pattern = default.PatternPristineQuality;
                    break;
            }
        }
    }
    else if(Modifier < 0)
    {
        Pattern = default.PatternNeg;
    }

    NewItemName = Repl(Pattern, "$W", WeaponClass.default.ItemName);

    if(!default.bOmitModifierInName)
    {
        if(Modifier > 0)
            NewItemName @= "+" $ Modifier;
        else if(Modifier < 0)
            NewItemName @= Modifier;
    }

    return NewItemName;
}

#ifdef __DEBUG__
simulated function PostRender(Canvas Canvas)
{
    local float PosX, PosY;
    local float X, Y;
    local ArtificerAugmentBase Augment;

    Canvas.FontScaleX = (Canvas.ClipX / 1024.0f) * 0.35;
    Canvas.FontScaleY = Canvas.FontScaleX;
    Canvas.TextSize("A", X, Y);

    PosX = 384;
    PosY = 256;

    Canvas.Style = 1;
    for(Augment = AugmentList; Augment != None; Augment = Augment.NextAugment)
    {
        Canvas.SetPos(PosX, PosY);
        Canvas.DrawColor = Augment.ModifierColor;
        Canvas.DrawText(Augment.ModifierName $ ", Level" @ Augment.Modifier $ "," @ Eval(Augment.bDisabled, "DISABLED", "ENABLED"));

        PosY += Y;
    }
}
#endif

defaultproperties
{
    bCanHaveZeroModifier=False
    bCanThrow=False
    PatternPoorQuality="Crude Artificer's $W"
    PatternLowQuality="Artificer's Lesser $W"
    PatternMediumQuality="Artificer's $W of Handicraft"
    PatternHighQuality="Artificer's Pristine $W"
    PatternPristineQuality="Artificer's Mastercrafted $W"
    Description="embodies effects which are sealed by an Artificer's Charm"
    PatternPos="Artificer's $W"
    PatternNeg="Artificer's $W"
}
