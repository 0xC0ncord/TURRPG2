class Artifact_FireBall extends RPGArtifact
    config(TURRPG);

var config int AIHealthMin, AIMinTargets;

function BotWhatNext(Bot Bot)
{
    if(
        !HasActiveArtifact(Instigator) &&
        Bot.Adrenaline >= CostPerSec &&
        Instigator.Health >= AIHealthMin && //should survive until then
        CountNearbyEnemies(2000, false) >= AIMinTargets
    )
    {
        Activate();
    }
}

function bool DoEffect()
{
    local Vector FaceVect;
    local Rotator FaceDir;
    local Projectile p;

    if (Instigator != None)
    {
        // change the guts of it
        FaceDir = Instigator.Controller.GetViewRotation();
        FaceVect = Vector(FaceDir);

        p = Instigator.Spawn(class'PROJ_FireBall',,, Instigator.Location + Instigator.EyePosition() + (FaceVect * Instigator.CollisionRadius * 1.1), FaceDir);
        if (p != None)
        {
            p.PlaySound(Sound'WeaponSounds.RocketLauncher.RocketLauncherFire',,Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
            return true;
        }
        return false;
    }
}

defaultproperties
{
    AIHealthMin=50
    AIMinTargets=1
    bCanBeTossed=False
    bAllowInVehicle=False
    MinAdrenaline=10
    Cooldown=1.600000
    CostPerSec=10
    IconMaterial=Texture'AW-2004Particles.Fire.NapalmSpot'
    HudColor=(R=255,G=128,B=0)
    ItemName="Fireball"
    Description="Fires a fireball projectile."
    ArtifactID="FireBall"
}
