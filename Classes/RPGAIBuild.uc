//=============================================================================
// RPGAIBuild.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGAIBuild extends Object
    config(TURRPG2AI)
    PerObjectConfig;

struct AIBuildAction
{
    var string BuyAbility;
    var int Level;
};
var config array<AIBuildAction> BuildActions;

/*
These settings allow overriding the bot's behaviour so it fits the build.
*/
const NO_CHANGE = -999;

var config float Aggressiveness, CombatStyle, Jumpiness, StrafingAbility, Accuracy, Tactics, ReactionTime, TranslocUse;

function InitBot(Bot Bot)
{
    if(RPGBot(Bot) != None)
        RPGBot(Bot).AIBuild = Self;

    if(Aggressiveness != NO_CHANGE)
        Bot.BaseAggressiveness = Aggressiveness;

    if(CombatStyle != NO_CHANGE)
        Bot.CombatStyle = CombatStyle;

    if(Jumpiness != NO_CHANGE)
        Bot.Jumpiness = Jumpiness;

    if(StrafingAbility != NO_CHANGE)
        Bot.StrafingAbility = StrafingAbility;

    if(Accuracy != NO_CHANGE)
        Bot.Accuracy = Accuracy;

    if(Tactics != NO_CHANGE)
        Bot.Tactics = Tactics;

    if(ReactionTime != NO_CHANGE)
        Bot.ReactionTime = ReactionTime;

    if(TranslocUse != NO_CHANGE)
        Bot.TranslocUse = TranslocUse;
}

function Build(RPGPlayerReplicationInfo RPRI)
{
    local AIBuildAction Action;
    local RPGAbility BuyAbility;
    local int Cost;

    //make totally sure it's a bot here...
    if(AIController(RPRI.Controller) == None)
        return;

    while(RPRI.StatPointsAvailable > 0 || RPRI.AbilityPointsAvailable > 0)
    {
        if(RPRI.AIBuildAction >= BuildActions.Length)
        {
            Log(RPRI.PRI.PlayerName @ "has finished his/her AIBuild!", 'TURRPG2');
            break;
        }

        Action = BuildActions[RPRI.AIBuildAction];
        BuyAbility = RPRI.GetAbility(class'MutTURRPG'.static.Instance(RPRI.Level).ResolveAbility(Action.BuyAbility));
        if(BuyAbility != None)
        {
            Cost = BuyAbility.Cost();

            if(BuyAbility.bIsStat && RPRI.StatPointsAvailable < Cost ||
                (!BuyAbility.bIsStat && RPRI.AbilityPointsAvailable < Cost))
            {
                break;
            }
            else if(Cost <= 0 || !BuyAbility.Buy())
            {
                Warn(RPRI.PRI.PlayerName @ "failed to buy ability" @ BuyAbility);
                break;
            }

            RPRI.ModifyStats();

            if(RPRI.HasAbility(BuyAbility.class, true) >= Action.Level)
                RPRI.AIBuildAction++;
        }
        else
        {
            Warn(Self $ " Unable to find ability:" @ Action.BuyAbility);
            break;
        }
    }
}

defaultproperties
{
    Aggressiveness=NO_CHANGE
    CombatStyle=NO_CHANGE
    Jumpiness=NO_CHANGE
    StrafingAbility=NO_CHANGE
    Accuracy=NO_CHANGE
    Tactics=NO_CHANGE
    ReactionTime=NO_CHANGE
    TranslocUse=NO_CHANGE
}
