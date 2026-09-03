package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Stage extends FlxTypedSpriteGroup<FlxSprite>
{
    override public function new(stageId:String)
    {
        super();
        switch(stageId)
        {
            case "mainStage":
                var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image("stageback"));
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
            case "spookyMansion":  
                var halloweenBG:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image("halloween_bg"));
                halloweenBG.antialiasing = true;
                add(halloweenBG);
        }
    }

    public function beatHit(currentBeat:Int)
    {
        
    }
}