--[=============================================================================[
The MIT License (MIT)

Copyright (c) 2014 RepeatPan
excluding parts that were written by Radiant Entertainment

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]=============================================================================]

local console = require('console')
local is_entity = radiant.check.is_entity

local function Success(result)
	return { status = 'Success', result = result }
end

local function add_entity_command(names, callback, usage_str)
	console.add_command(names, function(cmd, args, ...)
		if not is_entity(args[1]) then
			if not is_entity(SELECTED) then
				USAGE('No entity found.')
			end
			
			table.insert(args, 1, SELECTED)
		end
		
		return console.set_function_scope(callback)(cmd, args, ...)
	end, usage_str)
end

-- @foo specifies that this command may be executed as plain one, therefore JS will register both "foo" and "@foo"
console.add_command({ '@eval', '@lua_run', '@lua', '@l' }, function(cmd, args, argstr)
	local func, err = loadstring(argstr, 'eval')
	if not func then
		error('Cannot compile function: ' .. err)
	end
	
	return Success(console.set_function_scope(func)())
end, 'Usage: eval lua_string')

add_entity_command({ '@kill_entity', '@kill' }, function(cmd, args)
	radiant.entities.kill_entity(args[1])
	return Success()
end, 'Usage: kill_entity [entity]. If `entity` was not specified, the selected entity is used instead.')

add_entity_command({ '@destroy_entity', '@destroy', '@remove_entity', '@remove' }, function(cmd, args)
	radiant.entities.destroy_entity(args[1])
	return Success()
end, 'Usage: destroy_entity [entity]. If `entity` was not specified, the selected entity is used instead.')

add_entity_command('@set_attribute', function(cmd, args)
	local entity, name, value = args[1], args[2], args[3]
	
	if type(name) ~= 'string' or type(value) ~= 'string' then
		USAGE('Invalid name/value specified.')
	end
	
	radiant.entities.set_attribute(entity, name, value)
	return Success()
end, 'Usage: set_attribute [entity] attribute_name attribute_value. If `entity` was not specified, the selected entity is used instead.')

add_entity_command('@get_attribute', function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid name')
	end
	
	return Success(radiant.entities.get_attribute(args[1], args[2]))
end, 'Usage: get_attribute [entity] attribute_name. If `entity` was not specified, the selected entity is used instead.')

add_entity_command('@get_attributes', function(cmd, args)
	local t = {}
	local attr = args[1]:get_component('stonehearth:attributes')
	if not attr then
		Success({})
	end
	
	for name, data in pairs(attr._sv._attribute_data) do
		if not data.private then
			t[name] = attr:get_attribute(name)
		end
	end
	
	return Success(t)
end, 'Usage: get_attribtues [entity]. If `entity` was not specified, the selected entity is used instead.')

add_entity_command('@set_scale', function(cmd, args)
	local ent, size = args[1], tonumber(args[2])
	if not size then
		USAGE('Invalid scale.')
	end
	
	ent:add_component('render_info'):set_scale(size)
	return Success()
end, 'Usage: set_scale [entity] scale. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@get_scale', function(cmd, args)
	return Success(args[1]:add_component('render_info'):get_scale())
end, 'Usage: get_scale [entity]. If `entity` is not specified, the selected entity is used instead.')

-- Model variants *might* have whitespace?
add_entity_command('set_model_variant', function(cmd, args)
	local model = args[2]
	if type(model) ~= 'string' then
		USAGE('Invalid model.')
	end
	
	args[1]:add_component('render_info'):set_model_variant(args[2])
	return Success()
end, 'Usage: set_model_variant [entity] model. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@get_model_variant', function(cmd, args)
	return Success(args[1]:add_component('render_info'):get_model_variant())
end, 'Usage: get_model_variant [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@set_pos', function(cmd, args)
	local ent, x, y, z = args[1], tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
	
	if not x or not y or not z then
		USAGE('Invalid coordinates.')
	end
	
	radiant.entities.move_to(ent, { x = x, y = y, z = z })
	return Success()
end)

add_entity_command('@get_pos', function(cmd, args)
  return Success(args[1]:get_component('mob'):get_location())
end, 'Usage: get_pos [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@get_world_pos', function(cmd, args)
	return Success(radiant.entities.get_world_location(args[1]))
end, 'Usage: get_pos [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@add_buff', function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid buff name')
	end
	radiant.entities.add_buff(args[1], args[2])
	return Success()
end, 'Usage: add_buff [entity] buff_name. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@get_display_name', function(cmd, args)
	return Success(radiant.entities.get_display_name(args[1]))
end, 'Usage: get_display_name [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@set_display_name', function(cmd, args, arg_str)
	local ent = table.remove(args, 1)
	local name = table.concat(args, ' ')
	radiant.entities.set_display_name(ent, name)
	return Success()
end, 'Usage: set_display_name [entity] name. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@get_name', function(cmd, args)
	return Success(radiant.entities.get_name(args[1]))
end, 'Usage: get_name [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@set_name', function(cmd, args, arg_str)
	local ent = table.remove(args, 1)
	local name = table.concat(args, ' ')
	radiant.entities.set_name(ent, name)
	return Success()
end, 'Usage: set_name [entity] name. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@think', function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid uri.')
	end
	
	radiant.entities.think(args[1], args[2], tonumber(args[3]) or 0)
	return Success()
end, 'Usage: think [entity] uri [priority]. If `entity` is not specified, the selected entity is used instead.')

-- stonehearth:thought_bubble is currently broken; _thought_uri is never set so unset_thought won't work.
--~ add_entity_command('@unthink', function(cmd, args)
--~   if type(args[2]) ~= 'string' then
--~     USAGE('Invalid uri.')
--~   end
--~   
--~   args[1]:get_component('stonehearth:thought_bubble'):unset_thought(args[2])
--~   return Success()
--~ end, 'Usage: unthink [entity] uri. If `entity` is not specified, the selected entity is used instead.')

add_entity_command({ '@equip_item', '@equip' }, function(cmd, args)
	radiant.entities.equip_item(args[1], args[2])
	return Success()
end, 'Usage: equip_item [entity] (uri|entity). If an uri is specified as second parameter, a new item is created. If `entity` is not specified, the selected entity is used instead.')

add_entity_command({ '@unequip_item', '@unequip' }, function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid uri.')
	end
	
	radiant.entities.unequip_item(args[1], args[2])
	return Success()
end, 'Usage: unequip_item [entity] uri. If `entity` is not specified, the selected entity is used instead.')

add_entity_command({ '@get_equipment', '@get_equip', '@equip_get' }, function(cmd, args)
	local eq = assert(args[1]:get_component('stonehearth:equipment'), 'Entity does not have an equipment component')
	
	local t = {}
	for k, v in pairs(eq:get_all_items()) do
		t[k] = tostring(v) -- to make formatting nicer
	end
	
	return Success(t)
end, 'Usage: get_equipment [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@run_effect', function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid uri.')
	end
	
	radiant.effects.run_effect(args[1], args[2])
	return Success()
end, 'Usage: run_effect [entity] effect_uri. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@get_material', function(cmd, args)
  return Success(args[1]:add_component('render_info'):get_material())
end, 'Usage: get_material [entity].  If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@set_material', function(cmd, args)
  if type(args[2]) ~= 'string' then
    USAGE('Invalid material')
  end
  
  args[1]:add_component('render_info'):set_material(args[2])
  return Success()
end, 'Usage: set_material [entity] material_uri.  If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@turn_to', function(cmd, args)
  local degrees = tonumber(args[2])
  if not degrees then
    USAGE('Invalid number.')
  end
  
  radiant.entities.turn_to(args[1], degrees)
  return Success()
end, 'Usage: turn_to [entity] degrees. If `entity` is not specified, the selected entity is used instead.')

console.add_command('@set_game_speed', function(cmd, args, arg_str)
  local factor = tonumber(arg_str)
  if not factor then
    USAGE('Invalid speed.')
  elseif factor < 0 then
    USAGE('game_speed may not be less than 0.')
  end
  
  stonehearth.game_speed:set_game_speed(factor, true)
  return Success()
end, 'Usage: set_game_speed game_speed. `game_speed` is the factor the game should run at, with 1 being normal speed.')

-- run-related helper function
local function run_require(name)
  local ret, err = loadfile('mods/jelly_console/run/' .. name .. '.lua')
  if not ret then
    error(err, 2)
  end
  
  return console.set_function_scope(ret)()
end

console.add_command('@run', function(cmd, args, arg_str)
  local func, err = loadfile('mods/jelly_console/run/' .. arg_str)
  
  if not func then
    error('Cannot load file: ' .. tostring(err))
  end

  -- Overload require so it works as expected
  local old_require
  old_require, _L.require  = _L.require, run_require
  
  local status, ret = pcall(console.set_function_scope(func))
  
  _L.require = old_require
  if not status then
    return { status = 'Error', error = ret }
  end
  
  return Success(ret)
end)

-- Used by the console itself as a hidden command
console.add_command('~select', function(cmd, args, argstr)
	SELECTED = args[1]
  return Success(tostring(SELECTED or '(NONE)'))
end)

return console