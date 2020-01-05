class Ability_LoadedWeapons extends RPGAbility;

function bool OverrideGrantedWeapon(class<Weapon> WeaponClass, out class<RPGWeaponModifier> ModifierClass, out int Modifier)
{
    if(AbilityLevel >= 4)
        ModifierClass = class'MutTURRPG'.static.Instance(Level).GetRandomWeaponModifier(WeaponClass, RPRI.Controller.Pawn, true);
    else
        ModifierClass = class'MutTURRPG'.static.Instance(Level).GetRandomWeaponModifier(WeaponClass, RPRI.Controller.Pawn);

    if(ModifierClass != None)
    {
        if(AbilityLevel >= 5)
            Modifier = ModifierClass.static.GetRandomPositiveModifierLevel();
        else
            Modifier = ModifierClass.static.GetRandomModifierLevel();
    }

    return true;
}

function ModifyGrantedWeapon(Weapon W, RPGWeaponModifier Modifier)
{
    if(AbilityLevel == 1)
        W.FillToInitialAmmo();
    else if(AbilityLevel > 1)
    {
        if(InStr(Caps(string(W.Class)), "XWEAPONS.ASSAULTRIFLE") != -1)
            W.Loaded();
        W.MaxOutAmmo();
    }
}

defaultproperties
{
    AbilityName="Loaded Weapons"
    Description="Grants you an arsenal of modified weapons when you spawn."
    LevelDescription(0)="Level 1: You are granted all regular weapons with the default percentage chance for magic weapons."
    LevelDescription(1)="Level 2: You are granted onslaught weapons and all weapons with max ammo."
    LevelDescription(2)="Level 3: You are granted super weapons (Invasion gametypes only)."
    LevelDescription(3)="Level 4: Magic weapons will be generated for all your weapons."
    LevelDescription(4)="Level 5: You receive all positive magic weapons."
    RequiredLevels(1)=40
    RequiredLevels(2)=55
    MaxLevel=5
    StartingCost=10
    CostAddPerLevel=5
    GrantItem(0)=(Level=1,InventoryClass=Class'TURRPG2.RPGShieldGun')
    GrantItem(1)=(Level=1,InventoryClass=Class'XWeapons.AssaultRifle')
    GrantItem(2)=(Level=1,InventoryClass=Class'XWeapons.BioRifle')
    GrantItem(3)=(Level=1,InventoryClass=Class'XWeapons.ShockRifle')
    GrantItem(4)=(Level=1,InventoryClass=Class'TURRPG2.RPGLinkGun')
    GrantItem(5)=(Level=1,InventoryClass=Class'XWeapons.Minigun')
    GrantItem(6)=(Level=1,InventoryClass=Class'XWeapons.FlakCannon')
    GrantItem(7)=(Level=1,InventoryClass=Class'TURRPG2.RPGRocketLauncher')
    GrantItem(8)=(Level=1,InventoryClass=Class'XWeapons.SniperRifle')
    GrantItem(9)=(Level=2,InventoryClass=Class'UTClassic.ClassicSniperRifle')
    GrantItem(10)=(Level=2,InventoryClass=Class'Onslaught.ONSGrenadeLauncher')
    GrantItem(11)=(Level=2,InventoryClass=Class'Onslaught.ONSAVRiL')
    GrantItem(12)=(Level=2,InventoryClass=Class'TURRPG2.RPGMineLayer')
    GrantItem(13)=(Level=3,InventoryClass=Class'XWeapons.Redeemer')
    GrantItem(14)=(Level=3,InventoryClass=Class'XWeapons.Painter')
    GrantItem(15)=(Level=3,InventoryClass=Class'OnslaughtFull.ONSPainter')
    Category=Class'TURRPG2.AbilityCategory_Weapons'
}
