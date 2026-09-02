package;

import flixel.FlxSprite;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	private final specialAnimationLength:Float = 1;
	private var isPlayingSpecialAnimation:Bool = false;
	private var specialAnimationTimer:Float = 0.0;
	public var charId:String = "";
	private var danced:Bool = true;
	public var stunned:Bool = false;

	public function new(x:Float, y:Float,charId:String)
	{
		super(x, y);
		this.charId = charId;
		animOffsets = new Map<String, Array<Dynamic>>();

		switch(charId)
		{
			case "gf":
				frames = Paths.fromSparrow("GF_assets");
				animation.addByPrefix('cheer', 'GF Cheer',24,false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('cheer');
				addOffset('sad');
				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight',true);
			case "dad":
				frames = Paths.fromSparrow("DADDY_DEAREST");
				animation.addByPrefix('idle', 'Dad idle dance', 24,false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24,false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24,false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24,false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24,false);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');
			case "bf":
				frames = Paths.fromSparrow('BOYFRIEND');
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				playAnim('idle');
			case "spooky":
				frames = Paths.fromSparrow('SpookyKids');
				animation.addByIndices('danceLeft', 'spooky dance idle0', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, false);
				animation.addByIndices('danceRight', 'spooky dance idle0', [8, 9, 10, 11, 12, 13, 14, 15], "", 24, false);
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -125, -12);
				addOffset("singLEFT", 120,-8);
				addOffset("singDOWN", -40, -147);
				playAnim('danceRight',true);
		}
		antialiasing = true;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		isPlayingSpecialAnimation = false;
		specialAnimationTimer = 0.0;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
	}

	public function playSpecialAnim(AnimName:String)
	{
		playAnim(AnimName,true);
		isPlayingSpecialAnimation = true;
		specialAnimationTimer = specialAnimationLength;
	}

	override public function update(elapsed)
	{
		super.update(elapsed);
		if(isPlayingSpecialAnimation)
		{
			specialAnimationTimer -= elapsed;
			if(specialAnimationTimer <= 0)
				isPlayingSpecialAnimation = false;
		}
	}

	public function dance()
	{
		if(isPlayingSpecialAnimation) return;
		if(charId == 'gf' || charId == 'spooky')
		{
			danced = !danced;

			if (danced)
				playAnim('danceRight',true);
			else
				playAnim('danceLeft',true);
		}
		else
		{
			playAnim('idle',true);
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
