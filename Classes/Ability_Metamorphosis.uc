//=============================================================================
// Ability_Metamorphosis.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Ability_Metamorphosis extends RPGAbility
    config(TURRPG2);

var bool bSelect;

struct MonsterType
{
    var() int Level;
    var() class<xPawn> MonsterClass;
    var() bool bFlying;
    var() string DisplayName;
    var() int Cost;
    var() int Cooldown;
};
var() config array<MonsterType> MonsterTypes;

struct StoredWeapon
{
    var class<Weapon> WeaponClass;
    var class<RPGWeaponModifier> ModifierClass;
    var int Modifier;
    var bool bIdentified;
    var int Ammo[2];
};
var array<StoredWeapon> StoredWeapons;

struct StoredArtifact
{
    var class<RPGArtifact> ArtifactClass;
    var float NextUseTime;
    var int Charge;
};
var array<StoredArtifact> StoredArtifacts;

var() config float PassiveDamageBonus;
var() config float PassiveDamageReduction;

var() localized string MonsterPreText, MonsterPostText;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientModifyPossession;
}

function ModifyPawn(Pawn Other)
{
    local RPGArtifact A;

    Super.ModifyPawn(Other);

    A = Artifact_Metamorphosis(Other.FindInventoryType(class'Artifact_Metamorphosis'));
    if(A != None)
    {
        bSelect = (A == Other.SelectedItem);
        A.Destroy();
    }

    if(!bSelect)
        bSelect = (Other.SelectedItem == None);

    A = Other.Spawn(class'Artifact_Metamorphosis');
    if(A != None)
        A.GiveTo(Other);
}

function ModifyArtifact(RPGArtifact A)
{
    local int i;
    local MonsterType M;
    local Artifact_Metamorphosis Artifact;

    if(Artifact_Metamorphosis(A) != None)
    {
        Artifact = Artifact_Metamorphosis(A);

        Artifact.Ability = Self;
        Artifact.bCanBeTossed = false;
        Artifact.MonsterTypes.Length = 0;
        for(i = 0; i < MonsterTypes.Length; i++)
        {
            if(AbilityLevel >= MonsterTypes[i].Level)
            {
                M.MonsterClass = MonsterTypes[i].MonsterClass;
                M.bFlying = MonsterTypes[i].bFlying;
                M.DisplayName = MonsterTypes[i].DisplayName;
                M.Cost = MonsterTypes[i].Cost;
                M.Cooldown = MonsterTypes[i].Cooldown;

                Artifact.MonsterTypes[Artifact.MonsterTypes.Length] = M;
            }
        }
        Artifact.SendMonsterTypes();

        if(bSelect)
            Artifact.Instigator.SelectedItem = Artifact;
    }
    bSelect = False;
}

function bool Metamorphosize(Artifact_Metamorphosis A, Pawn Other, class<xPawn> PawnClass, bool bFlying, int Cost)
{
    local xPawn P;
    local Inventory Inv;
    local vector SpawnLoc;
    local rotator SpawnRot;
    local PlayerController PC;
    local vector HitLocation, HitNormal, End, Start;
    local class<Pawn> OldPawnClass;
    local class<RPGArtifact> LastSelected;
    local bool bBehindView;
    local float HealthRatio;
    local Ability_MetamorphosisRefund RefundAbility;

    if(Other == None || PawnClass == None)
        return false;

    PC = PlayerController(Other.Controller);
    if(PC == None)
        return false;

    //forcibly unset god mode, otherwise we may
    //be semi-permanently invulnerable afterwards
    if(PC.bGodMode)
        PC.bGodMode = false;

    RefundAbility = Ability_MetamorphosisRefund(RPRI.GetOwnedAbility(class'Ability_MetamorphosisRefund'));
    if(RefundAbility != None)
        RefundAbility.ProcessTransformation(Other, Cost);

    Start = Other.Location;
    End = Other.Location;
    End.Z -= PawnClass.default.CollisionHeight;
    if(Trace(HitLocation, HitNormal, End, Other.Location) != None)
    {
        Start = End;
        Start.Z += PawnClass.default.CollisionHeight;
        if(!CheckSpace(Other, Start, PawnClass.default.CollisionRadius, PawnClass.default.CollisionHeight))
        {
            A.MSG(A.MSG_NoSpace);
            return false;
        }
    }
    else if(!CheckSpace(Other, Start, PawnClass.default.CollisionRadius, PawnClass.default.CollisionHeight))
    {
        A.MSG(A.MSG_NoSpace);
        return false;
    }

    if(Other != None)
    {
        if(xPawn(Other).CurrentCombo != None)
            xPawn(Other).CurrentCombo.Destroy();

        StoredWeapons.Length = 0;
        StoredArtifacts.Length = 0;
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(Weapon(Inv) != None)
                TryStoreWeapon(Weapon(Inv));
            else if(RPGArtifact(Inv) != None)
                TryStoreArtifact(RPGArtifact(Inv));
        }
        LastSelected = class<RPGArtifact>(Other.SelectedItem.Class);

        HealthRatio = float(Other.Health) / Other.HealthMax;
        bBehindView = PC.bBehindView;
        SpawnLoc = Other.Location;
        SpawnRot = Other.Rotation;
        OldPawnClass = Other.Class;

        Other.SetCollision(false, false, false);

        if(ClassIsChildOf(PawnClass, class'Monster'))
        {
            P = Monster(Spawn(PawnClass,,, SpawnLoc, SpawnRot));
            if(P != None)
            {
                DoPossession(PC, P);

                RPRI.DrainAdrenaline(Cost, Self);

                //monsters can't use weapons
                //TODO what about monsters that can?
                P.bNoWeaponFiring = true;

                //set default values so that health bonus and
                //other abilities apply correctly
                P.default.HealthMax = P.default.Health;
                P.default.SuperHealthMax = P.HealthMax+99;
                P.HealthMax = P.default.Health;
                P.SuperHealthMax = P.HealthMax + 99;
                P.Health = Max(1, P.Health * HealthRatio);

                if(bFlying)
                    PC.GotoState('PlayerFlying');
                else
                    PC.GotoState('PlayerWalking');

                if(MorphMonster(P) != None)
                    MorphMonster(P).RPRI = RPRI;
            }
            else
            {
                //spawn failed, give them back their pawn
                Other.SetCollision(true, true, true);
                return true;
            }
        }
        else if(PawnClass == Class'xPawn')
        {
            PawnClass = class<xPawn>(DynamicLoadObject(Level.Game.DefaultPlayerClassName, class'Class'));

            P = Spawn(PawnClass,,, SpawnLoc, SpawnRot);
            if(P != None)
            {
                DoPossession(PC, P);

                P.Health = Max(1, P.Health * HealthRatio);
            }
            else
            {
                //spawn failed, give them back their pawn
                Other.SetCollision(true, true, true);
                return true;
            }
        }

        Other.Destroy();

        if(P == None)
        {
            //something went very very wrong... no real recovery here
            Level.Game.Killed(PC, PC, None, class'DamTypeMetamorphosisFail');
            Spawn(class'FX_Metamorphosis',,, SpawnLoc);

            return true;
        }

        RestoreWeapons(P); //add weapons to queue because they get added by ModifyPlayer
        RPRI.ModifyPlayer(P); //give weapons and activate abilities
        RestoreArtifacts(P); //replace any artifacts with our old ones to initate cooldowns

        if(bBehindView)
            PC.ClientSetBehindView(true);

        Spawn(class'FX_Metamorphosis', P,, P.Location);

        P.SelectedItem = RPGArtifact(P.FindInventoryType(LastSelected));

        return true;
    }
    return false;
}

function DoPossession(PlayerController PC, Pawn P)
{
    local Inventory Inv, NextInv;

    if(P.Controller != None)
    {
        P.Controller.Pawn = None;
        P.Controller.Destroy();
    }
    Inv = P.Inventory;
    while(Inv != None)
    {
        NextInv = Inv.Inventory;

        //remove FakeMonsterWeapon, etc
        Inv.Destroy();

        Inv = NextInv;
    }
    PC.PreviousPawnClass = PC.Pawn.Class;
    P.Controller = PC;
    PC.Pawn = P;
    PC.TimeMargin = -0.1;
    PC.Pawn.LastStartTime = Level.TimeSeconds;
    PC.Possess(P);
    PC.PawnClass = P.Class;

    ClientModifyPossession(P);
}

simulated function ClientModifyPossession(Pawn P)
{
    P.bNoWeaponFiring = true;
    P.default.HealthMax = P.default.Health;
    P.default.SuperHealthMax = P.HealthMax + 99;
    P.HealthMax = P.default.Health;
    P.SuperHealthMax = P.HealthMax + 99;
}

function RestoreWeapons(Pawn P)
{
    local int i;

    if(StoredWeapons.Length > 0 && RPRI != None)
    {
        for(i=0; i < StoredWeapons.Length; i++)
        {
            RPRI.QueueWeapon(
                StoredWeapons[i].WeaponClass,
                StoredWeapons[i].ModifierClass,
                StoredWeapons[i].Modifier,
                StoredWeapons[i].Ammo[0],
                StoredWeapons[i].Ammo[1],
                StoredWeapons[i].bIdentified,
                true,
                Self
            );
        }
    }
    StoredWeapons.Length = 0;
}

function RestoreArtifacts(Pawn P)
{
    local RPGArtifact A;
    local int i;

    if(StoredArtifacts.Length > 0)
    {
        for(i = 0; i < StoredArtifacts.Length; i++)
        {
            //if an ability granted this artifact again,
            //just reset its properties
            A = RPGArtifact(P.FindInventoryType(StoredArtifacts[i].ArtifactClass));
            if(A == None)
                A = RPGArtifact(class'Util'.static.GiveInventory(P, StoredArtifacts[i].ArtifactClass));
            if(A != None)
            {
                A.NextUseTime = StoredArtifacts[i].NextUseTime;
                A.Charge = StoredArtifacts[i].Charge;
            }
        }
    }
    StoredArtifacts.Length = 0;
}

function bool CheckSpace(Pawn Instigator, vector SpawnLocation, int HorizontalSpaceReqd, int VerticalSpaceReqd)
{
    local Controller C;

    // check to see that we have the required space around and up
    if(!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 0, 1) * VerticalSpaceReqd)))
        return false;

    if(!FastTrace(SpawnLocation, SpawnLocation + (vect(0, 1, 0) * HorizontalSpaceReqd))
        || !FastTrace(SpawnLocation, SpawnLocation - (vect(0, 1, 0) * HorizontalSpaceReqd)))
        return false;

    if(!FastTrace(SpawnLocation, SpawnLocation + (vect(1, 0, 0) * HorizontalSpaceReqd))
        || !FastTrace(SpawnLocation, SpawnLocation - (vect(1, 0, 0) * HorizontalSpaceReqd)))
        return false;

    //now to be safe lets check near the top and bottom
    if(!FastTrace(SpawnLocation + vect(0, 0, 1) * (VerticalSpaceReqd * 0.5f), SpawnLocation + (vect(1, 0, 0) * HorizontalSpaceReqd))
        || !FastTrace(SpawnLocation - vect(0, 0, 1) * (VerticalSpaceReqd * 0.5f), SpawnLocation - (vect(1, 0, 0) * HorizontalSpaceReqd)))
        return false;

    if(!FastTrace(SpawnLocation + vect(0, 0, 1) * (VerticalSpaceReqd * 0.5f), SpawnLocation + (vect(1, 0, 0) * HorizontalSpaceReqd))
        || !FastTrace(SpawnLocation - vect(0, 0, 1) * (VerticalSpaceReqd * 0.5f), SpawnLocation - (vect(1, 0, 0) * HorizontalSpaceReqd)))
        return false;

    //check for any pawns in the way
    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(C.Pawn != None && C.Pawn != Instigator &&
        (
            VSize(C.Pawn.Location - Instigator.Location) < HorizontalSpaceReqd + C.Pawn.CollisionRadius + Instigator.CollisionRadius ||
            VSize(C.Pawn.Location - Instigator.Location) < VerticalSpaceReqd + C.Pawn.CollisionRadius + Instigator.CollisionRadius)
        )
            return false;

    // should be room
    return true;
}

function TryStoreWeapon(Weapon W)
{
    local RPGWeaponModifier WM;
    local StoredWeapon SW;
    local int i;

    if(W == None)
        return;

    SW.WeaponClass = W.class;

    SW.Ammo[0] = W.AmmoAmount(0);
    SW.Ammo[1] = W.AmmoAmount(1);

    WM = class'RPGWeaponModifier'.static.GetFor(W);
    if(WM != None)
    {
        SW.ModifierClass = WM.class;
        SW.Modifier = WM.Modifier;
        SW.bIdentified=WM.bIdentified;
    }
    else
    {
        SW.ModifierClass = None;
        SW.Modifier = 0;
    }

    i = StoredWeapons.Length;
    StoredWeapons.Length = i + 1;
    StoredWeapons[i] = SW;
}

function TryStoreArtifact(RPGArtifact A)
{
    local StoredArtifact SA;
    local int i;

    if(A == None)
        return;

    SA.ArtifactClass = A.class;
    SA.NextUseTime = A.NextUseTime;
    SA.Charge = A.Charge;

    i = StoredArtifacts.Length;
    StoredArtifacts.Length = i + 1;
    StoredArtifacts[i] = SA;
}

function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Monster(InstigatedBy) != None && PlayerController(InstigatedBy.Controller) != None)
        Damage += float(OriginalDamage) * PassiveDamageBonus;
}

function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    if(Monster(Injured) != None && PlayerController(Injured.Controller) != None)
        Damage = Max(0, Damage - (float(OriginalDamage) * PassiveDamageReduction));
}

function PlayerDied(bool bLogout, optional Pawn Killer, optional class<DamageType> DamageType)
{
    // MAKE SURE to reset pawn class on death!
    if(RPRI.Controller != None)
        RPRI.Controller.PawnClass = RPRI.Controller.default.PawnClass;
}

simulated function string DescriptionText()
{
    local int lv, x, i;
    local string text;
    local array<string> list;

    text = Super.DescriptionText();

    text = Repl(text, "$1", class'Util'.static.FormatPercent(PassiveDamageBonus));
    text = Repl(text, "$2", class'Util'.static.FormatPercent(PassiveDamageReduction));

    for(lv = 1; lv <= MaxLevel; lv++)
    {
        list.Remove(0, list.Length);
        for(x = 0; x < MonsterTypes.Length; x++)
        {
            if(MonsterTypes[x].MonsterClass != class'xPawn' && MonsterTypes[x].Level == lv)
                list[list.Length] = MonsterTypes[x].DisplayName;
        }

        if(list.Length > 0)
        {
            i = 0;
            text $= "|" $ AtLevelText @ string(lv) $ MonsterPreText;
            for(x = 0; x < list.Length; x++)
            {
                i++;
                text @= list[x];

                if(x + 2 < list.Length)
                    text $= ",";
                else if(i >= 2 && x + 1 < list.Length)
                    text $= "," @ AndText;
                else if(x + 1 < list.Length)
                    text @= AndText;
            }
            text $= MonsterPostText;
        }
    }
    return text;
}

defaultproperties
{
    MonsterTypes(0)=(MonsterClass=Class'SkaarjPack.SkaarjPupae',DisplayName="Skaarj Pupae",cost=10,Cooldown=5)
    MonsterTypes(1)=(MonsterClass=Class'SkaarjPack.Krall',DisplayName="Krall",cost=25,Cooldown=5)
    MonsterTypes(2)=(MonsterClass=Class'SkaarjPack.Brute',DisplayName="Brute",cost=50,Cooldown=5)
    MonsterTypes(3)=(MonsterClass=Class'SkaarjPack.WarLord',DisplayName="Warlord",bFlying=True,cost=75,Cooldown=10)
    GrantItem(0)=(Level=1,InventoryClass=Class'Artifact_ConjurerSize')
    MonsterPreText=", you can transform into the"
    MonsterPostText="."
    AbilityName="Metamorphosis"
    Description="You are granted the Metamorphic Charm when you spawn, which allows you to transform into different monsters and use their own abilities against them.|Upon transformation, all your weapons and artifacts will be preserved and all your abilities and stats will apply (weapon speed will only affect your firing speed by 0.5% per level).|As a monster, you cannot use your weapons (you can, however, scroll through them and toss them). You may, however, pick up any weapon, item, or artifact on the map as if you weren't a monster.|You may revert back to your normal form for free by using the Metamorphic Charm.|Each level of this ability allows you to transform into more powerful monsters.|Passively, while transformed, you also have $1 increased damage bonus and $2 increased damage reduction."
    LevelCost(0)=5
    LevelCost(1)=5
    LevelCost(2)=10
    LevelCost(3)=10
    LevelCost(4)=10
    LevelCost(5)=5
    LevelCost(6)=15
    LevelCost(7)=15
    LevelCost(8)=20
    LevelCost(9)=20
    bUseLevelCost=True
    RequiredLevels(0)=4
    RequiredLevels(1)=8
    RequiredLevels(2)=12
    RequiredLevels(3)=16
    RequiredLevels(4)=20
    RequiredLevels(5)=24
    RequiredLevels(6)=28
    RequiredLevels(7)=32
    MaxLevel=10
    Category=Class'AbilityCategory_Monsters'
    IconMaterial=Texture'AbMetamorphosis'
}
