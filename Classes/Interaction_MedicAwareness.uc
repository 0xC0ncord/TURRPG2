class Interaction_MedicAwareness extends RPGBaseInteraction;

var Interaction_Global GlobalInteraction;
var Ability_LoadedMedic Ability;

event Initialized() {
    local int i;

    Super.Initialized();

    for(i = 0; i < ViewportOwner.LocalInteractions.Length; i++) {
        if(Interaction_Global(ViewportOwner.LocalInteractions[i]) != None) {
            GlobalInteraction = Interaction_Global(ViewportOwner.LocalInteractions[i]);
            break;
        }
    }
}

function PostRender(Canvas C) {
    local int i, k;
    local float FarAwayInv, Dist, ScaledDist, Scale, Height, Pct;
    local vector ScreenPos;
    local Pawn P;
    local Color BarColor;
    local Texture BeaconTexture;
    local xPlayer xPC;
    local int HealMax;

    if(Ability == None || Ability.AbilityLevel <= 0) {
        return;
    }

    if(ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0) {
        return;
    }

    HealMax = class'Ability_LoadedMedic'.default.LevelCap[class'Ability_LoadedMedic'.default.MaxLevel - 1];

    xPC = xPlayer(ViewportOwner.Actor);

    FarAwayInv = 1.0f / TeamBeaconPlayerInfoMaxDist;

    for(i = 0; i < Ability.Teammates.Length; i++) {
        P = Ability.Teammates[i];
        if(IsPawnVisible(C, P, ScreenPos, Dist)) {
            ScaledDist = TeamBeaconPlayerInfoMaxDist * FClamp(0.04f * P.CollisionRadius, 1.0f, 2.0f);

            if(Dist < 0.0f || Dist > 2.0f * ScaledDist) {
                continue;
            }

            if(Dist > ScaledDist) {
                ScreenPos.Z = 0;
                if(VSize(ScreenPos) * VSize(ScreenPos) > 0.02f * Dist * Dist) {
                    continue;
                }
            }

            //Beacon scale
            Scale = FClamp(0.28f * (ScaledDist - Dist) / ScaledDist, 0.1f, 0.25f);

            //Draw height
            Height = P.CollisionHeight * FClamp(0.85f + Dist * 0.85f * FarAwayInv, 1.1f, 1.75f);

            //Offset, including the team beacon and text!
            ScreenPos = C.WorldToScreen(P.Location + Height * vect(0, 0, 1));

            //Check if speaking (see UnPawn.cpp)
            if(
                xPC != None &&
                xPC.myHUD.PortraitPRI != None &&
                xPC.myHUD.PortraitPRI == P.PlayerReplicationInfo
            ) {
                BeaconTexture = xPC.SpeakingBeaconTexture;
                Scale *= 3;
            } else {
                if(xPC != None) {
                    for(k = 0; k < P.Attached.Length; k++) {
                        if(WeaponAttachment(P.Attached[k]) != None && WeaponAttachment(P.Attached[k]).bMatchWeapons) {
                            BeaconTexture = xPC.LinkBeaconTexture;
                            k = 999; //inner break
                        }
                    }
                }

                if(BeaconTexture == None) {
                    BeaconTexture = TeamBeacon;
                }
            }

            ScreenPos.X -= 0.5f * BeaconTexture.USize * Scale;
            ScreenPos.Y -= 0.5f * BeaconTexture.VSize * Scale;

            //Text
            if(Dist < TeamBeaconPlayerInfoMaxDist && C.ClipX > 600) {
                ScreenPos.Y -= SmallFontHeight;
            }

            //Bar height
            Height = SmallFontHeight * FClamp(1 - Dist / (TeamBeaconPlayerInfoMaxDist * 0.5), 0.5, 1);

            if(Vehicle(P) != None) {
                Height *= 1.75;
            }

            BarColor.A = 255;

            //Health bar
            ScreenPos.Y -= Height + 4;
            Pct = FClamp(float(P.Health) / (P.HealthMax + HealMax), 0f, 1f);

            if(P.Health >= P.HealthMax + HealMax)
                BarColor = class'HUD'.default.BlueColor;
            else
            {
                if(P.Health < P.HealthMax * 0.33)
                    BarColor = class'HUD'.default.RedColor;
                else if(P.Health < P.HealthMax)
                    BarColor = class'Util'.static.InterpolateColor(class'HUD'.default.RedColor, class'HUD'.default.GreenColor, (P.Health - P.HealthMax * 0.33) / P.HealthMax);
                else
                    BarColor = class'Util'.static.InterpolateColor(class'HUD'.default.GreenColor, class'HUD'.default.CyanColor, (P.Health - P.HealthMax) / (P.HealthMax + HealMax));
            }

            DrawCenterStyleBar(C, ScreenPos.X, ScreenPos.Y, BarColor, Pct, 10 * Height, Height, true);
        }
    }
}

defaultproperties {
    bVisible = true;
}
