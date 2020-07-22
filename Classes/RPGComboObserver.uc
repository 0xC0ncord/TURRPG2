//=============================================================================
// RPGComboObserver.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Observer for combos
class RPGComboObserver extends Info
    config(TURRPG2);

var config float AdrenalineDrainThreshold;

var Controller ComboStarter;

var Combo ActualCombo;
var class<Combo> ActualComboClass;

var float Cost;
var float InitialAdrenaline;

event PostBeginPlay() {
    ActualCombo = Combo(Owner);
    ActualComboClass = ActualCombo.class;

    Cost = ActualCombo.AdrenalineCost;
    ComboStarter = xPawn(ActualCombo.Owner).Controller;

    InitialAdrenaline = ComboStarter.Adrenaline;
}

event Tick(float DeltaTime) {
    if(ActualCombo == None) {
        Destroy(); //actual combo ended
    }
}

event Destroyed() {
    if(ActualCombo != None) {
        ActualCombo.Destroy();
    }

    //assume that the combo was successful if the controller's adrenaline was sufficiently drained
    if(ComboStarter != None && ComboStarter.Adrenaline <= InitialAdrenaline - Cost * AdrenalineDrainThreshold) {
        class'RPGRules'.static.Instance(Level).ComboSuccess(ComboStarter, ActualComboClass);
    }
}

defaultproperties {
    AdrenalineDrainThreshold=0.5
}
