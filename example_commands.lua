local console = radiant.mods.require('jelly_console.console')

-- Adds a new command which just prints what it receives
console.add_command(
	'@example_echo',
	function(
		name, -- name of the command the user used to call this command
		args,  -- the arguments as table. If the function was called as @name (which can be figured out by looking at `name`), this is simply whitespace separated. Otherwise, it's grouped as defined by Jelly.Console+
		arg_str, -- the complete argument string as passed by the user. Useful when you won't need more than one parameter or require text input
		response -- the response object from the console call. This can be used to reject/resolve. Normally, returning a value results in a resolve returning these values, whereas an error results in a reject with the error message
	)
	
		-- Print all relevant things
		print(name, args, arg_str)
		
		-- Return them too
		-- You're free to return whatever you want. What you return here is displayed to the user in the console, however, so you might want to specially format this.
		return { status = 'Success', name = name, args = args, arg_str = arg_str }
	end,
	'Usage: example_echo ...'
)

-- Returns the longest parameter. This function will not accept the simple mode (by prefixing the command with @).
console.add_command('get_longest_argument', function(name, args)
	local str, length = nil, 0
	for k, v in pairs(args) do
		if #v > length then
			str, length = v, #v
		end
	end
	
	return { status = (str and 'Success' or 'Failure'), longest = str, length = length }
end, 'Usage: get_longest_argument ...')

-- Shows how to use SELECTED and USAGE
console.add_command('biggify', function(name, args)
	-- Make sure that args[1] is the entity
	if not radiant.check.is_entity(args[1]) then
		-- If no entity was passed, check if there was a SELECTED one
		if not radiant.check.is_entity(SELECTED) then
			USAGE('No entity selected')
		end
		
		-- the SELECTED entity becomes args[1]
		table.insert(args, 1, SELECTED)
	end
	
	-- Get the entity and the size
	local ent, size = args[1], args[2]
	
	-- Determine size by the argument given
	if size == 'titan' then
		size = 1
	elseif size == 'tiny' then
		size = 0.01
	else
		-- Throw an error, showing the usage of the function
		USAGE('size must be either titan or tiny!')
	end
	
	ent:add_component('render_info'):set_scale(size)
end, 'Usage: biggify [entity] (titan|tiny)')

return {}