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
    inline public static function sound(key:String)
    {
        return "assets/sounds/"+key+".ogg";
    }
    inline public static function music(key:String)
    {
        return "assets/music/"+key+".ogg";
    }
    inline public static function inst(songId:String)
    {
        return "assets/songs/"+songId+"/Inst.ogg";
    }
    inline public static function vocals(songId:String,charId:String)
    {
        return "assets/songs/"+songId+"/Voices-"+charId+".ogg";
    }
    inline public static function songChart(songId:String)
    {
        return "assets/data/"+songId+"/"+songId+"-chart.json";
    }
    inline public static function songMetadata(songId:String)
    {
        return "assets/data/"+songId+"/"+songId+"-metadata.json";
    }

    public static function fromSparrow(key:String)
    {
        return FlxAtlasFrames.fromSparrow(image(key), xml(key));
    }
}
