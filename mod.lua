-- mod.lua

mod.neuer_command("test", function()
    mod.chat("Hallo Welt!")
end)


--Macht einen TNT würfel um eine postition
local function tnt_cube(x, y, z, size)

     local half = math.floor(size / 2)

    local pos1= {x = x-half, y = y-half, z = z-half}
    local pos2= {x = x+half, y = y+half, z = z+half}
    mod.set_blocks("tnt:tnt_burning",pos1,pos2)
end


mod.pfeil_pos(function(pos)
    -- Testausgabe
    mod.chat(("Einschlag bei %d, %d, %d"):format(pos.x, pos.y, pos.z))
    -- und z.B. TNT-Würfel setzen
    tnt_cube(pos.x, pos.y, pos.z, 2)
end)
