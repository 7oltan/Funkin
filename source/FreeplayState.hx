package;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class FreeplayState extends FlxTransitionableState
{
	var songList:Array<String> = ['bopeebo','fresh','dad-battle','spookeez','south','monster'];
	var difficultyList:Array<String> = ['easy','normal','hard'/**,'erect','nightmare'**/];
	var songTextGroup:Array<FlxText> = [];
	var difficultyText:FlxText;
	var curDifficulty:Int = 1;
	var curSelected:Int = 0;
	override public function create():Void
	{
		super.create();
		
		difficultyText = new FlxText(0, 50, 0, '', 32);
		add(difficultyText);

		var songIndex:Int = 0;
		for(song in songList)
		{
			var songText:FlxText = new FlxText(0, 100+(50*songIndex), 0, song, 32);
			songText.screenCenter(X);
			songText.ID = songIndex;
			add(songText);
			songTextGroup.push(songText);
			songIndex++;
		}

		changeSelection(0);
		changeDifficulty(0);
	}

	function changeSelection(val:Int)
	{
		curSelected = FlxMath.wrap(curSelected+val,0,songList.length-1);
		for(songText in songTextGroup)
		{
			if(songText.ID == curSelected)
			{
				songText.color = 0xFFFF0000;
			}
			else
			{
				songText.color = 0xFFFFFFFF;
			}
		}
	}

	function changeDifficulty(val:Int)
	{
		curDifficulty = FlxMath.wrap(curDifficulty+val,0,difficultyList.length-1);

		difficultyText.text = difficultyList[curDifficulty];
		difficultyText.updateHitbox();
		difficultyText.x = (FlxG.width-100)-(difficultyText.width/2);
	}

	override function update(elapsed:Float)
	{
		if(Controls.DOWN_P)
			changeSelection(1);
		if(Controls.UP_P)
			changeSelection(-1);
		if(Controls.RIGHT_P)
			changeDifficulty(1);
		if(Controls.LEFT_P)
			changeDifficulty(-1);

		if (Controls.ACCEPT_P)
		{
			PlayState.curSong = songList[curSelected];
			PlayState.curDifficulty = difficultyList[curDifficulty];
			FlxG.switchState(new PlayState());
		}

		super.update(elapsed);
	}
}
