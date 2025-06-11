## Example Usage:

```lua
function platziere_tnt(position)
  mod.set_block('tnt:tnt_burning', position)
end

function ersetze_ofen()
  local position = mod.spieler():get_pos()
  local bloecke = mod.finde_bloecke(position, 10, 'coderdojo:eisenofen')

  for _, block in ipairs(bloecke) do
    mod.set_block('tnt:tnt_burning', block)
  end
end

mod.neues_item('Zauberstab', 'zauberstab.png', { platzieren = platziere_tnt, rechtsklick = ersetze_ofen })

mod.neuer_block('Eisenofen', 'eisenofen.png', {
  rechtsklick = function(pos, clicker, item)
    mod.chat('Eisenofen at ' .. core.pos_to_string(pos) .. ' was clicked by ' .. clicker:get_player_name() .. item)
  end,
  linksklick = function()
    mod.chat 'Reactor was punched'
  end,
  abbauen = function()
    mod.chat 'Reactor was mined'
  end,
})

mod.neuer_befehl('boost', function(param)
  mod.setze_geschwindigkeit(10)
  mod.setze_sprungkraft(5)
  mod.setze_schwerkraft(0.5)

  return 'Test command executed with parameter: ' .. param
end)

mod.pfeil(function(position)
  mod.kugel('tnt:tnt', position, 10)
end)
```
