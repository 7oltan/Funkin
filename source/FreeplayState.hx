package;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class FreeplayState extends FlxTransitionableState
{
	var songList:Array<String> = ['bopeebo','fresh','dad-battle','spookeez','south'];
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
		if(FlxG.keys.justPressed.DOWN)
			changeSelection(1);
		if(FlxG.keys.justPressed.UP)
			changeSelection(-1);
		if(FlxG.keys.justPressed.RIGHT)
			changeDifficulty(1);
		if(FlxG.keys.justPressed.LEFT)
			changeDifficulty(-1);

		if (FlxG.keys.justPressed.ENTER)
		{
			PlayState.curSong = songList[curSelected];
			PlayState.curDifficulty = difficultyList[curDifficulty];
			FlxG.switchState(new PlayState());
		}

		super.update(elapsed);
	}
}
