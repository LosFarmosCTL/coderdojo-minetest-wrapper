-- mod.lua

mod.neuer_command("test", function()
    mod.chat("Hallo Welt!")
end)


--Macht einen TNT würfel um eine postition
local function tnt_cube(x, y, z, length)
    local pos1 = { x = x, y = y, z = z }
    local pos2 = { x = x + length, y = y + length, z = z + length }
    mod.quader("tnt:tnt_burning", pos1, pos2)
end


local tntpfeil = false

mod.neuer_command("tntpfeil", function()
    if tntpfeil then
        tntpfeil = false
    else
        tntpfeil = true
    end
end)


mod.pfeil(function(pos)
    -- Testausgabe
    mod.chat(("Einschlag bei %d, %d, %d"):format(pos.x, pos.y, pos.z))
    -- und z.B. TNT-Würfel setzen
    if tntpfeil then
        tnt_cube(pos.x, pos.y, pos.z, 2)
    end
    default.grow_tree(pos.x, pos.y, pos.z, true, false)
end)


mod.neues_item("gold_Feuerstab", "gold_fire_wand.png", {
    rechtsklick = function(player)
        local pos = player:get_pos()

        if not pos then
            mod.chat("Kein Spieler gefunden!")
            return false
        end

        tnt_cube(pos.x, pos.y, pos.z, 2)
        return false
    end,

    linksklick = function(_, player)
        -- 2) Spielerposition holen
        local ppos = mod.spieler_position()
        if not ppos then
            mod.chat("Kein Spieler gefunden!")
            return false
        end

        -- 3) Blickrichtung abfragen
        local dir = player:get_look_dir()

        -- 4) Parameter: Länge der Reihe und welcher Block
        local length = 30
        local blockname = "default:wood"

        -- 5) Schleife: für jeden Schritt i
        for i = 1, length do
            -- exakte Position berechnen und ganzzahlig runden
            local x = math.floor(ppos.x + dir.x * i + 0.5)
            local y = math.floor(ppos.y + 1 + dir.y * i + 0.5) -- +1, damit es auf Kopf¬höhe spawnt
            local z = math.floor(ppos.z + dir.z * i + 0.5)
            mod.set_block(blockname, { x = x, y = y, z = z })
        end

        return false -- false = Verbrauch des Items unterbinden
    end
}

)

-- mod.lua

-- 1) Deine Logik: nur beim ersten Aufprall
local function meine_logik(start)
    return function(pos)
        -- Ignoriere, wenn wir noch in Starthöhe sind
        if pos.y == start.y + 1 then
            return
        end

        -- Frag den Block ab
        local node = mod.get_block(pos).name
        if node ~= "air" and node ~= "default:air" then
            -- Erst hier ist der „wirkliche“ Einschlag
            mod.baum(pos.x, pos.y, pos.z, "apple")
        end
    end
end

-- 2) Projektilstab mit deinem Callback
mod.neues_item("Projektilstab", "iron_earth_wand.png", {
    rechtsklick = function(player)
        local ppos = player:get_pos()
        if not ppos then
            mod.chat("Kein Spieler gefunden!")
            return false
        end

        -- Erzeuge den projektil-Callback mit Start-Y
        local cb = mod.projektil("bubble.png", 0.03, 100, meine_logik(ppos))

        -- Rufe ihn auf (Wrapper erwartet player als Parameter)
        return cb(player)
    end
})
