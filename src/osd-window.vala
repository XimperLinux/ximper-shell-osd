namespace XimperShellOsd {

    public class OsdWindow : Gtk.Window {

        private weak Application app;
        private OsdContent content;
        private uint hide_timeout_id = 0;
        private Adw.TimedAnimation? fade_in_anim;
        private Adw.TimedAnimation? fade_out_anim;
        private bool is_showing = false;
        private OsdType last_type;
        private double last_value = -1;
        private int64 last_show_time = 0;
        private const int64 DEDUP_WINDOW_US = 500000;

        public OsdWindow (Application app) {
            this.app = app;

            add_css_class ("osd-window");

            GtkLayerShell.init_for_window (this);
            GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);
            GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
            GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, false);
            GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, false);
            GtkLayerShell.set_margin (this, GtkLayerShell.Edge.BOTTOM, app.config.margin_bottom);
            GtkLayerShell.set_exclusive_zone (this, -1);
            GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.NONE);
            GtkLayerShell.set_namespace (this, "ximper-shell-osd");

            set_size_request (app.config.width, -1);

            content = new OsdContent ();
            set_child (content);

            set_visible (false);
            opacity = 0;
        }

        public void show_osd (OsdType type, double value, string label, string? icon_name = null) {
            int64 now = GLib.get_monotonic_time ();
            if (type == last_type && value == last_value && (now - last_show_time) < DEDUP_WINDOW_US) {
                return;
            }
            last_type = type;
            last_value = value;
            last_show_time = now;

            content.update (type, value, label, icon_name);

            cancel_hide ();

            if (!is_showing) {
                is_showing = true;
                set_visible (true);

                if (fade_out_anim != null) {
                    fade_out_anim.pause ();
                    fade_out_anim = null;
                }

                var target = new Adw.PropertyAnimationTarget (this, "opacity");
                fade_in_anim = new Adw.TimedAnimation (this, opacity, 1.0, 150, target);
                fade_in_anim.play ();
            }

            hide_timeout_id = Timeout.add (app.config.timeout_ms, () => {
                hide_timeout_id = 0;
                hide_animated ();
                return Source.REMOVE;
            });
        }

        private void hide_animated () {
            if (fade_in_anim != null) {
                fade_in_anim.pause ();
                fade_in_anim = null;
            }

            var target = new Adw.PropertyAnimationTarget (this, "opacity");
            fade_out_anim = new Adw.TimedAnimation (this, opacity, 0.0, 200, target);
            fade_out_anim.done.connect (() => {
                set_visible (false);
                is_showing = false;
                fade_out_anim = null;
            });
            fade_out_anim.play ();
        }

        private void cancel_hide () {
            if (hide_timeout_id != 0) {
                Source.remove (hide_timeout_id);
                hide_timeout_id = 0;
            }
        }
    }
}
