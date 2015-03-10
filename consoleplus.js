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

$(function() {
   if (typeof(jelly) == 'undefined')
      jelly = {};
   
	jelly.console = {};

	// Returns the length of a pattern, if found, zero otherwise
	var repetitions = function(str, pattern)
	{
			var match = str.match(pattern);
			return match != null ? match[0].length : 0;
	};

	// Returns how many times "char" is at the start of the string
	var repetitions_start = function(str, char)
	{
			return repetitions(str, '^(' + char + ')(?:\\1)*');
	};

	// Returns how many times "char" is at the end of the string
	var repetitions_end = function(str, char)
	{
			return repetitions(str, '(' + char + ')(?:\\1)*$');
	};

	// Removes all double-quoteChars from the string, replacing them with quoteChar
	var unquote = function(str, quoteChar)
	{
			return str.replace(new RegExp(quoteChar + quoteChar, 'g'), quoteChar);
	};

	/**
	* jelly.console.parse_parameters(Array args)
	*
	* Parses a string to group parameters where appropriate.
	* RULES:
	* - Quotation chars are " and '. 
	*
	* - Arguments are called "long strings" when they contain whitespaces and start and end with the same type of quotation mark.
	*   The quotation marks can be freely used, as one pleases. There are no limitations.
	*   EXAMPLE: short1 short2 "long string #1" "long string #2" 'long string #3' 'long string #4'
	*		RESULT: [ "short1", "short2", "long string #1", "long string #2", "long string #3", "long string #4" ]
	*
	* - Within long strings, it's possible to use the other (i.e. unused) quotation mark.
	*	  EXAMPLE: "How's the weather, partner?" 'This is not "Sparta".'
	*		RESULT: [ "How's the weather, partner?", "This is not \"Sparta\".' ]
	*
	* - Within long strings, escaping of the quotation character is done by using it twice.
	*		EXAMPLE: 'How''s the weather, partner?' "This is not ""Sparta""."
	*
	* - Double quotations at the start or end of a parameter, long or short, will count as escaping
	*		EXAMPLE: ""Quote"" ''Unquote'' "This is not ""Sparta"""
	*		RESULT: ["\"Quote\", "\"Unquote\"", "This is not \"Sparta\""]
	*
	* In the case of "runaway strings" or other weird things, this function will throw an exception with a
	* (hopefully) useful hint as to where the error began.
	*/
	jelly.console.parse_arguments = function(args)
	{
			var protoArgs = [];
			var enclosed = false;
			var builder = "";
			var quoteChar = null;
			
			$(args).each(function(k, arg)
			{
					var length = arg.length;
					if (length == 0)
							return;
					
					// If we already have a long string running...
					if (enclosed)
					{
							// Did we try to finish the string at the start of a new word?
							// e.g. foo "bar bar bar rhabarbar "cake
							//                                ^^
							if (enclosed && repetitions_start(arg, quoteChar) % 2 == 1 && length > 1)
									throw 'Long parameter was not properly terminated; conflicting parameter begun at ' + arg;
							
							// Is this the end of the long string?
							if (repetitions_end(arg, quoteChar) % 2 == 1)
							{
									builder += ' ' + unquote(arg.substr(0, length - 1), quoteChar);
									protoArgs.push(builder);
									enclosed = false;
							}
							// Nope, just another part.
							else
									builder += ' ' + unquote(arg, quoteChar);
					}
					else if (arg == '""' || arg == "''")
							protoArgs.push('');
					// The begin of a long string: " in any odd combination
					else if (repetitions_start(arg, '["\']') % 2 == 1)
					{
							// single quotes, aka "param"
							if (repetitions_end(arg, arg.charAt(0)) % 2 == 1 && length > 1)
									protoArgs.push(unquote(arg.substr(1, length - 2), arg.charAt(0)));
							else
							{
									quoteChar = arg.charAt(0);
									enclosed = true;
									builder = unquote(arg.substr(1), quoteChar);
							}
					}
					else
							protoArgs.push(arg.replace(/^(["'])\1|(["'])\1$/g, '$1'));
			});
			
			if (enclosed)
					throw 'Long parameter was not terminated (no ending ' + quoteChar + ' found); runaway started at ' + builder;

			return protoArgs;
	};
});