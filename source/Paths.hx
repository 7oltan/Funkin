package;
import flixel.graphics.frames.FlxAtlasFrames;

class Paths 
{
    inline public static function xml(key:String)
    {
        return "assets/images/"+key+".xml";
    }
    inline public static function image(key:String)
    {
        return "assets/images/"+key+".png";
    }
    public static function fromSparrow(key:String)
    {
        return FlxAtlasFrames.fromSparrow(image(key), xml(key));
    }
}
