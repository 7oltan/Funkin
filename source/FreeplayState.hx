package;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class FreeplayState extends FlxTransitionableState
{
	var songList:Array<String> = ['bopeebo','fresh','dad-battle','spookeez','south'];
	var songTextGroup:Array<FlxText> = [];
	var curSelected:Int = 0;
	override public function create():Void
	{
		super.create();
		
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

	override function update(elapsed:Float)
	{
		if(FlxG.keys.justPressed.DOWN)
			changeSelection(1);
		if(FlxG.keys.justPressed.UP)
			changeSelection(-1);

		if (FlxG.keys.justPressed.ENTER)
		{
			PlayState.curSong = songList[curSelected];
			FlxG.switchState(new PlayState());
		}

		super.update(elapsed);
	}
}
