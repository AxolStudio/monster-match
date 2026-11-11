#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
#end

/** Enable the library's complete intro in Android test builds without editing axollib. */
class FullIntro {
    #if macro
    public static function enable():Void {
        Compiler.addGlobalMetadata("axollib.AxolversaryState", "@:build(FullIntro.restore())", false, true, false);
        Compiler.addGlobalMetadata("flixel.system.debug.log.BitmapLog", "@:build(FullIntro.repairBitmapLog())", false, true, false);
    }
    public static function repairBitmapLog():Array<Field> {
        var fields = Context.getBuildFields();
        if (!Context.defined("FLX_DEBUG")) return fields;
        for (field in fields) if (field.name == "clear") switch (field.kind) {
            case FFun(fn):
                switch (fn.expr.expr) {
                    case EBlock(expressions):
                        if (expressions.length != 2 || ExprTools.toString(expressions[0]).indexOf("entries.resize(0)") < 0
                            || ExprTools.toString(expressions[1]).indexOf("drawCanvas()") < 0)
                            Context.error("BitmapLog.clear changed; review the intro compatibility fix.", field.pos);
                        expressions.insert(1, macro index = -1);
                    default: Context.error("Unexpected BitmapLog.clear body.", field.pos);
                }
            default:
        }
        return fields;
    }
    public static function restore():Array<Field> {
        var fields = Context.getBuildFields();
        if (!Context.defined("debug")) return fields;
        for (field in fields) if (field.name == "update") switch (field.kind) {
            case FFun(fn):
                switch (fn.expr.expr) {
                    case EBlock(expressions):
                        if (expressions.length < 3 || ExprTools.toString(expressions[0]).indexOf("exitState()") < 0)
                            Context.error("Axol intro debug guard changed; review FullIntro before building.", field.pos);
                        switch (expressions[1].expr) {
                            case EReturn(null): fn.expr.expr = EBlock(expressions.slice(2));
                            default: Context.error("Unexpected Axol intro debug guard.", field.pos);
                        }
                    default: Context.error("Unexpected Axol intro update body.", field.pos);
                }
            default:
        }
        return fields;
    }
    #end
}
