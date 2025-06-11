local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

dofile(modpath .. '/wrapper.lua')
dofile(modpath .. '/mod.lua')

local function load_mod()
  local ok, err = pcall(dofile, modpath .. '/mod.lua')
  if not ok then
    core.log('error', '[reload_mod] Fehler in mod.lua: ' .. tostring(err))
  end
end

load_mod()

core.register_chatcommand('reload', {
  description = 'Lädt mod.lua neu (Live-Reload).',
  privs = { server = true },
  func = function(_, _)
    load_mod()
    return true, 'mod.lua neu geladen.'
  end,
})
