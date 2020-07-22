//=============================================================================
// RPGBlockSquareWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockSquareWall extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=14
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=60,YOffset=150,ZOffset=20)
     Blocks(1)=(BlockType=Class'RPGBlock',XOffset=-60,YOffset=150,ZOffset=20)
     Blocks(2)=(BlockType=Class'RPGBlock',XOffset=150,YOffset=60,ZOffset=20,Angle=1)
     Blocks(3)=(BlockType=Class'RPGBlock',XOffset=150,YOffset=-60,ZOffset=20,Angle=1)
     Blocks(4)=(BlockType=Class'RPGBlock',XOffset=60,YOffset=-150,ZOffset=20)
     Blocks(5)=(BlockType=Class'RPGBlock',XOffset=-60,YOffset=-150,ZOffset=20)
     Blocks(6)=(BlockType=Class'RPGBlock',XOffset=-150,YOffset=60,ZOffset=20,Angle=1)
     Blocks(7)=(BlockType=Class'RPGBlock',XOffset=-150,YOffset=-60,ZOffset=20,Angle=1)
     Blocks(8)=(BlockType=Class'RPGBlock',XOffset=60,YOffset=150,ZOffset=100)
     Blocks(9)=(BlockType=Class'RPGBlock',XOffset=-60,YOffset=150,ZOffset=100)
     Blocks(10)=(BlockType=Class'RPGBlock',XOffset=150,ZOffset=100,Angle=1)
     Blocks(11)=(BlockType=Class'RPGBlock',XOffset=60,YOffset=-150,ZOffset=100)
     Blocks(12)=(BlockType=Class'RPGBlock',XOffset=-60,YOffset=-150,ZOffset=100)
     Blocks(13)=(BlockType=Class'RPGBlock',XOffset=-150,ZOffset=100,Angle=1)
}
