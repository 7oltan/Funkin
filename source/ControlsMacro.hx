package;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
class ControlsMacro
{
    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        
        var buttons:Array<String> = ["ACCEPT","LEFT","DOWN","UP","RIGHT"];
        for(button in buttons)
        {
            var pressTypes = ["","_P","_R"];
            for(pressType in pressTypes)
            {
                var propField:Field = {
                    name: button+pressType,
                    access: [APublic,AStatic],
                    kind: FProp("get", "null", (macro:Bool)),
                    pos: Context.currentPos()
                };

                var getterExpr = null;

                if(pressType == "")
                {
                    getterExpr = macro{
                        return FlxG.keys.anyPressed(getKeybindsFor($v{button}));
                    };
                }
                if(pressType == "_P")
                {
                    getterExpr = macro{
                        return FlxG.keys.anyJustPressed(getKeybindsFor($v{button}));
                    };
                }
                if(pressType == "_R")
                {
                    getterExpr = macro{
                        return FlxG.keys.anyJustReleased(getKeybindsFor($v{button}));
                    };
                }

                var getterField:Field = {
                    name: "get_" + button+pressType,
                    access: [APublic,AStatic],
                    kind: FFun({
                        args: [],
                        ret: (macro:Bool),
                        expr: getterExpr
                    }),
                    pos: Context.currentPos()
                };

                fields.push(propField);
                fields.push(getterField);
            }
        }
        
        return fields;
    }
}
#end