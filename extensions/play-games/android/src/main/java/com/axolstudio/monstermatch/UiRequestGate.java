package com.axolstudio.monstermatch;

/** UI requests survive their own native consent screen, but never a Home/state change. */
final class UiRequestGate {
    private int generation;
    private boolean foreground, externalUi;
    int begin() { return ++generation; }
    int currentTicket() { return generation; }
    void cancel() { generation++; }
    void resume() { foreground = true; }
    void pause() { foreground = false; if (!externalUi) cancel(); }
    void reset() { cancel(); foreground = externalUi = false; }
    boolean isForeground() { return foreground; }
    boolean ownsNativeUi() { return externalUi; }
    boolean canPresent(int ticket) { return foreground && generation == ticket; }
    void leaveForNativeUi() { externalUi = true; }
    void returnFromNativeUi() { externalUi = false; }
}
