class RPGCeilingSentinel extends ASVehicle_Sentinel_Ceiling
    cacheexempt;

simulated function PostBeginPlay()
{
    DefaultWeaponClassName = string(class'Weapon_RPGSentinel');
    super.PostBeginPlay();
}

defaultproperties
{
    DefaultWeaponClassName=""
    bNoTeamBeacon=False
}
