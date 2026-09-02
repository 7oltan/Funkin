package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public function new(strumTime:Float, noteData:Int, prevNote:Note)
	{
		super();

		this.prevNote = prevNote;

		x += 50;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var tex = FlxAtlasFrames.fromSparrow(Paths.image("NOTE_assets"), Paths.xml("NOTE_assets"));
		frames = tex;
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		switch (Math.abs(noteData))
		{
			case 1:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 2:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 3:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 4:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		if (noteData < 0 && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case -1:
					animation.play('purpleholdend');
				case -2:
					animation.play('blueholdend');
				case -3:
					animation.play('greenholdend');
				case -4:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (prevNote.noteData < 0)
			{
				switch (prevNote.noteData)
				{
					case -1:
						prevNote.animation.play('purplehold');
					case -2:
						prevNote.animation.play('bluehold');
					case -3:
						prevNote.animation.play('greenhold');
					case -4:
						prevNote.animation.play('redhold');
				}

				prevNote.offset.y = -19;
				prevNote.scale.y *= 2.25;
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
			{
				canBeHit = true;
			}
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
			{
				wasGoodHit = true;
			}
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
