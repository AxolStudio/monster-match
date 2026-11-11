package com.axolstudio.monstermatch;

public final class InitialsTextTest {
    private static void expect(String input, String expected) {
        String actual = InitialsText.sanitize(input);
        if (!expected.equals(actual)) throw new AssertionError(input + " => " + actual + "; expected " + expected);
    }
    public static void main(String[] args) {
        expect("tim", "TIM");
        expect("ABCDE", "ABC");
        expect("a@b#c", "ABC");
        expect("7! ", "7! ");
        expect("", "");
        expect(null, "");
        expect("\ud83d\ude00aéZ", "AZ");
        expect("ßab", "AB");
        System.out.println("Initials normalization tests passed");
    }
}
