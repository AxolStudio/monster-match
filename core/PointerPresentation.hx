/** Suppress synthesized mouse movement immediately following touch input. */
class PointerPresentation {
    private var lastTouch:Float = Math.NEGATIVE_INFINITY;
    public function new() {}
    public function touch(now:Float):Void { lastTouch = now; }
    public function mouse(now:Float):Bool { return now - lastTouch > 750; }
}
