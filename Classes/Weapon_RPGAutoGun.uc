class Weapon_RPGAutoGun extends Weapon_Sentinel
    config(user)
    HideDropDown
    CacheExempt;

defaultproperties
{
     FireModeClass(0)=Class'FM_RPGAutoGun_Fire'
     FireModeClass(1)=Class'FM_RPGAutoGun_Fire'
     ItemName="AutoGun Weapon"
}
