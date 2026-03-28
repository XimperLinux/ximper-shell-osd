# ximper-shell-osd

On-screen display daemon.

A component of the Ximper Shell.

Displays volume and brightness OSD overlays on Wayland. Built with Vala, GTK4, libadwaita, gtk4-layer-shell.

## Build

```sh
meson setup _build
ninja -C _build
./_build/src/ximper-shell-osd
```

### Build options

| Option        | Default | Description                              |
| ------------- | ------- | ---------------------------------------- |
| `pulse-audio` | `true`  | Monitor PulseAudio volume changes        |
| `ddc`         | `true`  | Monitor DDC/CI brightness via libddcutil |

```sh
meson setup _build -Dddc=false
```

## Config

`~/.config/ximper-shell/osd/config.json`

```json
{
  "timeout_ms": 1500,
  "margin_bottom": 80,
  "width": 300,
  "monitor_volume": true,
  "monitor_brightness": true,
  "monitor_ddc": true,
  "ddc_poll_interval_sec": 5
}
```

| Key                     | Type | Default | Description                       |
| ----------------------- | ---- | ------- | --------------------------------- |
| `timeout_ms`            | int  | `1500`  | OSD display duration in ms        |
| `margin_bottom`         | int  | `80`    | Bottom margin in pixels           |
| `width`                 | int  | `300`   | OSD window width in pixels        |
| `monitor_volume`        | bool | `true`  | Monitor PulseAudio volume changes |
| `monitor_brightness`    | bool | `true`  | Monitor sysfs backlight changes   |
| `monitor_ddc`           | bool | `true`  | Monitor DDC/CI brightness changes |
| `ddc_poll_interval_sec` | int  | `5`     | DDC polling interval in seconds   |

All fields are optional — defaults are used when config is absent.

## D-Bus

`ru.ximperlinux.shell.OSD` at `/ru/ximperlinux/shell/OSD`:
- `ShowVolumeOsd(double percent, bool muted)`
- `ShowBrightnessOsd(double percent)`

## CSS

Default style is installed to `/etc/xdg/ximper-shell/osd/style.css`.
User override: `~/.config/ximper-shell/osd/style.css`.

## License

GPL-3.0
