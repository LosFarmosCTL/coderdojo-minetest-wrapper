-- init.lua

-- Ermittle den Mod-Namen dynamisch. Wenn der Ordner "coderdojo" heißt,
-- ist 'modname' jetzt "coderdojo".
local modname = minetest.get_current_modname() -- Dies sollte jetzt "coderdojo" sein
local modpath = minetest.get_modpath(modname)  -- Dies ist der korrekte Pfad zu deinem Mod-Ordner

-- Lade den Wrapper
dofile(modpath .. '/wrapper.lua')

-- Lade die Hauptmod-Logik
dofile(modpath .. '/mod.lua')

-- Funktion, um mod.lua neu zu laden (mit Fehler-Pufferung)
local function load_mod()
    local ok, err = pcall(dofile, modpath .. "/mod.lua")
    if not ok then
        minetest.log("error", "[reload_mod] Fehler in mod.lua: " .. tostring(err))
    end
end

-- Beim Mod-Start einmal mod.lua laden
load_mod()

-- Chat-Befehl /reload registrieren
minetest.register_chatcommand("reload", {
    description = "Lädt mod.lua neu (Live-Reload).",
    privs = { server = true }, -- Privileg "server" nötig
    func = function(name, param)
        load_mod()
        return true, "mod.lua neu geladen."
    end,
})



