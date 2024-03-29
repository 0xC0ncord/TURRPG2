//=============================================================================
// RPGWeaponModifier.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    FINALLY getting rid of RPGWeapon. This is the future.
*/
class RPGWeaponModifier extends ReplicationInfo
    config(TURRPG2);

//Weapon
var Weapon Weapon;
var RPGPlayerReplicationInfo RPRI;
var bool bActive;
var float OldFireTime[2];

//Modifier level
var config int MinModifier, MaxModifier;
var bool bCanHaveZeroModifier;

var int Modifier;

//Bonus
var config float DamageBonus, BonusPerLevel;

//Visual
var bool bIdentified;
var Material ModifierOverlay;

//Client Sync
var Sync_OverlayMaterial SyncThirdPerson;

var int ClientModifier;
var bool bClientIdentified; //checked client-side
var bool bResetPendingWeapon; //fixes PipedSwitchWeapon

//Item name
var localized string PatternPos, PatternNeg;

//AI
var float AIRatingBonus;
var array<class<DamageType> > CountersDamage;
var array<class<RPGWeaponModifier> > CountersModifier;
var bool bTeamFriendly; //whether or not this modifier counts as one which boosts or heals teammates

//Restrictions
var config array<class<Weapon> > ForbiddenWeaponTypes;
var config array<string> ForbiddenWeaponNames; //same as above but as strings to avoid external deps
var config bool bAllowForSpecials; //inventory groups 0 (super weapons) and 10 (xloc)
var bool bCanThrow;

//Description
var bool bOmitModifierInName;
var localized string DamageBonusText;
var string Description;

replication{
    reliable if(Role == ROLE_Authority && bNetInitial)
        Weapon;

    reliable if(Role == ROLE_Authority && bNetDirty)
        Modifier, bIdentified;

    reliable if(Role == ROLE_Authority)
        ClientSetFirstPersonOverlay, ClientSetActive, ClientRestore;
}

static function bool AllowedFor(class<Weapon> WeaponType, optional Pawn Other) {
    local int i;
    local int Pos;

    for(i = 0; i < class'MutTURRPG'.default.DisallowModifiersFor.Length; i++) {
        if(ClassIsChildOf(WeaponType, class'MutTURRPG'.default.DisallowModifiersFor[i])) {
            return false;
        }
    }

    if(!default.bAllowForSpecials &&
        (
            WeaponType.default.InventoryGroup == 0 || //Super weapons
            WeaponType.default.InventoryGroup == 10 || //Translocator
            WeaponType.default.InventoryGroup == 15 //Ball Launcher
        )
    ) {
        return false;
    }

    for(i = 0; i < default.ForbiddenWeaponTypes.Length; i++) {
        if(WeaponType == default.ForbiddenWeaponTypes[i]) {
            return false;
        }
    }

    for(i = 0; i < default.ForbiddenWeaponNames.Length; i++) {
        Pos = InStr(string(WeaponType), ".");
        if(Right(string(WeaponType), Len(string(WeaponType)) - Pos - 1) ~= default.ForbiddenWeaponNames[i]) {
            return false;
        }
    }

    return true;
}

//interface for weapon makers
static function bool AllowRemoval(Weapon W, int Modifier)
{
    return true;
}

static function RPGWeaponModifier Modify(Weapon W, int Modifier, optional bool bIdentify, optional bool bForce) {
    local RPGWeaponModifier WM;

    if(!bForce && !AllowedFor(W.class, W.Instigator))
        return None;

    RemoveModifier(W); //remove existing

    WM = W.Instigator.Spawn(default.class, W);
    if(WM != None) {
        if(Modifier == -100) {
            //Random
            Modifier = GetRandomModifierLevel();
        }

        WM.SetModifier(Modifier, bIdentify);
    }

    return WM;
}

static function RemoveModifier(Weapon W) {
    local RPGWeaponModifier WM;

    WM = GetFor(W, true);
    if(WM != None) {
        WM.Destroy();
    }
}

static function RPGWeaponModifier GetFor(Weapon W, optional bool bAny) {
    local RPGWeaponModifier WM;

    if(W != None && W.Instigator != None) {
        foreach W.Instigator.ChildActors(class'RPGWeaponModifier', WM) {
            if(WM.Weapon == W && (bAny || ClassIsChildOf(WM.class, default.class))) {
                return WM;
            }
        }
    }
    return None;
}

static function string ConstructItemName(class<Weapon> WeaponClass, int Modifier) {
    local string NewItemName;
    local string Pattern;

    if(default.PatternNeg == "")
        default.PatternNeg = default.PatternPos;

    if(Modifier >= 0) {
        Pattern = default.PatternPos;
    } else if(Modifier < 0) {
        Pattern = default.PatternNeg;
    }

    NewItemName = repl(Pattern, "$W", WeaponClass.default.ItemName);

    if(!default.bOmitModifierInName) {
        if(Modifier > 0)
            NewItemName @= "+" $ Modifier;
        else if(Modifier < 0)
            NewItemName @= Modifier;
    }

    return NewItemName;
}

static function int GetRandomModifierLevel() {
    local int x;

    if(default.MinModifier == 0 && default.MaxModifier == 0)
        return 0;

    x = Rand(default.MaxModifier + 1 - default.MinModifier) + default.MinModifier;

    if(x == 0 && !default.bCanHaveZeroModifier)
        x = 1;

    return x;
}

static function int GetRandomPositiveModifierLevel(optional int Minimum) {
    local int x;

    if(default.bCanHaveZeroModifier) {
        Minimum = Max(0, Minimum);
    } else {
        Minimum = Max(1, Minimum);
    }

    x = Max(Minimum, default.MinModifier);

    if(default.MaxModifier <= x) {
        return default.MaxModifier; //well, what can we do?
    } else {
        return Rand(default.MaxModifier + 1 - x) + x;
    }
}

simulated event PostBeginPlay() {
    Super.PostBeginPlay();

    if(Role == ROLE_Authority) {
        SetWeapon(Weapon(Owner));
        if(Weapon == None) {
            Warn(Self @ "has no weapon!");
            Destroy();
        }
    }
}

function SetWeapon(Weapon W) {
    Weapon = W;
    Instigator = W.Instigator;

    // WOP: ensure that BaseChange() gets called if the weapon is destroyed
    // so we can act on it as early as possible during the destroy process
    SetBase(W);

    if(Instigator.PlayerReplicationInfo != None) {
        RPRI = class'RPGPlayerReplicationInfo'.static.GetForPRI(Instigator.PlayerReplicationInfo);
    } else {
        RPRI = None;
    }
}

function SetModifier(int x, optional bool bIdentify) {
    local bool bWasActive;

    bWasActive = bActive;
    if(bActive) {
        SetActive(false);
    }

    Modifier = x;

    if(Modifier < 0 || Modifier > MaxModifier) {
        Weapon.bCanThrow = false; //cannot throw negative or enhanced weapons
    } else {
        Weapon.bCanThrow = Weapon.default.bCanThrow && bCanThrow;
    }

    if(bIdentify || bIdentified) {
        Identify(true);
    }

    if(bWasActive) {
        SetActive(true);
    }
}

simulated event Tick(float dt) {
    local xPawn X;
    local int i;
    local WeaponFire WF;

    if(Role == ROLE_Authority) {
        if(Weapon == None) {
            SetActive(false);
            Destroy();
            return;
        }

        if(Instigator != None) {
            if(!bActive && Instigator.Weapon == Weapon) {
                SetActive(true);
            } else if(bActive && Instigator.Weapon != Weapon) {
                SetActive(false);
            }
        } else if(bActive) {
            SetActive(false);
        }

        if(bActive) {
            if(bIdentified && xPawn(Instigator) != None) {
                X = xPawn(Instigator);
                if(X.HasUDamage()) {
                    if(Weapon.OverlayMaterial != X.UDamageWeaponMaterial) {
                        SetOverlay(X.UDamageWeaponMaterial);
                    }
                } else if(X.bInvis) {
                    if(Weapon.OverlayMaterial != X.InvisMaterial) {
                        SetOverlay(X.InvisMaterial);
                    }
                } else if(Weapon.OverlayMaterial != ModifierOverlay) {
                    SetOverlay();
                }
            }

            // WeaponFire hook
            for(i = 0; i < Weapon.NUM_FIRE_MODES; i++) {
                WF = Weapon.GetFireMode(i);
                // WeaponFire calls DoFireEffect() on the tick immediately
                // after the tick where fire was pressed
                if(
                    WF.NextFireTime > OldFireTime[i]
                    && WF.NextFireTime != Level.TimeSeconds
                    && (
                        MinigunFire(WF) == None
                        || WF.IsInState('FireLoop')
                    )
                ) {
                    WeaponFire(i);
                }
                OldFireTime[i] = WF.NextFireTime;
            }

            RPGTick(dt);
        }
    }

    if(Role < ROLE_Authority || Level.NetMode == NM_Standalone) {
        if(bResetPendingWeapon) {
            bResetPendingWeapon = false;

            if(Instigator != None) {
                Instigator.PendingWeapon = None;
            }
        }

        if(Weapon != None) {
            if(bIdentified && (!bClientIdentified || Modifier != ClientModifier)) {
                ClientModifier = Modifier;
                bClientIdentified = true;

                ClientIdentify();
            }

            if(bActive) {
                if(Weapon != None) {
                    ClientRPGTick(dt);
                }
            }
        }
    }
}

function Identify(optional bool bReIdentify) {
    if(!bIdentified || bReIdentify) {
        Weapon.ItemName = ConstructItemName(Weapon.class, Modifier);
        bIdentified = true;
    }
}

simulated function ClientIdentify() {
    if(Role < ROLE_Authority) {
        Weapon.ItemName = ConstructItemName(Weapon.class, Modifier);
        Description = "";

        if(Instigator != None && Instigator.Weapon == Weapon) {
            //Hud hack - force display of weapon name as if it has just been selected
            Instigator.PendingWeapon = Weapon;
            bResetPendingWeapon = true;
        }
    }

    //notify the player if this is a favorite
    if(Level.NetMode != NM_DedicatedServer && Level.GetLocalPlayerController() == Instigator.Controller)
    {
        if(RPRI == None && Instigator.PlayerReplicationInfo != None)
            RPRI = class'RPGPlayerReplicationInfo'.static.GetForPRI(Instigator.PlayerReplicationInfo);
        if(RPRI != None && RPRI.IsFavorite(Weapon.Class, Class))
            RPRI.NotifyFavorite(Self);
    }
}

simulated function ClientRestore() {
    Weapon.ItemName = Weapon.default.ItemName;
    if(Role < ROLE_Authority && Instigator != None && Instigator.Weapon == Weapon) {
        Instigator.PendingWeapon = Weapon;
    }
}

function SetActive(bool bActivate) {
    if(bActivate && !bActive) {
        StartEffect();
        ClientSetActive(true);

        if(bIdentified)
            SetOverlay();
    }
    else if(!bActivate && bActive) {
        StopEffect();
        ClientSetActive(false);
    }

    bActive = bActivate;
}

simulated function ClientSetActive(bool bActivate) {
    if(Role < ROLE_Authority || Level.NetMode == NM_Standalone) {
        bActive = bActivate;

        if(bActivate) {
            ClientStartEffect();
        } else {
            ClientStopEffect();
        }
    }
}

simulated function ClientSetFirstPersonOverlay(Material Mat) {
    Weapon.SetOverlayMaterial(Mat, 9999, true);
}

function SetOverlay(optional Material Mat) {
    if(Mat == None) {
        Mat = ModifierOverlay;
    }

    Weapon.SetOverlayMaterial(Mat, 9999, true);
    ClientSetFirstPersonOverlay(Mat);

    if(SyncThirdPerson != None) {
        SyncThirdPerson.Destroy();
    }

    if(Weapon.ThirdPersonActor != None) {
        SyncThirdPerson = class'Sync_OverlayMaterial'.static.Sync(Weapon.ThirdPersonActor, Mat, -1, true);
    }
}

//interface
function StartEffect(); //weapon gets drawn
function StopEffect(); //weapon gets put down

simulated function ClientStartEffect();
simulated function ClientStopEffect();

simulated function PostRender(Canvas C); //called client-side by the Interaction

function RPGTick(float dt); //called only if weapon is active
simulated function ClientRPGTick(float dt);

function WeaponFire(byte Mode); //called when weapon just fired

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    if(DamageBonus != 0 && Modifier != 0)
        Damage += float(Damage) * Modifier * DamageBonus;
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);

function bool PreventDeath(Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented) {
    return false;
}

function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier) {
    return true;
}

function float GetAIRating() {
    local RPGBot B;
    local int x;
    local float Rating;

    Rating = Weapon.GetAIRating();

    if(MaxModifier == 0) {
        Rating += AIRatingBonus;
    } else {
        Rating += AIRatingBonus * Modifier;
    }

    Rating += DamageBonus * Modifier;

    B = RPGBot(Instigator.Controller);
    if(B != None) {
        if(B.LastModifierSuffered != None) {
            for(x = 0; x < CountersModifier.Length; x++) {
                if(CountersModifier[x] == B.LastModifierSuffered) {
                    Rating *= 2.5;
                    break;
                }
            }
        }

        if(B.LastDamageTypeSuffered != None) {
            for(x = 0; x < CountersDamage.Length; x++) {
                if(CountersDamage[x] == B.LastDamageTypeSuffered) {
                    Rating *= 2.5;
                    break;
                }
            }
        }
    }

    return Rating;
}

simulated event Destroyed() {
    if(Role == ROLE_Authority) {
        SetActive(false);

        if(Weapon != None) {
            ClientRestore();
            Weapon.bCanThrow = Weapon.default.bCanThrow;

            if(Weapon.OverlayMaterial == ModifierOverlay) {
                Weapon.SetOverlayMaterial(None, 9999, true);
                ClientSetFirstPersonOverlay(None);
            }
        }

        if(SyncThirdPerson != None) {
            SyncThirdPerson.Destroy();

            if(Weapon != None) {
                class'Sync_OverlayMaterial'.static.Sync(Weapon.ThirdPersonActor, None, 5, true);
            }
        }
    }

    Super.Destroyed();
}

simulated function AddToDescription(string Format, optional float Bonus) {
    StaticAddToDescription(Description, Modifier, Format, Bonus);
}

simulated function BuildDescription() {
    if(DamageBonus != 0) {
        AddToDescription(DamageBonusText, DamageBonus);
    }
}

simulated function string GetDescription() {
    if(Description == "")
        BuildDescription();

    return Description;
}

simulated function string GetBonusPercentageString(float Bonus) {
    return StaticGetBonusPercentageString(Bonus, Modifier);
}

//Helper function
simulated static final function string StaticGetBonusPercentageString(float Bonus, int Modifier)
{
    local string text;

    if(default.MinModifier != 0 && default.MaxModifier != 0)
        Bonus *= float(Modifier);

    if(Bonus > 0) {
        text = "+";
    }

    text $= class'Util'.static.FormatPercent(Bonus);

    return text;
}

simulated static final function StaticAddToDescription(out string Description, int Modifier, string Format, optional float Bonus)
{
    if(Description != "")
        Description $= ", ";

    if(Bonus != 0) {
        Description $= Repl(Format, "$1", StaticGetBonusPercentageString(Bonus, Modifier));
    } else {
        Description $= Format;
    }
}

simulated static function string StaticGetDescription(int Modifier)
{
    local string Description;

    if(default.DamageBonus != 0)
        StaticAddToDescription(Description, Modifier, default.DamageBonusText, default.DamageBonus);

    return Description;
}

defaultproperties {
    DamageBonusText="$1 damage"

    DamageBonus=0
    BonusPerLevel=0

    bCanThrow=True
    bCanHaveZeroModifier=True

    DrawType=DT_None
    bHidden=True

    bAlwaysRelevant=False
    bOnlyRelevantToOwner=True
    bOnlyDirtyReplication=False
    bReplicateInstigator=True
    bSkipActorPropertyReplication=False
    NetUpdateFrequency=4.000000
    RemoteRole=ROLE_SimulatedProxy

    bAllowForSpecials=True

    AIRatingBonus=0
}
