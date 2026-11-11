/** Restore the fixed game coordinates after the full-device intro. */
class CompactPixelScaleMode extends flixel.system.scaleModes.PixelPerfectScaleMode {
    override public function onMeasure(width:Int, height:Int):Void {
        setGlobalSize(160, 120);
        updateGameSize(width, height);
        updateDeviceSize(width, height);
        updateScaleOffset();
        updateGamePosition();
    }
}
