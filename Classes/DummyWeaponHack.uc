//total hack to access protected variables on weapons
class DummyWeaponHack extends Weapon
    abstract
    HideDropDown;

static final function ModifyFireMode(Weapon W, int Num, WeaponFire FireMode)
{
    W.ImmediateStopFire();
    W.FireMode[Num] = FireMode;
}

static final function Ammunition GetAmmo(Weapon W, int Num)
{
    if(W != None)
        return W.Ammo[Num];
}

defaultproperties
{
}
