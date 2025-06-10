mod.neuer_command('test', function()
  mod.chat 'Hallo Welt!'
end)

local function tnt_cube(x, y, z, size)
  local half = math.floor(size / 2)

  local pos1 = { x = x - half, y = y - half, z = z - half }
  local pos2 = { x = x + half, y = y + half, z = z + half }
  mod.set_blocks('tnt:tnt_burning', pos1, pos2)
end

mod.pfeil_pos(function(pos)
  mod.chat(('Einschlag bei %d, %d, %d'):format(pos.x, pos.y, pos.z))

  tnt_cube(pos.x, pos.y, pos.z, 2)
end)
