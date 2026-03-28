namespace XimperShellOsd {

    [DBus (name = "ru.ximperlinux.shell.OSD")]
    public class OsdDBusService : Object {

        private weak Application app;

        public OsdDBusService (Application app) {
            this.app = app;
        }

        public void show_volume_osd (double percent, bool muted) throws DBusError, IOError {
            if (muted) {
                app.show_osd_external (OsdType.VOLUME_MUTE, 0, "Muted");
            } else {
                app.show_osd_external (
                    OsdType.VOLUME, percent / 100.0,
                    "%d%%".printf ((int) percent),
                    get_volume_icon (percent)
                );
            }
        }

        public void show_brightness_osd (double percent) throws DBusError, IOError {
            app.show_osd_external (OsdType.BRIGHTNESS, percent / 100.0, "%d%%".printf ((int) percent));
        }
    }
}
