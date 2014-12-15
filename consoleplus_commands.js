/*=============================================================================//
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
//=============================================================================*/

var tracer; // no idea why I've kept this public in jelly - to avoid GC?

$(top).on('jelly.PostRootViewInit', function() {
	$(top).on("radiant_selection_changed.unit_frame", function (_, data) {
		radiant.call('jelly_console:server:call', '~select', [ data.selected_entity ], undefined);
	});
	
	// Calls a lua function with said arguments, parsing the arguments nicely before it does though
	var call_lua_function = function(cmdobj, fn, args)
	{
		var parsed_args;

		try
		{
			parsed_args = jelly.console.parse_arguments(args);
		}
		catch (err)
		{
			var def = jQuery.Deferred();
			def.reject('Error while parsing arguments: ' + err);
			return def;
		}
		
		return radiant.callv('jelly_console:server:call', [ fn, parsed_args, args.join(' ') ]).deferred;
	};
	
	// Calls a lua function, sending the arguments 1:1 as "unparsed" array
	var call_lua_function_plain = function(cmdobj, fn, args)
	{
		return radiant.callv('jelly_console:server:call', [ fn.substr(1), args, args.join(' ') ]).deferred;
	};
	
	// Get the data store
	radiant.call('jelly_console:server:get_datastore').done(function(o) {
	tracer = radiant.trace(o.datastore).progress(function(update)
	{
		$(update.commands).each(function (_, cmd)
		{
			if (cmd.endpoint != 'server')
			{
				console.error('NYI: client sided function calls');
				return;
			}
			
			radiant.console.register(cmd.name, {
				call : call_lua_function
			}); // end console.register
			
			if (cmd.plain_allowed)
				radiant.console.register('@' + cmd.name, {
					call: call_lua_function_plain
				}); // end radiant.console.register
		}); // end foreach command
	}); // end tracer.progress
}).fail(function(o) { console.error('trace error: ', o); }); // end radiant.call
	
	var setHeight = function(newHeight)
	{
		$('#console .output').height(newHeight);
		radiant.call('radiant:set_config', 'mods.jelly_console.height', newHeight);
	};
	
	// It makes little sense that both expand and shrink accept a new parameter
	// defining the new height - but I really don't want to introduce a "resize" command.
	radiant.console.register('expand', {
		call: function(cmdobj, fn, args)
		{
			var output = $('#console .output');
			var newHeight = args[0] || (output.height() + 50);
			if (newHeight > 500 || newHeight < 50)
				return;
			setHeight(newHeight);
		}
	});
	
	radiant.console.register('shrink', {
		call: function(cmdobj, fn, args)
		{
			var output = $('#console .output');
			var newHeight = args[0] || (output.height() - 50);
			if (newHeight < 50 || newHeight > 500)
				return;
			setHeight(newHeight);
		}
	});
	
	radiant.console.register('show_arguments', {
		call: function(cmdobj, fn, args)
		{
			var def = jQuery.Deferred();
			try
			{
				def.resolve(jelly.console.parse_arguments(args));
			}
			catch (e)
			{
				def.reject({ error: e });
				return;
			}
			
			return def;
		}
	});
	
	radiant.console.register('@show_arguments', {
		call: function(cmdobj, fn, args)
		{
			var def = jQuery.Deferred();
			def.resolve(args);
			return def;
		}
	});
	
	// Allow empty lines. Not exactly a nice solution, but a cheap one.
	radiant.console.register('', {
		call: function() {}
	});
	
	radiant.console.register('clear', {
		call: function() { $('#console .output').empty(); }
	});
}); // end jelly.PostRootViewInit