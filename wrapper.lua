mod = {}

-----------------------------------
-------------- Chat ---------------
-----------------------------------

function mod.chat(message)
  core.chat_send_all(message)
end

function mod.neuer_command(name, callback)
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
