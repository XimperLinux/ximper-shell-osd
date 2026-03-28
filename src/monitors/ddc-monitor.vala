namespace XimperShellOsd {

    public class DdcMonitor : Object {

        private void* handle = null;
        private uint poll_source = 0;
        private int last_percent = -1;
        private int poll_interval;

        private static bool lib_initialized = false;

        public signal void brightness_changed (int percent);

        public DdcMonitor (int poll_interval_sec = 5) {
            this.poll_interval = poll_interval_sec;
        }

        public bool start () {
            if (!init_library ()) return false;
            if (!open_display ()) return false;

            read_brightness_silent ();
            poll_source = Timeout.add_seconds (poll_interval, () => {
                read_brightness ();
                return Source.CONTINUE;
            });

            return true;
        }

        public void close () {
            if (poll_source != 0) {
                Source.remove (poll_source);
                poll_source = 0;
            }
        }

        ~DdcMonitor () {
            close ();
            if (handle != null) {
                Ddcutil.close_display (handle);
                handle = null;
            }
        }

        private static bool init_library () {
            if (lib_initialized) return true;

            string[]? msgs;
            int rc = Ddcutil.init2 (
                null,
                Ddcutil.SyslogLevel.NEVER,
                Ddcutil.InitOptions.DISABLE_CONFIG_FILE,
                out msgs);

            if (rc != 0) {
                warning ("ddcutil init failed: %d", rc);
                return false;
            }
            lib_initialized = true;
            return true;
        }

        private bool open_display () {
            Ddcutil.DisplayInfoList? dlist;
            int rc = Ddcutil.get_display_info_list2 (false, out dlist);
            if (rc != 0 || dlist == null || dlist.ct == 0) {
                warning ("No DDC displays found");
                return false;
            }

            void* dh;
            rc = Ddcutil.open_display2 (dlist.info[0].dref, true, out dh);
            if (rc != 0) {
                warning ("Failed to open DDC display: %d", rc);
                return false;
            }
            handle = dh;
            return true;
        }

        private void read_brightness_silent () {
            if (handle == null) return;

            Ddcutil.NonTableVcpValue val;
            int rc = Ddcutil.get_non_table_vcp_value (handle, 0x10, out val);
            if (rc != 0) return;

            int current = (val.sh << 8) | val.sl;
            int max = (val.mh << 8) | val.ml;
            if (max > 0) {
                last_percent = (int) Math.round (current * 100.0 / max);
            }
        }

        private void read_brightness () {
            if (handle == null) return;

            Ddcutil.NonTableVcpValue val;
            int rc = Ddcutil.get_non_table_vcp_value (handle, 0x10, out val);
            if (rc != 0) return;

            int current = (val.sh << 8) | val.sl;
            int max = (val.mh << 8) | val.ml;
            if (max == 0) return;

            int percent = (int) Math.round (current * 100.0 / max);
            if (percent != last_percent) {
                last_percent = percent;
                brightness_changed (percent);
            }
        }
    }
}
