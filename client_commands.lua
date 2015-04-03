--[=============================================================================[
The MIT License (MIT)

Copyright (c) 2015 RepeatPan
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
local Point3 = _radiant.csg.Point3
local Cube3 = _radiant.csg.Cube3
local Region3 = _radiant.csg.Region3
local Color4 = _radiant.csg.Color4
local is_entity = radiant.check.is_entity

local function Success(result)
	return { status = 'Success', result = result }
end

-- @foo specifies that this command may be executed as plain one, therefore JS will register both "foo" and "@foo"
console.add_command({ '@eval_client', '@lua_run_cl', '@lua_cl', '@lc' }, function(cmd, args, argstr)
	local func, err = loadstring(argstr, 'eval')
	if not func then
		error('Cannot compile function: ' .. err)
	end
	
	return Success(console.set_function_scope(func)())
end, 'Usage: eval lua_string')

-- Cube stuff as visual debugging aid
local function hsv_to_rgb(h, s, v)
  local r, g, b
  
  h = h % 360
  
  local f = h * 6 - 1
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t =  v * (1 - (1 - f) * s)
  
  local h1 = h / 60
  
  if h1 < 1 then
    return v, t, p
  elseif h1 < 2 then
    return q, v, p
  elseif h1 < 3 then
    return p, v, t
  elseif h1 < 4 then
    return p, q, v
  elseif h1 < 5 then
    return t, p, v
  elseif h1 < 6 then
    return v, p, q
  end
end

local displayed_cubes = {}
local function display_cube(min, max)
  local cube = Cube3(min, max)
  
  local region = Region3()
  region:add_cube(cube)
  
  -- lo and behold the golden ratio
	-- http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
  local r, g, b = hsv_to_rgb((#displayed_cubes * 0.618033988749895 * 360 + 10) % 360, 0.8, 1)
  local node = _radiant.client.create_region_outline_node(1, region, Color4(r, g, b, 128), Color4(r, g, b, 64))
  
  table.insert(displayed_cubes, node)
  return node
end

console.add_command('@display_cube', function(cmd, args)
  local min_x, min_y, min_z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
  local max_x, max_y, max_z = tonumber(args[4]), tonumber(args[5]), tonumber(args[6])
  
  if not min_x or not min_y or not min_z or not max_x or not max_y or not max_z then
    USAGE('Invalid coordinate.')
  end
  
  display_cube(Point3(min_x, min_y, min_z), Point3(max_x, max_y, max_z))
  return Success()
end, 'Usage: display_cube min_x min_y min_z max_x max_y max_z')

console.add_command('@clear_cubes', function()
  for k, v in pairs(displayed_cubes) do
    v:destroy()
  end
  
  displayed_cubes = {}
  
  return Success()
end)

-- Add a few things to the environment
do
  local env = console.get_environment()
  env.display_cube = display_cube
end

-- Used by the console itself as a hidden command
console.add_command('~select', function(cmd, args, argstr)
	SELECTED = args[1]
  return Success(tostring(SELECTED or '(NONE)'))
end)

return console