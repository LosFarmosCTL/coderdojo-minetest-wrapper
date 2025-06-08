-- mod.lua

mod.neuer_command("test", function()
    mod.chat("Hallo Welt!")
end)


-- 1) Deinen TNT-Cube oder sonstige Logik definieren
local function tnt_cube(x, y, z, size)
    for ix = -size, size do
        for iy = -size, size do
            for iz = -size, size do
                mod.set_block("tnt:tnt_burning", { x = x + ix, y = y + iy, z = z + iz })
            end
        end
    end
end

-- 2) Hook registrieren
mod.pfeil_pos(function(pos)
    -- Testausgabe
    mod.chat(("Einschlag bei %d, %d, %d"):format(pos.x, pos.y, pos.z))
    -- und z.B. TNT-Würfel setzen
    tnt_cube(pos.x, pos.y, pos.z, 1)
end)
