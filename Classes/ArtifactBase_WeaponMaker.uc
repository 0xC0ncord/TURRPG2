class ArtifactBase_WeaponMaker extends ArtifactBase_DelayedUse
    abstract
    HideDropDown;

var config bool bAvoidRepetition;

var config array<class<Weapon> > ForbiddenWeaponTypes;

var class<RPGWeaponModifier> ModifierClass;

const MSG_UnableToGenerate = 0x0100;
const MSG_AlreadyConstructing = 0x0101;
const MSG_Broken = 0x0102;

var localized string MsgUnableToGenerate, MsgAlreadyConstructing, MsgBroken;

var Weapon OldWeapon, ModifiedWeapon;
var int OldAmmo[2];
var() Sound BrokenSound;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_UnableToGenerate:
            return default.MsgUnableToGenerate;

        case MSG_AlreadyConstructing:
            return default.MsgAlreadyConstructing;

        case MSG_Broken:
            return default.MsgBroken;

        default:
            return Super.GetMessageString(Msg, Value);
    }
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Role < ROLE_Authority)
        return;
}

function bool CanActivate()
{
    local int i;

    if(!Super.CanActivate())
        return false;

    ModifiedWeapon = Instigator.Weapon;

    if(ModifiedWeapon != None)
    {
        for(i = 0; i < ForbiddenWeaponTypes.Length; i++)
        {
            if(ClassIsChildOf(ModifiedWeapon.Class, ForbiddenWeaponTypes[i]))
            {
                ModifiedWeapon = None;
                break;
            }
        }
    }

    if(ModifiedWeapon == None
    || class'WeaponModifier_EngineerLink'.static.GetFor(ModifiedWeapon) != None
    || (ModifierClass != None && ModifiedWeapon != None && (!ModifierClass.static.AllowedFor(ModifiedWeapon.Class, Instigator) || ModifierClass == class'RPGWeaponModifier'.static.GetFor(ModifiedWeapon).Class))
    )
    {
        Msg(MSG_UnableToGenerate);
        return false;
    }

    return true;
}

state Activated
{
    function bool DoEffect()
    {
        //local Ability_LoadedArtifacts LA;
        local RPGWeaponModifier WM;
        local class<RPGWeaponModifier> OldModifier, NewModifier;
        local int x, tries;

        if(ModifiedWeapon == None) {
            Msg(MSG_UnableToGenerate);
            return false;
        }

        WM = class'RPGWeaponModifier'.static.GetFor(ModifiedWeapon);
        if(WM != None) {
            OldModifier = WM.class;
        }

        for(x = 0; x < 50; x++) {
            if(bAvoidRepetition) {
                //try to generate a weapon of different magic than the old one
                for(tries = 0; tries < 50; tries++) {
                    NewModifier = GetRandomWeaponModifier(ModifiedWeapon.class, Instigator);

                    if(NewModifier == None || NewModifier != OldModifier) {
                        tries = 50; //break inner loop
                    }
                }
            } else {
                NewModifier = GetRandomWeaponModifier(ModifiedWeapon.class, Instigator);
            }

            if(NewModifier == None || NewModifier.static.AllowedFor(ModifiedWeapon.class, Instigator)) {
                break;
            }
        }

        if(x == 50) {
            Msg(MSG_UnableToGenerate);
            return false;
        }

        if(NewModifier != None) {
            WM = ModifyWeapon(ModifiedWeapon, NewModifier);
            OldWeapon = ModifiedWeapon;
            OldAmmo[0] = OldWeapon.AmmoAmount(0);
            OldAmmo[1] = OldWeapon.AmmoAmount(1);
        } else {
            class'RPGWeaponModifier'.static.RemoveModifier(ModifiedWeapon);
        }

        //Former breaking logic
        /*
        LA = Ability_LoadedArtifacts(InstigatorRPRI.GetOwnedAbility(class'Ability_LoadedArtifacts'));
        if(LA == None || !LA.ProtectArtifacts())
        {
            if(bCanBreak && Rand(3) == 0) //25% chance
            {
                Msg(MSG_Broken);

                if(PlayerController(Instigator.Controller) != None)
                    PlayerController(Instigator.Controller).ClientPlaySound(BrokenSound);

                Destroy();
            }
        }
        */

        return true;
    }
}

function RPGWeaponModifier ModifyWeapon(Weapon Weapon, class<RPGWeaponModifier> NewModifier)
{
    local RPGWeaponModifier WM;

    WM = NewModifier.static.Modify(Weapon, NewModifier.static.GetRandomPositiveModifierLevel(), true);

    return WM;
}

function class<RPGWeaponModifier> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
    if(ModifierClass != None)
        return ModifierClass;
    else
        return class'MutTURRPG'.static.Instance(Level).GetRandomWeaponModifier(WeaponType, Other, true);
}

defaultproperties
{
    bAllowInVehicle=False
    MsgUnableToGenerate="Unable to enchant weapon."
    MsgAlreadyConstructing="Already enchanting a weapon."
    MsgBroken="The artifact has broken."
    ForbiddenWeaponTypes(0)=class'BallLauncher'
    ForbiddenWeaponTypes(1)=class'TransLauncher'
}
