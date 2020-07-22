//=============================================================================
// EngineerWeaponLocker.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class EngineerWeaponLocker extends WeaponLocker;

struct MultiPickupTypeClone
{
    var() class<Pickup> PickupClass;
    var() float Duration;
    var() float SpawnRating;
};
var array<MultiPickupTypeClone> MultiPickupTypes;

var array<Emitter> LockerWeaponEmitters;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientReceiveLockerWeapon, ClientSpawnLockerWeapons;
}

simulated function PostNetBeginPlay()
{
    local int i;

    Super(Pickup).PostNetBeginPlay();

    MaxDesireability = 0;

    if(bHidden)
        return;
    for(i = 0; i < Weapons.Length; i++)
        MaxDesireability += Weapons[i].WeaponClass.Default.AIRating;
    if(Role == ROLE_Authority)
        SpawnLockerWeapon();

    if(Level.NetMode != NM_DedicatedServer)
        Effect = Spawn(class'FX_WeaponLocker', Self,, Location, Rotation);
}

simulated function PostBeginPlay()
{
    local Actor A;
    local class<Weapon> WClass;
    local int i,x;
    local array<class<Weapon> > WeaponsAdded;

    Super.PostBeginPlay();

    if(Role < Role_Authority)
        return;
    foreach RadiusActors(class'Actor', A, 2000)
    {
        if(WeaponPickup(A) != None && A.IsInState('Pickup') || A.IsInState('Sleeping'))
        {
            WClass = class<Weapon>(WeaponPickup(A).InventoryType);
            if(WClass == None || class'Util'.static.InArray(WClass, WeaponsAdded) != -1 || class'Util'.static.InArray(WClass, class'MutTURRPG'.default.SuperWeaponClasses) != -1)
                continue;
            x = Weapons.Length;
            Weapons.Length = x+1;
            Weapons[x].WeaponClass = WClass;
            WeaponsAdded[WeaponsAdded.Length] = Weapons[x].WeaponClass;
            ClientReceiveLockerWeapon(WClass);
        }
        else if(WeaponLocker(A) != None)
        {
            for(i = 0; i < WeaponLocker(A).Weapons.Length; i++)
            {
                if(class'Util'.static.InArray(WeaponLocker(A).Weapons[i].WeaponClass, WeaponsAdded) != -1 || class'Util'.static.InArray(WeaponLocker(A).Weapons[i].WeaponClass, class'MutTURRPG'.default.SuperWeaponClasses) != -1)
                    continue;
                WClass = WeaponLocker(A).Weapons[i].WeaponClass;
                x = Weapons.Length;
                Weapons.Length = x+1;
                Weapons[x].WeaponClass = WClass;
                WeaponsAdded[WeaponsAdded.Length] = Weapons[x].WeaponClass;
                ClientReceiveLockerWeapon(WClass);
            }
        }
        else if(A.IsA('MultiPickupBase'))
        {
            SetPropertyText("MultiPickupTypes", A.GetPropertyText("PickupTypes"));
            for(i = 0; i < MultiPickupTypes.Length; i++)
            {
                if(class<Weapon>(MultiPickupTypes[i].PickupClass.default.InventoryType) != None && class'Util'.static.InArray(class<Weapon>(MultiPickupTypes[i].PickupClass.default.InventoryType), class'MutTURRPG'.default.SuperWeaponClasses) == -1)
                {
                    if(class'Util'.static.InArray(class<Weapon>(MultiPickupTypes[i].PickupClass.default.InventoryType), WeaponsAdded) > -1)
                        continue;
                    WClass = class<Weapon>(MultiPickupTypes[i].PickupClass.default.InventoryType);
                    x = Weapons.Length;
                    Weapons.Length = x+1;
                    Weapons[x].WeaponClass = WClass;
                    WeaponsAdded[WeaponsAdded.Length] = Weapons[x].WeaponClass;
                    ClientReceiveLockerWeapon(WClass);
                }
            }
        }
        else
            continue;
    }
    ClientSpawnLockerWeapons();
}

simulated function Destroyed()
{
    local int i;

    Super.Destroyed();

    for(i=0; i < LockerWeaponEmitters.Length; i++)
        if(LockerWeaponEmitters[i] != None)
            LockerWeaponEmitters[i].Destroy();
}

simulated function ClientReceiveLockerWeapon(class<Weapon> WeaponClass)
{
    local int x;

    x = Weapons.Length;
    Weapons.Length = x+1;
    Weapons[x].WeaponClass = WeaponClass;
}

simulated function ClientSpawnLockerWeapons()
{
    SpawnLockerWeapon();
}

simulated function SpawnLockerWeapon()
{
    local LockerWeapon L;
    local Rotator WeaponDir;
    local class<UTWeaponPickup> P;
    local int i;
    local float Interval;

    if(Level.NetMode == NM_DedicatedServer || Level.DetailMode == DM_Low)
        return;

    L = Spawn(class'LockerWeapon');
    LockerWeaponEmitters[LockerWeaponEmitters.Length] = L;
    Interval = 65536.0 / Weapons.Length;

    for(i = 0; i < 8; i++)
    {
        if(i >= Weapons.Length)
            L.Emitters[i].Disabled = true;
        else
        {
            P = class<UTWeaponPickup>(Weapons[i].WeaponClass.Default.PickupClass);
            if(P == None || P.Default.StaticMesh == None)
                L.Emitters[i].Disabled = true;
            else
            {
                MeshEmitter(L.Emitters[i]).StaticMesh = P.Default.StaticMesh;
                L.Emitters[i].StartLocationOffset = P.default.LockerOffset * vector(WeaponDir);
                WeaponDir.Yaw += Interval;
                MeshEmitter(L.Emitters[i]).StartSpinRange.X.Min = P.Default.Standup.X;
                MeshEmitter(L.Emitters[i]).StartSpinRange.X.Max = P.Default.Standup.X;
                MeshEmitter(L.Emitters[i]).StartSpinRange.Y.Min = P.Default.Standup.Y;
                MeshEmitter(L.Emitters[i]).StartSpinRange.Y.Max = P.Default.Standup.Y;
                MeshEmitter(L.Emitters[i]).StartSpinRange.Z.Min = P.Default.Standup.Z;
                MeshEmitter(L.Emitters[i]).StartSpinRange.Z.Max = P.Default.Standup.Z;
                MeshEmitter(L.Emitters[i]).StartSizeRange.X.Min = 0.9 * P.default.DrawScale;
                MeshEmitter(L.Emitters[i]).StartSizeRange.X.Max = 0.9 * P.default.DrawScale;
                MeshEmitter(L.Emitters[i]).StartSizeRange.Y.Min = 0.9 * P.default.DrawScale;
                MeshEmitter(L.Emitters[i]).StartSizeRange.Y.Max = 0.9 * P.default.DrawScale;
                MeshEmitter(L.Emitters[i]).StartSizeRange.Z.Min = 0.9 * P.default.DrawScale;
                MeshEmitter(L.Emitters[i]).StartSizeRange.Z.Max = 0.9 * P.default.DrawScale;
            }
        }
    }
}

defaultproperties
{
    bStatic=False
    bGameRelevant=True
    bCollideWorld=False
}
