/*
    Due to OverlayMaterial being only replicated unreliably (see Actor),
    often people do not receive it properly and thus cannot see an Actor's overlay.

    However, in RPG, overlays can be pretty important (e.g. Invulnerability),
    so this class serves as a secure method to set an overlay on an actor.
*/
class Sync_OverlayMaterial extends Sync;

var Actor Target;
var Material Mat;
var float Duration;
var bool bOverride;

replication
{
    reliable if(Role == ROLE_Authority)
        Target, Mat, Duration, bOverride;
}

static function Discard(Actor Target) {
    local Sync_OverlayMaterial Sync, X;

    foreach Target.ChildActors(class'Sync_OverlayMaterial', Sync) {
        X = Sync;
        break;
    }

    if(X != None) {
        X.Destroy();
    }
}

static function Sync_OverlayMaterial Sync(Actor Target, Material Mat, float Duration, optional bool bOverride)
{
    local Sync_OverlayMaterial Sync;
    local ASTurret_Base A;

    Discard(Target); //Discard any existing

    Sync = Target.Spawn(class'Sync_OverlayMaterial', Target);

    Sync.Target = Target;
    Sync.Mat = Mat;

    if(Duration < 0)
        Duration = 86400; //24 hours...

    Sync.Duration = Duration;
    Sync.bOverride = bOverride;

    //Net
    Sync.LifeSpan = 2.0 * Duration;
    if(Target.bOnlyRelevantToOwner) {
        Sync.bOnlyRelevantToOwner = true;
        Sync.bAlwaysRelevant = false;
    }

    //server
    Target.SetOverlayMaterial(Mat, Duration, bOverride);

    if(Target.Level.NetMode != NM_DedicatedServer)
    {
        //hack to fix ASTurret bases not updating overlay when setting to NULL
        if(Duration == 0.0 && ASTurret(Target) != None)
            foreach Target.ChildActors(class'ASTurret_Base', A)
                A.SetOverlayMaterial(Mat, Duration, bOverride);
    }

    return Sync;
}

simulated function bool ClientFunction()
{
    local ASTurret_Base A;

    if(Target == None) {
        return false;
    } else {
        Target.SetOverlayMaterial(Mat, Duration, bOverride);

        //hack to fix ASTurret bases not updating overlay when setting to NULL
        if(Duration == 0.0 && ASTurret(Target) != None)
            foreach Target.ChildActors(class'ASTurret_Base', A)
                A.SetOverlayMaterial(Mat, Duration, bOverride);

        return true;
    }
}

function bool ShouldDestroy() {
    if(Target == None) {
        return true;
    } else {
        return false;
    }
}

simulated event Destroyed() {
    Super.Destroyed();
}

defaultproperties {
}
