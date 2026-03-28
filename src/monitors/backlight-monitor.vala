namespace XimperShellOsd {

    public class BacklightMonitor : Object {

        private string path_current;
        private string path_max;
        private File fd;
        private FileMonitor? monitor;
        private int max_value;
        private int last_percent = -1;

        public signal void brightness_changed (int percent);

        public BacklightMonitor (string device) {
            path_current = Path.build_filename ("/sys", "class", "backlight", device, "brightness");
            path_max = Path.build_filename ("/sys", "class", "backlight", device, "max_brightness");
            fd = File.new_for_path (path_current);
        }

        public bool start () {
            if (!fd.query_exists ()) {
                warning ("Backlight device not found: %s", path_current);
                return false;
            }

            read_max ();
            read_brightness_silent ();

            try {
                monitor = fd.monitor (FileMonitorFlags.NONE, null);
                monitor.changed.connect (() => read_brightness ());
            } catch (Error e) {
                warning ("Failed to monitor backlight: %s", e.message);
                return false;
            }

            return true;
        }

        public void close () {
            if (monitor != null) {
                monitor.cancel ();
                monitor = null;
            }
        }

        private void read_max () {
            try {
                var dis = new DataInputStream (File.new_for_path (path_max).read (null));
                max_value = int.parse (dis.read_line (null));
            } catch (Error e) {
                warning ("Failed to read max brightness: %s", e.message);
            }
        }

        private void read_brightness_silent () {
            try {
                var dis = new DataInputStream (fd.read (null));
                int val = int.parse (dis.read_line (null));
                last_percent = (int) Math.round (val * 100.0 / max_value);
            } catch (Error e) {
                warning ("Failed to read brightness: %s", e.message);
            }
        }

        private void read_brightness () {
            try {
                var dis = new DataInputStream (fd.read (null));
                int val = int.parse (dis.read_line (null));
                int percent = (int) Math.round (val * 100.0 / max_value);

                if (percent != last_percent) {
                    last_percent = percent;
                    brightness_changed (percent);
                }
            } catch (Error e) {
                warning ("Failed to read brightness: %s", e.message);
            }
        }

        public static string? detect_device () {
            try {
                var dir = Dir.open ("/sys/class/backlight");
                string? name;
                while ((name = dir.read_name ()) != null) {
                    return name;
                }
            } catch (FileError e) {}
            return null;
        }
    }
}
