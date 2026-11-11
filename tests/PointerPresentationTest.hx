class PointerPresentationTest {
    static function main() {
        var mode = new PointerPresentation();
        mode.touch(1000);
        if (mode.mouse(1000) || mode.mouse(1100)) throw 'Touch synthesis re-showed pointer';
        mode.touch(1200);
        if (mode.mouse(1201)) throw 'Touch end re-showed pointer';
        if (!mode.mouse(2200)) throw 'Real mouse could not return';
        trace('Pointer presentation tests passed');
    }
}
