//=============================================================================
// RPGBlockLongShelter.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockLongShelter extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=12
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=-60,YOffset=-134,ZOffset=20)
     Blocks(1)=(BlockType=Class'RPGBlock',XOffset=-180,YOffset=-134,ZOffset=20)
     Blocks(2)=(BlockType=Class'RPGBlock',XOffset=60,YOffset=-134,ZOffset=20)
     Blocks(3)=(BlockType=Class'RPGBlock',XOffset=180,YOffset=-134,ZOffset=20)
     Blocks(4)=(BlockType=Class'RPGBlock',XOffset=-268,YOffset=-53,ZOffset=20,Angle=1)
     Blocks(5)=(BlockType=Class'RPGBlock',XOffset=268,YOffset=-53,ZOffset=20,Angle=1)
     Blocks(6)=(BlockType=Class'RPGBlock',XOffset=-60,YOffset=-134,ZOffset=90)
     Blocks(7)=(BlockType=Class'RPGBlock',XOffset=60,YOffset=-134,ZOffset=90)
     Blocks(8)=(BlockType=Class'RPGBlock',XOffset=30,YOffset=-75,ZOffset=160,Angle=1)
     Blocks(9)=(BlockType=Class'RPGBlock',XOffset=-30,YOffset=-75,ZOffset=160,Angle=1)
     Blocks(10)=(BlockType=Class'RPGBlock',XOffset=90,YOffset=-75,ZOffset=160,Angle=1)
     Blocks(11)=(BlockType=Class'RPGBlock',XOffset=-90,YOffset=-75,ZOffset=160,Angle=1)
}
