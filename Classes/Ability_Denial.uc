class Ability_Denial extends RPGAbility;

var config array<class<Weapon> > ForbiddenWeaponTypes;

struct StoredWeapon
{
    var class<Weapon> WeaponClass;
    var class<RPGWeaponModifier> ModifierClass;
    var int Modifier;
    var int Ammo[2];
};
var array<StoredWeapon> StoredWeapons;

static function bool CanSaveWeapon(Weapon W)
{
    local int x;

    if(W == None)
        return false;

    for(x = 0; x < default.ForbiddenWeaponTypes.Length; x++)
    {
        if(ClassIsChildof(W.class, default.ForbiddenWeaponTypes[x]))
            return false;
    }

    return true;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    local Inventory Inv;
    local Weapon W;
    local Ability_VehicleEject EjectorSeat;

    // Ejector Seat hack.
    if(Vehicle(Killed) != None && Killed.Controller != None)
    {
        EjectorSeat = Ability_VehicleEject(RPRI.GetOwnedAbility(class'Ability_VehicleEject'));
        if(EjectorSeat != None && EjectorSeat.CanEjectDriver(Vehicle(Killed)))
            return false;
    }

    if(Vehicle(Killed) != None) {
        Killed = Vehicle(Killed).Driver;
    }

    if(AbilityLevel < 3 && class'MutTURRPG'.static.Instance(Level).static.IsSuperWeapon(Killed.Weapon.Class)) {
        RPRI.Controller.LastPawnWeapon = None;
    } else if(Killed.Weapon != None) {
        RPRI.Controller.LastPawnWeapon = Killed.Weapon.Class;
    }

    if(AbilityLevel >= 2)
    {
        //store all weapons
        for(Inv = Killed.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            W = Weapon(Inv);
            if(W != None)
                TryStoreWeapon(W);
        }
    }
    else
    {
        //store last held weapon
        W = Killed.Weapon;

        //when carrying the ball launcher, save the old weapon
        if(RPGBallLauncher(W) != None) {
            W = RPGBallLauncher(W).RestoreWeapon;
        }

        if(W != None)
            TryStoreWeapon(W);
    }

    //Make current weapon unthrowable so it doesn't get dropped
    if(Killed.Weapon != None)
        Killed.Weapon.bCanThrow = false;

    return false;
}

function TryStoreWeapon(Weapon W)
{
    local RPGWeaponModifier WM;
    local StoredWeapon SW;

    if(!CanSaveWeapon(W))
        return;

    if(AbilityLevel < 3 && class'MutTURRPG'.static.Instance(Level).IsSuperWeapon(W.Class))
        return;

    SW.WeaponClass = W.class;

    SW.Ammo[0] = W.AmmoAmount(0);
    SW.Ammo[1] = W.AmmoAmount(1);

    WM = class'RPGWeaponModifier'.static.GetFor(W);
    if(WM != None) {
        SW.ModifierClass = WM.class;
        SW.Modifier = WM.Modifier;
    }

    StoredWeapons[StoredWeapons.Length] = SW;
}

function PreModifyPawn(Pawn Other)
{
    local int i;
    local Inventory Inv;

    for(i = 0; i < StoredWeapons.Length; i++)
    {
        RPRI.QueueWeapon(
            StoredWeapons[i].WeaponClass,
            StoredWeapons[i].ModifierClass,
            StoredWeapons[i].Modifier,
            StoredWeapons[i].Ammo[0],
            StoredWeapons[i].Ammo[1],
            ,
            Self
        );

        // Delete starting Shield Gun and Assault Rifle if needed
        if(InStr(Caps(StoredWeapons[i].WeaponClass.default.ItemName), "SHIELD GUN") != -1)
        {
            for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
            {
                if(InStr(Caps(Inv.ItemName), "SHIELD GUN") != -1)
                {
                    Other.DeleteInventory(Inv);
                    break;
                }
            }
        }
        else if(InStr(Caps(StoredWeapons[i].WeaponClass.default.ItemName), "ASSAULT RIFLE") != -1)
        {
            for(Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
            {
                if(InStr(Caps(Inv.ItemName), "ASSAULT RIFLE") != -1)
                {
                    Other.DeleteInventory(Inv);
                    break;
                }
            }
        }
    }
}

function PostModifyPawn(Pawn Other)
{
    StoredWeapons.Length = 0;
}

defaultproperties
{
    AbilityName="Denial"
    Description="With this ability, you will respawn with your previously held weapon(s) and ammo."
    LevelDescription(0)="Level 1 of this ability allows you to respawn with the weapon and ammo you were using when you died, even if you died in a vehicle. If you were holding the Ball Launcher, your previously selected weapon will be saved."
    LevelDescription(1)="Level 2 will save all of your weapons (except for super weapons)."
    LevelDescription(2)="Level 3 will save all of your weapons, including super weapons."
    MaxLevel=3
    bUseLevelCost=true
    LevelCost(0)=20
    LevelCost(1)=15
    LevelCost(2)=20
    ForbiddenWeaponTypes(0)=class'XWeapons.BallLauncher'
    ForbiddenWeaponTypes(1)=class'XWeapons.TransLauncher'
    ForbiddenWeaponTypes(2)=class'UT2k4AssaultFull.Weapon_SpaceFighter'
    ForbiddenWeaponTypes(3)=class'UT2k4AssaultFull.Weapon_SpaceFighter_Skaarj'
    ForbiddenWeaponTypes(4)=class'UT2k4Assault.Weapon_Turret_Minigun' //however this should happen...
    Category=class'AbilityCategory_Weapons'
}
