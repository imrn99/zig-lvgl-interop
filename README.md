# zig-lvgl-interop

This repository contains the basic setup required to call the LVGL library from Zig. The code given as example is
a port of [one of LVGL's examples](https://docs.lvgl.io/master/examples.html#a-button-with-a-label-and-react-on-click-event).

I believe that providing an "example" that cannot be copypasted into existence should be considered a criminal offense, so here I am.

## Note on `lv_conf.h`

LVGL is configured to use the SDL2 backend. The configuration file present is a copy of the template provided, with two changes:

- Under the `Drivers` section, the SDL2 flag is enabled.
- Logging is set at `TRACE` level, with some log categories disabled.

It is also possible to configure LVGL through the Zig build script, using `defineCMacro`. In that case, know that the `lv_conf.h` takes
priority, so you need to comment out the flags you want to configure via Zig from it.

## LICENSE

Licensed under the [GLWTS](LICENSE) Public License.

Good luck and Godspeed.
