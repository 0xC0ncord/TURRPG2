//=============================================================================
// RPGBlockLeaningWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockLeaningWall extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=15
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=-120,YOffset=-133,ZOffset=20)
     Blocks(1)=(BlockType=Class'RPGBlock',YOffset=-133,ZOffset=20)
     Blocks(2)=(BlockType=Class'RPGBlock',XOffset=120,YOffset=-133,ZOffset=20)
     Blocks(3)=(BlockType=Class'RPGBlock',XOffset=-120,YOffset=-133,ZOffset=90)
     Blocks(4)=(BlockType=Class'RPGBlock',YOffset=-133,ZOffset=90)
     Blocks(5)=(BlockType=Class'RPGBlock',XOffset=120,YOffset=-133,ZOffset=90)
     Blocks(6)=(BlockType=Class'RPGBlock',XOffset=-120,YOffset=-133,ZOffset=160)
     Blocks(7)=(BlockType=Class'RPGBlock',YOffset=-133,ZOffset=160)
     Blocks(8)=(BlockType=Class'RPGBlock',XOffset=120,YOffset=-133,ZOffset=160)
     Blocks(9)=(BlockType=Class'RPGBlock',XOffset=-120,YOffset=-78,ZOffset=230)
     Blocks(10)=(BlockType=Class'RPGBlock',YOffset=-78,ZOffset=230)
     Blocks(11)=(BlockType=Class'RPGBlock',XOffset=120,YOffset=-78,ZOffset=230)
     Blocks(12)=(BlockType=Class'RPGBlock',XOffset=-120,YOffset=-23,ZOffset=300)
     Blocks(13)=(BlockType=Class'RPGBlock',YOffset=-23,ZOffset=300)
     Blocks(14)=(BlockType=Class'RPGBlock',XOffset=120,YOffset=-23,ZOffset=300)
}
