using PulseAudio;

namespace XimperShellOsd {

    public class PulseMonitor : Object {
        private Context? context;
        private GLibMainLoop mainloop;
        private bool quitting = false;

        private string? default_sink_name;
        private double last_volume = -1;
        private bool last_muted = false;

        public signal void volume_changed (double percent, bool is_muted);

        construct {
            mainloop = new GLibMainLoop ();
        }

        public void start () {
            connect_context ();
        }

        public void close () {
            quitting = true;
            if (context != null) {
                context.disconnect ();
                context = null;
            }
        }

        ~PulseMonitor () {
            close ();
        }

        private void connect_context () {
            var ctx = new Context (mainloop.get_api (), null);
            ctx.set_state_callback ((ctx) => {
                switch (ctx.get_state ()) {
                    case Context.State.READY:
                        ctx.set_subscribe_callback (on_subscription);
                        ctx.subscribe (
                            Context.SubscriptionMask.SINK |
                            Context.SubscriptionMask.SERVER
                        );
                        ctx.get_server_info (on_server_info);
                        break;
                    case Context.State.TERMINATED:
                    case Context.State.FAILED:
                        if (quitting) {
                            quitting = false;
                            break;
                        }
                        warning ("PulseAudio connection lost. Retrying...");
                        connect_context ();
                        break;
                    default:
                        break;
                }
            });

            if (ctx.connect (null, Context.Flags.NOFAIL, null) < 0) {
                warning ("pa_context_connect() failed: %s",
                    PulseAudio.strerror (ctx.errno ()));
            }
            this.context = ctx;
        }

        private void on_subscription (Context ctx,
                                       Context.SubscriptionEventType t,
                                       uint32 index) {
            var type = t & Context.SubscriptionEventType.FACILITY_MASK;
            var event = t & Context.SubscriptionEventType.TYPE_MASK;

            switch (type) {
                case Context.SubscriptionEventType.SINK:
                    if (event == Context.SubscriptionEventType.NEW ||
                        event == Context.SubscriptionEventType.CHANGE) {
                        ctx.get_sink_info_by_index (index, on_sink_info);
                    }
                    break;
                case Context.SubscriptionEventType.SERVER:
                    ctx.get_server_info (on_server_info);
                    break;
                default:
                    break;
            }
        }

        private void on_server_info (Context ctx, ServerInfo? info) {
            if (info == null) return;
            default_sink_name = info.default_sink_name;
            ctx.get_sink_info_list (on_sink_info);
        }

        private void on_sink_info (Context ctx, SinkInfo? info, int eol) {
            if (info == null || eol != 0) return;
            if (info.name != default_sink_name) return;

            bool is_muted = info.mute == 1;
            double volume = volume_to_double (info.volume.max ());

            if (volume != last_volume || is_muted != last_muted) {
                last_volume = volume;
                last_muted = is_muted;
                volume_changed (volume, is_muted);
            }
        }

        private static double volume_to_double (PulseAudio.Volume vol) {
            double tmp = (double) (vol - PulseAudio.Volume.MUTED);
            return 100 * tmp / (double) (PulseAudio.Volume.NORM - PulseAudio.Volume.MUTED);
        }
    }
}
