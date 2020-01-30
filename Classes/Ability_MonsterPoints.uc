class Ability_MonsterPoints extends RPGAbility;

function ModifyRPRI()
{
    local int i;

    RPRI.MaxMonsterPoints = AbilityLevel;
    RPRI.MonsterPoints = AbilityLevel;

    if(RPRI.Monsters.Length > 0)
        for(i = 0; i < RPRI.Monsters.Length; i++)
            RPRI.MonsterPoints -= RPRI.Monsters[i].Points;
}

defaultproperties
{
    AbilityName="Monster Points"
    Description="Allows you to summon monsters with the Loaded Monsters skill."
    bUseLevelCost=True
    LevelCost(0)=1
    LevelCost(1)=1
    LevelCost(2)=2
    LevelCost(3)=2
    LevelCost(4)=3
    LevelCost(5)=3
    LevelCost(6)=4
    LevelCost(7)=4
    LevelCost(8)=5
    LevelCost(9)=5
    LevelCost(10)=6
    LevelCost(11)=6
    LevelCost(12)=7
    LevelCost(13)=7
    LevelCost(14)=8
    LevelCost(15)=8
    LevelCost(16)=9
    LevelCost(17)=9
    LevelCost(18)=10
    LevelCost(19)=10
    LevelCost(20)=11
    LevelCost(21)=11
    LevelCost(22)=12
    LevelCost(23)=12
    LevelCost(24)=13
    LevelCost(25)=13
    LevelCost(26)=14
    LevelCost(27)=14
    LevelCost(28)=15
    LevelCost(29)=15
    MaxLevel=30
    RequiredAbilities(0)=(AbilityClass=Class'TURRPG2.Ability_LoadedMonsters',Level=1)
    Category=Class'TURRPG2.AbilityCategory_Monsters'
    StatusIconClass=Class'TURRPG2.StatusIcon_MonsterPoints'
}
