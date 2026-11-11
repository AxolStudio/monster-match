package com.axolstudio.monstermatch;

/** The same small character set supported by the game's bitmap font. */
public final class InitialsText {
    public static String sanitize(String value) {
        if (value == null) return "";
        StringBuilder result = new StringBuilder(3);
        for (int i = 0; i < value.length() && result.length() < 3; i++) {
            char c = value.charAt(i);
            if (c >= 'a' && c <= 'z') c = (char)(c - 'a' + 'A');
            if ((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == ' ' || c == '!') result.append(c);
        }
        return result.toString();
    }
}
