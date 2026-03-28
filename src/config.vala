namespace XimperShellOsd {

    public class ConfigManager : Object {

        public int timeout_ms { get; set; default = 1500; }
        public int margin_bottom { get; set; default = 80; }
        public int width { get; set; default = 300; }
        public bool monitor_volume { get; set; default = true; }

        private string config_path;

        public ConfigManager () {
            config_path = Path.build_filename (
                Environment.get_user_config_dir (), "ximper-shell", "osd", "config.json"
            );
        }

        public void load () {
            if (!FileUtils.test (config_path, FileTest.EXISTS)) {
                return;
            }

            try {
                var parser = new Json.Parser ();
                parser.load_from_file (config_path);

                var root = parser.get_root ().get_object ();

                if (root.has_member ("timeout_ms"))
                    timeout_ms = (int) root.get_int_member ("timeout_ms");
                if (root.has_member ("margin_bottom"))
                    margin_bottom = (int) root.get_int_member ("margin_bottom");
                if (root.has_member ("width"))
                    width = (int) root.get_int_member ("width");
                if (root.has_member ("monitor_volume"))
                    monitor_volume = root.get_boolean_member ("monitor_volume");
            } catch (Error e) {
                warning ("Failed to load OSD config: %s", e.message);
            }
        }
    }
}
