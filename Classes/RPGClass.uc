//=============================================================================
// RPGClass.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGClass extends RPGAbility
    abstract;

struct LevelStruct
{
    var int Level;
    var int TargetLevel;
};
struct ForbiddenStruct
{
    var int Index;
    var array<LevelStruct> Levels;
};
struct RequiredStruct
{
    var int Index;
    var array<LevelStruct> Levels;
};

//For predetermining layout of the ability tree in menus
struct ClassTreeInfoStruct
{
    var class<RPGAbility> AbilityClass;
    var int Row;
    var int Column;
    var int MaxLevel;
    var array<ForbiddenStruct> ForbidsAbilities;
    var array<RequiredStruct> RequiredByAbilities;
    var bool bDisjunctiveRequirements;
};
var array<ClassTreeInfoStruct> ClassTreeInfos;

defaultproperties
{
     StartingCost=0
     MaxLevel=1
     Category=Class'AbilityCategory_Class'
}
