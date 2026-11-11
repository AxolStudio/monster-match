import flixel.text.FlxBitmapText;

/** Refresh line widths before fixed-width alignment in Flixel 6.1.2. */
class PixelBitmapText extends FlxBitmapText {
    override function computeTextSize():Void {
        // Base computeTextSize only reads textWidth for auto-sized labels.
        // Fixed-width labels otherwise align using the previous line's width.
        var measuredWidth = textWidth;
        super.computeTextSize();
    }
}
