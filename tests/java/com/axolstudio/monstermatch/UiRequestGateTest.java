package com.axolstudio.monstermatch;
public final class UiRequestGateTest {
    public static void main(String[] args) {
        UiRequestGate gate = new UiRequestGate();
        gate.resume();
        int ticket = gate.begin();
        require(gate.canPresent(ticket), "active request unavailable");
        gate.pause();
        require(!gate.canPresent(ticket), "Home allowed background UI");
        gate.resume();
        require(!gate.canPresent(ticket), "old request reopened on return");
        ticket = gate.begin();
        gate.leaveForNativeUi();
        gate.pause();
        require(!gate.canPresent(ticket), "consent allowed background UI");
        gate.returnFromNativeUi();
        gate.resume();
        require(gate.canPresent(ticket), "consent continuation was lost");
        gate.cancel();
        require(!gate.canPresent(ticket), "leaving game screen did not cancel request");
        ticket = gate.begin();
        gate.leaveForNativeUi();
        gate.pause();
        gate.cancel();
        gate.returnFromNativeUi();
        gate.resume();
        require(!gate.canPresent(ticket), "abandoned sign-in request reopened later");
        System.out.println("Platform UI lifecycle tests passed");
    }
    static void require(boolean ok, String message) { if(!ok) throw new AssertionError(message); }
}
