import flixel.text.FlxBitmapText;

/** Refresh line widths before fixed-width alignment in Flixel 6.1.2. */
class PixelBitmapText extends FlxBitmapText {
    #if desktop
    // Flixel 6.2 blit sizing re-enters through textWidth before the bitmap exists.
    private var processingPendingChanges=false;
    override function checkPendingChanges(useTiles:Bool=false):Void {
        if(processingPendingChanges)return;
        processingPendingChanges=true;
        try super.checkPendingChanges(useTiles) catch(e:Dynamic) {
            processingPendingChanges=false;
            throw e;
        }
        processingPendingChanges=false;
    }
    #end
    override function computeTextSize():Void {
        // Base computeTextSize only reads textWidth for auto-sized labels.
        // Fixed-width labels otherwise align using the previous line's width.
        var measuredWidth = textWidth;
        super.computeTextSize();
    }
}
