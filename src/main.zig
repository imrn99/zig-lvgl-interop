const std = @import("std");

const lvgl = @cImport(@cInclude("lvgl.h"));

const WIDTH: u16 = 1024;
const HEIGHT: u16 = 600;

var count: u8 = 0;

// if clicked, increment counter & update label
// all callback functions you write will have to be marked with `callconv(.C)`
fn btn_event_cb(e: ?*lvgl.lv_event_t) callconv(.C) void {
    const code: lvgl.lv_event_code_t = lvgl.lv_event_get_code(e);
    const btn: *lvgl.lv_obj_t = @ptrCast(lvgl.lv_event_get_target(e).?);
    if (code == lvgl.LV_EVENT_CLICKED) {
        count += 1;
        const label: *lvgl.lv_obj_t = lvgl.lv_obj_get_child(btn, 0).?;
        lvgl.lv_label_set_text_fmt(label, "Button: %d", count); // use C format!
    }
}

fn run_loop(win: *lvgl.struct__lv_display_t) !void {
    _ = win;
    var idle_t: u32 = 0;
    while (true) : (idle_t = lvgl.lv_timer_handler()) {
        _ = lvgl.lv_task_handler();
        std.time.sleep(@as(u64, idle_t) * 1_000_000);
    }
}

pub fn main() !void {
    // plumbering
    lvgl.lv_init();
    defer lvgl.lv_deinit();

    // window
    const win = lvgl.lv_sdl_window_create(WIDTH, HEIGHT).?;

    // input logic
    // CALLING THIS BEFORE MAKING THE WINDOW WILL NOT WORK OUT OF THE BOX
    // LVGL LOOKS DECLARATIVE BUT IT'S NOT, THERE'S A LOT GLOBAL ACCESSES UNDER THE HOOD
    _ = lvgl.lv_sdl_mouse_create().?;

    // content
    const btn = lvgl.lv_btn_create(lvgl.lv_scr_act());
    lvgl.lv_obj_set_pos(btn, 350, 200);
    lvgl.lv_obj_set_size(btn, 324, 200);
    _ = lvgl.lv_obj_add_event_cb(btn, btn_event_cb, lvgl.LV_EVENT_CLICKED, null);

    const label = lvgl.lv_label_create(btn);
    lvgl.lv_label_set_text_fmt(label, "Button: %d", count); // use C format!
    lvgl.lv_obj_center(label);

    // run loop
    try run_loop(win);
}
