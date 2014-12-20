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

-- @foo specifies that this command may be executed as plain one, therefore JS will register both "foo" and "@foo"
console.add_command({ '@eval', '@lua_run', '@lua', '@l' }, function(cmd, args, argstr)
	local func, err = loadstring(argstr, 'eval')
	if not func then
		error('Cannot compile function: ' .. err)
	end
	
	return { status = 'Success', result = setfenv(func, getfenv())() }
end, 'Usage: eval lua_string')

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
		
		return setfenv(callback, getfenv())(cmd, args, ...)
	end, usage_str)
end

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
end, 'Usage: think [entity] uri [priority]')

add_entity_command('@unthink', function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid uri.')
	end
	
	radiant.entities.unthink(args[1], args[2])
	return Success()
end, 'Usage: unthink [entity] uri. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@equip_item', function(cmd, args)
	if type(args[2]) == 'string' then
		args[2] = radiant.entities.create_entity(args[2])
	end
	
	if not is_entity(args[2]) then
		USAGE('The equipment must be an entity too.')
	end
	
	radiant.entities.equip_item(args[1], args[2])
	return Success()
end, 'Usage: equip_item [entity] (uri|entity). If an uri is specified, a new item is created. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@unequip_item', function(cmd, args)
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
	
	return t
end, 'Usage: get_equipment [entity]. If `entity` is not specified, the selected entity is used instead.')

add_entity_command('@run_effect', function(cmd, args)
	if type(args[2]) ~= 'string' then
		USAGE('Invalid uri.')
	end
	
	radiant.effects.run_effect(args[1], args[2])
	return Success()
end)

console.add_command('@run', function(cmd, args, arg_str)
  local func, err = loadfile('mods/jelly_console/run/' .. arg_str)
  
  if not func then
    error('Cannot load file: ' .. tostring(err))
  end

  -- Overload require so it works as expected
  local old_require = _L.require
  _L.require = function(name)
    local ret, err = loadfile('mods/jelly_console/run/' .. name .. '.lua')
    if not ret then
      error(err, 2)
    end
    
    return ret()
  end
  
  local status, ret = pcall(setfenv(func, getfenv()))
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