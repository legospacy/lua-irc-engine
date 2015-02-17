--[[
	Example for Lua IRC Engine (https://github.com/legospacy/lua-irc-engine)
	Uses LuaSocket for network communication.
]]

local IRCe = require("irce")
local socket = require("socket.core")

---

local server = "irc.example.com"

local nick = "IRCe"
local username = "ircengine"
local realname = "IRC Engine"

local channel = "#example"

---

local irc = IRCe.new()

-- If installed via LuaRocks:
--assert(irc:load_module(require("irce.modules.base")))
--assert(irc:load_module(require("irce.modules.message")))
--assert(irc:load_module(require("irce.modules.channel")))

-- If installed locally:
assert(irc:load_module(require("modules.base")))
assert(irc:load_module(require("modules.message")))
assert(irc:load_module(require("modules.channel")))

---

local running = true

---

local client = socket.tcp()

irc:set_send_func(function(message)
    return client:send(message)
end)

client:settimeout(1)

---

irc:set_callback("RAW", function(send, message)
	print(("%s %s"):format(send and ">>>" or "<<<", message))
end)

irc:set_callback("CTCP", function(sender, origin, command, params, pm)
	if command == "VERSION" then
		assert(irc:CTCP_REPLY(origin, "VERSION", "Lua IRC Engine - Test"))
	end
end)

irc:set_callback("001", function(...)
	assert(irc:JOIN(channel))
end)

irc:set_callback("PRIVMSG", function(sender, origin, message, pm)
	if message == "?quit" then
		assert(irc:QUIT("And away we go!"))
		running = false
	end
end)


irc:set_callback("NAMES", function(sender, channel, list, kind, message)
	print("---")
	if not list then
		print("No channel called " .. channel)
	else
		print(("Channel %s (%s):"):format(channel, kind))
		print("-")
		for _, nick in ipairs(list) do
			print(nick)
		end
	end
	print("---")
end)

---

assert(client:connect(server, 6667))

assert(irc:NICK(nick))
assert(irc:USER(username, realname))


while running do
    irc:process(client:receive())
end

---

client:close()

---
