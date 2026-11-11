package com.axolstudio.monstermatch;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.text.InputFilter;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import org.haxe.extension.Extension;

/** A local-only initials editor. No Play Games initialization or account needed. */
public final class InitialsInput extends Extension {
    private static AlertDialog dialog;
    private static volatile String result;
    private static int generation;

    public static synchronized String takeResult() {
        String value = result;
        result = null;
        return value;
    }

    public static void open(String previous) {
        final Activity activity = mainActivity;
        result = null;
        if (activity == null || activity.isFinishing() || activity.isDestroyed()) { result = "cancel"; return; }
        activity.runOnUiThread(() -> {
            if (activity != mainActivity || activity.isFinishing() || activity.isDestroyed()) { result = "cancel"; return; }
            if (dialog != null) return;
            final int ticket = ++generation;
            EditText input = new EditText(activity) {
                @Override public void onWindowFocusChanged(boolean focused) {
                    super.onWindowFocusChanged(focused);
                    if (focused) post(() -> {
                        if (dialog != null && ticket == generation && isAttachedToWindow()) {
                            requestFocus();
                            ((InputMethodManager)activity.getSystemService(Context.INPUT_METHOD_SERVICE)).showSoftInput(this, InputMethodManager.SHOW_IMPLICIT);
                        }
                    });
                }
            };
            input.setSingleLine(true);
            input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
            input.setImeOptions(EditorInfo.IME_ACTION_DONE | EditorInfo.IME_FLAG_NO_EXTRACT_UI | EditorInfo.IME_FLAG_NO_PERSONALIZED_LEARNING);
            input.setFilters(new InputFilter[] {
                (source, start, end, dest, dstart, dend) -> {
                    String raw = source.subSequence(start, end).toString();
                    String clean = InitialsText.sanitize(raw);
                    return raw.equals(clean) ? null : clean;
                },
                new InputFilter.LengthFilter(3)
            });
            input.setText(InitialsText.sanitize(previous).trim());
            input.setHint("ABC");
            input.setContentDescription("Initials, up to three characters");
            input.setSelectAllOnFocus(true);
            int pad = (int)(20 * activity.getResources().getDisplayMetrics().density);
            AlertDialog editor = new AlertDialog.Builder(activity)
                .setTitle("Enter initials")
                .setMessage("Up to 3 letters, numbers, spaces or ! for your local score.")
                .setNegativeButton("Cancel", (d, which) -> {})
                .setPositiveButton("Save score", (d, which) -> result = "save:" + InitialsText.sanitize(input.getText().toString()))
                .create();
            editor.setView(input, pad, 0, pad, 0);
            dialog = editor;
            editor.setCanceledOnTouchOutside(false);
            editor.setOnDismissListener(d -> {
                if (ticket == generation) {
                    dialog = null;
                    if (result == null) result = "cancel";
                }
            });
            input.setOnEditorActionListener((v, action, event) -> {
                if (action == EditorInfo.IME_ACTION_DONE || (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER && event.getAction() == KeyEvent.ACTION_UP)) {
                    result = "save:" + InitialsText.sanitize(input.getText().toString());
                    editor.dismiss();
                    return true;
                }
                return false;
            });
            editor.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE | WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
            editor.show();
            input.requestFocus();
            input.selectAll();
        });
    }

    public static void close() {
        Activity activity = mainActivity;
        if (activity != null) activity.runOnUiThread(() -> {
            ++generation;
            if (dialog != null) { dialog.dismiss(); dialog = null; }
            result = null;
        });
    }

    @Override public void onDestroy() { close(); super.onDestroy(); }
}
