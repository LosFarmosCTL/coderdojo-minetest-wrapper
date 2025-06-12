mod = {}

-----------------------------------
-------------- Chat ---------------
-----------------------------------

function mod.chat(message)
  core.chat_send_all(message)
end

function mod.neuer_befehl(name, callback)
  core.register_chatcommand(name, {
    func = function(_, param)
      local answer = callback(param)
      if answer then
        return true, answer
      end

      return true
    end,
  })
end

-----------------------------------
---------- World editing ----------
-----------------------------------

function mod.get_block(position)
  return core.get_node(position)
end

function mod.set_block(name, position)
  core.set_node(position, { name = name })
end

function mod.quader(name, position, position2)
  for ix = position.x, position2.x do
    for iy = position.y, position2.y do
      for iz = position.z, position2.z do
        mod.set_block(name, { x = ix, y = iy, z = iz })
      end
    end
  end
end

function mod.wuerfel(name, position, size)
  local half = math.floor(size / 2)

  local pos1 = { x = position.x - half, y = position.y - half, z = position.z - half }
  local pos2 = { x = position.x + half, y = position.y + half, z = position.z + half }

  mod.quader(name, pos1, pos2)
end

function mod.kugel(name, position, radius)
  local radius_squared = radius * radius
  for ix = -radius, radius do
    for iy = -radius, radius do
      for iz = -radius, radius do
        if ix * ix + iy * iy + iz * iz <= radius_squared then
          mod.set_block(name, position:add { x = ix, y = iy, z = iz })
        end
      end
    end
  end
end

function mod.entferne_block(position, position2)
  if position2 then
    core.delete_area(position, position2)
  else
    core.remove_node(position)
  end
end

function mod.finde_block(position, distance, block_name)
  if type(block_name) == 'string' then
    block_name = { block_name }
  end

  return core.find_node_near(position, distance, block_name)
end

function mod.finde_bloecke(position, distance, block_name)
  if type(block_name) == 'string' then
    block_name = { block_name }
  end

  local pos1 = position:subtract { x = distance, y = distance, z = distance }
  local pos2 = position:add { x = distance, y = distance, z = distance }
  local found_nodes = core.find_nodes_in_area(pos1, pos2, block_name)

  local filtered_nodes = {}
  for _, node in ipairs(found_nodes) do
    local delta = node:subtract(position)
    if delta.x * delta.x + delta.y * delta.y + delta.z * delta.z <= distance * distance then
      table.insert(filtered_nodes, node)
    end
  end

  return filtered_nodes
end

-----------------------------------
------- Spieler und Physik --------
-----------------------------------

function mod.spieler()
  return core.get_player_by_name 'singleplayer'
end

function mod.setze_schwerkraft(gravity)
  local player = core.get_player_by_name 'singleplayer'
  if not player then
    return
  end

  player:set_physics_override {
    gravity = gravity,
  }
end

function mod.setze_sprungkraft(jump_strength)
  local player = core.get_player_by_name 'singleplayer'
  if not player then
    return
  end

  player:set_physics_override {
    jump = jump_strength,
  }
end

function mod.setze_geschwindigkeit(speed)
  local player = core.get_player_by_name 'singleplayer'
  if not player then
    return
  end

  player:set_physics_override {
    speed = speed,
  }
end

-----------------------------------
------ Neue Items und Blöcke ------
-----------------------------------

function mod.neues_item(name, picture, callbacks)
  local item_id = 'coderdojo:' .. name:lower():gsub(' ', '_')
  local opts = {
    description = name,
    inventory_image = picture,
  }

  if callbacks and callbacks.platzieren then
    opts.on_place = function(itemstack, placer, pointed_thing)
      if pointed_thing.type ~= 'node' then
        return itemstack
      end

      local remove_item = callbacks.platzieren(pointed_thing.above, placer)
      if remove_item then
        itemstack:take_item()
      end

      return itemstack
    end
  end

  if callbacks and callbacks.linksklick then
    opts.on_use = function(itemstack, user, pointed_thing)
      if pointed_thing.type ~= 'node' then
        return itemstack
      end

      callbacks.linksklick(pointed_thing.under, user)

      return itemstack
    end
  end

  if callbacks and callbacks.rechtsklick then
    opts.on_secondary_use = function(itemstack, user, _)
      callbacks.rechtsklick(user)

      return itemstack
    end
  end

  core.register_craftitem(item_id, opts)
end

function mod.neuer_block(name, texture, callbacks, one_sided_texture)
  local block_id = 'coderdojo:' .. name:lower():gsub(' ', '_')

  local opts = {
    description = name,
    tiles = {
      texture .. '^[sheet:6x1:1,0]', -- Top
      texture .. '^[sheet:6x1:0,0]', -- Bottom
      texture .. '^[sheet:6x1:4,0]', -- Right
      texture .. '^[sheet:6x1:5,0]', -- Left
      texture .. '^[sheet:6x1:2,0]', -- Back
      texture .. '^[sheet:6x1:3,0]', -- Front
    },
    paramtype2 = 'facedir',
    on_place = core.rotate_node,
    groups = { cracky = 3 },
  }

  if callbacks and callbacks.rechtsklick then
    opts.on_rightclick = function(pos, _, clicker, itemstack, pointed_thing)
      if pointed_thing == nil then
        return
      end

      callbacks.rechtsklick(pos, clicker, itemstack:get_name())
    end
  end

  if callbacks and callbacks.linksklick then
    opts.on_punch = function(pos, _, puncher, pointed_thing)
      if pointed_thing == nil then
        return
      end

      callbacks.linksklick(pos, puncher)
    end
  end

  if callbacks and callbacks.abbauen then
    opts.on_dig = function(pos, node, digger)
      callbacks.abbauen(pos, digger)
      core.node_dig(pos, node, digger)
    end
  end

  if one_sided_texture then
    opts.tiles = { texture }
  end

  core.register_node(block_id, opts)
end

-----------------------------------
------------ XBows API ------------
-----------------------------------

function mod.pfeil(callback)
  if not XBows or type(XBows.registered_arrows) ~= 'table' then
    core.log('warning', '[coderdojo] XBows nicht gefunden – pfeil_pos deaktiviert.')
    return
  end

  for _, arrow_def in pairs(XBows.registered_arrows) do
    local old_hit = arrow_def.custom.on_hit_node

    arrow_def.custom.on_hit_node = function(selfObj, pointed_thing)
      if pointed_thing.under then
        callback(pointed_thing.under)
      end
      if old_hit then
        old_hit(selfObj, pointed_thing)
      end
    end
  end
end

------------------------------------
---------- Global Timer ------------
------------------------------------

function mod.timer(interval, callback)
  if type(interval) ~= 'number' or interval <= 0 then
    core.log('error', '[coderdojo] Ungültiges Intervall für mod.timer: ' .. tostring(interval))
    return
  end

  local time_elapsed = 0
  core.register_globalstep(function(deltatime)
    time_elapsed = time_elapsed + deltatime

    if time_elapsed >= interval then
      callback()
      time_elapsed = 0
    end
  end)
end
