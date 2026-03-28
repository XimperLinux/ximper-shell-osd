namespace XimperShellOsd {

    public static string get_volume_icon (double percent) {
        if (percent <= 0) return "audio-volume-muted-symbolic";
        if (percent <= 33) return "audio-volume-low-symbolic";
        if (percent <= 66) return "audio-volume-medium-symbolic";
        return "audio-volume-high-symbolic";
    }

    public class Application : Adw.Application {

        public ConfigManager config { get; private set; }

        private OsdWindow? osd_window;
        private OsdDBusService? dbus_service;

#if HAVE_PULSE_AUDIO
        private PulseMonitor? pulse_monitor;
#endif

        public Application () {
            Object (
                application_id: "ru.ximperlinux.shell.OSD",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void startup () {
            base.startup ();

            config = new ConfigManager ();
            config.load ();

            load_css ();
        }

        protected override bool dbus_register (DBusConnection conn, string object_path) throws Error {
            base.dbus_register (conn, object_path);
            dbus_service = new OsdDBusService (this);
            conn.register_object ("/ru/ximperlinux/shell/OSD", dbus_service);
            return true;
        }

        protected override void activate () {
            if (osd_window != null) return;

            osd_window = new OsdWindow (this);
            add_window (osd_window);

#if HAVE_PULSE_AUDIO
            if (config.monitor_volume) {
                pulse_monitor = new PulseMonitor ();
                pulse_monitor.volume_changed.connect ((percent, is_muted) => {
                    if (is_muted) {
                        osd_window.show_osd (OsdType.VOLUME_MUTE, 0, "Muted");
                    } else {
                        var icon = get_volume_icon (percent);
                        osd_window.show_osd (OsdType.VOLUME, percent / 100.0, "%d%%".printf ((int) percent), icon);
                    }
                });
                pulse_monitor.start ();
            }
#endif

            hold ();
        }

        public void show_osd_external (OsdType type, double value, string label, string? icon_name = null) {
            if (osd_window != null) {
                osd_window.show_osd (type, value, label, icon_name);
            }
        }

        protected override void shutdown () {
#if HAVE_PULSE_AUDIO
            if (pulse_monitor != null) {
                pulse_monitor.close ();
                pulse_monitor = null;
            }
#endif
            base.shutdown ();
        }

        private void load_css () {
            var css_path = find_css_path ();
            if (css_path == null) {
                warning ("Could not find CSS file!");
                return;
            }

            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_path (css_path);

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        private static string? find_css_path () {
            string[] paths = {};

            paths += Path.build_filename (
                Environment.get_user_config_dir (), "ximper-shell", "osd", "style.css"
            );

            foreach (var dir in Environment.get_system_config_dirs ()) {
                paths += Path.build_filename (dir, "ximper-shell", "osd", "style.css");
            }

            foreach (var path in paths) {
                if (FileUtils.test (path, FileTest.EXISTS)) {
                    return path;
                }
            }

            return null;
        }
    }
}
