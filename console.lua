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

local console = { _commands = {}, _datastore = radiant.create_datastore() }

-- The currently selected entity
local SELECTED
local USAGE -- function that can be called in case the command was used wrongly
local _L = {
  Point2 = _radiant.csg.Point2,
  Point3 = _radiant.csg.Point3,
  Cube3 = _radiant.csg.Cube3,
  Region3 = _radiant.csg.Region3
} -- local environment that new variables are inserted into

-- Scopes a function so they gain access to SELECTED. This is really evil. Kinda.
-- (it's also not working with lua5.2 I think?)
local set_scope
local last_usage_text -- last string to be used for usage()

do
	local function create_env(old_env)
		local ENV = {}
		
		function ENV:__index(key)
			-- Because of its nature, "SELECTED" and "USAGE" are always available
			-- and are not meant to be overwritten/changed by console commands
			if key == 'SELECTED' then
				return SELECTED
			elseif key == 'USAGE' then
				return USAGE
			elseif key == '_L' then
				return _L
			else
				-- Last attempt; prefer local values
				local val = rawget(_L, key)
				if val ~= nil then
					return val
				elseif old_env == _G then
          val = rawget(old_env, key)
          -- Make errors more obvious. TODO: Only do this if strict lua is active?
          if val == nil then
            error("variable '" .. key .. "' is not declared", 2)
          end
        end
        
        return old_env[key]
			end
		end
		
		function ENV:__newindex(key, value)
			if key == 'SELECTED' then
				SELECTED = value
			-- Functions that are already defined globally may be overwritten
			elseif rawget(old_env, key) == nil then
				_L[key] = value
			else
				old_env[key] = value
			end
		end
		
		ENV = setmetatable({}, ENV)
		
		return ENV
	end
	
	local G_ENV = create_env(_G)
	
	-- Scopes a function to allow it access to SELECTED and other nasty bits I have yet to add
	function set_scope(func)
		local old_env = getfenv(func)
		if old_env == _G then
			return setfenv(func, G_ENV)
		else
			return setfenv(func, create_env(old_env))
		end
	end
	
  console.set_function_scope = set_scope
  
	function USAGE(additional_text)
		error((additional_text and additional_text .. ' ' or '') .. last_usage_text, 2)
	end
end

local function update_command_list()
	local t = {}
	for cmd, data in pairs(console._commands) do
		table.insert(t, { name = cmd, endpoint = radiant.is_server and 'server' or 'client', plain_allowed = data.plain_allowed })
	end
	console._datastore:set_data({ commands = t })
end

-- Adds one or multiple commands called `names' (or elements of `names') that point towards `callback'.
-- lua functions will most likely override same-named JS functions. It's possible to name your lua functions with
-- special characters, but whitespace is not allowed, neither are '@' at the beginning.
--
-- Note that `callback` is a function receiving the following parameters:
-- * cmdName: Name of the cmd, identical with what it was called (and one of the registered names)
-- * args: List of arguments. This can be either parsed (if called with "name") or the raw, space-splitted arguments (if called with "@name")
-- * arg_string: The raw string after the command as it was entered by the user. Useful for eval, naming and the like.
-- * response: The response object from the call handler in case you wish to manually resolve/reject the answer. Note that as of current, this has no observable effect on the console.
-- The return value of `callback` is returned to the console and displayed as JSON. Errors are caught by jelly_console and displayed accordingly.
-- `callback` will be put into a different environment which allows it access to console-exclusive functions and variables:
-- * SELECTED: last selected entity using the 'select' command
function console.add_command(names, callback, usage_text)
	if type(names) == 'string' then
		names = { names }
	end
	
	for _, name in pairs(names) do
		if not name or name:find(' ') then
			error('Invalid command name ' .. tostring(name))
		end
		
		local plain_allowed
		if name:sub(1, 1) == '@' then
			name, plain_allowed = name:sub(2), true
		end
		
		console._commands[name] = { call = set_scope(callback), usage_text = usage_text, plain_allowed = plain_allowed }
	end
	
	update_command_list()
end

-- Returns the environment that this part of the lua environment uses.
function console.get_environment()
  return _L
end

function console._dispatch(session, response, name, args, arg_str)
	local command = console._commands[name]
	if not command then
		response:reject('Command not found')
		return
	end
	
	last_usage_text = command.usage_text or 'Invalid use of ' .. name .. ' (and the author hasn\'t specified how to properly use it)'
	
	local ret = { pcall(command.call, name, args, arg_str, response) }
	local status = table.remove(ret, 1)
	if not status then
		-- Sadly, we cannot just return the string - the data binding seems to 
		-- transform it into { result: str }
		response:reject({ error = 'Executing command failed: ' .. ret[1] })
		return
	end
	
	return unpack(ret)
end

function console._set_selected(entity)
	SELECTED = entity
end

return console