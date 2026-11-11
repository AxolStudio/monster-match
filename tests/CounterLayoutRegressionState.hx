/** Checks the real counter's outlined bounds against the adjacent zone title. */
class CounterLayoutRegressionState extends PlayState {
    override public function create():Void {
        Globals.initGame();
        super.create();
        heroCounter.alpha = 1;
        var bottom = heroCounter.y + heroCounter.height + heroCounter.borderSize;
        var result = bottom < envTitle.y ? "PASS" : "FAIL: counter bottom " + bottom + " overlaps title at " + envTitle.y;
        trace(result);
        #if html5
        js.Browser.document.body.setAttribute("data-counter-test", result);
        #end
    }
}
