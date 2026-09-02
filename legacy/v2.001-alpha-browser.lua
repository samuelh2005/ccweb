--[[>
	  CC Browser 2.001 alpha, 
	  Contributed with QuickMuffin8782 and SamH - ©2020
<]]--


local version = 2.001

--{APIS}
-- GUI API

black = colors.black
white = colors.white
lightBlue = colors.lightBlue
green = colors.green
yellow = colors.yellow
blue = colors.blue
purple = colors.purple
magenta = colors.magenta
lime = colors.lime
orange = colors.orange
red = colors.red
brown = colors.brown
cyan = colors.cyan
pink = colors.pink
grey = colors.gray
gray = colors.gray
lightGray = colors.lightGray
lightGrey = colors.lightGray

-- Buttons

buttonList = {}
Buttons = {}
Buttons.__index = Buttons

function createButton( name, func )
	button = {}
	setmetatable(button,Buttons)
	button.name = name
	button.action = func
	return button
end

function Buttons:toggle( newColor,sec )

	self:draw( self.x,self.y,self.width,newColor,self.tcolor)

	if sec ~= nil then
		sleep(sec)
		self:draw( self.x,self.y,self.width,self.color,self.tcolor )
	end
end


function Buttons:draw( x,y,width,color,tcolor )

	table.insert(buttonList,{self.name,x,y,width,self.action})
	
	self.x = x
	self.y = y 
	self.width = width
	if self.tcolor == nil then
		self.color = color
	end
	self.tcolor = tcolor

	for i = 1,width do
		paintutils.drawLine(x, y + i, x + #self.name + 1, y + i, color)
	end

	term.setCursorPos(x,y + math.ceil(width/2))
	term.setTextColor(tcolor)
	term.setBackgroundColor(color)
	term.write(" "..self.name.." ")
end

function Buttons:trigger()
	buttonList[i][5]()
end

function Buttons:remove()
	for i = 1,#buttonList do
		if self.name == buttonList[i][1] then
			table.remove(buttonList,i)
		end
	end
	self = nil
end

function detect( x,y,trigger )
	for i = 1,#buttonList do
		if x >= buttonList[i][2] and x <= buttonList[i][2] + #buttonList[i][1] and y >= buttonList[i][3] and y <= buttonList[i][3] + buttonList[i][4] then
			if trigger == true then
				buttonList[i][5]()
			end 
			return buttonList[i][1]
		end
	end
end

-- Progress Bars

barList = {}
Bars = {}
Bars.__index = Bars

function createBar( name )
	bar = {}
	setmetatable(bar,Bars)
	bar.name = name
	return bar
end

function Bars:setup( x,y,length,color,pcolor,disp,dispbcolor,tcolor )
	self.x,self.y,self.length,self.color,self.pcolor,self.disp,self.dispbcolor,self.tcolor = x,y,length,color,pcolor,disp,dispbcolor,tcolor
end

function Bars:draw( x,y,length,color,pcolor,disp,dispbcolor,tcolor )
	
	if self.x == nil and x ~= nil then
		self.x,self.y,self.length,self.color,self.pcolor,self.disp,self.dispbcolor,self.tcolor = x,y,length,color,pcolor,disp,dispbcolor,tcolor
	end

	self.percent = 0
	term.setCursorPos(x,y)
	paintutils.drawLine(x,y,x+ length,y,color)
	term.setCursorPos(x,y)
	if self.percent > 0 then
		paintutils.drawLine(x,y,x + length*(self.percent/100),y,pcolor)	
	end

	
	percentString = tostring(self.percent).."%"
	if disp == true then
		term.setCursorPos(math.max(x + math.ceil(length/2) - math.ceil(#percentString/2),0) + 1,y-1)
		term.setBackgroundColor(dispbcolor)
		term.setTextColor(tcolor)
		write(percentString)
	end
end

function Bars:update( percent )
	self.percent = percent
	term.setCursorPos(self.x,self.y)
	paintutils.drawLine(self.x,self.y,self.x + self.length,self.y,self.color)
	term.setCursorPos(self.x,self.y)
	if self.percent > 0 then
		paintutils.drawLine(self.x,self.y,self.x + self.length*(self.percent/100),self.y,self.pcolor)	
	end

	
	percentString = tostring(self.percent).."%"
	if self.disp == true then
		term.setCursorPos(math.max(self.x + math.ceil(self.length/2) - math.ceil(#percentString/2),0) + 1,self.y-1)
		term.setBackgroundColor(self.dispbcolor)
		term.setTextColor(self.tcolor)
		write(percentString)
	end
end

-- Textboxs

function newTextBox(x,y,length,bcolor,tcolor)
	typed = {}
	alphabet = "abcdefghijklmnopqrstuvwxyz"

	term.setBackgroundColor(bcolor)
	paintutils.drawLine(x, y, x + length - 1, y, bcolor)
	term.setCursorPos(x, y)
	term.setTextColor(tcolor)
	term.write("_")

	typing = true
	term.setCursorPos(x,y)
	while typing do
		event,key = os.pullEvent()
		if event == "key" then
			if key >= 0 and key <= 11 then
				table.insert(typed,key)
			elseif keys.getName(key) == "enter" then
				typing = false
				return string.gsub(table.concat(typed,""),"space"," ")
			elseif keys.getName(key) == "space" then
				table.insert(typed,keys.getName(key))
			elseif keys.getName(key) == "period" then
				table.insert(typed,".")
			elseif keys.getName(key) == "comma" then
				table.insert(typed,",")
			elseif keys.getName(key) == "backspace" then
				table.remove(typed,#typed)
			else 
				key = keys.getName(key)
				if string.find(alphabet,key) ~= nil then
					table.insert(typed,key)
				end	
			end
			if #typed > length then
				table.remove(typed,#typed)
			else
				cx,cy = term.getCursorPos()
				term.setBackgroundColor(bcolor)
				paintutils.drawLine(x, y, x + length - 1, y, bcolor)
				term.setCursorPos(x,y)
				term.write(string.gsub(table.concat(typed,""),"space"," "))
				if cx < x + length then
					term.write("_")
				end
			end
		end
	end
end

-- Boxes

Boxs = {}
Boxs.__index = Boxs

function createDialogueBox( title,body,boxType )
	boxes = {}
	setmetatable(boxes,Boxs)
	boxes.title = title
	boxes.body = body
	boxes.boxType = boxType
	return boxes
end

function Boxs:draw( x,y,width,color,bcolor,tcolor )
	ret = nil
	self.width = width
	self.x = x
	self.y = y 

	if self.boxType == "yn" then                                                                      -- YN Box

		if type(self.body) ~= "table" then
			paintutils.drawLine(x, y, x + #self.body + 1, y, bcolor)
			term.setCursorPos(x,y)
			term.setTextColor(tcolor)
			write(self.title)

			self.len = #self.body

			for i = 1,width do
				paintutils.drawLine(x, y + i, x + #self.body, y + i, color)
			end

			term.setCursorPos(x + 1, y + 2)
			term.write(self.body)


			term.setCursorPos(x + 1,y + width)
			term.setTextColor(tcolor)
			term.setBackgroundColor(green)
			write(" Yes ")

			term.setCursorPos(x + len - 4,y + width)
			term.setBackgroundColor(red)
			write(" No ")

			repeat
				event,click,cx,cy = os.pullEvent("mouse_click")

				if cx >= x + 1 and cx <= x + 5 and cy == y + width then
					ret = true
				elseif cx >= x + len - 5 and cx <= x + len - 1  and cy == y + width then
					ret = false
				end
			until ret ~= nil

		else

			len = 0
			for i = 1,#self.body do
				if #self.body[i] > len then
					len = #self.body[i]
				end
			end

			paintutils.drawLine(x, y, x + len + 1, y, bcolor)
			term.setCursorPos(x,y)
			term.setTextColor(tcolor)
			write(self.title)

			for i = 1,width do
				paintutils.drawLine(x, y + i, x + len + 1, y + i, color)
			end

			for i = 1,#self.body do
				term.setCursorPos(x + (len/2 - #self.body[i]/2) + 1, y + i + 1)
				term.write(self.body[i])
			end

			term.setCursorPos(x + 1,y + width)
			term.setTextColor(tcolor)
			term.setBackgroundColor(green)
			write(" Yes ")

			term.setCursorPos(x + len - 4,y + width)
			term.setBackgroundColor(red)
			write(" No ")

			repeat
				event,click,cx,cy = os.pullEvent("mouse_click")

				if cx >= x + 1 and cx <= x + 5 and cy == y + width then
					ret = true
				elseif cx >= x + len - 5 and cx <= x + len - 1  and cy == y + width then
					ret = false
				end
			until ret ~= nil


			self.len = len
		end

	elseif self.boxType == "ok" then                                                                  -- Ok Box
		if type(self.body) ~= "table" then

			paintutils.drawLine(x, y, x + #self.body + 1, y, bcolor)
			term.setCursorPos(x,y)
			term.setTextColor(tcolor)
			write(self.title)
			self.len = #self.body

			for i = 1,width do
				paintutils.drawLine(x, y + i, x + #self.body, y + i, color)
			end

			term.setCursorPos(x + 1, y + 2)
			term.write(self.body)

			term.setCursorPos(x + (self.len/2) - 1,y + width)
			term.setTextColor(tcolor)
			term.setBackgroundColor(green)
			write(" Ok ")

			
			repeat 
				event,click,cx,cy = os.pullEvent("mouse_click")

				if cx > x + (self.len/2 - 4) and cx < x + (self.len/2) and cy == y + width then
					ret = true
				end
			until ret == true

		else
			
			len = 0
			for i = 1,#self.body do
				if #self.body[i] > len then
					len = #self.body[i]
				end
			end
			self.len = len

			paintutils.drawLine(x, y, x + len + 1, y, bcolor)
			term.setCursorPos(x,y)
			term.setTextColor(tcolor)
			write(self.title)

			for i = 1,width do
				paintutils.drawLine(x, y + i, x + len + 1, y + i, color)
			end

			for i = 1,#self.body do
				term.setCursorPos(x + (len/2 - #self.body[i]/2) + 1, y + i + 1)
				term.write(self.body[i])
			end

			term.setCursorPos(x + (self.len/2) - 1,y + width)
			term.setTextColor(tcolor)
			term.setBackgroundColor(green)
			write(" Ok ")
			
			repeat 
				event,click,cx,cy = os.pullEvent("mouse_click")

				if cx > x + (len/2 - 4) and cx < x + (len/2) and cy == y + width then
					ret = true
				end
			until ret == true
		end
	end
	return ret 
end

function Boxs:clear( color )
	paintutils.drawLine(self.x, self.y, self.x + self.len + 1, self.y, color)
	for i = 1,self.width do
		paintutils.drawLine(self.x, self.y + i, self.x + self.len + 1, self.y + i, color)
	end
end

--- An API for logging in computer craft, based of lua logging.
-- @classmod logging
-- @author Wobbo
-- @alias mt

local mt = {}
mt.__index = mt

--- The DEBUG level designates fine-grained informational events that are most useful to debug an application.
DEBUG = "DEBUG"

--- The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
INFO = "INFO"

--- The WARN level designates potentially harmful situations.
WARN = "WARN"

--- The ERROR level designates error events that still allow the application to continue running.
ERROR = "ERROR"

--- The FATAL level designates very severe error events that would lead the application to abort. 
FATAL = "FATAL"

--- A table to keep track of the order between levels. There is a field for each valid level. In order to be logged, the order of a level has to be equal to or greater than the current logging level.
-- @usage logging.order[logging.DEBUG] -- returns the order of DEBUG.
-- @field DEBUG The order of `logging.DEBUG`
-- @field INFO The order of `logging.INFO`
-- @field WARN The order of `logging.WARN`
-- @field ERROR The order of `logging.ERROR`
-- @field FATAL The order of `logging.FATAL`
order = {DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, FATAL = 5}

function mt.__gc(self) if self.file then self.file:close() end end

local function newArgs(func, file, format, level)
	local obj = setmetatable({}, mt)
	obj.func = func
	if file then
		local handle
		if not fs.exists(file) then
			handle = io.open(file, "w")
		else
			handle = io.open(file, "a")
		end
		obj.file = handle
	end
	obj.format = format or "%date %time %level %message"
	obj:setLevel(level or INFO)
	return obj
end

--- Create a new logging object. 
-- Can also be called as `logging.new{func = func, file = file, format = format}`. Either a file or a function is advised, but not obligatory. 
-- @function new
-- @constructor
-- @tparam function func The function that is called when a message is logged. This function recieves a self argument, the level that is calles with and the message that is logged.
-- @string file The file that is logged to.
-- @string format The format that is used for logging to a file. The day can be inserted by `%date`, the time by using `%time`, the level by using `%level` and the message itself by using `%message`.
-- @string level The initial level for the `logging` object. 
-- @treturn logging The new logging object. 
-- @usage logger = logging.new{func = function(level, message)
--     print(level..": "..message) 
--   end,
--   file = "usage.log", 
--   format = "%date %time Usage: %level %message"}
-- @usage logger = logging.new(function(level, message) 
--   print(message) 
--   os.queueEvent("log Usage", level, message)
-- end)
-- @usage logger = logging.new{function(self, level, message) 
--   print(level..": "..message) end,
--   level = logging.DEBUG}
function new(...)
	local t
	if type(...) == "table" then
		t = ...
	else
		t = {...}
	end
	return newArgs(t.func or t[1], t.file or t[2], t.timeFmt or t[3], t.level or t[4])
end

--- Sets the minimum level needed for a message to be logged. Default is `INFO`.
-- @string level The minimum level.
-- @usage logger:setLevel(logging.WARN)
function mt:setLevel(level)
	if order[level] then 
		self.level = level 
	else 
		error("undefinded level "..level) 
	end 
end

--- Logs a message if the specified level is higher then the loggers level.
-- This function will call the 
-- @string level The level of the message.
-- @string message The message that need to be logged. 
-- @usage logger:log(logging.INFO, "Prepared the environment")
function mt:log(level, message)
	if order[level] < order[self.level] then return end
	if self.func then
		self:func(level, message)
	end
	if self.file then
		self.file:write(prepMsg(self.format, message, os.day(), textutils.formatTime(os.time(), true), level)..'\n')
		self.file:flush()
	end
end

--- Log a message with DEBUG level.
-- @string message The message to be logged. 
-- @usage logger:debug("Found the logging API")
-- @see log
-- @see DEBUG
function mt:debug(message)
	self:log(DEBUG, message)
end


--- Log a message with INFO level.
-- @string message The message to be logged.
-- @usage logger:info("Prepared the invironment")
-- @see log
-- @see INFO
function mt:info(message)
	self:log(INFO, message)
end

--- Log a message with WARN level.
-- @string message The message to be logged.
-- @usage logger:warn("Expected integer, got string")
-- @see log
-- @see WARN
function mt:warn(message)
	self:log(WARN, message)
end

--- Log a message with ERROR level.
-- @string message The message to be logged.
-- @usage logger:error("No modem found!")
-- @see log
-- @see ERROR
function mt:error(message)
	self:log(ERROR, message)
end

--- Log a message with FATAL level.
-- @string message The message to be logged.
-- @usage logger:fatal("No fuel found to refuel. Sending distress signal and aborting.")
-- @see log
-- @see FATAL
function mt:fatal(message)
	self:log(FATAL, message)
end


--- Prepare a message using a specified pattern.
-- @constructor
-- @tparam string pattern The pattern used for the message. Defaults to `"%date %time %level %message"`. The day can be inserted by `%date`, the time by using `%time`, the level by using `%level` and the message itself by using `%message`. 
-- @string message The message that needs to be formatted. The value for `%message`
-- @number date The value for `%date`.
-- @string time The value for `%time`. This needs to be formatted beforehand. 
-- @string level The value for `%level`.
-- @treturn string The prepared message.
function prepMsg(pattern, message, date, time, level)
	local logMsg = pattern or "%date %time %level %message"
	message = string.gsub(message, "%%", "%%%%")
	logMsg = string.gsub(logMsg,"%%date", date)
	logMsg = string.gsub(logMsg, "%%time", time)
	logMsg = string.gsub(logMsg, "%%level", level)
	return string.gsub(logMsg, "%%message", message)
end

-------------------------------------------------------------------------------------
-- Wojbies API 4.1 - Bigfont - functions to write bigger font using drawing sybols --
-------------------------------------------------------------------------------------
--   Copyright (c) 2015-2020 Wojbie (wojbie@wojbie.net)
--   Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
--   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--   4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   5. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--   NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--### Initializing
bigFont = shell and {} or (_ENV or getfenv())
bigFont.versionName = "Bigfont By Wojbie"
bigFont.versionNum = 4.1 --2020-01-28

--### Font database
local rawFont = {{"\32\32\32\137\156\148\158\159\148\135\135\144\159\139\32\136\157\32\159\139\32\32\143\32\32\143\32\32\32\32\32\32\32\32\147\148\150\131\148\32\32\32\151\140\148\151\140\147", "\32\32\32\149\132\149\136\156\149\144\32\133\139\159\129\143\159\133\143\159\133\138\32\133\138\32\133\32\32\32\32\32\32\150\150\129\137\156\129\32\32\32\133\131\129\133\131\132", "\32\32\32\130\131\32\130\131\32\32\129\32\32\32\32\130\131\32\130\131\32\32\32\32\143\143\143\32\32\32\32\32\32\130\129\32\130\135\32\32\32\32\131\32\32\131\32\131", "\139\144\32\32\143\148\135\130\144\149\32\149\150\151\149\158\140\129\32\32\32\135\130\144\135\130\144\32\149\32\32\139\32\159\148\32\32\32\32\159\32\144\32\148\32\147\131\132", "\159\135\129\131\143\149\143\138\144\138\32\133\130\149\149\137\155\149\159\143\144\147\130\132\32\149\32\147\130\132\131\159\129\139\151\129\148\32\32\139\131\135\133\32\144\130\151\32", "\32\32\32\32\32\32\130\135\32\130\32\129\32\129\129\131\131\32\130\131\129\140\141\132\32\129\32\32\129\32\32\32\32\32\32\32\131\131\129\32\32\32\32\32\32\32\32\32", "\32\32\32\32\149\32\159\154\133\133\133\144\152\141\132\133\151\129\136\153\32\32\154\32\159\134\129\130\137\144\159\32\144\32\148\32\32\32\32\32\32\32\32\32\32\32\151\129", "\32\32\32\32\133\32\32\32\32\145\145\132\141\140\132\151\129\144\150\146\129\32\32\32\138\144\32\32\159\133\136\131\132\131\151\129\32\144\32\131\131\129\32\144\32\151\129\32", "\32\32\32\32\129\32\32\32\32\130\130\32\32\129\32\129\32\129\130\129\129\32\32\32\32\130\129\130\129\32\32\32\32\32\32\32\32\133\32\32\32\32\32\129\32\129\32\32", "\150\156\148\136\149\32\134\131\148\134\131\148\159\134\149\136\140\129\152\131\32\135\131\149\150\131\148\150\131\148\32\148\32\32\148\32\32\152\129\143\143\144\130\155\32\134\131\148", "\157\129\149\32\149\32\152\131\144\144\131\148\141\140\149\144\32\149\151\131\148\32\150\32\150\131\148\130\156\133\32\144\32\32\144\32\130\155\32\143\143\144\32\152\129\32\134\32", "\130\131\32\131\131\129\131\131\129\130\131\32\32\32\129\130\131\32\130\131\32\32\129\32\130\131\32\130\129\32\32\129\32\32\133\32\32\32\129\32\32\32\130\32\32\32\129\32", "\150\140\150\137\140\148\136\140\132\150\131\132\151\131\148\136\147\129\136\147\129\150\156\145\138\143\149\130\151\32\32\32\149\138\152\129\149\32\32\157\152\149\157\144\149\150\131\148", "\149\143\142\149\32\149\149\32\149\149\32\144\149\32\149\149\32\32\149\32\32\149\32\149\149\32\149\32\149\32\144\32\149\149\130\148\149\32\32\149\32\149\149\130\149\149\32\149", "\130\131\129\129\32\129\131\131\32\130\131\32\131\131\32\131\131\129\129\32\32\130\131\32\129\32\129\130\131\32\130\131\32\129\32\129\131\131\129\129\32\129\129\32\129\130\131\32", "\136\140\132\150\131\148\136\140\132\153\140\129\131\151\129\149\32\149\149\32\149\149\32\149\137\152\129\137\152\129\131\156\133\149\131\32\150\32\32\130\148\32\152\137\144\32\32\32", "\149\32\32\149\159\133\149\32\149\144\32\149\32\149\32\149\32\149\150\151\129\138\155\149\150\130\148\32\149\32\152\129\32\149\32\32\32\150\32\32\149\32\32\32\32\32\32\32", "\129\32\32\130\129\129\129\32\129\130\131\32\32\129\32\130\131\32\32\129\32\129\32\129\129\32\129\32\129\32\131\131\129\130\131\32\32\32\129\130\131\32\32\32\32\140\140\132", "\32\154\32\159\143\32\149\143\32\159\143\32\159\144\149\159\143\32\159\137\145\159\143\144\149\143\32\32\145\32\32\32\145\149\32\144\32\149\32\143\159\32\143\143\32\159\143\32", "\32\32\32\152\140\149\151\32\149\149\32\145\149\130\149\157\140\133\32\149\32\154\143\149\151\32\149\32\149\32\144\32\149\149\153\32\32\149\32\149\133\149\149\32\149\149\32\149", "\32\32\32\130\131\129\131\131\32\130\131\32\130\131\129\130\131\129\32\129\32\140\140\129\129\32\129\32\129\32\137\140\129\130\32\129\32\130\32\129\32\129\129\32\129\130\131\32", "\144\143\32\159\144\144\144\143\32\159\143\144\159\138\32\144\32\144\144\32\144\144\32\144\144\32\144\144\32\144\143\143\144\32\150\129\32\149\32\130\150\32\134\137\134\134\131\148", "\136\143\133\154\141\149\151\32\129\137\140\144\32\149\32\149\32\149\154\159\133\149\148\149\157\153\32\154\143\149\159\134\32\130\148\32\32\149\32\32\151\129\32\32\32\32\134\32", "\133\32\32\32\32\133\129\32\32\131\131\32\32\130\32\130\131\129\32\129\32\130\131\129\129\32\129\140\140\129\131\131\129\32\130\129\32\129\32\130\129\32\32\32\32\32\129\32", "\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32", "\32\32\32\32\32\32\32\32\32\32\32\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\32\32\32\32\32\32\32\32\32\32\32", "\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32", "\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32", "\32\32\32\32\32\32\32\32\32\32\32\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\32\32\32\32\32\32\32\32\32\32\32", "\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32", "\32\32\32\32\145\32\159\139\32\151\131\132\155\143\132\134\135\145\32\149\32\158\140\129\130\130\32\152\147\155\157\134\32\32\144\144\32\32\32\32\32\32\152\131\155\131\131\129", "\32\32\32\32\149\32\149\32\145\148\131\32\149\32\149\140\157\132\32\148\32\137\155\149\32\32\32\149\154\149\137\142\32\153\153\32\131\131\149\131\131\129\149\135\145\32\32\32", "\32\32\32\32\129\32\130\135\32\131\131\129\134\131\132\32\129\32\32\129\32\131\131\32\32\32\32\130\131\129\32\32\32\32\129\129\32\32\32\32\32\32\130\131\129\32\32\32", "\150\150\32\32\148\32\134\32\32\132\32\32\134\32\32\144\32\144\150\151\149\32\32\32\32\32\32\145\32\32\152\140\144\144\144\32\133\151\129\133\151\129\132\151\129\32\145\32", "\130\129\32\131\151\129\141\32\32\142\32\32\32\32\32\149\32\149\130\149\149\32\143\32\32\32\32\142\132\32\154\143\133\157\153\132\151\150\148\151\158\132\151\150\148\144\130\148", "\32\32\32\140\140\132\32\32\32\32\32\32\32\32\32\151\131\32\32\129\129\32\32\32\32\134\32\32\32\32\32\32\32\129\129\32\129\32\129\129\130\129\129\32\129\130\131\32", "\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\159\142\32\150\151\129\150\131\132\140\143\144\143\141\145\137\140\148\141\141\144\157\142\32\159\140\32\151\134\32\157\141\32", "\157\140\149\157\140\149\157\140\149\157\140\149\157\140\149\157\140\149\151\151\32\154\143\132\157\140\32\157\140\32\157\140\32\157\140\32\32\149\32\32\149\32\32\149\32\32\149\32", "\129\32\129\129\32\129\129\32\129\129\32\129\129\32\129\129\32\129\129\131\129\32\134\32\131\131\129\131\131\129\131\131\129\131\131\129\130\131\32\130\131\32\130\131\32\130\131\32", "\151\131\148\152\137\145\155\140\144\152\142\145\153\140\132\153\137\32\154\142\144\155\159\132\150\156\148\147\32\144\144\130\145\136\137\32\146\130\144\144\130\145\130\136\32\151\140\132", "\151\32\149\151\155\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\152\137\144\157\129\149\149\32\149\149\32\149\149\32\149\149\32\149\130\150\32\32\157\129\149\32\149", "\131\131\32\129\32\129\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\32\32\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\129\32\130\131\32\133\131\32", "\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\159\142\32\159\159\144\152\140\144\156\143\32\159\141\129\153\140\132\157\141\32\130\145\32\32\147\32\136\153\32\130\146\32", "\152\140\149\152\140\149\152\140\149\152\140\149\152\140\149\152\140\149\149\157\134\154\143\132\157\140\133\157\140\133\157\140\133\157\140\133\32\149\32\32\149\32\32\149\32\32\149\32", "\130\131\129\130\131\129\130\131\129\130\131\129\130\131\129\130\131\129\130\130\131\32\134\32\130\131\129\130\131\129\130\131\129\130\131\129\32\129\32\32\129\32\32\129\32\32\129\32", "\159\134\144\137\137\32\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\32\132\32\159\143\32\147\32\144\144\130\145\136\137\32\146\130\144\144\130\145\130\138\32\146\130\144", "\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\131\147\129\138\134\149\149\32\149\149\32\149\149\32\149\149\32\149\154\143\149\32\157\129\154\143\149", "\130\131\32\129\32\129\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\32\32\130\131\32\130\131\129\130\131\129\130\131\129\130\131\129\140\140\129\130\131\32\140\140\129" }, {[[000110000110110000110010101000000010000000100101]], [[000000110110000000000010101000000010000000100101]], [[000000000000000000000000000000000000000000000000]], [[100010110100000010000110110000010100000100000110]], [[000000110000000010110110000110000000000000110000]], [[000000000000000000000000000000000000000000000000]], [[000000110110000010000000100000100000000000000010]], [[000000000110110100010000000010000000000000000100]], [[000000000000000000000000000000000000000000000000]], [[010000000000100110000000000000000000000110010000]], [[000000000000000000000000000010000000010110000000]], [[000000000000000000000000000000000000000000000000]], [[011110110000000100100010110000000100000000000000]], [[000000000000000000000000000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[110000110110000000000000000000010100100010000000]], [[000010000000000000110110000000000100010010000000]], [[000000000000000000000000000000000000000000000000]], [[010110010110100110110110010000000100000110110110]], [[000000000000000000000110000000000110000000000000]], [[000000000000000000000000000000000000000000000000]], [[010100010110110000000000000000110000000010000000]], [[110110000000000000110000110110100000000010000000]], [[000000000000000000000000000000000000000000000000]], [[000100011111000100011111000100011111000100011111]], [[000000000000100100100100011011011011111111111111]], [[000000000000000000000000000000000000000000000000]], [[000100011111000100011111000100011111000100011111]], [[000000000000100100100100011011011011111111111111]], [[100100100100100100100100100100100100100100100100]], [[000000110100110110000010000011110000000000011000]], [[000000000100000000000010000011000110000000001000]], [[000000000000000000000000000000000000000000000000]], [[010000100100000000000000000100000000010010110000]], [[000000000000000000000000000000110110110110110000]], [[000000000000000000000000000000000000000000000000]], [[110110110110110110000000110110110110110110110110]], [[000000000000000000000110000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[000000000000110110000110010000000000000000010010]], [[000010000000000000000000000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[110110110110110110110000110110110110000000000000]], [[000000000000000000000110000000000000000000000000]], [[000000000000000000000000000000000000000000000000]], [[110110110110110110110000110000000000000000010000]], [[000000000000000000000000100000000000000110000110]], [[000000000000000000000000000000000000000000000000]] }}

--### Genarate fonts using 3x3 chars per a character. (1 character is 6x9 pixels)
local fonts = {}
local firstFont = {}
do
    local char = 0
    local height = #rawFont[1]
    local lenght = #rawFont[1][1]
    for i = 1, height, 3 do
        for j = 1, lenght, 3 do
            local thisChar = string.char(char)

            local temp = {}
            temp[1] = rawFont[1][i]:sub(j, j + 2)
            temp[2] = rawFont[1][i + 1]:sub(j, j + 2)
            temp[3] = rawFont[1][i + 2]:sub(j, j + 2)

            local temp2 = {}
            temp2[1] = rawFont[2][i]:sub(j, j + 2)
            temp2[2] = rawFont[2][i + 1]:sub(j, j + 2)
            temp2[3] = rawFont[2][i + 2]:sub(j, j + 2)

            firstFont[thisChar] = {temp, temp2}
            char = char + 1
        end
    end
    fonts[1] = firstFont
end

local function generateFontSize(size,yeld)
    local inverter = {["0"] = "1", ["1"] = "0"} --:gsub("[01]",inverter)
    if size<= #fonts then return true end
    for f = #fonts+1, size do
        --automagicly make bigger fonts using firstFont and fonts[f-1].
        local nextFont = {}
        local lastFont = fonts[f - 1]
        for char = 0, 255 do
            local thisChar = string.char(char)
            --sleep(0) print(f,thisChar)

            local temp = {}
            local temp2 = {}

            local templateChar = lastFont[thisChar][1]
            local templateBack = lastFont[thisChar][2]
            for i = 1, #templateChar do
                local line1, line2, line3, back1, back2, back3 = {}, {}, {}, {}, {}, {}
                for j = 1, #templateChar[1] do
                    local currentChar = firstFont[templateChar[i]:sub(j, j)][1]
                    table.insert(line1, currentChar[1])
                    table.insert(line2, currentChar[2])
                    table.insert(line3, currentChar[3])

                    local currentBack = firstFont[templateChar[i]:sub(j, j)][2]
                    if templateBack[i]:sub(j, j) == "1" then
                        table.insert(back1, (currentBack[1]:gsub("[01]", inverter)))
                        table.insert(back2, (currentBack[2]:gsub("[01]", inverter)))
                        table.insert(back3, (currentBack[3]:gsub("[01]", inverter)))
                    else
                        table.insert(back1, currentBack[1])
                        table.insert(back2, currentBack[2])
                        table.insert(back3, currentBack[3])
                    end
                end
                table.insert(temp, table.concat(line1))
                table.insert(temp, table.concat(line2))
                table.insert(temp, table.concat(line3))
                table.insert(temp2, table.concat(back1))
                table.insert(temp2, table.concat(back2))
                table.insert(temp2, table.concat(back3))
            end

            nextFont[thisChar] = {temp, temp2}
            if yeld then yeld = "Font"..f.."Yeld"..char os.queueEvent(yeld) os.pullEvent(yeld) end
        end
        fonts[f] = nextFont
    end
    return true
end

generateFontSize(3,false)

--## Use pre-generated fonts instead of old code above.

--local fonts = {}

local tHex = {[ colors.white ] = "0", [ colors.orange ] = "1", [ colors.magenta ] = "2", [ colors.lightBlue ] = "3", [ colors.yellow ] = "4", [ colors.lime ] = "5", [ colors.pink ] = "6", [ colors.gray ] = "7", [ colors.lightGray ] = "8", [ colors.cyan ] = "9", [ colors.purple ] = "a", [ colors.blue ] = "b", [ colors.brown ] = "c", [ colors.green ] = "d", [ colors.red ] = "e", [ colors.black ] = "f"}

--# Write data on terminal in specified location.
local function stamp(tTerminal, tData, nX, nY)

    local oX, oY = tTerminal.getSize()
    local cX, cY = #tData[1][1], #tData[1]
    nX = nX or math.floor((oX - cX) / 2) + 1
    nY = nY or math.floor((oY - cY) / 2) + 1

    for i = 1, cY do
        if i > 1 and nY + i - 1 > oY then term.scroll(1) nY = nY - 1 end
        tTerminal.setCursorPos(nX, nY + i - 1)
        tTerminal.blit(tData[1][i], tData[2][i], tData[3][i])
    end
end

--# Generate data from strings for data and colors.
local function makeText(nSize, sString, nFC, nBC, bBlit)
    if not type(sString) == "string" then error("Not a String") end
    local cFC = type(nFC) == "string" and nFC:sub(1, 1) or tHex[nFC] or error("Wrong Front Color")
    local cBC = type(nBC) == "string" and nBC:sub(1, 1) or tHex[nBC] or error("Wrong Back Color")
    local font = fonts[nSize] or error("Wrong font size selected")

    local input = {}
    for i in sString:gmatch('.') do table.insert(input, i) end

    local tText = {}
    local height = #font[input[1]][1]


    for nLine = 1, height do
        local outLine = {}
        for i = 1, #input do
            outLine[i] = font[input[i]] and font[input[i]][1][nLine] or ""
        end
        tText[nLine] = table.concat(outLine)
    end

    local tFront = {}
    local tBack = {}
    local tFrontSub = {["0"] = cFC, ["1"] = cBC}
    local tBackSub = {["0"] = cBC, ["1"] = cFC}

    for nLine = 1, height do
        local front = {}
        local back = {}
        for i = 1, #input do
            local template = font[input[i]] and font[input[i]][2][nLine] or ""
            front[i] = template:gsub("[01]", bBlit and {["0"] = nFC:sub(i, i), ["1"] = nBC:sub(i, i)} or tFrontSub)
            back[i] = template:gsub("[01]", bBlit and {["0"] = nBC:sub(i, i), ["1"] = nFC:sub(i, i)} or tBackSub)
        end
        tFront[nLine] = table.concat(front)
        tBack[nLine] = table.concat(back)
    end

    return {tText, tFront, tBack}
end

--# Writing in big font using current terminal settings.
bigFont.bigWrite = function(sString)
    stamp(term, makeText(1, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 2)
end

bigFont.bigBlit = function(sString, sFront, sBack)
    stamp(term, makeText(1, sString, sFront, sBack, true), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 2)
end

bigFont.bigPrint = function(sString)
    stamp(term, makeText(1, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    print()
end

--# Writing in huge font using current terminal settings.
bigFont.hugeWrite = function(sString)
    stamp(term, makeText(2, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 8)
end

bigFont.hugeBlit = function(sString, sFront, sBack)
    stamp(term, makeText(2, sString, sFront, sBack, true), term.getCursorPos())
    local x, y = term.getCursorPos()
    term.setCursorPos(x, y - 8)
end

bigFont.hugePrint = function(sString)
    stamp(term, makeText(2, sString, term.getTextColor(), term.getBackgroundColor()), term.getCursorPos())
    print()
end

--# Write/blit string on terminal in specified location
bigFont.writeOn = function(tTerminal, nSize, sString, nX, nY)
    stamp(tTerminal, makeText(nSize, sString, tTerminal.getTextColor(), tTerminal.getBackgroundColor()), nX, nY)
end

bigFont.blitOn = function(tTerminal, nSize, sString, sFront, sBack, nX, nY)
    stamp(tTerminal, makeText(nSize, sString, sFront, sBack, true), nX, nY)
end

--# Generate blittle object in blittle format for printing with that api.
bigFont.makeBlittleText = function(nSize, sString, nFC, nBC)
    local out = makeText(nSize, sString, nFC, nBC)
    out.height = #out[1]
    out.width = #out[1][1]
    return out
end

--# Calculate higher size fonts
bigFont.generateFontSize = function(size)
    if type(size) ~= "number" then error("Size need to be a number") end
    if size > 6 then return false end
    return generateFontSize(math.floor(size),true)
end

--### Finalizing big font api


args = {...}
entity = {
  nbsp = " ",
  lt = "<",
  gt = ">",
  quot = "\"",
  amp = "&",
}

-- keep unknown entity as is
setmetatable(entity, {
  __index = function (t, key)
    return "&" .. key .. ";"
  end
})

block = {
  "address",
  "blockquote",
  "center",
  "dir", "div", "dl",
  "fieldset", "form",
  "h1", "h2", "h3", "h4", "h5", "h6", "hr", 
  "isindex",
  "menu",
  "noframes",
  "ol",
  "p",
  "pre",
  "table",
  "ul",
}

inline = {
  "a", "abbr", "acronym", "applet",
  "b", "basefont", "bdo", "big", "br", "button",
  "cite", "code",
  "dfn",
  "em",
  "font",
  "i", "iframe", "img", "input",
  "kbd",
  "label",
  "map",
  "object",
  "q",
  "s", "samp", "select", "small", "span", "strike", "strong", "sub", "sup",
  "textarea", "tt",
  "u",
  "var",
}

tags = {
  a = { empty = false },
  abbr = {empty = false} ,
  acronym = {empty = false} ,
  address = {empty = false} ,
  applet = {empty = false} ,
  area = {empty = true} ,
  b = {empty = false} ,
  base = {empty = true} ,
  basefont = {empty = true} ,
  bdo = {empty = false} ,
  big = {empty = false} ,
  blockquote = {empty = false} ,
  body = { empty = false, },
  br = {empty = true} ,
  button = {empty = false} ,
  caption = {empty = false} ,
  center = {empty = false} ,
  cite = {empty = false} ,
  code = {empty = false} ,
  col = {empty = true} ,
  colgroup = {
    empty = false,
    optional_end = true,
    child = {"col",},
  },
  dd = {empty = false} ,
  del = {empty = false} ,
  dfn = {empty = false} ,
  dir = {empty = false} ,
  div = {empty = false} ,
  dl = {empty = false} ,
  dt = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  em = {empty = false} ,
  fieldset = {empty = false} ,
  font = {empty = false} ,
  form = {empty = false} ,
  frame = {empty = true} ,
  frameset = {empty = false} ,
  h1 = {empty = false} ,
  h2 = {empty = false} ,
  h3 = {empty = false} ,
  h4 = {empty = false} ,
  h5 = {empty = false} ,
  h6 = {empty = false} ,
  head = {empty = false} ,
  hr = {empty = true} ,
  html = {empty = false} ,
  i = {empty = false} ,
  iframe = {empty = false} ,
  img = {empty = true} ,
  input = {empty = true} ,
  ins = {empty = false} ,
  isindex = {empty = true} ,
  kbd = {empty = false} ,
  label = {empty = false} ,
  legend = {empty = false} ,
  li = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  link = {empty = true} ,
  map = {empty = false} ,
  menu = {empty = false} ,
  meta = {empty = true} ,
  noframes = {empty = false} ,
  noscript = {empty = false} ,
  object = {empty = false} ,
  ol = {empty = false} ,
  optgroup = {empty = false} ,
  option = {
    empty = false,
    optional_end = true,
    child = {},
  },
  p = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      "del",
      "ins",
      "noscript",
      "script",
    },
  } ,
  param = {empty = true} ,
  pre = {empty = false} ,
  q = {empty = false} ,
  s =  {empty = false} ,
  samp = {empty = false} ,
  script = {empty = false} ,
  select = {empty = false} ,
  small = {empty = false} ,
  span = {empty = false} ,
  strike = {empty = false} ,
  strong = {empty = false} ,
  style = {empty = false} ,
  sub = {empty = false} ,
  sup = {empty = false} ,
  table = {empty = false} ,
  tbody = {empty = false} ,
  td = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  textarea = {empty = false} ,
  tfoot = {
    empty = false,
    optional_end = true,
    child = {"tr",},
  },
  th = {
    empty = false,
    optional_end = true,
    child = {
      inline,
      block,
      "del",
      "ins",
      "noscript",
      "script",
    },
  },
  thead = {
    empty = false,
    optional_end = true,
    child = {"tr",},
  },
  title = {empty = false} ,
  tr = {
    empty = false,
    optional_end = true,
    child = {
      "td", "th",
    },
  },
  tt = {empty = false} ,
  u = {empty = false} ,
  ul = {empty = false} ,
  var = {empty = false} ,
}

setmetatable(tags, {
  __index = function (t, key)
    return {empty = false}
  end
})

-- string buffer implementation
function newbuf ()
  local buf = {
    _buf = {},
    clear =   function (self) self._buf = {}; return self end,
    content = function (self) return table.concat(self._buf) end,
    append =  function (self, s)
      self._buf[#(self._buf) + 1] = s
      return self
    end,
    set =     function (self, s) self._buf = {s}; return self end,
  }
  return buf
end

-- unescape character entities
function unescape (s)
  function entity2string (e)
    return entity[e]
  end
  return s.gsub(s, "&(#?%w+);", entity2string)
end

-- iterator factory
function makeiter (f)
  local co = coroutine.create(f)
  return function ()
    local code, res = coroutine.resume(co)
    return res
  end
end

-- constructors for token
function Tag (s) 
  return string.find(s, "^</") and
    {type = "End",   value = s} or
    {type = "Start", value = s}
end

function Text (s)
  local unescaped = unescape(s) 
  return {type = "Text", value = unescaped} 
end

-- lexer: text mode
function text (f, buf)
  local c = f:read(1)
  if c == "<" then
    if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
    buf:set(c)
    return tag(f, buf)
  elseif c then
    buf:append(c)
    return text(f, buf)
  else
    if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
  end
end

-- lexer: tag mode
function tag (f, buf)
  local c = f:read(1)
  if c == ">" then
    coroutine.yield(Tag(buf:append(c):content()))
    buf:clear()
    return text(f, buf)
  elseif c then
    buf:append(c)
    return tag(f, buf)
  else
    if buf:content() ~= "" then coroutine.yield(Tag(buf:content())) end
  end
end

function parse_starttag(tag)
  local tagname = string.match(tag, "<%s*(%w+)")
  local elem = {_attr = {}}
  elem._tag = tagname
  for key, _, val in string.gmatch(tag, "(%w+)%s*=%s*([\"'])(.-)%2", i) do
    local unescaped = unescape(val)
    elem._attr[key] = unescaped
  end
  return elem
end

function parse_endtag(tag)
  local tagname = string.match(tag, "<%s*/%s*(%w+)")
  return tagname
end

-- find last element that satisfies given predicate
function rfind(t, pred)
  local length = #t
  for i=length,1,-1 do
    if pred(t[i]) then
      return i, t[i]
    end
  end
end

function flatten(t, acc)
  acc = acc or {}
  for i,v in ipairs(t) do
    if type(v) == "table" then
      flatten(v, acc)
    else
      acc[#acc + 1] = v
    end
  end
  return acc
end

function optional_end_p(elem)
  if tags[elem._tag].optional_end then
    return true
  else
    return false
  end
end

function valid_child_p(child, parent)
  local schema = tags[parent._tag].child
  if not schema then return true end

  for i,v in ipairs(flatten(schema)) do
    if v == child._tag then
      return true
    end
  end

  return false
end

-- tree builder
function parse(f)
  local root = {_tag = "#document", _attr = {}}
  local stack = {root}
  for i in makeiter(function () return text(f, newbuf()) end) do
    if i.type == "Start" then
      local new = parse_starttag(i.value)
      local top = stack[#stack]

      while
        top._tag ~= "#document" and 
        optional_end_p(top) and
        not valid_child_p(new, top)
      do
        stack[#stack] = nil 
        top = stack[#stack]
      end

      top[#top+1] = new -- appendchild
      if not tags[new._tag].empty then 
        stack[#stack+1] = new -- push
      end
    elseif i.type == "End" then
      local tag = parse_endtag(i.value)
      local openingpos = rfind(stack, function(v) 
          if v._tag == tag then
            return true
          else
            return false
          end
        end)
      if openingpos then
        local length = #stack
        for j=length,openingpos,-1 do
          table.remove(stack, j)
        end
      end
    else -- Text
      local top = stack[#stack]
      top[#top+1] = i.value
    end
  end
  return root
end

function parsestr(s)
  local handle = {
    _content = s,
    _pos = 1,
    read = function (self, length)
      if self._pos > string.len(self._content) then return end
      local ret = string.sub(self._content, self._pos, self._pos + length - 1)
      self._pos = self._pos + length
      return ret
    end
  }
  return parse(handle)
end
function getTable(filename)
	file = fs.open(filename, "r")
	local str = file.readAll()
	file.close()
	return parsestr(str)
end
--End of html parser

------------------------------------------------------------------ utils
local controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}

local function isArray(t)
	local max = 0
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		elseif k > max then
			max = k
		end
	end
	return max == #t
end

local whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}
function removeWhite(str)
	while whites[str:sub(1, 1)] do
		str = str:sub(2)
	end
	return str
end

------------------------------------------------------------------ encoding

local function encodeCommon(val, pretty, tabLevel, tTracking)
	local str = ""

	-- Tabbing util
	local function tab(s)
		str = str .. ("\t"):rep(tabLevel) .. s
	end

	local function arrEncoding(val, bracket, closeBracket, iterator, loopFunc)
		str = str .. bracket
		if pretty then
			str = str .. "\n"
			tabLevel = tabLevel + 1
		end
		for k,v in iterator(val) do
			tab("")
			loopFunc(k,v)
			str = str .. ","
			if pretty then str = str .. "\n" end
		end
		if pretty then
			tabLevel = tabLevel - 1
		end
		if str:sub(-2) == ",\n" then
			str = str:sub(1, -3) .. "\n"
		elseif str:sub(-1) == "," then
			str = str:sub(1, -2)
		end
		tab(closeBracket)
	end

	-- Table encoding
	if type(val) == "table" then
		assert(not tTracking[val], "Cannot encode a table holding itself recursively")
		tTracking[val] = true
		if isArray(val) then
			arrEncoding(val, "[", "]", ipairs, function(k,v)
				str = str .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		else
			arrEncoding(val, "{", "}", pairs, function(k,v)
				assert(type(k) == "string", "JSON object keys must be strings", 2)
				str = str .. encodeCommon(k, pretty, tabLevel, tTracking)
				str = str .. (pretty and ": " or ":") .. encodeCommon(v, pretty, tabLevel, tTracking)
			end)
		end
	-- String encoding
	elseif type(val) == "string" then
		str = '"' .. val:gsub("[%c\"\\]", controls) .. '"'
	-- Number encoding
	elseif type(val) == "number" or type(val) == "boolean" then
		str = tostring(val)
	else
		error("JSON only supports arrays, objects, numbers, booleans, and strings", 2)
	end
	return str
end

function encode(val)
	return encodeCommon(val, false, 0, {})
end

function encodePretty(val)
	return encodeCommon(val, true, 0, {})
end

--JSON API
------------------------------------------------------------------ decoding

local decodeControls = {}
for k,v in pairs(controls) do
	decodeControls[v] = k
end

function parseBoolean(str)
	if str:sub(1, 4) == "true" then
		return true, removeWhite(str:sub(5))
	else
		return false, removeWhite(str:sub(6))
	end
end

function parseNull(str)
	return nil, removeWhite(str:sub(5))
end

local numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
function parseNumber(str)
	local i = 1
	while numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
		i = i + 1
	end
	local val = tonumber(str:sub(1, i - 1))
	str = removeWhite(str:sub(i))
	return val, str
end

function parseString(str)
	str = str:sub(2)
	local s = ""
	while str:sub(1,1) ~= "\"" do
		local next = str:sub(1,1)
		str = str:sub(2)
		assert(next ~= "\n", "Unclosed string")

		if next == "\\" then
			local escape = str:sub(1,1)
			str = str:sub(2)

			next = assert(decodeControls[next..escape], "Invalid escape character")
		end

		s = s .. next
	end
	return s, removeWhite(str:sub(2))
end

function parseArray(str)
	str = removeWhite(str:sub(2))

	local val = {}
	local i = 1
	while str:sub(1, 1) ~= "]" do
		local v = nil
		v, str = parseValue(str)
		val[i] = v
		i = i + 1
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseObject(str)
	str = removeWhite(str:sub(2))

	local val = {}
	while str:sub(1, 1) ~= "}" do
		local k, v = nil, nil
		k, v, str = parseMember(str)
		val[k] = v
		str = removeWhite(str)
	end
	str = removeWhite(str:sub(2))
	return val, str
end

function parseMember(str)
	local k = nil
	k, str = parseValue(str)
	local val = nil
	val, str = parseValue(str)
	return k, val, str
end

function parseValue(str)
	local fchar = str:sub(1, 1)
	if fchar == "{" then
		return parseObject(str)
	elseif fchar == "[" then
		return parseArray(str)
	elseif tonumber(fchar) ~= nil or numChars[fchar] then
		return parseNumber(str)
	elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
		return parseBoolean(str)
	elseif fchar == "\"" then
		return parseString(str)
	elseif str:sub(1, 4) == "null" then
		return parseNull(str)
	end
	return nil
end

function decode(str)
	str = removeWhite(str)
	t = parseValue(str)
	return t
end

function decodeFromFile(path)
	local file = assert(fs.open(path, "r"))
	local decoded = decode(file.readAll())
	file.close()
	return decoded
end



--{End of APIS}
--{Start of program}

cssom = {}

local logger = new{func = function(self, level, message)
  --print(level..": "..message)
end,
file = "log.log"}

logger:info("Opened log file")

function download(url, file)
	local content = http.get(url).readAll()
	if not content then
	  error("Could not connect to website")
	end
	f = fs.open(file, "w")
	f.write(content)
	f.close()
end

function update()
	local sVers = http.get("https://raw.githubusercontent.com/ajh123/packages/main/packages.json")
	jsonVers = sVers.readAll() --Read and print contents of page
	sVers.close() --Just in case
	--logger:info(jsonVers)
	t = decode(jsonVers)
	name = t['name']
	jver = t['version']
	if name == 'cc-browser' and tonumber(jver) >= version then
		logger:info('New update ('..jver..')')

		box = createDialogueBox("Updater",{"New verson availalbe {"..tostring(jver).."}","Do you want to update?"},"yn") --#Creates a dialogue box with the title "GUI API" ,two body lines: "This is a dialogue box!" and "Do you like it?" and the box type is "yn"
		ret = box:draw( 3,3,5,colors.gray,colors.lightBlue,colors.white )
		term.setTextColor(colors.green)
		if ret then
			logger:info('updating')
			local fname = shell.getRunningProgram()
			local url = "http://raw.githubusercontent.com/ajh123/packages/cc-browser/"..tostring(jver).."/main.lua"
			logger:info(url)
			local sData, serr http.get(url)
			if not sData then
				local ebox = createDialogueBox("Updater",{"There was an error updating {"..tostring(err).."}"},"ok")
				ebox:draw( 3,3,5,colors.gray,colors.lightBlue,colors.white )
				return false
			end
			local rData = sData.readAll()
			h = fs.open(fname, "w")
			h.write(rData)
			h.close()
			error('Updated')
		end

	end
end

function string.starts(String,Start)
 return string.sub(String,1,string.len(Start))==Start
end


function css_select(selector, attr, check_with)
	if not type(selector) == 'string' then error('selector must be string') end
	if not type(attr) == 'string' then error('attr must be string') end
	if not type(check_with) == 'string' then error('check_with must be string') end

	if string.starts(selector, "#") and attr == "id"then
		if selector:sub(2) == check_with then
			return true
		else
			return false
		end
	end
	if string.starts(selector, ".") and attr == "class"then
		if selector:sub(2) == check_with then
			return true
		else
			return false
		end
	end
	if selector and attr == "element"then
		if selector == check_with then
			return true
		else
			return false
		end
	end
	return false
end


function mysplit (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
--End of css parser


function dumpTable(args)
	if type(args) == 'table' then
		local output = ""
		for i,v in ipairs(args) do
			if type(v) == 'table' then
				output = output..dumpTable(v)
			else
				output = output .. v
			end
		end
		return output
	else
		local x = 1
	end
end

lines = 0
local offset = 1
function parse_page(b)
	lines = 0
	for i=1,#b do
		local element = b[i]
		if type(element) == 'table' then
			if i>1 then
				element._prevElement = b[i-1]
			end
			-- print(element._tag)
			-- print(element._attr.id)
			if element._tag == "script" then
				local x = 1
			end
			if element._tag == "style" then
				-- local css = element[1]--string.gsub(element[1], " ", "")
				for selector, css in element[1]:gmatch("(.-)%{(.-)%}") do
					--print("css for "..selector.." >")
					local csscom = mysplit(css, ";")
					local elm = {}
					local attr = {}
					elm.selector = selector
					for k,v in pairs(csscom) do
						local vals = mysplit(v, ":")
						attr[vals[1]] = vals[2]
					end
					elm._attr = attr
					table.insert(cssom, elm)
					-- print(w)
					--print(string.gsub(element[1], w, ""))
				end
				--print(textutils.serialize(cssom))
			else
				local fg_col = "black"
				local bg_col = "white"
				for _,style in pairs(cssom) do
					if type(style) == 'table' then
						local selector = ""
						for _,v in pairs(style) do
							if type(v) == 'string' then selector = v end
						end
						--print(selector, element._tag)
						if css_select(selector, "element", element._tag) then
							fg_col = style._attr['color']
							bg_col = style._attr['background-color']
						end
						if css_select(selector, "id", element._attr.id) then
							fg_col = style._attr['color']
							bg_col = style._attr['background-color']
						end
						if css_select(selector, "class", element._attr.style) then
							fg_col = style._attr['color']
							bg_col = style._attr['background-color']
						end
						--print(selector..":",style._attr)
					end
				end
				if type(element[1]) == 'string' then
					if type(colors[fg_col]) == 'nil' then fg_col = 'black' end
					if type(colors[bg_col]) == 'nil' then bg_col = 'white' end

					myWindow.setTextColor(colors[fg_col])
					myWindow.setBackgroundColor(colors[bg_col])
					if element._tag == 'script' then
						--JAVASCRIPT TIME!!
					else
						if element._tag == 'h1' then
							lines = lines + 1
							local xPos, yPos = myWindow.getCursorPos()
							myWindow.clearLine()
							bigFont.bigPrint(element[1])
						else
							lines = lines + 1
							local xPos, yPos = myWindow.getCursorPos()
							print(element[1])
						end
					end
				end
				parse_page(element)
			end
		else
			--print(element)
		end
	end
end

_term = term.current()
myWindow = nil

local termw, termh = term.getSize()
term.setBackgroundColor(colors.gray)
term.clear()
myWindow = window.create(term.current(),1,3,termw-1,termh-2)
myWindow.setBackgroundColor(colors.white)
myWindow.clear()

myWindow.setTextColor(colors['black'])
myWindow.setBackgroundColor(colors['white'])
myWindow.clear()
myWindow.setCursorPos(1,offset)

update()

local termw, termh = term.getSize()
term.setBackgroundColor(colors.gray)
term.clear()
myWindow = window.create(term.current(),1,3,termw-1,termh-2)
myWindow.setBackgroundColor(colors.white)
myWindow.clear()

myWindow.setTextColor(colors['black'])
myWindow.setBackgroundColor(colors['white'])
myWindow.clear()
myWindow.setCursorPos(1,offset)

tArgs = { ... }

function restart()

	term.setCursorPos(1,1)
	term.setBackgroundColor(colors.gray)
	term.clearLine()
	term.write("URL : ")
	sExample = nil

	if #tArgs < 1 then

		local myInput = read()
		sExample, err = http.get(myInput) --Get contents of page

		logger:info("Opening url "..myInput)
	else
		logger:info("Opening file "..tArgs[1])
		sExample = fs.open(tArgs[1], "r")

	end

	if sExample then
		logger:info("Opened page")
		s = sExample.readAll() --Read contents of page
		sExample.close() --Just in case
	else
		logger:error("HTTP error: "..err)
		--s = "<style>#bob{background-color:blue;color:red}div{background-color:red;}</style><div><p id='bob'>HI? ya?</p><h1>?</h1></div>"
		s = "<style>h1{color:red;} div{background-color:red;</style>"
		if err == 'Not Found' then
			s = s.."<h1>404</h1> <div> <p>"..err.."</p> </div>"
		else
			s = s.."<p>"..err.."</p>"
		end
	end
	dom = parsestr(s)

	term.redirect(myWindow)

	myWindow.setBackgroundColor(colors.white)
	myWindow.clear()

	myWindow.setTextColor(colors['black'])
	myWindow.setBackgroundColor(colors['white'])
	myWindow.clear()
	myWindow.setCursorPos(1,offset)

	parse_page(dom)
	term.redirect(_term)

	if not sExample then
		restart()
	end

	running = true
	while running do
		term.redirect(_term)
		term.setCursorPos(termw, 1)
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.white)
		term.write('X')
		term.redirect(_term)
		e, p1, p2, p3, p4 = os.pullEvent()
		local termw, termh = myWindow.getSize()
		if e == "mouse_click" then
			if p2 >= termw and p3 == 1 then
				running = false
			else
				if p3 == 1 and p2 < termw then
					term.setTextColor(colors.black)
					restart()
				end
			end
		end
	  if e == "mouse_scroll" then
	    if p1 == 1 and offset < (termh - lines) then
	      offset = offset + 1
	      myWindow.setTextColor(colors['black'])
				myWindow.setBackgroundColor(colors['white'])
				myWindow.clear()
	      myWindow.setCursorPos(1, offset)
	      term.redirect(myWindow)
	      parse_page(dom)
	      term.redirect(_term)
	    end
	    if p1 == -1 and offset > 1 then
	      offset = offset - 1
	      myWindow.setTextColor(colors['black'])
				myWindow.setBackgroundColor(colors['white'])
				myWindow.clear()
	      myWindow.setCursorPos(1, offset)
	      term.redirect(myWindow)
	      parse_page(dom)
	      term.redirect(_term)
	    end
	  end
	  if e == 'key' and p1 == keys.q then
	  	running = false
	  end
	end
end
restart()

term.setTextColor(colors['white'])
term.setBackgroundColor(colors['black'])
term.clear()