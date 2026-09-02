package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

class PlayState extends FlxTransitionableState
{
	private var currentBeat:Int = 0;
	private var currentStep:Int = 0;
	private var vocalsPlayer:FlxSound;
	private var vocalsOpponent:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Character;

	private var scrollSpeed:Float = 1.0;
	private var notes:FlxTypedGroup<Note>;
	private var events:Array<Dynamic> = [];
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	public static var curSong:String = "";

	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var countingDown:Bool = false;

	private var healthHeads:FlxSprite;

	override public function create()
	{
		persistentUpdate = true;
		persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image("stageback"));
		// bg.setGraphicSize(Std.int(bg.width * 2.5));
		// bg.updateHitbox();
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image("stagefront"));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image("stagecurtains"));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;

		add(stageCurtains);

		generateSong(curSong.toLowerCase());

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		notes = new FlxTypedGroup<Note>();
		add(notes);
		
		var swagCounter:Int = 0;

		countingDown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			currentBeat = swagCounter-5;
			beatHit();

			var countdownSounds:Array<String> = ['intro3','intro2','intro1','introGo'];
			var countdownGraphics:Array<String> = ['','ready','set','go'];

			if(countdownGraphics[swagCounter] != '')
			{
				var countdownSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(countdownGraphics[swagCounter]));
				countdownSprite.scrollFactor.set();
				countdownSprite.screenCenter();
				add(countdownSprite);
				FlxTween.tween(countdownSprite, {y: countdownSprite.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						countdownSprite.destroy();
					}
				});
			}


			FlxG.sound.play(Paths.sound(countdownSounds[swagCounter]), 0.6);
			swagCounter += 1;
		}, 4);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(dad.getGraphicMidpoint().x + 150, dad.getGraphicMidpoint().y - 100);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 1.05;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image("healthBar"));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		healthHeads = new FlxSprite();
		var headTex = FlxAtlasFrames.fromSparrow(Paths.image("healthHeads"), Paths.xml("healthHeads"));
		healthHeads.frames = headTex;
		healthHeads.animation.add('healthy', [0]);
		healthHeads.animation.add('unhealthy', [1]);
		healthHeads.y = healthBar.y - (healthHeads.height / 2);
		healthHeads.scrollFactor.set();
		add(healthHeads);

		super.create();
	}

	function startSong():Void
	{
		countingDown = false;
		FlxG.sound.music.resume();
		vocalsPlayer.play();
		vocalsOpponent.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		trace(dataPath);
		// FlxG.log.add(ChartParser.parse());
		generatedMusic = true;

		var songChartData = Json.parse(Assets.getText('assets/data/' + dataPath + '/' + dataPath + '-chart.json'));
		var songMetaData = Json.parse(Assets.getText('assets/data/' + dataPath + '/' + dataPath + '-metadata.json'));
		var timeChanges:Array<Dynamic> = songMetaData.timeChanges;
		var opponentCharacter:String = songMetaData.playData.characters.opponent;
		var playerCharacter:String = songMetaData.playData.characters.player;
		var gfCharacter:String = songMetaData.playData.characters.girlfriend;

		gf = new Character(400, 730,gfCharacter);
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		dad = new Character(100, 850,opponentCharacter);
		add(dad);

		boyfriend = new Character(770, 850,playerCharacter);
		add(boyfriend);
		
		Conductor.changeBPM(timeChanges[0].bpm);

		scrollSpeed = songChartData.scrollSpeed.hard;

		FlxG.sound.playMusic(Paths.inst(dataPath));
		FlxG.sound.music.pause();
		vocalsOpponent = new FlxSound().loadEmbedded(Paths.vocals(dataPath,opponentCharacter));
		FlxG.sound.list.add(vocalsOpponent);
		vocalsPlayer = new FlxSound().loadEmbedded(Paths.vocals(dataPath,playerCharacter));
		FlxG.sound.list.add(vocalsPlayer);

		events = songChartData.events;

		var songDataNotes:Array<Dynamic> = songChartData.notes.hard;
		for(noteData in songDataNotes)
		{
			var noteTime:Float = noteData.t;
			var noteKind:Int = Std.int((noteData.d%4)+1); 
			var isDad:Bool = noteData.d>3;

			var oldNote:Note;
			if (unspawnNotes.length > 0)
				oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
			else
				oldNote = null;

			var swagNote:Note = new Note(noteTime, noteKind, oldNote);
			swagNote.scrollFactor.set(0, 0);

			unspawnNotes.push(swagNote);

			if(!isDad)
				swagNote.x += (FlxG.width / 2);

			if (!isDad) // is the player
				swagNote.mustPress = true;
		}

		unspawnNotes.sort(sortByShit);
		trace('FIRST NOTE ' + unspawnNotes[0]);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var sortedNotes:Bool = false;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var arrTex = FlxAtlasFrames.fromSparrow(Paths.image("NOTE_assets"), Paths.xml("NOTE_assets"));
			babyArrow.frames = arrTex;
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.scrollFactor.set();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.antialiasing = true;

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i + 1;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			switch (Math.abs(i + 1))
			{
				case 1:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 4:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	var sectionScored:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		healthHeads.setGraphicSize(Std.int(FlxMath.lerp(100, healthHeads.width, 0.98)));
		healthHeads.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (healthHeads.width / 2);

		if (healthBar.percent < 10)
			healthHeads.animation.play('unhealthy');
		else
			healthHeads.animation.play('healthy');
		/* 
			if (FlxG.keys.justPressed.NINE)
				FlxG.switchState(new Charting());
			if (FlxG.keys.justPressed.EIGHT)
				FlxG.switchState(new Charting(true));
		 */

		if (countingDown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (Conductor.songPosition >= 0)
				startSong();
		}
		else
			Conductor.songPosition = FlxG.sound.music.time;

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(1.05, FlxG.camera.zoom, 0.96);
		}

		FlxG.watch.addQuick("beatShit", currentBeat);

		if (curSong == 'fresh')
		{
			switch (currentBeat)
			{
				case 16:
					camZooming = true;
					gf.danceIntervals = 2;
				case 48:
					gf.danceIntervals = 1;
				case 80:
					gf.danceIntervals = 2;
				case 112:
					gf.danceIntervals = 1;
			}
		}
		
		if(Conductor.songPosition >= 0)
		{
			if(Math.floor(Conductor.songPosition/Conductor.crochet) > currentBeat)
			{
				currentBeat = Math.floor(Conductor.songPosition/Conductor.crochet);
				beatHit();
			}
			if(Math.floor(Conductor.songPosition/Conductor.stepCrochet) > currentStep)
			{
				currentStep = Math.floor(Conductor.songPosition/Conductor.stepCrochet);
				stepHit();
			}
		}


		if (health <= 0)
		{
			boyfriend.stunned = true;
			FlxG.switchState(new GameOverState());
		}

		if(FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.music.stop();
			vocalsPlayer.stop();
			vocalsOpponent.stop();
			FlxG.switchState(new FreeplayState());
		}

		//very bare bones
		for(event in events)
		{
			if(Conductor.songPosition >= event.t)
			{
				var eventData:Dynamic = event.v;
				switch(event.e)
				{
					case "FocusCamera":
						var eventCharacter:Int = 0;
						if(Std.isOfType(eventData,Int))
							eventCharacter = eventData;
						else
							eventCharacter = eventData.char;
						if(eventCharacter == 1)
							camFollow.setPosition(dad.getGraphicMidpoint().x + 150, dad.getGraphicMidpoint().y - 100);
						if(eventCharacter == 0)
							camFollow.setPosition(boyfriend.getGraphicMidpoint().x - 100, boyfriend.getGraphicMidpoint().y - 100);
					case "PlayAnimation":
						if(eventData.target == "bf")
							boyfriend.playSpecialAnim(eventData.anim);
				}
				
				events.remove(event);
			}
		}

		if (unspawnNotes[0] != null)
		{
			FlxG.watch.addQuick('spsa', unspawnNotes[0].strumTime);
			FlxG.watch.addQuick('weed', Conductor.songPosition);
			
			if (FlxG.height+100 > strumLine.y-(0.45 * (Conductor.songPosition - unspawnNotes[0].strumTime) * scrollSpeed))
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					switch (Math.abs(daNote.noteData))
					{
						case 1:
							dad.playSpecialAnim('singLEFT');
						case 2:
							dad.playSpecialAnim('singDOWN');
						case 3:
							dad.playSpecialAnim('singUP');
						case 4:
							dad.playSpecialAnim('singRIGHT');
					}

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				daNote.y = strumLine.y-(0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed);

				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate)
					{
						health -= 0.05;
						vocalsPlayer.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// one time sort
				if (!sortedNotes)
					notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			});
		}

		keyShit();
	}

	private function popUpScore():Void
	{
		/*boyfriend.playAnim('hey');
		vocals.volume = 1;*/

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.75;
		//

		var rating:FlxSprite = new FlxSprite();

		var daRating:String = "shit";

		if (combo > 60)
			daRating = 'sick';
		else if (combo > 12)
			daRating = 'good'
		else if (combo > 4)
			daRating = 'bad';
		rating.loadGraphic(Paths.image(daRating));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		rating.antialiasing = true;
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("combo"));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.antialiasing = true;
		comboSpr.velocity.y -= 150;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.updateHitbox();
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(comboSpr);
		add(rating);

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num'+ Std.int(i)));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		trace(combo);
		trace(seperatedScore);

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = FlxG.keys.anyPressed([W, UP]);
		var right = FlxG.keys.anyPressed([D, RIGHT]);
		var down = FlxG.keys.anyPressed([S, DOWN]);
		var left = FlxG.keys.anyPressed([A, LEFT]);

		var upP = FlxG.keys.anyJustPressed([W, UP]);
		var rightP = FlxG.keys.anyJustPressed([D, RIGHT]);
		var downP = FlxG.keys.anyJustPressed([S, DOWN]);
		var leftP = FlxG.keys.anyJustPressed([A, LEFT]);

		var upR = FlxG.keys.anyJustReleased([W, UP]);
		var rightR = FlxG.keys.anyJustReleased([D, RIGHT]);
		var downR = FlxG.keys.anyJustReleased([S, DOWN]);
		var leftR = FlxG.keys.anyJustReleased([A, LEFT]);

		FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			var possibleNotes:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					possibleNotes.push(daNote);
					trace('NOTE-' + daNote.strumTime + ' ADDED');
				}
			});

			if (possibleNotes.length > 0)
			{
				for (daNote in possibleNotes)
				{
					if (upP || rightP || downP || leftP)
					{
						switch (daNote.noteData)
						{
							case 1: 
								noteCheck(leftP, daNote);
							case 2:
								noteCheck(downP, daNote);
							case 3:
								noteCheck(upP, daNote);
							case 4:
								noteCheck(rightP, daNote);
						}
					}


					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case -1:
							if (left && daNote.prevNote.wasGoodHit)
								goodNoteHit(daNote);
						case -2:
							if (down && daNote.prevNote.wasGoodHit)
								goodNoteHit(daNote);
						case -3:
							if (up && daNote.prevNote.wasGoodHit)
								goodNoteHit(daNote);
						case -4:
							if (right && daNote.prevNote.wasGoodHit)
								goodNoteHit(daNote);
					}
				}
			});
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 1:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 2:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 3:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 4:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.08;
			if (combo > 5)
			{
				gf.playSpecialAnim('sad');
			}
			combo = 0;

			FlxG.sound.play(Paths.sound('missnote'+FlxG.random.int(1, 3)), FlxG.random.float(0.05, 0.2));

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 1:
					boyfriend.playSpecialAnim('singLEFTmiss');
				case 2:
					boyfriend.playSpecialAnim('singDOWNmiss');
				case 3:
					boyfriend.playSpecialAnim('singUPmiss');
				case 4:
					boyfriend.playSpecialAnim('singRIGHTmiss');
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		var upP = FlxG.keys.anyJustPressed([W, UP]);
		var rightP = FlxG.keys.anyJustPressed([D, RIGHT]);
		var downP = FlxG.keys.anyJustPressed([S, DOWN]);
		var leftP = FlxG.keys.anyJustPressed([A, LEFT]);

		if (leftP)
			noteMiss(1);
		if (downP)
			noteMiss(2);
		if (upP)
			noteMiss(3);
		if (rightP)
			noteMiss(4);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		trace(note.noteData + ' note check here ' + keyP);
		if (keyP)
			goodNoteHit(note);
		else
			badNoteCheck();
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			combo += 1;
			popUpScore();

			if (note.noteData > 0)
				health += 0.03;
			else
				health += 0.007;

			switch (Math.abs(note.noteData))
			{
				case 1:
					boyfriend.playSpecialAnim('singLEFT');
				case 2:
					boyfriend.playSpecialAnim('singDOWN');
				case 3:
					boyfriend.playSpecialAnim('singUP');
				case 4:
					boyfriend.playSpecialAnim('singRIGHT');
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocalsPlayer.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	private function beatHit():Void
	{
		trace(currentBeat);
		if (camZooming && FlxG.camera.zoom < 1.35 && currentBeat % 4 == 0)
			FlxG.camera.zoom += 0.025;

		healthHeads.setGraphicSize(Std.int(healthHeads.width + 20));

		if(currentBeat % dad.danceIntervals == 0)
			dad.dance();
		if(currentBeat % boyfriend.danceIntervals == 0)
			boyfriend.dance();
		if(currentBeat % gf.danceIntervals == 0)
			gf.dance();

	}
	private function stepHit():Void
	{
	}
}
