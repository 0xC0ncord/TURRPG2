class RPGForceField extends RPGMatrixField;

event Tick(float dt) {
    local Projectile Proj;

    Super(Info).Tick(dt);

    foreach CollidingActors(class'Projectile', Proj, Radius) {
        if(Proj.Tag == 'Force' || Proj.Tag == 'Matrix') {
            continue;
        }

        if(!class'Util'.static.ProjectileSameTeamC(Proj, Instigator.Controller)) {
            continue;
        }

        Proj.Tag = 'Force';
        class'Util'.static.ModifyProjectileSpeed(Proj, Multiplier, 'Force');
    }
}

defaultproperties {
    Radius=768
    Multiplier=0.5
}
