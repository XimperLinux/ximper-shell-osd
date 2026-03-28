namespace XimperShellOsd {

    public enum OsdType {
        VOLUME,
        VOLUME_MUTE;
    }

    public class OsdContent : Gtk.Box {

        private Gtk.Image icon;
        private Gtk.ProgressBar progress;
        private Gtk.Label label;

        public OsdContent () {
            Object (
                orientation: Gtk.Orientation.HORIZONTAL,
                spacing: 10,
                halign: Gtk.Align.FILL,
                valign: Gtk.Align.CENTER,
                hexpand: true
            );

            icon = new Gtk.Image ();
            icon.pixel_size = 24;
            icon.add_css_class ("osd-icon");
            append (icon);

            progress = new Gtk.ProgressBar ();
            progress.hexpand = true;
            progress.valign = Gtk.Align.CENTER;
            progress.add_css_class ("osd-progress");
            append (progress);

            label = new Gtk.Label ("");
            label.add_css_class ("osd-label");
            label.halign = Gtk.Align.END;
            label.width_chars = 4;
            label.xalign = 1.0f;
            append (label);
        }

        public void update (OsdType type, double value, string text, string? icon_name = null) {
            if (type == OsdType.VOLUME_MUTE) {
                icon.icon_name = "audio-volume-muted-symbolic";
            } else {
                icon.icon_name = icon_name ?? "audio-volume-high-symbolic";
            }

            progress.fraction = value.clamp (0.0, 1.0);
            label.label = text;
        }
    }
}
