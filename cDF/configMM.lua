local addon = select(2,...)
if not addon.config then
    addon.config = {
        map = {
        scale = 1.15,
        border_point = {'CENTER', 0, 100},
        border_alpha = 1,
        blip_scale = 1.12,
        blip_skin = true,
        player_arrow_size = 40,
        tracking_icons = false,
        skin_button = true,
        fade_button = true,
        zonetext_font_size = 12,
        zoom_in_out = false,
        },
        times = {
            clock = true,
            calendar = true,
            clock_font_size = 11,
        },
        assets = {
            font = addon._dir..'expressway.ttf',
        }
    }
end