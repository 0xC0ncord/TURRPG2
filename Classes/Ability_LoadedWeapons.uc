class Ability_LoadedWeapons extends RPGAbility;

function ModifyPawn(Pawn Other)
{
    local int x, i;
    local Ability_Denial Denial;
    local bool bGotIt;
    local Inventory Inv;
    local Inventory SGInv, ARInv;

    Instigator = Other;

    if(StatusIconClass != None)
        RPRI.ClientCreateStatusIcon(StatusIconClass);

    if(GrantItem.Length > 0)
        Denial = Ability_Denial(RPRI.GetOwnedAbility(class'Ability_Denial'));

    if(!bJustBought)
    {
        // Delete starting Shield Gun and Assault Rifle if found
        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if(InStr(Caps(Inv.ItemName), "SHIELD GUN") != -1)
                SGInv = Inv;
            else if(InStr(Caps(Inv.ItemName), "ASSAULT RIFLE") != -1)
                ARInv = Inv;

            if(SGInv != None && ARInv != None)
                break;
        }

        if(SGInv != None)
            Other.DeleteInventory(SGInv);
        if(ARInv != None)
            Other.DeleteInventory(ARInv);
    }

    for(x = 0; x < GrantItem.Length; x++)
    {
        if(AbilityLevel >= GrantItem[x].Level)
        {
            if(ClassIsChildOf(GrantItem[x].InventoryClass, class'Weapon'))
            {
                // If we have denial, don't grant the same weapon if it's already going to be restored
                if(Denial != None)
                {
                    for(i = 0; i < Denial.StoredWeapons.Length; i++)
                    {
                        if(Denial.StoredWeapons[i].WeaponClass == GrantItem[x].InventoryClass)
                        {
                            bGotIt = true;
                            break;
                        }
                    }
                }
                if(!bGotIt)
                {
                    if(bJustBought)
                    {
                        // Check if they already have this weapon
                        for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
                            if(Inv.Class == GrantItem[x].InventoryClass)
                                break;

                        // Already have this weapon, don't give them another
                        if(Inv != None)
                            continue;
                    }
                    RPRI.QueueWeapon(class<Weapon>(GrantItem[x].InventoryClass), None, 0, 0, 0,, Self);
                }
                else
                    bGotIt = false;
            }
            else
                class'Util'.static.GiveInventory(Other, GrantItem[x].InventoryClass);
        }
    }
}

function bool OverrideGrantedWeapon(class<Weapon> WeaponClass, out class<RPGWeaponModifier> ModifierClass, out int Modifier, optional Object Source)
{
    //don't mess with any restored weapons from Denial
    if(Ability_Denial(Source) != None)
        return true;

    //don't mess with the engineer link gun
    if(WeaponClass == class'EngineerLinkGun' && ModifierClass == class'WeaponModifier_EngineerLink')
        return true;

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

function ModifyGrantedWeapon(Weapon W, RPGWeaponModifier Modifier, optional Object Source)
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
    LevelDescription(0)="At level 1, you are granted all regular weapons with the default percentage chance for magic weapons."
    LevelDescription(1)="At level 2, you are granted onslaught weapons and all weapons with max ammo."
    LevelDescription(2)="At level 3, you are granted super weapons (Invasion gametypes only)."
    LevelDescription(3)="At level 4, magic weapons will be generated for all your weapons."
    LevelDescription(4)="At level 5, you receive all positive magic weapons."
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
