class EngineerLinkGun extends RPGLinkGun
    config(User)
    HideDropDown
    CacheExempt;

var float HealTimeDelay;     // when linking to turrets how long after healing before get damage boost

defaultproperties
{
     HealTimeDelay=0.500000
     FireModeClass(0)=Class'EngineerLinkProjFire'
     FireModeClass(1)=Class'EngineerLinkFire'
}
