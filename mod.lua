mod.neuer_befehl('hallo', function()
  mod.chat 'Hallo, Welt!'
end)

mod.neuer_befehl('baum', function()
  mod.baum(mod.spieler_pos(), 'apfel')
end)

mod.neues_item('Feuerstab', 'zauberstab_feuer.png', {
  rechtsklick = function()
    mod.schiesse_projektil('server_favorite.png', function(pos)
      mod.setze_block('tnt:tnt_burning', pos)
    end)
  end,
  platzieren = function(pos)
    mod.setze_block('fire:permanent_flame', pos)
  end,
})

mod.neues_item('Baumstab', 'zauberstab_erde.png', {
  platzieren = function(pos)
    mod.baum(pos, 'dschungel')
  end,
})

mod.neues_item('Diamandfinder', 'karte.png', {
  platzieren = function(pos)
    local diamonds = mod.finde_bloecke(pos, 10, 'default:stone_with_diamond')
    if #diamonds > 0 then
      mod.chat('Diamanten gefunden: ' .. #diamonds)
      for diamond in each(diamonds) do
        mod.chat('Diamant bei: ' .. core.pos_to_string(diamond))
      end
    else
      mod.chat 'Keine Diamanten in der Nähe gefunden.'
    end
  end,
})

mod.neuer_block('Teleporter', 'teleporter_block.png')

local stored_teleporter = nil
mod.neues_item('Tragbarer Teleporter', 'teleporter.png', {
  platzieren = function(pos, block_pos)
    local block = mod.lese_block(block_pos)
    if block == 'coderdojo:teleporter' then
      stored_teleporter = pos
      mod.chat('Teleporter gespeichert bei: ' .. core.pos_to_string(pos))
    else
      mod.chat 'Das ist kein Teleporter!'
    end
  end,
  rechtsklick = function()
    if stored_teleporter then
      mod.chat('Du teleportierst dich zu: ' .. core.pos_to_string(stored_teleporter))
      mod.teleportiere_spieler(stored_teleporter)
    else
      mod.chat 'Kein Teleporter gespeichert!'
    end
  end,
})
