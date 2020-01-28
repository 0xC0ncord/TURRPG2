class RPGSentinel extends ASVehicle_Sentinel_Floor
    cacheexempt;

simulated event PostBeginPlay()
{
    DefaultWeaponClassName=string(class'Weapon_RPGSentinel');

    super.PostBeginPlay();
}

defaultproperties
{
     DefaultWeaponClassName=""
     bNoTeamBeacon=False
}
