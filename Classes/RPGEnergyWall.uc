//=============================================================================
// RPGEnergyWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGEnergyWall extends ASTurret
    cacheexempt;

var int DamagePerHit;
var float DamageFraction;

var int MaxGap;
var int MinGap;     // minimum gap for the Wall, including posts.
var int Height;

var vector P1Loc, P2Loc;
var RPGEnergyWallPost Post1,Post2;
var() class<Controller> DefaultController;
var() class<RPGEnergyWallPost> DefaultPost;

var float vScaleY;
var int origDamage;
var int TotalDamage;
var int TakenDamage;
var int MinDamage, MaxDamage;

var float DamageAdjust;     // set by AbilityLoadedEngineer

replication
{
    reliable if(Role == ROLE_Authority && bNetDirty)
        vScaleY;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Role == ROLE_Authority)
    {
        if(AssignPosts())
            DrawWall();
    }

    // now ASVehicle calls SetCollision(true,true) which sets bCollideActors and bBlockActors. We just want to collide actors and block nothing
    SetCollision(true,false,false);
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    // ok lets draw the Wall.
    if(Role < ROLE_Authority)
        ClientDrawWall();
}

function bool AssignPosts()
{
    local RPGEnergyWallPost P;

    foreach DynamicActors(class'RPGEnergyWallPost', P)
    {
        if( P.Wall == None && VSize(P.Location - Location) < default.MaxGap && P.Owner == Owner)
        {
            // found a post
            if(Post1 == None)
            {
                Post1 = P;
                P1Loc = P.Location;
                P.Wall = self;
            }
            else if(Post2 == None)
            {
                Post2 = P;
                P2Loc = P.Location;
                P.Wall = self;
                return true;        // got both posts
            }
        }
    }
    return false;
}

function DrawWall()
{
    local float Wallgap;
    local vector vScale;

    // need to set the size of the Wall here. Relative to initial size (100,50,50 scaled at 0.1)
    vScale.X = 0.02;
    Wallgap = VSize(P1Loc - P2Loc) - 20.0;      // gap between posts take off the width of the posts
    vScale.Y = Wallgap / 50.0;
    if(vScale.Y < 0.1)
        vScale.Y = 0.1;
    vScaleY = vScale.Y;                         // for replication to the client. If use vScale, the values get rounded.
    vScale.Z = Height / 25.0;
    SetDrawScale3D(vScale);

}

simulated function ClientDrawWall()
{
    local vector cScale;

    if(Level.NetMode != NM_DedicatedServer)
    {
        cScale.X = 0.1; // cannot use vScale.X as it gets rounded to zero
        cScale.Y = vScaleY;
        cScale.Z = default.Height / 25.0;
        SetDrawScale3D(cScale);
    }
}

function AddDefaultInventory()
{
    // do nothing. Do not want default weapon adding
}

simulated function Destroyed()
{
    if( Post1 != None)
        Post1.Destroy();

    if( Post2 != None)
        Post2.Destroy();

    Super.Destroyed();
}

simulated event Touch (Actor Other)
{
    local Pawn P;
    local Controller C;
    local Controller PC;
    local int DamageToDo;

    Super.Touch(Other);

    if(Role < ROLE_Authority)
        return; // dont try to do anything clientside

    P = Pawn(Other);
    if(P == None || P.Health <= 0)
        return; // not pawn so no use hurting, or is already dead

    // let's hit them for damage
    if(Controller == None || RPGEnergyWallController(Controller) == None || RPGEnergyWallController(Controller).PlayerSpawner == None || RPGEnergyWallController(Controller).PlayerSpawner.Pawn == None)
        return;
    PC = RPGEnergyWallController(Controller).PlayerSpawner;

    if(P == PC.Pawn)
        return;     // is spawner

    C = P.Controller;
    if(C == None)
        return;     // not controlled so no use hurting

    if(TeamGame(Level.Game) != None && C.SameTeamAs(PC))   // on same team
        return;

    // now scale the damage as to how big the touched item is. The bigger it is, the more of the field it will disrupt. Clamp betwenn 20 and 200.
    DamageToDo = DamagePerHit * DamageAdjust * (1.0 + (P.HealthMax - 100.0) / 200.0);
    DamageToDo = Min(Max(DamageToDo, MinDamage * DamageAdjust), MaxDamage * DamageAdjust);
    P.TakeDamage(DamageToDo, self, P.Location, vect(0, 0, 0), class'DamTypeEnergyWall');

}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    local int ReducedDamage;

    ReducedDamage = float(Damage) * DamageFraction; // reduce damage by DamageFraction as it isn't really hitting anything

    // taking some damage
    if(ReducedDamage <= 0 && Damage > 0)
        ReducedDamage = 1;
    momentum = vect(0, 0, 0); // and we don't really want to move

    Super.TakeDamage(ReducedDamage, instigatedBy, hitlocation, momentum, damageType) ;

}

defaultproperties
{
    DamagePerHit=40
    DamageFraction=0.300000
    MaxGap=600
    MinGap=80
    Height=120
    DefaultController=Class'RPGEnergyWallController'
    DefaultPost=Class'RPGEnergyWallPost'
    MinDamage=10
    MaxDamage=150
    DamageAdjust=1.000000
    bNonHumanControl=True
    AutoTurretControllerClass=None
    VehicleNameString="Energy Wall"
    bCanBeBaseForPawns=False
    HealthMax=2000.000000
    Health=2000
    ControllerClass=None
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TestBlock'
    bReplicateMovement=False
    DrawScale=0.500000
    Skins(0)=FinalBlend'AW-ShieldShaders.Shaders.RedShieldFinal'
    Skins(1)=FinalBlend'AW-ShieldShaders.Shaders.RedShieldFinal'
    AmbientGlow=10
    bMovable=False
    bBlockActors=False
    bBlockKarma=False
    Mass=1000.000000
}
