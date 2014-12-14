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

/**
	This is an overriden Stonehearth file. Parts that were changed, added or removed
	by Jelly have been marked with "START JELLY" and "END JELLY" blocks.
	Everything outside of these Jelly blocks is assumed to have been taken from
	the original game files and its copyright belongs entirely to Radiant Entertainment.
**/	

//
// START JELLY
//
var consoleKey = 192;
var consoleHeight;
var consoleLastLines = [''];

$(function() 
{
	 radiant.call('radiant:get_config', 'mods.jelly_console').done(function(o)
	 {
		  var cfg = (o || {})['mods.jelly_console'] || {};
			consoleKey = cfg['console_key'] || 192;
			consoleHeight = cfg['height'] || 200; // can this cause a racing condition? It never did in my tests, but who knows
		  // Copy the content to make sure we're updating the array properly, no matter when this might happen
		  $(cfg['last_lines'] || ['']).each(function(k, v) { consoleLastLines[k] = v; });
			
			radiant.call('radiant:set_config', 'mods.jelly_console', { console_key: consoleKey, height: consoleHeight, last_lines: consoleLastLines });
	 });
});
//
// END JELLY
//

$(document).ready(function(){
			$(top).bind('keyup', function(e){
				 //
				 // START JELLY
				 //
				 if (e.keyCode == consoleKey)  { // whatever 192 is (tilde according to the comments, but "¨!]" on my keyboard)
				 //
				 // END JELLY
				 //
						
						var view = App.debugView.getView(App.StonehearthConsoleView);

						if (view && view.$()) {
							 view.$().toggle();
							 if (view.$().is(':visible')) {
									view.focus();   
							 }
						}
				 }
			});
});

App.StonehearthConsoleView = App.View.extend({
	 templateName: 'console',

	 //
	 // START JELLY
	 //
	 inputElements : consoleLastLines,
	 inputIndex : 0,
	 lastInputString : '',
	 //
	 // END JELLY
	 //
	 
	 init: function() {
			this._super();
	 },

	 didInsertElement: function() {
			var self = this;

			this.$('#input').keypress(function(e) {        
				 if (e.which == 13) { // return
						var command = $(this).val();
						$(this).val('');
						
						//
						// START JELLY
						//
						self.inputElements.push(command);
						if (self.inputElements.length == 50)
							self.inputElements.shift();
					  // I'm sure this isn't what the config is supposed to do, but I don't want to re-route everything
					  // through lua just to get access to saved variables (which are still heavily magic to me)
					  radiant.call('radiant:set_config', 'mods.jelly_console.last_lines', self.inputElements);
						self.inputIndex = 0;
						//
						// END JELLY
						//
						
						radiant.console.run(command);
				 }
			});

			this.$().hide();
			radiant.console.setContainer(self.$('.output'));
			
			//
			// START JELLY
			//
			// Allow scrolling through input
			self.getInput().keyup(function(e)
			{
				 if (e.keyCode == 38 || e.keyCode == 40)
				 self.scrollInput(e.keyCode == 38 ? -1 : 1);
			}); // end #input.keyup
			// Set the height
			if (consoleHeight != undefined)
			   self.$('.output').height(consoleHeight);
			//
			// END JELLY
			//
	 },

	 focus: function() {
			this.$('#input')
				 .val('')
				 .focus();
	 },
	 
	 //
	 // START JELLY
	 //
	 // Who knows when this is going to change
	 getInput : function() { return this.$('#input'); },
   		
	 scrollInput : function(dt)
	 {
			// Is our current index 0? If so, save our state
			if (this.inputIndex == 0)
				 this.inputElements[0] = this.getInput().val();

			this.inputIndex = (this.inputElements.length + this.inputIndex + dt) % this.inputElements.length;
			this.getInput().val(this.inputElements[this.inputIndex]);
	 }
	 //
	 // END JELLY
	 //
});
