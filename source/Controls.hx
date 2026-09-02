package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

@:build(ControlsMacro.build())
class Controls
{
    public static function getKeybindsFor(buttonName:String):Array<FlxKey>
    {
        switch(buttonName)
        {
            case "ACCEPT":
                return [FlxKey.ENTER,FlxKey.SPACE];
            case "LEFT":
                return [FlxKey.LEFT,FlxKey.A];
            case "DOWN":
                return [FlxKey.DOWN,FlxKey.S];
            case "UP":
                return [FlxKey.UP,FlxKey.W];
            case "RIGHT":
                return [FlxKey.RIGHT,FlxKey.D];
        }
        return [];
    }
}
