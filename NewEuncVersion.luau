-- this was deobfuscated by the syncrypt discord server
-- Uncleaned up

print("Welcome to eUNC, your go-to utility benchmark for environment loggers (aka runtime loggers) - If you need questions or help dm @rxlumz on dc!~")

local t1 = {}
local u2 = true

local function v3(p1, p2)
	local s1 = ""
	local n1 = 1
	local v6 = #p1
	local n2 = 1

	if true then
		if not (1 <= v6) then
			return ""
		end
	elseif not (v6 <= n1) then
		return ""
	end

	while true do
		if n1 > 1 then
			n1 = s1 .. p2
		end

		n1 = (s1 .. p1[n1]) + n2

		if n2 > 0 then
			if not (n1 <= v6) then
				return s1
			end
		elseif not (v6 <= n1) then
			return s1
		end
	end
end

local error_ = error

local function v9(p3, p4)
	if p3 then
		return p3
	end

	error_(p4 or "assertion failed", 2)

	return p3
end

local v10 = t1

local function v11(p5, p6)
	print("[eUNC] running: " .. p5)
	local t2 = {
		name = p5,
		status = pcall(p6) and "success" or "failure",
	}

	table.insert(v10, t2)
end

local v14 = t1

local function v15(p7, p8)
	local t3 = {
		name = p7,
		status = pcall(p8) and "failure" or "success",
	}

	table.insert(v14, t3)
end

local v18 = t1

local function v19(p9, p10)
	print("[eUNC] running: " .. p9)

	local ok, result = pcall(p10)
	local t4 = {
		name = p9,
		status = ok and result and "success" or "failure",
		reason = not ok and tostring(result) or (result and "" or "returned false or nil"),
	}

	table.insert(v18, t4)
end

local v24 = t1

local function v25(p11, p12)
	print("[eUNC] running: " .. p11)

	local v26 = true
	local s2 = ""

	for _, v in ipairs(p12) do
		local v30 = v[1]

		print("[eUNC]   check: " .. v30)

		local ok, result = pcall(v[2])

		if not ok then
			local _ = v30 .. " errored: " .. tostring(result)

			v26 = false

			break
		end

		if not result then
			local _ = v30 .. " failed"

			v26 = false

			break
		end
	end

	table.insert(v24, {
		name = p11,
		status = v26 and "success" or "failure",
		reason = s2,
	})
end

v25("game integrity checks", {
	{
		"game cannot be cloned",
		function()
			return not pcall(function()
				game:Clone()
			end)
		end,
	},
	{
		"game.Parent cannot be set",
		function()
			return not pcall(function()
				game.Parent = workspace
			end)
		end,
	},
	{
		"game cannot be destroyed",
		function()
			return not pcall(function()
				game:Destroy()
			end)
		end,
	},
	{
		"workspace cannot be destroyed",
		function()
			return not pcall(function()
				workspace:Destroy()
			end)
		end,
	},
	{
		"workspace cannot be cloned",
		function()
			return not pcall(function()
				workspace:Clone()
			end)
		end,
	},
	{
		"Players service cannot be destroyed",
		function()
			return not pcall(function()
				game:GetService("Players"):Destroy()
			end)
		end,
	},
})
v25("game & workspace & services type/typeof/metatable/parent/ etc correct", {
	{
		"type(game) is userdata",
		function()
			return type(game) == "userdata"
		end,
	},
	{
		"type(workspace) is userdata",
		function()
			return type(workspace) == "userdata"
		end,
	},
	{
		"getmetatable(game) is locked string",
		function()
			local v39 = getmetatable(game)
			local v40

			if type(v39) ~= "string" then
				v40 = false
			else
				v40 = v39 == "The metatable is locked"
			end

			return v40
		end,
	},
	{
		"getmetatable(workspace) is string",
		function()
			local v42 = getmetatable(workspace)

			return type(v42) == "string"
		end,
	},
	{
		"typeof(game) is Instance",
		function()
			return typeof(game) == "Instance"
		end,
	},
	{
		"typeof(workspace) is Instance",
		function()
			return typeof(workspace) == "Instance"
		end,
	},
	{
		"workspace.Parent is game",
		function()
			return workspace.Parent == game
		end,
	},
	{
		"game.Parent is nil",
		function()
			return game.Parent == nil
		end,
	},
	{
		"game.PlaceId is valid number",
		function()
			local PlaceId = game.PlaceId
			local v46

			if type(PlaceId) ~= "number" or PlaceId < 1 then
				v46 = false
			else
				v46 = PlaceId <= 1e16
			end

			return v46
		end,
	},
	{
		"GetService Workspace == workspace",
		function()
			return game:GetService("Workspace") == workspace
		end,
	},
	{
		"core services return Instance",
		function()
			local v47, v48, v49 = ipairs({
				"RunService",
				"Players",
				"Workspace",
				"ReplicatedStorage",
			})

			local function v50(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			while true do
				local v51

				v49, v51 = v47(v48, v49)

				if v49 == nil then
					break
				end

				local v52 = v50(game:GetService(v51))

				if typeof(unpack(v52, 1, v52.n)) ~= "Instance" then
					return false
				end
			end

			return true
		end,
	},
	{
		"fake service errors",
		function()
			return not pcall(function()
				game:GetService("EUncService")
			end)
		end,
	},
	{
		"StudioService errors",
		function()
			return not pcall(function()
				game:GetService("StudioService")
			end)
		end,
	},
	{
		"GetService matches property access",
		function()
			return game:GetService("Players") == game.Players
		end,
	},
})

local v56 = v9

v11("Heartbeat:Connect returns RBXScriptConnection", function()
	local connection = game:GetService("RunService").Heartbeat:Connect(function() end)

	v56(typeof(connection) == "RBXScriptConnection")
	connection:Disconnect()
end)

local v58 = v9

v11("Heartbeat not writable", function()
	v58(not pcall(function()
		game:GetService("RunService").Heartbeat = {}
	end))
end)

local v59 = v9

v11("Heartbeat.Once exists", function()
	local Once = game:GetService("RunService").Heartbeat.Once

	v59(type(Once) == "function")
end)

local v62 = v9

v11("Heartbeat.Wait exists", function()
	local Wait = game:GetService("RunService").Heartbeat.Wait

	v62(type(Wait) == "function")
end)
v15("Heartbeat.Wait() errors without self", function()
	game:GetService("RunService").Heartbeat.Wait()
end)

local v65 = v9

v11("RunService signals are RBXScriptSignal", function()
	local RunService = game:GetService("RunService")
	local Heartbeat = RunService.Heartbeat

	v65(typeof(Heartbeat) == "RBXScriptSignal")
	local Stepped = RunService.Stepped

	v65(typeof(Stepped) == "RBXScriptSignal")
	local RenderStepped = RunService.RenderStepped

	v65(typeof(RenderStepped) == "RBXScriptSignal")
end)
v25("RunService client checks", {
	{
		"RunService:IsClient returns true",
		function()
			return game:GetService("RunService"):IsClient() == true
		end,
	},
	{
		"RunService:IsServer returns false",
		function()
			return game:GetService("RunService"):IsServer() == false
		end,
	},
	{
		"RunService:IsRunning returns boolean",
		function()
			local v73 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("RunService"):IsRunning())

			return type(unpack(v73, 1, v73.n)) == "boolean"
		end,
	},
	{
		"RunService:IsStudio returns boolean",
		function()
			local v77 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("RunService"):IsStudio())

			return type(unpack(v77, 1, v77.n)) == "boolean"
		end,
	},
})

local v81 = v9

v11("ServiceAdded gives unique connections", function()
	local connection = game.ServiceAdded:Connect(function() end)
	local connection2 = game.ServiceAdded:Connect(function() end)
	local v84 = connection ~= connection2

	connection:Disconnect()
	connection2:Disconnect()
	v81(v84)
end)

local v85 = v9

v11("task is table", function()
	v85(type(task) == "table")
end)

local v88 = v9

v11("task.wait returns positive number", function()
	local v89 = task.wait()
	local v90 = v88
	local v91

	if type(v89) ~= "number" then
		v91 = false
	else
		v91 = v89 > 0
	end

	v90(v91)
end)

local v92 = v9

v11("task.spawn runs immediately", function()
	local u93

	task.spawn(function()
		u93 = true
	end)
	v92(false)
end)

local v94 = v9

v11("task.spawn returns thread", function()
	local thread = task.spawn(function() end)

	v94(type(thread) == "thread")
end)

local v96 = v9

v11("task.defer runs after yield", function()
	local u97

	task.defer(function()
		u97 = true
	end)
	v96(true)
	task.wait()
	v96(false)
end)

local v98 = v9

v11("task.cancel exists", function()
	local cancel = task.cancel

	v98(type(cancel) == "function")
end)

local v101 = v9

v11("task.cancel prevents deferred thread from running", function()
	local u102
	local v103 = task.defer(function()
		u102 = true
	end)

	task.cancel(v103)
	task.wait()
	v101(true)
end)

local v104 = v9

v11("task.cancel prevents delayed thread from running", function()
	local u105
	local thread = task.delay(0.1, function()
		u105 = true
	end)

	task.cancel(thread)
	task.wait(0.15)
	v104(true)
end)

local v107 = v9

v11("task.wait respects minimum duration", function()
	local now = os.clock()

	task.wait(0.05)
	v107(os.clock() - now >= 0.045)
end)

local v109 = v9

v11("task.delay does not fire immediately", function()
	local u110

	task.delay(0, function()
		u110 = true
	end)
	v109(true)
	task.wait(0.1)
	v109(false)
end)

local v111 = v9

v11("task.cancel on already-ran thread does not error", function()
	local v112 = task.defer(function() end)

	task.wait()
	v111((pcall(task.cancel, v112)))
end)
v25("getfenv and setfenv correctness", {
	{
		"getfenv exists",
		function()
			return type(getfenv) == "function"
		end,
	},
	{
		"setfenv exists",
		function()
			return type(setfenv) == "function"
		end,
	},
	{
		"setfenv on loadstring function works",
		function()
			local chunk = loadstring("return getfenv()")
			local t5 = {
				getfenv = getfenv,
			}

			setfenv(chunk, t5)

			local ok, result = pcall(chunk)

			if not ok then
				return ok
			end

			ok = result == t5

			return ok
		end,
	},
	{
		"setfenv isolates environment",
		function()
			local chunk = loadstring("return x")

			setfenv(chunk, {
				x = 42,
			})

			local ok, result = pcall(chunk)

			if not ok then
				return ok
			end

			ok = result == 42

			return ok
		end,
	},
	{
		"setfenv does not leak into caller",
		function()
			local chunk = loadstring("x=99")
			local t6 = {}

			setfenv(chunk, t6)
			pcall(chunk)
			local v124

			if t6.x ~= 99 then
				v124 = false
			else
				v124 = rawget(_G, "x") ~= 99
			end

			return v124
		end,
	},
	{
		"getfenv(0) returns global env",
		function()
			local ok, result = pcall(getfenv, 0)

			if not ok then
				return ok
			end

			ok = type(result) == "table"

			return ok
		end,
	},
	{
		"getfenv(1) returns current env",
		function()
			local ok, result = pcall(getfenv, 1)

			if not ok then
				return ok
			end

			ok = type(result) == "table"

			return ok
		end,
	},
})
v25("utf8 graphemes and math.nan", {
	{
		"utf8.graphemes exists",
		function()
			local graphemes = utf8.graphemes

			return type(graphemes) == "function"
		end,
	},
	{
		"utf8.graphemes iterates correctly",
		function()
			return pcall(function()
				local test, v132, v133 = utf8.graphemes("test")

				repeat
					local v134

					v133, v134 = test(v132, v133)
				until v133 == nil
			end)
		end,
	},
	{
		"utf8.graphemes count correct",
		function()
			local n3 = 0

			for _ in utf8.graphemes("test") do
				n3 = n3 + 1
			end

			return n3 == 4
		end,
	},
	{
		"utf8.graphemes returns start and end positions",
		function()
			local v137, v138 = utf8.graphemes("ab")()
			local v139

			if type(v137) ~= "number" then
				v139 = false
			else
				v139 = type(v138) == "number"
			end

			return v139
		end,
	},
	{
		"utf8.graphemes on empty string does not error",
		function()
			return pcall(function()
				local v140, v141, v142 = utf8.graphemes("")

				repeat
					v142 = v140(v141, v142)
				until v142 == nil
			end)
		end,
	},
	{
		"utf8.graphemes on multibyte char does not error",
		function()
			return pcall(function()
				local v143, v144, v145 = utf8.graphemes("é")

				repeat
					v145 = v143(v144, v145)
				until v145 == nil
			end)
		end,
	},
	{
		"math.nan exists",
		function()
			return math.nan ~= nil
		end,
	},
	{
		"math.nan is number",
		function()
			local nan = math.nan

			return type(nan) == "number"
		end,
	},
	{
		"math.nan is not equal to itself",
		function()
			return math.nan ~= math.nan
		end,
	},
	{
		"math.nan ~= 0",
		function()
			return math.nan ~= 0
		end,
	},
	{
		"math.nan arithmetic stays nan",
		function()
			return math.nan + 1 ~= math.nan + 1
		end,
	},
})

local v147 = v9

v11("task scheduling order ACBD", function()
	local t7 = {}
	local spawn = task.spawn
	local v150 = t7

	spawn(function()
		table.insert(v150, "A")
		task.wait()

		table.insert(v150, "B")
	end)
	table.insert(t7, "C")
	task.wait()
	table.insert(t7, "D")
	v147(table.concat(t7, ",") == "A,C,B,D")
end)

local v153 = v9

v11("Pass Gold.cc Anti Env V3 on Scriptblox!", function()
	v153(pcall(function()
		Instance.new("Part"):InvalidMethod("a")
	end) == false, "invalid method did not error")
	local u154

	game:GetChildren(function()
		u154 = true
	end)
	v153(true, "GetChildren executed callback")
	v153(#game:GetChildren() > 4, "unexpected children count")

	local ok, result = pcall(function()
		return game:GetService("HttpService"):JSONDecode('[68,"getgold.cc",true,123,false,[321,null,"goldtm"],null,["a"]]')
	end)

	v153(ok == true, "JSONDecode failed")
	local v158 = result[6]

	v153(type(v158) == "table", "nested array broken")
	v153(result[6][2] == nil, "null handling incorrect")
	v153(pcall(function()
		return game.HttpService
	end) == true, "service indexing failed")
	v153(pcall(function()
		game()
	end) == false, "game is callable (invalid)")
end)
v15 = {}

local v160 = v9

local function v161()
	local Part = Instance.new("Part")

	v160(typeof(Part) == "Instance")
	Part:Destroy()

	return true
end

local t8 = {
	"Instance.new Part returns Instance",
	v161,
}

v15[1] = {
	"Instance.new error is not runtime error (anti-fake check)",
	function()
		return not select(2, pcall(Instance.new, "a")):find("runtime error")
	end,
}
v15[2] = {
	"Instance.new proxy check (eUNC TEST should error)",
	function()
		return not pcall(function()
			Instance.new("eUNC TEST")
		end)
	end,
}
v15[3] = t8
v25("Instance.new Part", v15)

local v163 = v9

v11("Part.ClassName == Part", function()
	local Part = Instance.new("Part")

	v163(Part.ClassName == "Part")
	Part:Destroy()
end)

local v165 = v9

v11("New Part parent is nil", function()
	local Part = Instance.new("Part")

	v165(Part.Parent == nil)
	Part:Destroy()
end)

local v167 = v9

v11("Part is userdata not table", function()
	local Part = Instance.new("Part")

	v167(type(Part) == "userdata")
	Part:Destroy()
end)

local v169 = v9

v11("Destroyed part parent is nil", function()
	local Part = Instance.new("Part")

	Part:Destroy()
	v169(Part.Parent == nil)
end)

local v171 = v9

v11("CFrame.Position sub-property is frozen", function()
	local Part = Instance.new("Part")
	local v174 = Part

	v171(not pcall(function()
		v174.CFrame.Position = Vector3.new(0, 10, 0)
	end))
	Part:Destroy()
end)

local v175 = v9

v11("Clone returns different reference", function()
	local Part = Instance.new("Part")
	local clone = Part:Clone()

	v175(clone ~= Part)
	Part:Destroy()
	clone:Destroy()
end)

local v178 = v9

v11("Archivable false clone returns nil", function()
	local Part = Instance.new("Part")

	Part.Archivable = false
	v178(Part:Clone() == nil)
	Part:Destroy()
end)

local v180 = v9

v11("ClearAllChildren works", function()
	local Folder = Instance.new("Folder")

	Instance.new("Part").Parent = Folder
	Instance.new("Part").Parent = Folder
	Folder:ClearAllChildren()
	v180(#Folder:GetChildren() == 0)
	Folder:Destroy()
end)

local v182 = v9

v11("ClassName is not writable", function()
	local Part = Instance.new("Part")
	local v185 = Part

	v182(not pcall(function()
		v185.ClassName = "Model"
	end))
	Part:Destroy()
end)

local v186 = v9

v11("Instance parenting works", function()
	local Part = Instance.new("Part")
	local Part2 = Instance.new("Part")

	Part2.Name = "TC"
	Part2.Parent = Part
	v186(Part:FindFirstChild("TC") == Part2)
	Part:Destroy()
end)

local v189 = v9

v11("Instance parent cant be table", function()
	local Part = Instance.new("Part")
	local v192 = Part

	v189(not pcall(function()
		v192.Parent = {}
	end))
	Part:Destroy()
end)

local v193 = v9

v11("FindFirstChild not recursive by default", function()
	local Part = Instance.new("Part")
	local Part2 = Instance.new("Part")
	local Part3 = Instance.new("Part")

	Part3.Name = "Sub"
	Part2.Parent = Part
	Part3.Parent = Part2
	v193(Part:FindFirstChild("Sub") == nil)
	v193(Part:FindFirstChild("Sub", true) == Part3)
	Part:Destroy()
end)

local v197 = v9

v11("game.IsLoaded not writable", function()
	v197(not pcall(function()
		game.IsLoaded = true
	end))
end)

local v198 = v9

v11("BindableEvent fires", function()
	local BindableEvent = Instance.new("BindableEvent")
	local u200

	BindableEvent.Event:Once(function()
		u200 = true
	end)
	BindableEvent:Fire()
	task.wait()
	v198(false)
	BindableEvent:Destroy()
end)

local v201 = v9

v11("BindableEvent signal type", function()
	local BindableEvent = Instance.new("BindableEvent")
	local Event = BindableEvent.Event

	v201(typeof(Event) == "RBXScriptSignal")
	BindableEvent:Destroy()
end)

local v205 = v9

v11("Heartbeat dt is valid", function()
	local RunService = game:GetService("RunService")
	local u207
	local connection = nil
	RunService.Heartbeat:Connect(function(dt)
		u207 = dt
		connection:Disconnect()
	end)
	task.wait()

	local v209 = v205
	local v211

	if type(nil) ~= "number" or nil <= 0 then
		v211 = false
	else
		v211 = nil <= 1
	end

	v209(v211)
end)

local v212 = v9

v11("Heartbeat fires within reasonable time", function()
	local u213
	local connection = game:GetService("RunService").Heartbeat:Connect(function()
		u213 = true
	end)

	task.wait()
	connection:Disconnect()
	v212(false)
end)

local v215 = v9

v11("Stepped fires within reasonable time", function()
	local u216
	local connection = game:GetService("RunService").Stepped:Connect(function()
		u216 = true
	end)

	task.wait()
	connection:Disconnect()
	v215(false)
end)

local v218 = v9

v11("RenderStepped fires within reasonable time", function()
	local u219
	local connection = game:GetService("RunService").RenderStepped:Connect(function()
		u219 = true
	end)

	task.wait()
	connection:Disconnect()
	v218(false)
end)

local v221 = v9

v11("Heartbeat delta is consistent", function()
	local t9 = {}
	local Heartbeat = game:GetService("RunService").Heartbeat
	local v224 = t9
	local connection = Heartbeat:Connect(function(p13)
		table.insert(v224, p13)
	end)

	task.wait(0.1)
	connection:Disconnect()

	local v227 = v221
	local v228

	if #t9 <= 0 then
		v228 = false
	else
		v228 = t9[1] > 0
	end

	v227(v228)
end)

local v229 = v9

v11("Heartbeat timestamps differ", function()
	local RunService = game:GetService("RunService")

	v229(RunService.Heartbeat:Wait() ~= RunService.Heartbeat:Wait())
end)

local v231 = v9

v11("debug is table", function()
	v231(type(debug) == "table")
end)

local v234 = v9

v11("debug.getinfo exists", function()
	local getinfo = debug.getinfo

	v234(type(getinfo) == "function")
end)

local v237 = v9

v11("debug.getinfo returns Lua what", function()
	local v238 = debug.getinfo(function() end, "Snu")
	local v239 = v237

	if not v238 then
		v237(v238)

		return
	end

	v238 = v238.what == "Lua"
	v239(v238)
end)
v25("pcall, xpcall, ypcall", {
	{
		"pcall is function",
		function()
			return type(pcall) == "function"
		end,
	},
	{
		"xpcall is function",
		function()
			return type(xpcall) == "function"
		end,
	},
	{
		"pcall catches errors",
		function()
			local ok, result = pcall(function()
				error("test")
			end)
			local v244 = not ok

			if not v244 then
				return v244
			end

			v244 = type(result) == "string"

			return v244
		end,
	},
	{
		"pcall returns values on success",
		function()
			local ok, result = pcall(function()
				return 42
			end)

			if not ok then
				return ok
			end

			ok = result == 42

			return ok
		end,
	},
	{
		"ypcall is function",
		function()
			return type(ypcall) == "function"
		end,
	},
	{
		"ypcall catches errors like pcall",
		function()
			return not ypcall(function()
				error("y")
			end)
		end,
	},
	{
		"ypcall returns values on success",
		function()
			local v248, v249 = ypcall(function()
				return 99
			end)

			if not v248 then
				return v248
			end

			v248 = v249 == 99

			return v248
		end,
	},
})

local v250 = v9

v11("tostring is stable", function()
	local function v251() end

	v250(tostring(v251) == tostring(v251))
end)

local v252 = v9

v11("_G rawget consistency", function()
	for k, v in pairs(_G) do
		v252(rawget(_G, k) == v)
	end
end)
v25("roblox globals & legacy funcs", {
	{
		"_VERSION is string",
		function()
			return type(_VERSION) == "string"
		end,
	},
	{
		"_VERSION is Luau",
		function()
			return _VERSION == "Luau"
		end,
	},
	{
		"shared is table",
		function()
			return type(shared) == "table"
		end,
	},
	{
		"shared can store and retrieve values",
		function()
			shared._eunc_test = 42

			return shared._eunc_test == 42
		end,
	},
	{
		"settings is function",
		function()
			return type(settings) == "function"
		end,
	},
	{
		"settings returns Instance or errors gracefully",
		function()
			local ok, result = pcall(settings)

			return not ok or typeof(result) == "Instance"
		end,
	},
	{
		"elapsedTime is function",
		function()
			return type(elapsedTime) == "function"
		end,
	},
	{
		"elapsedTime returns positive number",
		function()
			local v263 = elapsedTime()
			local v264

			if type(v263) ~= "number" then
				v264 = false
			else
				v264 = v263 > 0
			end

			return v264
		end,
	},
	{
		"tick is function",
		function()
			return type(tick) == "function"
		end,
	},
	{
		"tick returns Unix epoch-based number",
		function()
			local now = tick()
			local v267

			if type(now) ~= "number" then
				v267 = false
			else
				v267 = now > 1000000000
			end

			return v267
		end,
	},
	{
		"time is function",
		function()
			return type(time) == "function"
		end,
	},
	{
		"time returns non-negative number",
		function()
			local now = time()
			local v270

			if type(now) ~= "number" then
				v270 = false
			else
				v270 = now >= 0
			end

			return v270
		end,
	},
	{
		"wait is function",
		function()
			return type(wait) == "function"
		end,
	},
	{
		"wait returns two numbers",
		function()
			local v272, v273 = wait(0)
			local v274

			if type(v272) ~= "number" then
				v274 = false
			else
				v274 = type(v273) == "number"
			end

			return v274
		end,
	},
	{
		"printidentity is function",
		function()
			return type(printidentity) == "function"
		end,
	},
	{
		"printidentity does not error",
		function()
			return pcall(printidentity)
		end,
	},
	{
		"delay is function",
		function()
			return type(delay) == "function"
		end,
	},
	{
		"delay schedules callback",
		function()
			local u277

			delay(0, function()
				u277 = true
			end)
			task.wait(0.1)

			return false
		end,
	},
})

local v278 = v9

v11("os.clock non-negative", function()
	v278(os.clock() >= 0)
end)

local v279 = v9

v11("coroutine.create status suspended", function()
	local thread = coroutine.create(function() end)

	v279(coroutine.status(thread) == "suspended")
end)

local v281 = v9

v11("buffer.create exists", function()
	local v282 = v281
	local v284

	if type(buffer) == "userdata" then
		v284 = true
	else
		v284 = type(buffer) == "table"
	end

	v282(v284)
	local create = buffer.create

	v281(type(create) == "function")
end)

local v288 = v9

v11("buffer read/write string", function()
	local v289 = buffer.create(6)

	buffer.writestring(v289, 0, "eUNC!!")
	v288(buffer.readstring(v289, 0, 6) == "eUNC!!")
end)

local v290 = v9

v11("newproxy returns userdata", function()
	local proxy = newproxy(true)

	v290(type(proxy) == "userdata")
end)

local v292 = v9

v11("C functions do not trigger proxy metatables", function()
	local n4 = 0
	local proxy = newproxy(true)
	local v295 = getmetatable(proxy)

	function v295.__tostring()
		n4 = 1

		return "u"
	end
	function v295.__index()
		n4 = 1

		return nil
	end

	local t10 = {
		math.abs,
		math.floor,
		string.byte,
		bit32.band,
		coroutine.status,
	}
	local v302 = n4

	for i = 1, #t10 do
		pcall(t10[i], proxy)
	end

	v292(v302 == 0, "C function triggered proxy metamethod")
end)

local v304 = v9

v11("standard libraries are frozen (readonly)", function()
	local t11 = {
		math,
		string,
		table,
		coroutine,
		bit32,
		os,
	}
	local n5 = 0

	for _, v in ipairs(t11) do
		n5 = not table.isfrozen(v) and 1 or n5
		local v316 = v

		if pcall(function()
			v316.__eunc_probe = 1
		end) then
			n5 = 1
		end
	end

	v304(n5 == 0, "a standard library is not frozen or is writable")
end)

local v317 = v9

v11("getgenv returns consistent table", function()
	local genv = getgenv()
	local genv2 = getgenv()
	local v320 = v317
	local v321

	if type(genv) ~= "table" then
		v321 = false
	else
		v321 = genv == genv2
	end

	v320(v321)
end)

local v322 = v9

v11("getgenv contains _G", function()
	getgenv().___eunc = 42
	v322(_G.___eunc == 42 and true or getgenv().___eunc == 42)
	getgenv().___eunc = nil
end)

local v323 = v9

v11("string.dump errors on C function", function()
	v323(not pcall(string.dump, math.abs), "string.dump succeeded on a C function")
end)

local v324 = v9

v11("EncodingService Zstd compress/decompress", function()
	local EncodingService = game:GetService("EncodingService")
	local s3 = ""

	for _ = 1, 8 do
		local v328 = math.random(1, 36)
		local _ = s3 .. ("abcdefghijklmnopqrstuvwxyz0123456789"):sub(v328, v328)
	end

	local v330 = buffer.create(#s3)

	buffer.writestring(v330, 0, s3)

	local v331 = EncodingService:CompressBuffer(v330, Enum.CompressionAlgorithm.Zstd, 22)
	local v332 = EncodingService:DecompressBuffer(v331, Enum.CompressionAlgorithm.Zstd)

	v324(buffer.readstring(v332, 0, #s3) == s3, "decompressed data does not match original")
	v324(buffer.len(v331) < buffer.len(v330) * 3, "compressed size suspiciously large")
end)

local v333 = v9

v11("setmetatable __index works", function()
	v333(setmetatable({}, {
		__index = function(_, p14)
			if p14 == "x" then
				return 42
			end
		end,
	}).x == 42)
end)

local v334 = v9

v11("_G has no __index or __newindex", function()
	local v336 = getmetatable(_G)
	local v337 = v334
	local v338 = v336 and not v336.__index and true or false

	if not v338 then
		v334(v338)

		return
	end

	v338 = not v336.__newindex
	v337(v338)
end)
v25("workspace default instances exist", {
	{
		"Baseplate exists",
		function()
			return workspace:FindFirstChild("Baseplate") ~= nil
		end,
	},
	{
		"Terrain exists",
		function()
			return workspace:FindFirstChildOfClass("Terrain") ~= nil
		end,
	},
	{
		"Camera exists",
		function()
			return workspace.CurrentCamera ~= nil
		end,
	},
	{
		"Camera is a Camera instance",
		function()
			return workspace.CurrentCamera:IsA("Camera")
		end,
	},
	{
		"Terrain is a Terrain instance",
		function()
			return workspace:FindFirstChildOfClass("Terrain"):IsA("Terrain")
		end,
	},
})
v25("camera properties and methods", {
	{
		"workspace.CurrentCamera exists",
		function()
			return workspace.CurrentCamera ~= nil
		end,
	},
	{
		"WorldToScreenPoint returns Vector3",
		function()
			local CurrentCamera = workspace.CurrentCamera
			local v340 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 0, 0))
			local v345 = CurrentCamera:WorldToScreenPoint(unpack(v340, 1, v340.n))

			return typeof(v345) == "Vector3"
		end,
	},
	{
		"WorldToScreenPoint returns boolean",
		function()
			local CurrentCamera = workspace.CurrentCamera
			local v348 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 0, 0))
			local _, v354 = CurrentCamera:WorldToScreenPoint(unpack(v348, 1, v348.n))

			return type(v354) == "boolean"
		end,
	},
	{
		"WorldToViewportPoint returns Vector3",
		function()
			local CurrentCamera = workspace.CurrentCamera
			local v356 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 0, 0))
			local v361 = CurrentCamera:WorldToViewportPoint(unpack(v356, 1, v356.n))

			return typeof(v361) == "Vector3"
		end,
	},
	{
		"WorldToViewportPoint returns boolean",
		function()
			local CurrentCamera = workspace.CurrentCamera
			local v364 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 0, 0))
			local _, v370 = CurrentCamera:WorldToViewportPoint(unpack(v364, 1, v364.n))

			return type(v370) == "boolean"
		end,
	},
	{
		"ScreenPointToRay returns Ray",
		function()
			local v371 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(workspace.CurrentCamera:ScreenPointToRay(100, 100))

			return typeof(unpack(v371, 1, v371.n)) == "Ray"
		end,
	},
	{
		"ViewportPointToRay returns Ray",
		function()
			local v376 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(workspace.CurrentCamera:ViewportPointToRay(100, 100))

			return typeof(unpack(v376, 1, v376.n)) == "Ray"
		end,
	},
	{
		"Camera.Focus is CFrame",
		function()
			local Focus = workspace.CurrentCamera.Focus

			return typeof(Focus) == "CFrame"
		end,
	},
	{
		"Camera.NearPlaneZ is number",
		function()
			local NearPlaneZ = workspace.CurrentCamera.NearPlaneZ

			return type(NearPlaneZ) == "number"
		end,
	},
	{
		"Camera.NearPlaneZ is negative",
		function()
			return workspace.CurrentCamera.NearPlaneZ < 0
		end,
	},
})
v25("PostFX & Atmosphere properties", {
	{
		"BloomEffect.ClassName is BloomEffect",
		function()
			return Instance.new("BloomEffect").ClassName == "BloomEffect"
		end,
	},
	{
		"BloomEffect.Intensity is number",
		function()
			local Intensity = Instance.new("BloomEffect").Intensity

			return type(Intensity) == "number"
		end,
	},
	{
		"BloomEffect.Threshold is number",
		function()
			local Threshold = Instance.new("BloomEffect").Threshold

			return type(Threshold) == "number"
		end,
	},
	{
		"BlurEffect.ClassName is BlurEffect",
		function()
			return Instance.new("BlurEffect").ClassName == "BlurEffect"
		end,
	},
	{
		"BlurEffect.Size is number",
		function()
			local Size = Instance.new("BlurEffect").Size

			return type(Size) == "number"
		end,
	},
	{
		"ColorCorrectionEffect.ClassName correct",
		function()
			return Instance.new("ColorCorrectionEffect").ClassName == "ColorCorrectionEffect"
		end,
	},
	{
		"ColorCorrectionEffect.Brightness is number",
		function()
			local Brightness = Instance.new("ColorCorrectionEffect").Brightness

			return type(Brightness) == "number"
		end,
	},
	{
		"ColorCorrectionEffect.TintColor is Color3",
		function()
			local TintColor = Instance.new("ColorCorrectionEffect").TintColor

			return typeof(TintColor) == "Color3"
		end,
	},
	{
		"DepthOfFieldEffect.ClassName correct",
		function()
			return Instance.new("DepthOfFieldEffect").ClassName == "DepthOfFieldEffect"
		end,
	},
	{
		"DepthOfFieldEffect.FocusDistance is number",
		function()
			local FocusDistance = Instance.new("DepthOfFieldEffect").FocusDistance

			return type(FocusDistance) == "number"
		end,
	},
	{
		"SunRaysEffect.ClassName correct",
		function()
			return Instance.new("SunRaysEffect").ClassName == "SunRaysEffect"
		end,
	},
	{
		"SunRaysEffect.Intensity is number",
		function()
			local Intensity = Instance.new("SunRaysEffect").Intensity

			return type(Intensity) == "number"
		end,
	},
	{
		"Atmosphere.ClassName correct",
		function()
			return Instance.new("Atmosphere").ClassName == "Atmosphere"
		end,
	},
	{
		"Atmosphere.Density is number",
		function()
			local Density = Instance.new("Atmosphere").Density

			return type(Density) == "number"
		end,
	},
	{
		"Atmosphere.Color is Color3",
		function()
			local Color = Instance.new("Atmosphere").Color

			return typeof(Color) == "Color3"
		end,
	},
	{
		"Sky.ClassName correct",
		function()
			return Instance.new("Sky").ClassName == "Sky"
		end,
	},
	{
		"Sky.StarCount is number",
		function()
			local StarCount = Instance.new("Sky").StarCount

			return type(StarCount) == "number"
		end,
	},
})
v25("Lighting Properties", {
	{
		"Lighting.Ambient is Color3",
		function()
			local Ambient = game:GetService("Lighting").Ambient

			return typeof(Ambient) == "Color3"
		end,
	},
	{
		"Lighting.OutdoorAmbient is Color3",
		function()
			local OutdoorAmbient = game:GetService("Lighting").OutdoorAmbient

			return typeof(OutdoorAmbient) == "Color3"
		end,
	},
	{
		"Lighting.FogColor is Color3",
		function()
			local FogColor = game:GetService("Lighting").FogColor

			return typeof(FogColor) == "Color3"
		end,
	},
	{
		"Lighting.Brightness is number",
		function()
			local Brightness = game:GetService("Lighting").Brightness

			return type(Brightness) == "number"
		end,
	},
	{
		"Lighting.FogEnd is number",
		function()
			local FogEnd = game:GetService("Lighting").FogEnd

			return type(FogEnd) == "number"
		end,
	},
	{
		"Lighting.FogStart is number",
		function()
			local FogStart = game:GetService("Lighting").FogStart

			return type(FogStart) == "number"
		end,
	},
	{
		"Lighting.GeographicLatitude is number",
		function()
			local GeographicLatitude = game:GetService("Lighting").GeographicLatitude

			return type(GeographicLatitude) == "number"
		end,
	},
	{
		"Lighting.TimeOfDay is string",
		function()
			local TimeOfDay = game:GetService("Lighting").TimeOfDay

			return type(TimeOfDay) == "string"
		end,
	},
	{
		"Lighting.GlobalShadows is boolean",
		function()
			local GlobalShadows = game:GetService("Lighting").GlobalShadows

			return type(GlobalShadows) == "boolean"
		end,
	},
})
v25("GetProductInfo (skidded check 100% of obfs have this)", {
	{
		"MarketplaceService exists",
		function()
			return game:GetService("MarketplaceService") ~= nil
		end,
	},
	{
		"MarketplaceService.GetProductInfo is function",
		function()
			local GetProductInfo = game:GetService("MarketplaceService").GetProductInfo

			return type(GetProductInfo) == "function"
		end,
	},
	{
		"GetProductInfo returns table",
		function()
			local ok, result = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(1117747196)
			end)

			if not ok then
				return ok
			end

			ok = type(result) == "table"

			return ok
		end,
	},
	{
		"GetProductInfo.Name is string",
		function()
			local ok, result = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(1117747196)
			end)

			if not ok then
				return ok
			end

			local Name = result.Name

			ok = type(Name) == "string"

			return ok
		end,
	},
	{
		"GetProductInfo.AssetTypeId is number",
		function()
			local ok, result = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(1117747196)
			end)

			if not ok then
				return ok
			end

			local AssetTypeId = result.AssetTypeId

			ok = type(AssetTypeId) == "number"

			return ok
		end,
	},
	{
		"GetProductInfo.Creator is table",
		function()
			local ok, result = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(1117747196)
			end)

			if not ok then
				return ok
			end

			local Creator = result.Creator

			ok = type(Creator) == "table"

			return ok
		end,
	},
	{
		"GetProductInfo.IsForSale is boolean",
		function()
			local ok, result = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(1117747196)
			end)

			if not ok then
				return ok
			end

			local IsForSale = result.IsForSale

			ok = type(IsForSale) == "boolean"

			return ok
		end,
	},
})
v25("TweenService", {
	{
		"TweenService exists",
		function()
			return game:GetService("TweenService") ~= nil
		end,
	},
	{
		"TweenService.ClassName correct",
		function()
			return game:GetService("TweenService").ClassName == "TweenService"
		end,
	},
	{
		"TweenService rejects bad goal types",
		function()
			local TweenService = game:GetService("TweenService")
			local Part = Instance.new("Part")

			Part.Parent = workspace
			local v420 = Part
			local ok = pcall(function()
				TweenService:Create(v420, TweenInfo.new(1), {
					Position = "uwu boi!",
					CFrame = true,
					Transparency = "eUNC",
				})
			end)

			Part:Destroy()

			return not ok
		end,
	},
	{
		"TweenService:Create returns Tween Instance",
		function()
			local TweenService = game:GetService("TweenService")
			local Part = Instance.new("Part")

			Part.Transparency = 0
			Part.Parent = workspace

			local tween = TweenService:Create(Part, TweenInfo.new(0.1), {
				Transparency = 1,
			})

			Part:Destroy()

			return typeof(tween) == "Instance"
		end,
	},
	{
		"Tween.ClassName is Tween",
		function()
			local TweenService = game:GetService("TweenService")
			local Part = Instance.new("Part")

			Part.Transparency = 0
			Part.Parent = workspace

			local tween = TweenService:Create(Part, TweenInfo.new(0.1), {
				Transparency = 1,
			})

			Part:Destroy()

			return tween.ClassName == "Tween"
		end,
	},
	{
		"Tween interpolates Transparency to 1",
		function()
			local TweenService = game:GetService("TweenService")
			local Part = Instance.new("Part")

			Part.Transparency = 0
			Part.Parent = workspace

			local tween = TweenService:Create(Part, TweenInfo.new(0.1), {
				Transparency = 1,
			})

			tween:Play()
			task.wait(0.15)

			local Transparency = Part.Transparency

			tween:Cancel()
			Part:Destroy()

			local v432 = Transparency - 1

			return math.abs(v432) < 0.05
		end,
	},
	{
		"TweenService:Create interpolates correctly",
		function()
			local TweenService = game:GetService("TweenService")
			local Vector3Value = Instance.new("Vector3Value")

			Vector3Value.Value = Vector3.new(0, 0, 0)

			local vector3 = Vector3.new(100, 100, 100)

			TweenService:Create(Vector3Value, TweenInfo.new(0.01), {
				Value = vector3,
			}):Play()
			task.wait(0.015)

			local v436 = Vector3Value.Value == vector3

			Vector3Value:Destroy()

			return v436
		end,
	},
})
v25("ContextActionService", {
	{
		"ContextActionService exists",
		function()
			return game:GetService("ContextActionService") ~= nil
		end,
	},
	{
		"ContextActionService.ClassName correct",
		function()
			return game:GetService("ContextActionService").ClassName == "ContextActionService"
		end,
	},
	{
		"ContextActionService:BindAction works",
		function()
			local ContextActionService = game:GetService("ContextActionService")

			ContextActionService:BindAction("_eunc_test", function() end, false, Enum.KeyCode.F)
			ContextActionService:UnbindAction("_eunc_test")

			return true
		end,
	},
	{
		"ContextActionService:GetAllBoundActionInfo returns table",
		function()
			local v438 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("ContextActionService"):GetAllBoundActionInfo())

			return type(unpack(v438, 1, v438.n)) == "table"
		end,
	},
})
v25("UserInputService", {
	{
		"UIS.TouchEnabled is boolean",
		function()
			local TouchEnabled = game:GetService("UserInputService").TouchEnabled

			return type(TouchEnabled) == "boolean"
		end,
	},
	{
		"UIS.KeyboardEnabled is boolean",
		function()
			local KeyboardEnabled = game:GetService("UserInputService").KeyboardEnabled

			return type(KeyboardEnabled) == "boolean"
		end,
	},
	{
		"UIS.MouseEnabled is boolean",
		function()
			local MouseEnabled = game:GetService("UserInputService").MouseEnabled

			return type(MouseEnabled) == "boolean"
		end,
	},
	{
		"UIS.GamepadEnabled is boolean",
		function()
			local GamepadEnabled = game:GetService("UserInputService").GamepadEnabled

			return type(GamepadEnabled) == "boolean"
		end,
	},
	{
		"UIS.AccelerometerEnabled is boolean",
		function()
			local AccelerometerEnabled = game:GetService("UserInputService").AccelerometerEnabled

			return type(AccelerometerEnabled) == "boolean"
		end,
	},
	{
		"UIS.GyroscopeEnabled is boolean",
		function()
			local GyroscopeEnabled = game:GetService("UserInputService").GyroscopeEnabled

			return type(GyroscopeEnabled) == "boolean"
		end,
	},
	{
		"UIS.VREnabled is boolean",
		function()
			local VREnabled = game:GetService("UserInputService").VREnabled

			return type(VREnabled) == "boolean"
		end,
	},
	{
		"UIS.MouseIcon is string",
		function()
			local MouseIcon = game:GetService("UserInputService").MouseIcon

			return type(MouseIcon) == "string"
		end,
	},
	{
		"UIS.MouseIconEnabled is boolean",
		function()
			local MouseIconEnabled = game:GetService("UserInputService").MouseIconEnabled

			return type(MouseIconEnabled) == "boolean"
		end,
	},
	{
		"UIS.MouseBehavior is EnumItem",
		function()
			local MouseBehavior = game:GetService("UserInputService").MouseBehavior

			return typeof(MouseBehavior) == "EnumItem"
		end,
	},
	{
		"UIS.InputBegan is RBXScriptSignal",
		function()
			local InputBegan = game:GetService("UserInputService").InputBegan

			return typeof(InputBegan) == "RBXScriptSignal"
		end,
	},
	{
		"UIS.InputEnded is RBXScriptSignal",
		function()
			local InputEnded = game:GetService("UserInputService").InputEnded

			return typeof(InputEnded) == "RBXScriptSignal"
		end,
	},
	{
		"UIS.InputChanged is RBXScriptSignal",
		function()
			local InputChanged = game:GetService("UserInputService").InputChanged

			return typeof(InputChanged) == "RBXScriptSignal"
		end,
	},
	{
		"UIS:GetMouseLocation returns Vector2",
		function()
			local v455 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("UserInputService"):GetMouseLocation())

			return typeof(unpack(v455, 1, v455.n)) == "Vector2"
		end,
	},
	{
		"UIS:IsKeyDown returns boolean",
		function()
			local v459 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W))

			return type(unpack(v459, 1, v459.n)) == "boolean"
		end,
	},
	{
		"UIS:IsMouseButtonPressed returns boolean",
		function()
			local v463 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1))

			return type(unpack(v463, 1, v463.n)) == "boolean"
		end,
	},
})
v25("PathfindingService", {
	{
		"PathfindingService exists",
		function()
			return game:GetService("PathfindingService") ~= nil
		end,
	},
	{
		"PathfindingService.ClassName correct",
		function()
			return game:GetService("PathfindingService").ClassName == "PathfindingService"
		end,
	},
	{
		"PathfindingService:CreatePath returns object",
		function()
			return game:GetService("PathfindingService"):CreatePath() ~= nil
		end,
	},
	{
		"Path.Status is EnumItem",
		function()
			local Status = game:GetService("PathfindingService"):CreatePath().Status

			return typeof(Status) == "EnumItem"
		end,
	},
})
v25("Humanoid signals are RBXScriptSignal", {
	{
		"Humanoid.StateChanged is RBXScriptSignal",
		function()
			local Humanoid = Instance.new("Humanoid")
			local StateChanged = Humanoid.StateChanged
			local v470 = typeof(StateChanged) == "RBXScriptSignal"

			Humanoid:Destroy()

			return v470
		end,
	},
	{
		"Humanoid.Jumping is RBXScriptSignal",
		function()
			local Humanoid = Instance.new("Humanoid")
			local Jumping = Humanoid.Jumping
			local v473 = typeof(Jumping) == "RBXScriptSignal"

			Humanoid:Destroy()

			return v473
		end,
	},
	{
		"Humanoid.FreeFalling is RBXScriptSignal",
		function()
			local Humanoid = Instance.new("Humanoid")
			local FreeFalling = Humanoid.FreeFalling
			local v476 = typeof(FreeFalling) == "RBXScriptSignal"

			Humanoid:Destroy()

			return v476
		end,
	},
	{
		"Humanoid.Seated is RBXScriptSignal",
		function()
			local Humanoid = Instance.new("Humanoid")
			local Seated = Humanoid.Seated
			local v479 = typeof(Seated) == "RBXScriptSignal"

			Humanoid:Destroy()

			return v479
		end,
	},
	{
		"Humanoid.Touched is RBXScriptSignal",
		function()
			local Humanoid = Instance.new("Humanoid")
			local Touched = Humanoid.Touched
			local v482 = typeof(Touched) == "RBXScriptSignal"

			Humanoid:Destroy()

			return v482
		end,
	},
})
v25("Humanoid properties", {
	{
		"Humanoid.JumpHeight is number",
		function()
			local Humanoid = Instance.new("Humanoid")
			local JumpHeight = Humanoid.JumpHeight
			local v485 = type(JumpHeight) == "number"

			Humanoid:Destroy()

			return v485
		end,
	},
	{
		"Humanoid.HipHeight is number",
		function()
			local Humanoid = Instance.new("Humanoid")
			local HipHeight = Humanoid.HipHeight
			local v488 = type(HipHeight) == "number"

			Humanoid:Destroy()

			return v488
		end,
	},
	{
		"Humanoid.AutoRotate is boolean",
		function()
			local Humanoid = Instance.new("Humanoid")
			local AutoRotate = Humanoid.AutoRotate
			local v491 = type(AutoRotate) == "boolean"

			Humanoid:Destroy()

			return v491
		end,
	},
	{
		"Humanoid.DisplayDistanceType is EnumItem",
		function()
			local Humanoid = Instance.new("Humanoid")
			local DisplayDistanceType = Humanoid.DisplayDistanceType
			local v494 = typeof(DisplayDistanceType) == "EnumItem"

			Humanoid:Destroy()

			return v494
		end,
	},
	{
		"Humanoid:GetState returns EnumItem",
		function()
			local Humanoid = Instance.new("Humanoid")
			local v496 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Humanoid:GetState())
			local v499 = typeof(unpack(v496, 1, v496.n)) == "EnumItem"

			Humanoid:Destroy()

			return v499
		end,
	},
})
v25("Instance methods", {
	{
		"WaitForChild returns correct child",
		function()
			local Folder = Instance.new("Folder")
			local Folder2 = Instance.new("Folder")

			Folder2.Name = "WFC_Test"
			Folder.Parent = workspace

			local spawn = task.spawn
			local v503 = Folder2
			local v504 = Folder

			spawn(function()
				task.wait(0.05)
				v503.Parent = v504
			end)

			local WFC_Test = Folder:WaitForChild("WFC_Test", 1)

			Folder:Destroy()

			return WFC_Test == Folder2
		end,
	},
	{
		"WaitForChild times out correctly",
		function()
			local Folder = Instance.new("Folder")

			Folder.Parent = workspace
			local v508 = Folder
			local ok, result = pcall(function()
				return v508:WaitForChild("NonExistent", 0.1)
			end)

			Folder:Destroy()

			if not ok then
				return ok
			end

			ok = result == nil

			return ok
		end,
	},
	{
		"FindFirstChildWhichIsA returns correct child",
		function()
			local Folder = Instance.new("Folder")
			local Part = Instance.new("Part")

			Part.Parent = Folder

			local BasePart = Folder:FindFirstChildWhichIsA("BasePart")

			Folder:Destroy()

			return BasePart == Part
		end,
	},
	{
		"FindFirstAncestorOfClass returns correct ancestor",
		function()
			local Folder = Instance.new("Folder")
			local Folder2 = Instance.new("Folder")

			Folder.Parent = workspace
			Folder2.Parent = Folder

			local Folder3 = Folder2:FindFirstAncestorOfClass("Folder")

			Folder:Destroy()

			return Folder3 == Folder
		end,
	},
	{
		"FindFirstAncestorWhichIsA returns correct ancestor",
		function()
			local Folder = Instance.new("Folder")
			local Folder2 = Instance.new("Folder")

			Folder.Parent = workspace
			Folder2.Parent = Folder

			local Instance_ = Folder2:FindFirstAncestorWhichIsA("Instance")

			Folder:Destroy()

			return Instance_ ~= nil
		end,
	},
	{
		"GetDescendants returns table",
		function()
			local Folder = Instance.new("Folder")

			Instance.new("Folder").Parent = Folder

			local descendants = Folder:GetDescendants()

			Folder:Destroy()
			local v522

			if type(descendants) ~= "table" then
				v522 = false
			else
				v522 = #descendants == 1
			end

			return v522
		end,
	},
	{
		"GetFullName returns string",
		function()
			local Folder = Instance.new("Folder")

			Folder.Name = "TestFolder"
			Folder.Parent = workspace

			local fullName = Folder:GetFullName()

			Folder:Destroy()
			local v525

			if type(fullName) ~= "string" then
				v525 = false
			else
				v525 = fullName:find("TestFolder") ~= nil
			end

			return v525
		end,
	},
	{
		"Clone returns identical instance",
		function()
			local Folder = Instance.new("Folder")

			Folder.Name = "CloneTest"
			Folder.Parent = workspace

			local clone = Folder:Clone()

			Folder:Destroy()
			local v528

			if clone == nil then
				v528 = false
			else
				v528 = clone.Name == "CloneTest"
			end

			return v528
		end,
	},
	{
		"IsAncestorOf returns correct result",
		function()
			local Folder = Instance.new("Folder")
			local Folder2 = Instance.new("Folder")

			Folder2.Parent = Folder
			Folder.Parent = workspace

			local v531 = Folder:IsAncestorOf(Folder2)

			Folder:Destroy()

			return v531 == true
		end,
	},
	{
		"GetPropertyChangedSignal returns RBXScriptSignal",
		function()
			local Folder = Instance.new("Folder")
			local v533 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Folder:GetPropertyChangedSignal("Name"))
			local v537 = typeof(unpack(v533, 1, v533.n)) == "RBXScriptSignal"

			Folder:Destroy()

			return v537
		end,
	},
	{
		"ChildAdded fires correctly",
		function()
			local Folder = Instance.new("Folder")

			Folder.Parent = workspace
			local u539

			Folder.ChildAdded:Once(function()
				u539 = true
			end)
			Instance.new("Folder").Parent = Folder
			task.wait()
			Folder:Destroy()

			return false
		end,
	},
	{
		"ChildRemoved fires correctly",
		function()
			local Folder = Instance.new("Folder")

			Folder.Parent = workspace

			local Folder2 = Instance.new("Folder")

			Folder2.Parent = Folder
			local u542

			Folder.ChildRemoved:Once(function()
				u542 = true
			end)
			Folder2:Destroy()
			task.wait()
			Folder:Destroy()

			return false
		end,
	},
	{
		"AncestryChanged fires correctly",
		function()
			local Folder = Instance.new("Folder")
			local u544

			Folder.AncestryChanged:Once(function()
				u544 = true
			end)
			Folder.Parent = workspace
			task.wait()
			Folder:Destroy()

			return false
		end,
	},
})
v25("Humanoid jump physics using HumanoidStateType.Jumping ", {
	{
		"LocalPlayer exists",
		function()
			return game:GetService("Players").LocalPlayer ~= nil
		end,
	},
	{
		"Character exists",
		function()
			return game:GetService("Players").LocalPlayer.Character ~= nil
		end,
	},
	{
		"Humanoid exists",
		function()
			return game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid") ~= nil
		end,
	},
	{
		"Humanoid can jump via ChangeState",
		function()
			local Humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

			return pcall(function()
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end,
	},
	{
		"HumanoidRootPart Y increases after jump",
		function()
			local Character = game:GetService("Players").LocalPlayer.Character
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")

			if HumanoidRootPart and Humanoid then
				local Y = HumanoidRootPart.Position.Y

				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				task.wait(0.2)

				return Y < HumanoidRootPart.Position.Y
			else
				return false
			end
		end,
	},
	{
		"Humanoid state changes to Jumping",
		function()
			local Humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				task.wait(0.05)

				local state = Humanoid:GetState()

				return state == Enum.HumanoidStateType.Jumping and true or state == Enum.HumanoidStateType.Freefall
			else
				return false
			end
		end,
	},
})
v25("particle effects", {
	{
		"ForceField.ClassName correct",
		function()
			return Instance.new("ForceField").ClassName == "ForceField"
		end,
	},
	{
		"ForceField.Visible is boolean",
		function()
			local Visible = Instance.new("ForceField").Visible

			return type(Visible) == "boolean"
		end,
	},
	{
		"Explosion.ClassName correct",
		function()
			return Instance.new("Explosion").ClassName == "Explosion"
		end,
	},
	{
		"Explosion.BlastRadius is number",
		function()
			local BlastRadius = Instance.new("Explosion").BlastRadius

			return type(BlastRadius) == "number"
		end,
	},
	{
		"Explosion.Hit is RBXScriptSignal",
		function()
			local Hit = Instance.new("Explosion").Hit

			return typeof(Hit) == "RBXScriptSignal"
		end,
	},
	{
		"Fire.ClassName correct",
		function()
			return Instance.new("Fire").ClassName == "Fire"
		end,
	},
	{
		"Fire.Size is number",
		function()
			local Size = Instance.new("Fire").Size

			return type(Size) == "number"
		end,
	},
	{
		"Fire.Color is Color3",
		function()
			local Color = Instance.new("Fire").Color

			return typeof(Color) == "Color3"
		end,
	},
	{
		"Smoke.ClassName correct",
		function()
			return Instance.new("Smoke").ClassName == "Smoke"
		end,
	},
	{
		"Smoke.Size is number",
		function()
			local Size = Instance.new("Smoke").Size

			return type(Size) == "number"
		end,
	},
	{
		"Smoke.Color is Color3",
		function()
			local Color = Instance.new("Smoke").Color

			return typeof(Color) == "Color3"
		end,
	},
	{
		"Sparkles.ClassName correct",
		function()
			return Instance.new("Sparkles").ClassName == "Sparkles"
		end,
	},
	{
		"Sparkles.SparkleColor is Color3",
		function()
			local SparkleColor = Instance.new("Sparkles").SparkleColor

			return typeof(SparkleColor) == "Color3"
		end,
	},
	{
		"HumanoidDescription.ClassName correct",
		function()
			return Instance.new("HumanoidDescription").ClassName == "HumanoidDescription"
		end,
	},
	{
		"HumanoidDescription.HeadScale is number",
		function()
			local HeadScale = Instance.new("HumanoidDescription").HeadScale

			return type(HeadScale) == "number"
		end,
	},
})
v25("constraints and forces", {
	{
		"NoCollisionConstraint.ClassName correct",
		function()
			return Instance.new("NoCollisionConstraint").ClassName == "NoCollisionConstraint"
		end,
	},
	{
		"HingeConstraint.ClassName correct",
		function()
			return Instance.new("HingeConstraint").ClassName == "HingeConstraint"
		end,
	},
	{
		"HingeConstraint.ActuatorType is EnumItem",
		function()
			local ActuatorType = Instance.new("HingeConstraint").ActuatorType

			return typeof(ActuatorType) == "EnumItem"
		end,
	},
	{
		"SpringConstraint.ClassName correct",
		function()
			return Instance.new("SpringConstraint").ClassName == "SpringConstraint"
		end,
	},
	{
		"SpringConstraint.Stiffness is number",
		function()
			local Stiffness = Instance.new("SpringConstraint").Stiffness

			return type(Stiffness) == "number"
		end,
	},
	{
		"RopeConstraint.ClassName correct",
		function()
			return Instance.new("RopeConstraint").ClassName == "RopeConstraint"
		end,
	},
	{
		"RopeConstraint.Length is number",
		function()
			local Length = Instance.new("RopeConstraint").Length

			return type(Length) == "number"
		end,
	},
	{
		"RodConstraint.ClassName correct",
		function()
			return Instance.new("RodConstraint").ClassName == "RodConstraint"
		end,
	},
	{
		"RodConstraint.Length is number",
		function()
			local Length = Instance.new("RodConstraint").Length

			return type(Length) == "number"
		end,
	},
	{
		"PrismaticConstraint.ClassName correct",
		function()
			return Instance.new("PrismaticConstraint").ClassName == "PrismaticConstraint"
		end,
	},
	{
		"CylindricalConstraint.ClassName correct",
		function()
			return Instance.new("CylindricalConstraint").ClassName == "CylindricalConstraint"
		end,
	},
	{
		"BallSocketConstraint.ClassName correct",
		function()
			return Instance.new("BallSocketConstraint").ClassName == "BallSocketConstraint"
		end,
	},
	{
		"UniversalConstraint.ClassName correct",
		function()
			return Instance.new("UniversalConstraint").ClassName == "UniversalConstraint"
		end,
	},
	{
		"Torque.ClassName correct",
		function()
			return Instance.new("Torque").ClassName == "Torque"
		end,
	},
	{
		"VectorForce.ClassName correct",
		function()
			return Instance.new("VectorForce").ClassName == "VectorForce"
		end,
	},
	{
		"DragDetector.ClassName correct",
		function()
			return Instance.new("DragDetector").ClassName == "DragDetector"
		end,
	},
	{
		"DragDetector.DragStart is RBXScriptSignal",
		function()
			local DragStart = Instance.new("DragDetector").DragStart

			return typeof(DragStart) == "RBXScriptSignal"
		end,
	},
})
v25("GUI textlabel properties", {
	{
		"TextLabel.TextTruncate is EnumItem",
		function()
			local TextTruncate = Instance.new("TextLabel").TextTruncate

			return typeof(TextTruncate) == "EnumItem"
		end,
	},
	{
		"TextLabel.TextXAlignment is EnumItem",
		function()
			local TextXAlignment = Instance.new("TextLabel").TextXAlignment

			return typeof(TextXAlignment) == "EnumItem"
		end,
	},
	{
		"TextLabel.TextYAlignment is EnumItem",
		function()
			local TextYAlignment = Instance.new("TextLabel").TextYAlignment

			return typeof(TextYAlignment) == "EnumItem"
		end,
	},
	{
		"TextLabel.Font is EnumItem",
		function()
			local Font_ = Instance.new("TextLabel").Font

			return typeof(Font_) == "EnumItem"
		end,
	},
	{
		"TextLabel.FontFace is Font",
		function()
			local FontFace = Instance.new("TextLabel").FontFace

			return typeof(FontFace) == "Font"
		end,
	},
	{
		"TextLabel.TextColor3 is Color3",
		function()
			local TextColor3 = Instance.new("TextLabel").TextColor3

			return typeof(TextColor3) == "Color3"
		end,
	},
	{
		"TextLabel.TextStrokeColor3 is Color3",
		function()
			local TextStrokeColor3 = Instance.new("TextLabel").TextStrokeColor3

			return typeof(TextStrokeColor3) == "Color3"
		end,
	},
	{
		"TextLabel.TextStrokeTransparency is number",
		function()
			local TextStrokeTransparency = Instance.new("TextLabel").TextStrokeTransparency

			return type(TextStrokeTransparency) == "number"
		end,
	},
})
v25("GUI frame properties", {
	{
		"Frame.Position is UDim2",
		function()
			local Frame = Instance.new("Frame")
			local Position = Frame.Position
			local v576 = typeof(Position) == "UDim2"

			Frame:Destroy()

			return v576
		end,
	},
	{
		"Frame.Size is UDim2",
		function()
			local Frame = Instance.new("Frame")
			local Size = Frame.Size
			local v579 = typeof(Size) == "UDim2"

			Frame:Destroy()

			return v579
		end,
	},
	{
		"Frame.AnchorPoint is Vector2",
		function()
			local Frame = Instance.new("Frame")
			local AnchorPoint = Frame.AnchorPoint
			local v582 = typeof(AnchorPoint) == "Vector2"

			Frame:Destroy()

			return v582
		end,
	},
	{
		"Frame.BorderColor3 is Color3",
		function()
			local Frame = Instance.new("Frame")
			local BorderColor3 = Frame.BorderColor3
			local v585 = typeof(BorderColor3) == "Color3"

			Frame:Destroy()

			return v585
		end,
	},
	{
		"Frame.Rotation is number",
		function()
			local Frame = Instance.new("Frame")
			local Rotation = Frame.Rotation
			local v588 = type(Rotation) == "number"

			Frame:Destroy()

			return v588
		end,
	},
	{
		"Frame.ZIndex is number",
		function()
			local Frame = Instance.new("Frame")
			local ZIndex = Frame.ZIndex
			local v591 = type(ZIndex) == "number"

			Frame:Destroy()

			return v591
		end,
	},
	{
		"Frame.LayoutOrder is number",
		function()
			local Frame = Instance.new("Frame")
			local LayoutOrder = Frame.LayoutOrder
			local v594 = type(LayoutOrder) == "number"

			Frame:Destroy()

			return v594
		end,
	},
	{
		"Frame.Visible is boolean",
		function()
			local Frame = Instance.new("Frame")
			local Visible = Frame.Visible
			local v597 = type(Visible) == "boolean"

			Frame:Destroy()

			return v597
		end,
	},
	{
		"Frame.Active is boolean",
		function()
			local Frame = Instance.new("Frame")
			local Active = Frame.Active
			local v600 = type(Active) == "boolean"

			Frame:Destroy()

			return v600
		end,
	},
	{
		"Frame.ClipsDescendants is boolean",
		function()
			local Frame = Instance.new("Frame")
			local ClipsDescendants = Frame.ClipsDescendants
			local v603 = type(ClipsDescendants) == "boolean"

			Frame:Destroy()

			return v603
		end,
	},
	{
		"Frame.Selectable is boolean",
		function()
			local Frame = Instance.new("Frame")
			local Selectable = Frame.Selectable
			local v606 = type(Selectable) == "boolean"

			Frame:Destroy()

			return v606
		end,
	},
	{
		"Frame.Interactable is boolean",
		function()
			local Frame = Instance.new("Frame")
			local Interactable = Frame.Interactable
			local v609 = type(Interactable) == "boolean"

			Frame:Destroy()

			return v609
		end,
	},
})
v25("Workspace properties and functions work", {
	{
		"workspace.DistributedGameTime is number",
		function()
			local DistributedGameTime = workspace.DistributedGameTime

			return type(DistributedGameTime) == "number"
		end,
	},
	{
		"workspace.Gravity is writable",
		function()
			local Gravity = workspace.Gravity

			workspace.Gravity = 100

			local v612 = workspace.Gravity == 100

			workspace.Gravity = Gravity

			return v612
		end,
	},
	{
		"workspace.FallenPartsDestroyHeight is number",
		function()
			local FallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight

			return type(FallenPartsDestroyHeight) == "number"
		end,
	},
	{
		"workspace:GetPartsInPart returns table",
		function()
			local Part = Instance.new("Part")

			Part.Size = Vector3.new(100, 100, 100)
			Part.Position = Vector3.new(0, 0, 0)
			Part.Parent = workspace

			local v615 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(workspace:GetPartsInPart(Part))
			local v619 = type(unpack(v615, 1, v615.n)) == "table"

			Part:Destroy()

			return v619
		end,
	},
	{
		"workspace:GetPartBoundsInBox returns table",
		function()
			local function v620(...)
				return {
					...,
					n = select("#", ...),
				}
			end
			local cFrame = CFrame.new(0, 0, 0)
			local v623 = v620(Vector3.new(10, 10, 10))
			local v628 = v620(workspace:GetPartBoundsInBox(cFrame, unpack(v623, 1, v623.n)))

			return type(unpack(v628, 1, v628.n)) == "table"
		end,
	},
	{
		"workspace:GetPartBoundsInRadius returns table",
		function()
			local v636 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(workspace:GetPartBoundsInRadius(Vector3.new(0, 0, 0), 10))

			return type(unpack(v636, 1, v636.n)) == "table"
		end,
	},
})
v25("Part properties and signals", {
	{
		"Part.Massless is boolean",
		function()
			local Part = Instance.new("Part")
			local Massless = Part.Massless
			local v645 = type(Massless) == "boolean"

			Part:Destroy()

			return v645
		end,
	},
	{
		"Part.RootPriority is number",
		function()
			local Part = Instance.new("Part")
			local RootPriority = Part.RootPriority
			local v648 = type(RootPriority) == "number"

			Part:Destroy()

			return v648
		end,
	},
	{
		"Part.CollisionGroup is string",
		function()
			local Part = Instance.new("Part")
			local CollisionGroup = Part.CollisionGroup
			local v651 = type(CollisionGroup) == "string"

			Part:Destroy()

			return v651
		end,
	},
	{
		"Part.CastShadow is boolean",
		function()
			local Part = Instance.new("Part")
			local CastShadow = Part.CastShadow
			local v654 = type(CastShadow) == "boolean"

			Part:Destroy()

			return v654
		end,
	},
	{
		"Part.CanQuery is boolean",
		function()
			local Part = Instance.new("Part")
			local CanQuery = Part.CanQuery
			local v657 = type(CanQuery) == "boolean"

			Part:Destroy()

			return v657
		end,
	},
	{
		"Part.CanTouch is boolean",
		function()
			local Part = Instance.new("Part")
			local CanTouch = Part.CanTouch
			local v660 = type(CanTouch) == "boolean"

			Part:Destroy()

			return v660
		end,
	},
	{
		"Part.Touched is RBXScriptSignal",
		function()
			local Part = Instance.new("Part")
			local Touched = Part.Touched
			local v663 = typeof(Touched) == "RBXScriptSignal"

			Part:Destroy()

			return v663
		end,
	},
	{
		"Part.TouchEnded is RBXScriptSignal",
		function()
			local Part = Instance.new("Part")
			local TouchEnded = Part.TouchEnded
			local v666 = typeof(TouchEnded) == "RBXScriptSignal"

			Part:Destroy()

			return v666
		end,
	},
	{
		"Part:GetMass returns positive number",
		function()
			local Part = Instance.new("Part")

			Part.Parent = workspace
			Part.Anchored = true
			local v669 = Part
			local ok, result = pcall(function()
				return v669:GetMass()
			end)

			Part:Destroy()

			if not ok then
				return ok
			end

			if type(result) ~= "number" then
				ok = false
			else
				ok = result > 0
			end

			return ok
		end,
	},
	{
		"Part:GetTouchingParts returns table",
		function()
			local Part = Instance.new("Part")

			Part.Parent = workspace
			Part.Anchored = true
			local v674 = Part
			local ok, result = pcall(function()
				return v674:GetTouchingParts()
			end)

			Part:Destroy()

			if not ok then
				return ok
			end

			ok = type(result) == "table"

			return ok
		end,
	},
})
v25("LocalPlayer & Players service(s)", {
	{
		"Players.LocalPlayer exists",
		function()
			return game:GetService("Players").LocalPlayer ~= nil
		end,
	},
	{
		"LocalPlayer.Character is nil or Model",
		function()
			local Character = game:GetService("Players").LocalPlayer.Character
			local v678

			if Character == nil then
				v678 = true
			elseif typeof(Character) ~= "Instance" then
				v678 = false
			else
				v678 = Character:IsA("Model")
			end

			return v678
		end,
	},
	{
		"LocalPlayer.CharacterAdded is RBXScriptSignal",
		function()
			local CharacterAdded = game:GetService("Players").LocalPlayer.CharacterAdded

			return typeof(CharacterAdded) == "RBXScriptSignal"
		end,
	},
	{
		"LocalPlayer.CharacterRemoving is RBXScriptSignal",
		function()
			local CharacterRemoving = game:GetService("Players").LocalPlayer.CharacterRemoving

			return typeof(CharacterRemoving) == "RBXScriptSignal"
		end,
	},
	{
		"LocalPlayer.AccountAge is number",
		function()
			local AccountAge = game:GetService("Players").LocalPlayer.AccountAge

			return type(AccountAge) == "number"
		end,
	},
	{
		"LocalPlayer.MembershipType is EnumItem",
		function()
			local MembershipType = game:GetService("Players").LocalPlayer.MembershipType

			return typeof(MembershipType) == "EnumItem"
		end,
	},
	{
		"LocalPlayer:GetMouse returns PlayerMouse",
		function()
			local ok, result = pcall(function()
				return game:GetService("Players").LocalPlayer:GetMouse()
			end)

			if not ok then
				return ok
			end

			if result == nil then
				ok = false
			else
				ok = result.ClassName == "PlayerMouse"
			end

			return ok
		end,
	},
	{
		"Players.PlayerAdded is RBXScriptSignal",
		function()
			local PlayerAdded = game:GetService("Players").PlayerAdded

			return typeof(PlayerAdded) == "RBXScriptSignal"
		end,
	},
	{
		"Players.PlayerRemoving is RBXScriptSignal",
		function()
			local PlayerRemoving = game:GetService("Players").PlayerRemoving

			return typeof(PlayerRemoving) == "RBXScriptSignal"
		end,
	},
	{
		"Players:GetPlayers returns table",
		function()
			local ok, result = pcall(function()
				return game:GetService("Players"):GetPlayers()
			end)

			if not ok then
				return ok
			end

			ok = type(result) == "table"

			return ok
		end,
	},
	{
		"Players:GetPlayerFromCharacter returns correct player",
		function()
			local Players = game:GetService("Players")
			local LocalPlayer = Players.LocalPlayer
			local Character = LocalPlayer.Character

			if not Character then
				return true
			end
			local v693 = Players
			local v694 = Character
			local ok, result = pcall(function()
				return v693:GetPlayerFromCharacter(v694)
			end)

			if not ok then
				return ok
			end

			ok = result == LocalPlayer

			return ok
		end,
	},
})
v25("StarterPlayer", {
	{
		"StarterPlayer.ClassName correct",
		function()
			return game:GetService("StarterPlayer").ClassName == "StarterPlayer"
		end,
	},
	{
		"StarterPlayer has StarterPlayerScripts",
		function()
			return game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") ~= nil
		end,
	},
	{
		"StarterPlayer has StarterCharacterScripts",
		function()
			return game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts") ~= nil
		end,
	},
	{
		"StarterPack.ClassName correct",
		function()
			return game:GetService("StarterPack").ClassName == "StarterPack"
		end,
	},
})
v25("Vector3 properties and methods", {
	{
		"Vector3.X Y Z correct",
		function()
			local vector3 = Vector3.new(1, 2, 3)
			local v698

			if vector3.X ~= 1 or vector3.Y ~= 2 then
				v698 = false
			else
				v698 = vector3.Z == 3
			end

			return v698
		end,
	},
	{
		"Vector3.Magnitude correct",
		function()
			local v699 = Vector3.new(3, 4, 0).Magnitude - 5

			return math.abs(v699) < 0.001
		end,
	},
	{
		"Vector3.Unit correct",
		function()
			local v700 = Vector3.new(0, 5, 0).Unit.Y - 1

			return math.abs(v700) < 0.001
		end,
	},
	{
		"Vector3.zero is 0,0,0",
		function()
			return Vector3.zero == Vector3.new(0, 0, 0)
		end,
	},
	{
		"Vector3.one is 1,1,1",
		function()
			return Vector3.one == Vector3.new(1, 1, 1)
		end,
	},
	{
		"Vector3.xAxis is 1,0,0",
		function()
			return Vector3.xAxis == Vector3.new(1, 0, 0)
		end,
	},
	{
		"Vector3.yAxis is 0,1,0",
		function()
			return Vector3.yAxis == Vector3.new(0, 1, 0)
		end,
	},
	{
		"Vector3.zAxis is 0,0,1",
		function()
			return Vector3.zAxis == Vector3.new(0, 0, 1)
		end,
	},
	{
		"Vector3.FromNormalId returns Vector3",
		function()
			local v701 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.FromNormalId(Enum.NormalId.Top))

			return typeof(unpack(v701, 1, v701.n)) == "Vector3"
		end,
	},
	{
		"Vector3.FromAxis returns Vector3",
		function()
			local v704 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.FromAxis(Enum.Axis.X))

			return typeof(unpack(v704, 1, v704.n)) == "Vector3"
		end,
	},
	{
		"Vector3:Dot correct",
		function()
			local vector3 = Vector3.new(1, 0, 0)
			local v708 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 1, 0))

			return vector3:Dot(unpack(v708, 1, v708.n)) == 0
		end,
	},
	{
		"Vector3:Cross correct",
		function()
			local vector3 = Vector3.new(1, 0, 0)
			local v714 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 1, 0))

			return vector3:Cross(unpack(v714, 1, v714.n)).Z == 1
		end,
	},
	{
		"Vector3:Cross result is orthogonal to both inputs",
		function()
			local function v719(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local vector3 = Vector3.new(1, 0, 0)
			local vector32 = Vector3.new(0, 1, 0)
			local v722 = vector3:Cross(vector32)
			local v723 = v722:Dot(vector3)
			local v724

			if math.abs(v723) >= 1e-9 then
				v724 = false
			else
				local v725 = v722:Dot(vector32)

				if math.abs(v725) >= 1e-9 then
					v724 = false
				else
					local v726 = v719(Vector3.new(0, 0, 1))
					local v731 = v722:Dot(unpack(v726, 1, v726.n)) - 1

					v724 = math.abs(v731) < 1e-9
				end
			end

			return v724
		end,
	},
	{
		"Vector3:Lerp correct",
		function()
			return Vector3.new(0, 0, 0):Lerp(Vector3.new(10, 0, 0), 0.5).X == 5
		end,
	},
	{
		"Vector3:Abs correct",
		function()
			return Vector3.new(-2, 4, -6):Abs() == Vector3.new(2, 4, 6)
		end,
	},
	{
		"Vector3:Ceil correct",
		function()
			return Vector3.new(-2.6, 5.1, 8.8):Ceil() == Vector3.new(-2, 6, 9)
		end,
	},
	{
		"Vector3:Floor correct",
		function()
			return Vector3.new(-2.6, 5.1, 8.8):Floor() == Vector3.new(-3, 5, 8)
		end,
	},
	{
		"Vector3:Sign correct",
		function()
			return Vector3.new(-2.6, 5.1, 0):Sign() == Vector3.new(-1, 1, 0)
		end,
	},
	{
		"Vector3:Angle returns number",
		function()
			local function v732(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local vector3 = Vector3.new(1, 0, 0)
			local v734 = v732(Vector3.new(0, 1, 0))
			local v739 = v732(vector3:Angle(unpack(v734, 1, v734.n)))

			return type(unpack(v739, 1, v739.n)) == "number"
		end,
	},
	{
		"Vector3:FuzzyEq correct",
		function()
			local function v746(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local vector3 = Vector3.new(1, 1, 1)
			local v748 = v746(Vector3.new(1, 1, 1))
			local v753 = v746(vector3:FuzzyEq(unpack(v748, 1, v748.n)))

			return unpack(v753, 1, v753.n)
		end,
	},
	{
		"Vector3:Max correct",
		function()
			local vector3 = Vector3.new(1, 2, 1)
			local v755 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(2, 1, 2))

			return vector3:Max(unpack(v755, 1, v755.n)) == Vector3.new(2, 2, 2)
		end,
	},
	{
		"Vector3:Min correct",
		function()
			local vector3 = Vector3.new(1, 2, 1)
			local v761 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(2, 1, 2))

			return vector3:Min(unpack(v761, 1, v761.n)) == Vector3.new(1, 1, 1)
		end,
	},
	{
		"Vector3 + Vector3 correct",
		function()
			return Vector3.new(1, 2, 3) + Vector3.new(4, 5, 6) == Vector3.new(5, 7, 9)
		end,
	},
	{
		"Vector3 - Vector3 correct",
		function()
			return Vector3.new(5, 7, 9) - Vector3.new(4, 5, 6) == Vector3.new(1, 2, 3)
		end,
	},
	{
		"Vector3 * Vector3 correct",
		function()
			return Vector3.new(2, 3, 4) * Vector3.new(5, 6, 7) == Vector3.new(10, 18, 28)
		end,
	},
	{
		"Vector3 / Vector3 correct",
		function()
			return Vector3.new(10, 18, 28) / Vector3.new(5, 6, 7) == Vector3.new(2, 3, 4)
		end,
	},
	{
		"Vector3 * number correct",
		function()
			return Vector3.new(2, 3, 4) * 2 == Vector3.new(4, 6, 8)
		end,
	},
	{
		"Vector3 / number correct",
		function()
			return Vector3.new(4, 6, 8) / 2 == Vector3.new(2, 3, 4)
		end,
	},
})
v25("coroutine suspend correctness", {
	{
		"coroutine status is suspended after yield",
		function()
			local thread = coroutine.create(function()
				coroutine.yield()
			end)

			coroutine.resume(thread)

			return coroutine.status(thread) == "suspended"
		end,
	},
})
v25("Property clamping and validation", {
	{
		"Color3 out of range is clamped or rejected",
		function()
			local Part = Instance.new("Part")

			Part.Color = Color3.new(0, 0, 0)
			Part.Parent = workspace
			local v769 = Part

			pcall(function()
				v769.Color = Color3.new(256, 0, 0)
			end)

			local v770 = Part.Color == Color3.new(0, 0, 0)

			Part:Destroy()

			return v770
		end,
	},
	{
		"CameraMinZoomDistance rejects negative values",
		function()
			local LocalPlayer = game:GetService("Players").LocalPlayer
			local CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance
			local v774 = LocalPlayer

			pcall(function()
				v774.CameraMinZoomDistance = -5
			end)

			return LocalPlayer.CameraMinZoomDistance == CameraMinZoomDistance
		end,
	},
	{
		"Terrain.WaterWaveSpeed clamps to max",
		function()
			local Terrain = workspace.Terrain
			local v777 = Terrain

			if pcall(function()
				v777.WaterWaveSpeed = 9000000000
			end) then
				return Terrain.WaterWaveSpeed == 100
			else
				return false
			end
		end,
	},
})
v25("GetChildren mutation correctness", {
	{
		"GetChildren snapshot is immutable to parent changes",
		function()
			local Folder = Instance.new("Folder", workspace)
			local Part = Instance.new("Part", Folder)
			local children = Folder:GetChildren()

			Part.Parent = nil

			local children2 = Folder:GetChildren()

			Folder:Destroy()
			local v782

			if #children ~= 1 then
				v782 = false
			else
				v782 = #children2 == 0
			end

			return v782
		end,
	},
})
v25("LogService.MessageOut signal", {
	{
		"LogService.MessageOut is RBXScriptSignal",
		function()
			local MessageOut = game:GetService("LogService").MessageOut

			return typeof(MessageOut) == "RBXScriptSignal"
		end,
	},
})
v25("Enum structural integrity", {
	{
		"EnumItem.EnumType points back to parent Enum",
		function()
			local enumItems = Enum.ConnectionError:GetEnumItems()

			for _, enumItem in ipairs(enumItems) do
				if enumItem.EnumType ~= Enum.ConnectionError then
					return false
				end
			end

			return true
		end,
	},
	{
		"Enum.ConnectionError has required items",
		function()
			local OK = Enum.ConnectionError.OK
			local v788

			if typeof(OK) ~= "EnumItem" then
				v788 = false
			else
				local Unknown = Enum.ConnectionError.Unknown

				if typeof(Unknown) ~= "EnumItem" then
					v788 = false
				else
					local ConnectErrors = Enum.ConnectionError.ConnectErrors

					v788 = typeof(ConnectErrors) == "EnumItem"
				end
			end

			return v788
		end,
	},
	{
		"EnumItem names are unique within Enum",
		function()
			local enumItems = Enum.ConnectionError:GetEnumItems()
			local v792, v793, v794 = ipairs(enumItems)
			local t12 = {}

			while true do
				local v796

				v794, v796 = v792(v793, v794)

				if v794 == nil then
					break
				end

				if t12[v796.Name] then
					return false
				end

				t12[v796.Name] = true
			end

			return true
		end,
	},
	{
		"EnumItem values are unique within Enum",
		function()
			local enumItems = Enum.ConnectionError:GetEnumItems()
			local v798, v799, v800 = ipairs(enumItems)
			local t13 = {}

			while true do
				local v802

				v800, v802 = v798(v799, v800)

				if v800 == nil then
					break
				end

				if t13[v802.Value] then
					return false
				end

				t13[v802.Value] = true
			end

			return true
		end,
	},
	{
		"Enum index returns same EnumItem as GetEnumItems",
		function()
			local enumItems = Enum.ConnectionError:GetEnumItems()

			for _, enumItem in ipairs(enumItems) do
				if Enum.ConnectionError[enumItem.Name] ~= enumItem then
					return false
				end
			end

			return true
		end,
	},
})
v25("task.defer and coroutine ordering", {
	{
		"deferred tasks across folders resolve correctly",
		function()
			local t14 = {}
			local n6 = 0

			for i = 1, 6 do
				local Folder = Instance.new("Folder")
				local defer = task.defer
				local v811 = i
				local v812 = Folder
				local v813 = t14

				defer(function()
					for i2 = 1, 4 do
						local NumberValue = Instance.new("NumberValue")

						NumberValue.Value = v811 * i2
						NumberValue.Parent = v812
						v813[#v813 + 1] = NumberValue
						n6 = n6 + 1
						task.wait()
					end
				end)
			end

			local now = tick()

			repeat
				task.wait()
			until n6 == 24 or tick() - now > 3

			return #t14 == 24
		end,
	},
	{
		"deferred value accumulation is deterministic",
		function()
			local t15 = {}
			local n7 = 0
			local n8 = 0

			for i = 1, 6 do
				local Folder = Instance.new("Folder")
				local defer = task.defer
				local v823 = i
				local v824 = Folder
				local v825 = t15

				defer(function()
					for i2 = 1, 4 do
						local NumberValue = Instance.new("NumberValue")

						NumberValue.Value = v823 * i2
						NumberValue.Parent = v824
						v825[#v825 + 1] = NumberValue
						n7 = n7 + 1
						task.wait()
					end
				end)
			end

			local now = tick()

			repeat
				task.wait()
			until n7 == 24 or tick() - now > 3

			for i = 1, #t15 do
				local defer = task.defer
				local v831 = t15
				local v832 = i

				defer(function()
					local v833 = v831[v832]

					n8 = n8 + (v833.Value + v832 + #v833.Parent:GetChildren())
					task.wait()
				end)
			end

			repeat
				task.wait()
			until n8 > 0 or tick() - now > 5

			return n8 == 606
		end,
	},
})
v25("coroutine and task interleaving", {
	{
		"ClearAllChildren during deferred parent chain",
		function()
			local Folder = Instance.new("Folder")
			local Folder2 = Instance.new("Folder")
			local MeshPart = Instance.new("MeshPart")
			local t16 = {}
			local resume = coroutine.resume
			local create = coroutine.create
			local v840 = MeshPart
			local v841 = Folder2
			local v842 = Folder
			local v843 = t16

			resume(create(function()
				v840.Parent = v841
				v841.Parent = v842
				task.defer(function()
					v843.p = v840.Parent
					v843.g = v841.Parent
					task.spawn(function()
						v842:ClearAllChildren()
					end)
				end)
			end))

			local resume2 = coroutine.resume
			local create2 = coroutine.create
			local v846 = t16
			local v847 = MeshPart

			resume2(create2(function()
				task.defer(function()
					v846.s = v847:GetAttribute("s") or 0
					v847:SetAttribute("s", "x")
				end)
			end))
			task.wait(0.07)
			local v848

			if MeshPart.Parent ~= nil or (Folder2.Parent ~= nil or (t16.p ~= Folder2 or t16.g ~= Folder)) then
				v848 = false
			else
				v848 = t16.s == 0
			end

			return v848
		end,
	},
	{
		"Destroy during deferred name mutation",
		function()
			local Folder = Instance.new("Folder")
			local Folder2 = Instance.new("Folder")
			local Part = Instance.new("Part")
			local t17 = {}
			local create = coroutine.create
			local v854 = Part
			local v855 = Folder2
			local v856 = Folder
			local v857 = t17
			local thread = create(function()
				v854.Parent = v855
				v855.Parent = v856
				task.defer(function()
					v857[1] = v854.Parent
					v857[2] = v855.Parent
					task.spawn(function()
						v856:Destroy()
					end)
				end)
			end)
			local create2 = coroutine.create
			local v860 = t17
			local v861 = Part
			local thread2 = create2(function()
				task.defer(function()
					v860[3] = v861.Name
					v861.Name = "dxfc was here (credits to him for inspiration for eUNC)"
				end)
			end)

			coroutine.resume(thread)
			coroutine.resume(thread2)
			task.wait(0.065)
			local v863

			if Part.Parent ~= nil or (Folder2.Parent ~= nil or (t17[1] ~= Folder2 or t17[2] ~= Folder)) then
				v863 = false
			else
				v863 = t17[3] == "Part"
			end

			return v863
		end,
	},
})
v25("Vector2 properties and methods", {
	{
		"Vector2.X Y correct",
		function()
			local vector2 = Vector2.new(3, 4)
			local v865

			if vector2.X ~= 3 then
				v865 = false
			else
				v865 = vector2.Y == 4
			end

			return v865
		end,
	},
	{
		"Vector2.Magnitude correct",
		function()
			return Vector2.new(3, 4).Magnitude == 5
		end,
	},
	{
		"Vector2.Unit correct",
		function()
			local v866 = Vector2.new(0, 5).Unit.Y - 1

			return math.abs(v866) < 0.001
		end,
	},
	{
		"Vector2.zero is Vector2",
		function()
			local vector2 = Vector2.zero

			return typeof(vector2) == "Vector2"
		end,
	},
	{
		"Vector2.zero is 0,0",
		function()
			local v868

			if Vector2.zero.X ~= 0 then
				v868 = false
			else
				v868 = Vector2.zero.Y == 0
			end

			return v868
		end,
	},
	{
		"Vector2.one is Vector2",
		function()
			local vector2 = Vector2.one

			return typeof(vector2) == "Vector2"
		end,
	},
	{
		"Vector2.one is 1,1",
		function()
			local v870

			if Vector2.one.X ~= 1 then
				v870 = false
			else
				v870 = Vector2.one.Y == 1
			end

			return v870
		end,
	},
	{
		"Vector2.xAxis is 1,0",
		function()
			local v871

			if Vector2.xAxis.X ~= 1 then
				v871 = false
			else
				v871 = Vector2.xAxis.Y == 0
			end

			return v871
		end,
	},
	{
		"Vector2.yAxis is 0,1",
		function()
			local v872

			if Vector2.yAxis.X ~= 0 then
				v872 = false
			else
				v872 = Vector2.yAxis.Y == 1
			end

			return v872
		end,
	},
	{
		"Vector2:Dot correct",
		function()
			local vector2 = Vector2.new(1, 0)
			local v874 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector2.new(0, 1))

			return vector2:Dot(unpack(v874, 1, v874.n)) == 0
		end,
	},
	{
		"Vector2:Cross correct",
		function()
			local function v878(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local vector2 = Vector2.new(1, 0)
			local v880 = v878(Vector2.new(0, 1))
			local v884 = v878(vector2:Cross(unpack(v880, 1, v880.n)))

			return type(unpack(v884, 1, v884.n)) == "number"
		end,
	},
	{
		"Vector2:Lerp correct",
		function()
			return Vector2.new(0, 0):Lerp(Vector2.new(10, 0), 0.5).X == 5
		end,
	},
	{
		"Vector2:Abs correct",
		function()
			return Vector2.new(-2, 4):Abs() == Vector2.new(2, 4)
		end,
	},
	{
		"Vector2:Ceil correct",
		function()
			return Vector2.new(-2.6, 5.1):Ceil() == Vector2.new(-2, 6)
		end,
	},
	{
		"Vector2:Floor correct",
		function()
			return Vector2.new(-2.6, 5.1):Floor() == Vector2.new(-3, 5)
		end,
	},
	{
		"Vector2:Sign correct",
		function()
			return Vector2.new(-2.6, 5.1):Sign() == Vector2.new(-1, 1)
		end,
	},
	{
		"Vector2:Angle returns number",
		function()
			local function v890(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local vector2 = Vector2.new(1, 0)
			local v892 = v890(Vector2.new(0, 1))
			local v896 = v890(vector2:Angle(unpack(v892, 1, v892.n)))

			return type(unpack(v896, 1, v896.n)) == "number"
		end,
	},
	{
		"Vector2:Max correct",
		function()
			local vector2 = Vector2.new(1, 2)
			local v903 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector2.new(2, 1))

			return vector2:Max(unpack(v903, 1, v903.n)) == Vector2.new(2, 2)
		end,
	},
	{
		"Vector2:Min correct",
		function()
			local vector2 = Vector2.new(1, 2)
			local v908 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector2.new(2, 1))

			return vector2:Min(unpack(v908, 1, v908.n)) == Vector2.new(1, 1)
		end,
	},
	{
		"Vector2:FuzzyEq correct",
		function()
			local function v912(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local vector2 = Vector2.new(1, 1)
			local v914 = v912(Vector2.new(1, 1))
			local v918 = v912(vector2:FuzzyEq(unpack(v914, 1, v914.n)))

			return unpack(v918, 1, v918.n)
		end,
	},
	{
		"Vector2 + Vector2 correct",
		function()
			return Vector2.new(1, 2) + Vector2.new(3, 4) == Vector2.new(4, 6)
		end,
	},
	{
		"Vector2 - Vector2 correct",
		function()
			return Vector2.new(4, 6) - Vector2.new(3, 4) == Vector2.new(1, 2)
		end,
	},
	{
		"Vector2 * Vector2 correct",
		function()
			return Vector2.new(2, 3) * Vector2.new(4, 5) == Vector2.new(8, 15)
		end,
	},
	{
		"Vector2 / Vector2 correct",
		function()
			return Vector2.new(8, 15) / Vector2.new(4, 5) == Vector2.new(2, 3)
		end,
	},
	{
		"Vector2 * number correct",
		function()
			return Vector2.new(2, 3) * 2 == Vector2.new(4, 6)
		end,
	},
	{
		"Vector2 / number correct",
		function()
			return Vector2.new(4, 6) / 2 == Vector2.new(2, 3)
		end,
	},
})
v25("SharedTable", {
	{
		"SharedTable.new empty returns correct type",
		function()
			local v919 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SharedTable.new())

			unpack(v919, 1, 1)

			return typeof(unpack(v919, 1, v919.n)) == "SharedTable"
		end,
	},
	{
		"SharedTable.new from table correct",
		function()
			local v920 = SharedTable.new({
				x = 1,
				y = 2,
			})
			local v921

			if v920.x ~= 1 then
				v921 = false
			else
				v921 = v920.y == 2
			end

			return v921
		end,
	},
	{
		"SharedTable element access by index",
		function()
			local v922 = SharedTable.new()

			v922[1] = "a"

			return v922[1] == "a"
		end,
	},
	{
		"SharedTable element access by string",
		function()
			local v923 = SharedTable.new()

			v923.x = 5

			return v923.x == 5
		end,
	},
	{
		"SharedTable invalid key errors",
		function()
			local v924 = SharedTable.new()

			return not pcall(function()
				v924[true] = 100
			end)
		end,
	},
	{
		"SharedTable invalid value errors",
		function()
			local v925 = SharedTable.new()

			return not pcall(function()
				function v925.f() end
			end)
		end,
	},
	{
		"SharedTable.size correct",
		function()
			local v926 = SharedTable.new({ "a", "b", "c" })

			return SharedTable.size(v926) == 3
		end,
	},
	{
		"SharedTable.clear works",
		function()
			local v927 = SharedTable.new({ "a", "b", "c" })

			SharedTable.clear(v927)

			return SharedTable.size(v927) == 0
		end,
	},
	{
		"SharedTable.clone returns SharedTable",
		function()
			local function v928(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local clone = SharedTable.clone
			local v930 = v928(SharedTable.new())
			local v931 = v928(clone(unpack(v930, 1, v930.n)))

			return typeof(unpack(v931, 1, v931.n)) == "SharedTable"
		end,
	},
	{
		"SharedTable.clone shallow correct",
		function()
			local v934 = SharedTable.new({
				x = 1,
			})

			return SharedTable.clone(v934).x == 1
		end,
	},
	{
		"SharedTable.clone deep correct",
		function()
			local v935 = SharedTable.new({
				x = 1,
			})

			return SharedTable.clone(v935, true).x == 1
		end,
	},
	{
		"SharedTable.cloneAndFreeze returns frozen",
		function()
			local v936 = SharedTable.new({
				x = 1,
			})
			local v937 = SharedTable.cloneAndFreeze(v936)

			return SharedTable.isFrozen(v937) == true
		end,
	},
	{
		"SharedTable.isFrozen false on new",
		function()
			return SharedTable.isFrozen(SharedTable.new()) == false
		end,
	},
	{
		"SharedTable frozen errors on write",
		function()
			local v938 = SharedTable.cloneAndFreeze(SharedTable.new({
				x = 1,
			}))

			return not pcall(function()
				v938.x = 2
			end)
		end,
	},
	{
		"SharedTable.increment correct",
		function()
			local v939 = SharedTable.new()

			v939.x = 1
			local v940

			if SharedTable.increment(v939, "x", 5) ~= 1 then
				v940 = false
			else
				v940 = v939.x == 6
			end

			return v940
		end,
	},
	{
		"SharedTable.update correct",
		function()
			local v941 = SharedTable.new()

			v941.x = 1
			SharedTable.update(v941, "x", function(p15)
				return p15 + 10
			end)

			return v941.x == 11
		end,
	},
})
v25("Vector2int16", {
	{
		"Vector2int16.new returns correct type",
		function()
			local v942 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector2int16.new(1, 2))

			return typeof(unpack(v942, 1, v942.n)) == "Vector2int16"
		end,
	},
	{
		"Vector2int16.X Y correct",
		function()
			local v946 = Vector2int16.new(3, 4)
			local v947

			if v946.X ~= 3 then
				v947 = false
			else
				v947 = v946.Y == 4
			end

			return v947
		end,
	},
	{
		"Vector2int16 non-integer rounds down",
		function()
			return Vector2int16.new(1.9, 2.9).X == 1
		end,
	},
	{
		"Vector2int16 + Vector2int16 correct",
		function()
			return Vector2int16.new(1, 2) + Vector2int16.new(3, 4) == Vector2int16.new(4, 6)
		end,
	},
	{
		"Vector2int16 - Vector2int16 correct",
		function()
			return Vector2int16.new(4, 6) - Vector2int16.new(3, 4) == Vector2int16.new(1, 2)
		end,
	},
	{
		"Vector2int16 * Vector2int16 correct",
		function()
			return Vector2int16.new(2, 3) * Vector2int16.new(4, 5) == Vector2int16.new(8, 15)
		end,
	},
	{
		"Vector2int16 / Vector2int16 correct",
		function()
			return Vector2int16.new(8, 15) / Vector2int16.new(4, 5) == Vector2int16.new(2, 3)
		end,
	},
	{
		"Vector2int16 * number correct",
		function()
			return Vector2int16.new(2, 3) * 2 == Vector2int16.new(4, 6)
		end,
	},
	{
		"Vector2int16 / number correct",
		function()
			return Vector2int16.new(4, 6) / 2 == Vector2int16.new(2, 3)
		end,
	},
	{
		"Vector2int16 overflow wraps",
		function()
			return Vector2int16.new(32768).X == -32768
		end,
	},
})
v25("Vector3int16", {
	{
		"Vector3int16.new returns correct type",
		function()
			local v948 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3int16.new(1, 2, 3))

			return typeof(unpack(v948, 1, v948.n)) == "Vector3int16"
		end,
	},
	{
		"Vector3int16.X Y Z correct",
		function()
			local v953 = Vector3int16.new(1, 2, 3)
			local v954

			if v953.X ~= 1 or v953.Y ~= 2 then
				v954 = false
			else
				v954 = v953.Z == 3
			end

			return v954
		end,
	},
	{
		"Vector3int16 non-integer rounds down",
		function()
			return Vector3int16.new(1.9, 2.9, 3.9).X == 1
		end,
	},
	{
		"Vector3int16 + Vector3int16 correct",
		function()
			return Vector3int16.new(1, 2, 3) + Vector3int16.new(4, 5, 6) == Vector3int16.new(5, 7, 9)
		end,
	},
	{
		"Vector3int16 - Vector3int16 correct",
		function()
			return Vector3int16.new(5, 7, 9) - Vector3int16.new(4, 5, 6) == Vector3int16.new(1, 2, 3)
		end,
	},
	{
		"Vector3int16 * Vector3int16 correct",
		function()
			return Vector3int16.new(2, 3, 4) * Vector3int16.new(5, 6, 7) == Vector3int16.new(10, 18, 28)
		end,
	},
	{
		"Vector3int16 / Vector3int16 correct",
		function()
			return Vector3int16.new(10, 18, 28) / Vector3int16.new(5, 6, 7) == Vector3int16.new(2, 3, 4)
		end,
	},
	{
		"Vector3int16 * number correct",
		function()
			return Vector3int16.new(2, 3, 4) * 2 == Vector3int16.new(4, 6, 8)
		end,
	},
	{
		"Vector3int16 / number correct",
		function()
			return Vector3int16.new(4, 6, 8) / 2 == Vector3int16.new(2, 3, 4)
		end,
	},
	{
		"Vector3int16 overflow wraps",
		function()
			return Vector3int16.new(32768).X == -32768
		end,
	},
})
v25("ValueCurveKey", {
	{
		"ValueCurveKey.new returns correct type",
		function()
			local v955 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant))

			return typeof(unpack(v955, 1, v955.n)) == "ValueCurveKey"
		end,
	},
	{
		"ValueCurveKey.Time correct",
		function()
			return ValueCurveKey.new(0.5, 1, Enum.KeyInterpolationMode.Constant).Time == 0.5
		end,
	},
	{
		"ValueCurveKey.Value correct",
		function()
			return ValueCurveKey.new(0, 42, Enum.KeyInterpolationMode.Constant).Value == 42
		end,
	},
	{
		"ValueCurveKey.Interpolation is EnumItem",
		function()
			local Interpolation = ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant).Interpolation

			return typeof(Interpolation) == "EnumItem"
		end,
	},
	{
		"ValueCurveKey.Interpolation correct",
		function()
			return ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Cubic).Interpolation == Enum.KeyInterpolationMode.Cubic
		end,
	},
})
v25("CFrame properties and methods", {
	{
		"CFrame.X Y Z correct",
		function()
			local cFrame = CFrame.new(1, 2, 3)
			local v962

			if cFrame.X ~= 1 or cFrame.Y ~= 2 then
				v962 = false
			else
				v962 = cFrame.Z == 3
			end

			return v962
		end,
	},
	{
		"CFrame.identity is CFrame",
		function()
			local cFrame = CFrame.identity

			return typeof(cFrame) == "CFrame"
		end,
	},
	{
		"CFrame.identity position is 0,0,0",
		function()
			return CFrame.identity.Position == Vector3.new(0, 0, 0)
		end,
	},
	{
		"CFrame.Position is Vector3",
		function()
			local Position = CFrame.new(1, 2, 3).Position

			return typeof(Position) == "Vector3"
		end,
	},
	{
		"CFrame.Rotation is CFrame",
		function()
			local Rotation = CFrame.new(1, 2, 3).Rotation

			return typeof(Rotation) == "CFrame"
		end,
	},
	{
		"CFrame.LookVector is Vector3",
		function()
			local LookVector = CFrame.new().LookVector

			return typeof(LookVector) == "Vector3"
		end,
	},
	{
		"CFrame.RightVector is Vector3",
		function()
			local RightVector = CFrame.new().RightVector

			return typeof(RightVector) == "Vector3"
		end,
	},
	{
		"CFrame.UpVector is Vector3",
		function()
			local UpVector = CFrame.new().UpVector

			return typeof(UpVector) == "Vector3"
		end,
	},
	{
		"CFrame.XVector is Vector3",
		function()
			local XVector = CFrame.new().XVector

			return typeof(XVector) == "Vector3"
		end,
	},
	{
		"CFrame.YVector is Vector3",
		function()
			local YVector = CFrame.new().YVector

			return typeof(YVector) == "Vector3"
		end,
	},
	{
		"CFrame.ZVector is Vector3",
		function()
			local ZVector = CFrame.new().ZVector

			return typeof(ZVector) == "Vector3"
		end,
	},
	{
		"CFrame.RightVector equals XVector",
		function()
			local cFrame = CFrame.new()

			return cFrame.RightVector == cFrame.XVector
		end,
	},
	{
		"CFrame.UpVector equals YVector",
		function()
			local cFrame = CFrame.new()

			return cFrame.UpVector == cFrame.YVector
		end,
	},
	{
		"CFrame.LookVector equals negated ZVector",
		function()
			local cFrame = CFrame.new()

			return cFrame.LookVector == -cFrame.ZVector
		end,
	},
	{
		"CFrame.lookAt LookVector correct",
		function()
			local v975 = CFrame.lookAt(Vector3.new(0, 0, 0), Vector3.new(0, 0, -1)).LookVector.Z + 1

			return math.abs(v975) < 0.001
		end,
	},
	{
		"CFrame.lookAlong returns CFrame",
		function()
			local function v976(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.lookAlong
			local vector3 = Vector3.new(0, 0, 0)
			local v979 = v976(Vector3.new(0, 0, -1))
			local v980 = v976(cFrame(vector3, unpack(v979, 1, v979.n)))

			return typeof(unpack(v980, 1, v980.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromRotationBetweenVectors returns CFrame",
		function()
			local function v987(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.fromRotationBetweenVectors
			local vector3 = Vector3.new(1, 0, 0)
			local v990 = v987(Vector3.new(0, 1, 0))
			local v991 = v987(cFrame(vector3, unpack(v990, 1, v990.n)))

			return typeof(unpack(v991, 1, v991.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromEulerAngles returns CFrame",
		function()
			local v998 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.fromEulerAngles(1, 2, 3))

			return typeof(unpack(v998, 1, v998.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromEulerAnglesXYZ returns CFrame",
		function()
			local v1003 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.fromEulerAnglesXYZ(1, 2, 3))

			return typeof(unpack(v1003, 1, v1003.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromEulerAnglesYXZ returns CFrame",
		function()
			local v1008 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.fromEulerAnglesYXZ(1, 2, 3))

			return typeof(unpack(v1008, 1, v1008.n)) == "CFrame"
		end,
	},
	{
		"CFrame.Angles returns CFrame",
		function()
			local v1013 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.Angles(0, math.pi, 0))

			return typeof(unpack(v1013, 1, v1013.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromOrientation returns CFrame",
		function()
			local v1018 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.fromOrientation(1, 2, 3))

			return typeof(unpack(v1018, 1, v1018.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromAxisAngle returns CFrame",
		function()
			local v1023 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.pi))

			return typeof(unpack(v1023, 1, v1023.n)) == "CFrame"
		end,
	},
	{
		"CFrame.fromMatrix returns CFrame",
		function()
			local function v1029(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.fromMatrix
			local vector3 = Vector3.new(0, 0, 0)
			local vector32 = Vector3.new(1, 0, 0)
			local vector33 = Vector3.new(0, 1, 0)
			local v1034 = v1029(Vector3.new(0, 0, 1))
			local v1035 = v1029(cFrame(vector3, vector32, vector33, unpack(v1034, 1, v1034.n)))

			return typeof(unpack(v1035, 1, v1035.n)) == "CFrame"
		end,
	},
	{
		"CFrame.Angles VectorToWorldSpace correct",
		function()
			local cFrame = CFrame.Angles(0, math.pi, 0)
			local v1045 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 0, 1))
			local v1050 = cFrame:VectorToWorldSpace(unpack(v1045, 1, v1045.n)).Z + 1

			return math.abs(v1050) < 0.01
		end,
	},
	{
		"CFrame:Inverse correct",
		function()
			local v1051 = CFrame.new(5, 0, 0):Inverse().X + 5

			return math.abs(v1051) < 0.001
		end,
	},
	{
		"CFrame:Lerp correct",
		function()
			local v1052 = CFrame.new(0, 0, 0):Lerp(CFrame.new(10, 0, 0), 0.5).X - 5

			return math.abs(v1052) < 0.001
		end,
	},
	{
		"CFrame:Orthonormalize returns CFrame",
		function()
			local v1053 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CFrame.new():Orthonormalize())

			return typeof(unpack(v1053, 1, v1053.n)) == "CFrame"
		end,
	},
	{
		"CFrame:ToWorldSpace returns CFrame",
		function()
			local function v1056(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.new(5, 0, 0)
			local v1058 = v1056(CFrame.new(0, 2, 0))
			local v1063 = v1056(cFrame:ToWorldSpace(unpack(v1058, 1, v1058.n)))

			return typeof(unpack(v1063, 1, v1063.n)) == "CFrame"
		end,
	},
	{
		"CFrame:ToObjectSpace returns CFrame",
		function()
			local function v1070(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.new(5, 0, 0)
			local v1072 = v1070(CFrame.new(0, 2, 0))
			local v1077 = v1070(cFrame:ToObjectSpace(unpack(v1072, 1, v1072.n)))

			return typeof(unpack(v1077, 1, v1077.n)) == "CFrame"
		end,
	},
	{
		"CFrame:PointToWorldSpace correct",
		function()
			local cFrame = CFrame.new(5, 10, 0)
			local v1085 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, 4, 0))
			local v1090 = cFrame:PointToWorldSpace(unpack(v1085, 1, v1085.n)).Y - 14

			return math.abs(v1090) < 0.001
		end,
	},
	{
		"CFrame:PointToObjectSpace correct",
		function()
			local cFrame = CFrame.new(5, 0, 0)
			local v1092 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(5, 0, 0))
			local X = cFrame:PointToObjectSpace(unpack(v1092, 1, v1092.n)).X

			return math.abs(X) < 0.001
		end,
	},
	{
		"CFrame:VectorToWorldSpace correct",
		function()
			local function v1098(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.new()
			local v1100 = v1098(Vector3.new(1, 0, 0))
			local v1105 = v1098(cFrame:VectorToWorldSpace(unpack(v1100, 1, v1100.n)))

			return typeof(unpack(v1105, 1, v1105.n)) == "Vector3"
		end,
	},
	{
		"CFrame:VectorToObjectSpace correct",
		function()
			local function v1112(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.new()
			local v1114 = v1112(Vector3.new(1, 0, 0))
			local v1119 = v1112(cFrame:VectorToObjectSpace(unpack(v1114, 1, v1114.n)))

			return typeof(unpack(v1119, 1, v1119.n)) == "Vector3"
		end,
	},
	{
		"CFrame:GetComponents returns 12 values",
		function()
			return #{ CFrame.new(1, 2, 3):GetComponents() } == 12
		end,
	},
	{
		"CFrame:components equals GetComponents",
		function()
			local function v1126(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local t18 = {}

			(function(p16, p17, p18, p19)
				for i = p19, p18.n do
					local v1129 = p18[i]

					p16[i - p19 + p17] = v1129
				end
			end)(t18, 1, v1126(CFrame.new(1, 2, 3):GetComponents()), 1)

			local t19 = {}
			local v1131 = v1126(CFrame.new(1, 2, 3):components())

			__set_list(t19, 1, { unpack(v1131, 1, v1131.n) })

			return #t18 == #t19
		end,
	},
	{
		"CFrame:ToEulerAnglesXYZ returns numbers",
		function()
			local v1132, v1133, v1134 = CFrame.Angles(1, 2, 3):ToEulerAnglesXYZ()
			local v1135

			if type(v1132) ~= "number" or type(v1133) ~= "number" then
				v1135 = false
			else
				v1135 = type(v1134) == "number"
			end

			return v1135
		end,
	},
	{
		"CFrame:ToEulerAnglesYXZ returns numbers",
		function()
			local v1136, v1137, v1138 = CFrame.Angles(1, 2, 3):ToEulerAnglesYXZ()
			local v1139

			if type(v1136) ~= "number" or type(v1137) ~= "number" then
				v1139 = false
			else
				v1139 = type(v1138) == "number"
			end

			return v1139
		end,
	},
	{
		"CFrame:ToEulerAngles returns numbers",
		function()
			local v1140, v1141, v1142 = CFrame.Angles(1, 2, 3):ToEulerAngles()
			local v1143

			if type(v1140) ~= "number" or type(v1141) ~= "number" then
				v1143 = false
			else
				v1143 = type(v1142) == "number"
			end

			return v1143
		end,
	},
	{
		"CFrame:ToOrientation returns numbers",
		function()
			local v1144, v1145, v1146 = CFrame.Angles(1, 2, 3):ToOrientation()
			local v1147

			if type(v1144) ~= "number" or type(v1145) ~= "number" then
				v1147 = false
			else
				v1147 = type(v1146) == "number"
			end

			return v1147
		end,
	},
	{
		"CFrame:ToAxisAngle returns Vector3 and number",
		function()
			local v1148, v1149 = CFrame.Angles(0, math.pi, 0):ToAxisAngle()
			local v1150

			if typeof(v1148) ~= "Vector3" then
				v1150 = false
			else
				v1150 = type(v1149) == "number"
			end

			return v1150
		end,
	},
	{
		"CFrame:FuzzyEq correct",
		function()
			local function v1151(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.new(1, 2, 3)
			local v1153 = v1151(CFrame.new(1, 2, 3))
			local v1158 = v1151(cFrame:FuzzyEq(unpack(v1153, 1, v1153.n)))

			return unpack(v1158, 1, v1158.n)
		end,
	},
	{
		"CFrame:AngleBetween returns number",
		function()
			local function v1159(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local cFrame = CFrame.new()
			local v1161 = v1159(CFrame.Angles(0, math.pi, 0))
			local v1166 = v1159(cFrame:AngleBetween(unpack(v1161, 1, v1161.n)))

			return type(unpack(v1166, 1, v1166.n)) == "number"
		end,
	},
	{
		"CFrame * CFrame correct",
		function()
			local v1173 = CFrame.new(1, 0, 0) * CFrame.new(0, 1, 0)

			return typeof(v1173) == "CFrame"
		end,
	},
	{
		"CFrame * Vector3 correct",
		function()
			local v1174 = CFrame.new(1, 0, 0) * Vector3.new(0, 1, 0)

			return typeof(v1174) == "Vector3"
		end,
	},
	{
		"CFrame + Vector3 correct",
		function()
			local v1175 = CFrame.new(1, 0, 0) + Vector3.new(0, 1, 0)

			return typeof(v1175) == "CFrame"
		end,
	},
	{
		"CFrame - Vector3 correct",
		function()
			local v1176 = CFrame.new(1, 0, 0) - Vector3.new(0, 1, 0)

			return typeof(v1176) == "CFrame"
		end,
	},
})
v25("Color3 properties and methods", {
	{
		"Color3.new R G B correct",
		function()
			local color3 = Color3.new(1, 0, 0)
			local v1178

			if color3.R ~= 1 or color3.G ~= 0 then
				v1178 = false
			else
				v1178 = color3.B == 0
			end

			return v1178
		end,
	},
	{
		"Color3.fromRGB correct",
		function()
			local color3 = Color3.fromRGB(255, 0, 0)
			local v1180

			if color3.R ~= 1 then
				v1180 = false
			else
				v1180 = color3.G == 0
			end

			return v1180
		end,
	},
	{
		"Color3.fromHSV correct",
		function()
			local color3 = Color3.fromHSV(0, 1, 1)
			local v1182 = color3.R - 1
			local v1183

			if math.abs(v1182) >= 0.001 then
				v1183 = false
			else
				v1183 = color3.G == 0
			end

			return v1183
		end,
	},
	{
		"Color3.fromHex correct",
		function()
			local color3 = Color3.fromHex("FF0000")
			local v1185 = color3.R - 1
			local v1186

			if math.abs(v1185) >= 0.001 or color3.G ~= 0 then
				v1186 = false
			else
				v1186 = color3.B == 0
			end

			return v1186
		end,
	},
	{
		"Color3.fromHex with hash correct",
		function()
			local v1187 = Color3.fromHex("#FF0000").R - 1

			return math.abs(v1187) < 0.001
		end,
	},
	{
		"Color3.fromHex shorthand correct",
		function()
			local v1188 = Color3.fromHex("#F00").R - 1

			return math.abs(v1188) < 0.001
		end,
	},
	{
		"Color3:ToHSV correct",
		function()
			local v1189 = Color3.fromHSV(0.5, 1, 1):ToHSV() - 0.5

			return math.abs(v1189) < 0.001
		end,
	},
	{
		"Color3:ToHSV returns 3 numbers",
		function()
			local v1190, v1191, v1192 = Color3.fromRGB(255, 0, 0):ToHSV()
			local v1193

			if type(v1190) ~= "number" or type(v1191) ~= "number" then
				v1193 = false
			else
				v1193 = type(v1192) == "number"
			end

			return v1193
		end,
	},
	{
		"Color3:ToHex returns string",
		function()
			local v1194 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Color3.fromRGB(255, 0, 0):ToHex())

			return type(unpack(v1194, 1, v1194.n)) == "string"
		end,
	},
	{
		"Color3:ToHex correct value",
		function()
			return Color3.fromRGB(255, 0, 0):ToHex() == "ff0000"
		end,
	},
	{
		"Color3:ToHex and fromHex roundtrip",
		function()
			local color3 = Color3.fromRGB(236, 0, 140)

			return Color3.fromHex(color3:ToHex()).R == color3.R
		end,
	},
	{
		"Color3:Lerp correct",
		function()
			local v1200 = Color3.new(0, 0, 0):Lerp(Color3.new(1, 0, 0), 0.5).R - 0.5

			return math.abs(v1200) < 0.001
		end,
	},
})
v25("UDim and UDim2", {
	{
		"UDim.Scale and Offset correct",
		function()
			local uDim = UDim.new(0.5, 10)
			local v1202

			if uDim.Scale ~= 0.5 then
				v1202 = false
			else
				v1202 = uDim.Offset == 10
			end

			return v1202
		end,
	},
	{
		"UDim + UDim correct",
		function()
			local v1203 = UDim.new(0.5, 10) + UDim.new(0.5, 10)
			local v1204

			if v1203.Scale ~= 1 then
				v1204 = false
			else
				v1204 = v1203.Offset == 20
			end

			return v1204
		end,
	},
	{
		"UDim - UDim correct",
		function()
			local v1205 = UDim.new(1, 20) - UDim.new(0.5, 10)
			local v1206

			if v1205.Scale ~= 0.5 then
				v1206 = false
			else
				v1206 = v1205.Offset == 10
			end

			return v1206
		end,
	},
	{
		"UDim2.X.Scale and Y.Offset correct",
		function()
			local uDim2 = UDim2.new(0.5, 10, 0.2, 5)
			local v1208

			if uDim2.X.Scale ~= 0.5 then
				v1208 = false
			else
				v1208 = uDim2.Y.Offset == 5
			end

			return v1208
		end,
	},
	{
		"UDim2.Width equals X",
		function()
			local uDim2 = UDim2.new(0.5, 10, 0.2, 5)
			local v1210

			if uDim2.Width.Scale ~= uDim2.X.Scale then
				v1210 = false
			else
				v1210 = uDim2.Width.Offset == uDim2.X.Offset
			end

			return v1210
		end,
	},
	{
		"UDim2.Height equals Y",
		function()
			local uDim2 = UDim2.new(0.5, 10, 0.2, 5)
			local v1212

			if uDim2.Height.Scale ~= uDim2.Y.Scale then
				v1212 = false
			else
				v1212 = uDim2.Height.Offset == uDim2.Y.Offset
			end

			return v1212
		end,
	},
	{
		"UDim2.fromScale correct",
		function()
			local uDim2 = UDim2.fromScale(0.5, 0.5)
			local v1214

			if uDim2.X.Scale ~= 0.5 then
				v1214 = false
			else
				v1214 = uDim2.X.Offset == 0
			end

			return v1214
		end,
	},
	{
		"UDim2.fromOffset correct",
		function()
			local uDim2 = UDim2.fromOffset(100, 200)
			local v1216

			if uDim2.X.Offset ~= 100 then
				v1216 = false
			else
				v1216 = uDim2.Y.Offset == 200
			end

			return v1216
		end,
	},
	{
		"UDim2 + UDim2 correct",
		function()
			local v1217 = UDim2.new(0.5, 10, 0.5, 10) + UDim2.new(0.5, 10, 0.5, 10)
			local v1218

			if v1217.X.Scale ~= 1 then
				v1218 = false
			else
				v1218 = v1217.X.Offset == 20
			end

			return v1218
		end,
	},
	{
		"UDim2.new from UDim objects correct",
		function()
			local uDim = UDim.new(0.5, 10)
			local uDim2 = UDim.new(0.2, 5)
			local uDim22 = UDim2.new(uDim, uDim2)
			local v1222

			if uDim22.X.Scale ~= 0.5 then
				v1222 = false
			else
				v1222 = uDim22.Y.Offset == 5
			end

			return v1222
		end,
	},
	{
		"UDim2 - UDim2 correct",
		function()
			local v1223 = UDim2.new(1, 20, 1, 20) - UDim2.new(0.5, 10, 0.5, 10)
			local v1224

			if v1223.X.Scale ~= 0.5 then
				v1224 = false
			else
				v1224 = v1223.X.Offset == 10
			end

			return v1224
		end,
	},
	{
		"UDim2:Lerp correct",
		function()
			return UDim2.new(0, 0, 0, 0):Lerp(UDim2.new(1, 0, 0, 0), 0.5).X.Scale == 0.5
		end,
	},
	{
		"UDim2 tostring format correct",
		function()
			local v1225 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(UDim2.new(0.5, 10, 0.2, 5))

			return tostring(unpack(v1225, 1, v1225.n)) == "{0.5, 10}, {0.200000003, 5}"
		end,
	},
})
v25("BrickColor", {
	{
		"BrickColor.new by name correct",
		function()
			return BrickColor.new("Bright red").Name == "Bright red"
		end,
	},
	{
		"BrickColor.new by number correct",
		function()
			return BrickColor.new(21).Number == 21
		end,
	},
	{
		"BrickColor.new by RGB correct",
		function()
			local v1231 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(BrickColor.new(1, 0, 0))

			return typeof(unpack(v1231, 1, v1231.n)) == "BrickColor"
		end,
	},
	{
		"BrickColor.new by Color3 correct",
		function()
			local function v1236(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local brickColorNew = BrickColor.new
			local v1238 = v1236(Color3.new(1, 0, 0))
			local v1239 = v1236(brickColorNew(unpack(v1238, 1, v1238.n)))

			return typeof(unpack(v1239, 1, v1239.n)) == "BrickColor"
		end,
	},
	{
		"BrickColor.Color is Color3",
		function()
			local Color = BrickColor.new("Bright red").Color

			return typeof(Color) == "Color3"
		end,
	},
	{
		"BrickColor.r g b are numbers",
		function()
			local brickColor = BrickColor.new("Bright red")
			local r = brickColor.r
			local v1248

			if type(r) ~= "number" then
				v1248 = false
			else
				local g = brickColor.g

				if type(g) ~= "number" then
					v1248 = false
				else
					local b = brickColor.b

					v1248 = type(b) == "number"
				end
			end

			return v1248
		end,
	},
	{
		"BrickColor.random returns BrickColor",
		function()
			local v1251 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(BrickColor.random())

			unpack(v1251, 1, 1)

			return typeof(unpack(v1251, 1, v1251.n)) == "BrickColor"
		end,
	},
	{
		"BrickColor.palette returns BrickColor",
		function()
			local v1252 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(BrickColor.palette(0))

			return typeof(unpack(v1252, 1, v1252.n)) == "BrickColor"
		end,
	},
	{
		"BrickColor.White correct",
		function()
			return BrickColor.White().Name == "White"
		end,
	},
	{
		"BrickColor.Gray correct",
		function()
			return BrickColor.Gray().Name == "Medium stone grey"
		end,
	},
	{
		"BrickColor.DarkGray correct",
		function()
			return BrickColor.DarkGray().Name == "Dark stone grey"
		end,
	},
	{
		"BrickColor.Black correct",
		function()
			return BrickColor.Black().Name == "Black"
		end,
	},
	{
		"BrickColor.Red correct",
		function()
			return BrickColor.Red().Name == "Bright red"
		end,
	},
	{
		"BrickColor.Yellow correct",
		function()
			return BrickColor.Yellow().Name == "Bright yellow"
		end,
	},
	{
		"BrickColor.Green correct",
		function()
			return BrickColor.Green().Name == "Dark green"
		end,
	},
	{
		"BrickColor.Blue correct",
		function()
			return BrickColor.Blue().Name == "Bright blue"
		end,
	},
})
v25("TweenInfo", {
	{
		"TweenInfo.Time correct",
		function()
			return TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0).Time == 1.5
		end,
	},
	{
		"TweenInfo.EasingStyle correct",
		function()
			return TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0).EasingStyle == Enum.EasingStyle.Quad
		end,
	},
	{
		"TweenInfo.EasingDirection correct",
		function()
			return TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0).EasingDirection == Enum.EasingDirection.InOut
		end,
	},
	{
		"TweenInfo.DelayTime correct",
		function()
			return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.5).DelayTime == 0.5
		end,
	},
	{
		"TweenInfo.RepeatCount correct",
		function()
			return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 3, false, 0).RepeatCount == 3
		end,
	},
	{
		"TweenInfo.RepeatCount indefinite correct",
		function()
			return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0).RepeatCount == -1
		end,
	},
	{
		"TweenInfo.Reverses correct",
		function()
			return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true).Reverses == true
		end,
	},
	{
		"TweenInfo default EasingDirection is Out",
		function()
			return TweenInfo.new(1).EasingDirection == Enum.EasingDirection.Out
		end,
	},
	{
		"TweenInfo default EasingStyle is Quad",
		function()
			return TweenInfo.new(1).EasingStyle == Enum.EasingStyle.Quad
		end,
	},
	{
		"TweenInfo default RepeatCount is 0",
		function()
			return TweenInfo.new(1).RepeatCount == 0
		end,
	},
	{
		"TweenInfo default Reverses is false",
		function()
			return TweenInfo.new(1).Reverses == false
		end,
	},
	{
		"TweenInfo default DelayTime is 0",
		function()
			return TweenInfo.new(1).DelayTime == 0
		end,
	},
	{
		"TweenInfo default Time is 1",
		function()
			return TweenInfo.new(1).Time == 1
		end,
	},
})
v25("NumberRange, NumberSequence, ColorSequence", {
	{
		"NumberRange.Min and Max correct",
		function()
			local numberRange = NumberRange.new(1, 5)
			local v1256

			if numberRange.Min ~= 1 then
				v1256 = false
			else
				v1256 = numberRange.Max == 5
			end

			return v1256
		end,
	},
	{
		"NumberRange single value Min==Max",
		function()
			local numberRange = NumberRange.new(3)
			local v1258

			if numberRange.Min ~= 3 then
				v1258 = false
			else
				v1258 = numberRange.Max == 3
			end

			return v1258
		end,
	},
	{
		"NumberRange min must be <= max errors",
		function()
			return not pcall(function()
				NumberRange.new(5, 1)
			end)
		end,
	},
	{
		"NumberSequence single value constructor correct",
		function()
			local numberSequence = NumberSequence.new(0.5)
			local v1260

			if numberSequence.Keypoints[1].Value ~= 0.5 then
				v1260 = false
			else
				v1260 = numberSequence.Keypoints[2].Value == 0.5
			end

			return v1260
		end,
	},
	{
		"NumberSequence keypoints correct",
		function()
			local numberSequence = NumberSequence.new(0, 1)
			local v1262

			if numberSequence.Keypoints[1].Value ~= 0 then
				v1262 = false
			else
				v1262 = numberSequence.Keypoints[2].Value == 1
			end

			return v1262
		end,
	},
	{
		"NumberSequence from keypoints correct",
		function()
			return #NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }).Keypoints == 2
		end,
	},
	{
		"NumberSequence from 3 keypoints correct",
		function()
			return #NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.5), NumberSequenceKeypoint.new(1, 1) }).Keypoints
				== 3
		end,
	},
	{
		"NumberSequenceKeypoint.Time correct",
		function()
			return NumberSequenceKeypoint.new(0.5, 1).Time == 0.5
		end,
	},
	{
		"NumberSequenceKeypoint.Value correct",
		function()
			return NumberSequenceKeypoint.new(0.5, 1).Value == 1
		end,
	},
	{
		"NumberSequenceKeypoint.Envelope correct",
		function()
			return NumberSequenceKeypoint.new(0.5, 1, 0.25).Envelope == 0.25
		end,
	},
	{
		"ColorSequence single color constructor correct",
		function()
			local colorSequence = ColorSequence.new(Color3.new(1, 0, 0))
			local v1264

			if colorSequence.Keypoints[1].Value.R ~= 1 then
				v1264 = false
			else
				v1264 = colorSequence.Keypoints[2].Value.R == 1
			end

			return v1264
		end,
	},
	{
		"ColorSequence first keypoint R correct",
		function()
			return ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)).Keypoints[1].Value.R == 1
		end,
	},
	{
		"ColorSequence last keypoint B correct",
		function()
			return ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)).Keypoints[2].Value.B == 1
		end,
	},
	{
		"ColorSequence from 3 keypoints correct",
		function()
			return #ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1)),
			}).Keypoints == 3
		end,
	},
	{
		"ColorSequenceKeypoint.Time and Value correct",
		function()
			local v1265 = ColorSequenceKeypoint.new(0.5, Color3.new(1, 0, 0))
			local v1266

			if v1265.Time ~= 0.5 then
				v1266 = false
			else
				v1266 = v1265.Value.R == 1
			end

			return v1266
		end,
	},
})
v25("Ray and RaycastParams and OverlapParams", {
	{
		"Ray.Origin correct",
		function()
			return Ray.new(Vector3.new(0, 10, 0), Vector3.new(0, -1, 0)).Origin.Y == 10
		end,
	},
	{
		"Ray.Direction correct",
		function()
			return Ray.new(Vector3.new(0, 10, 0), Vector3.new(0, -1, 0)).Direction.Y == -1
		end,
	},
	{
		"Ray:ClosestPoint returns Vector3",
		function()
			local function v1267(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local rayNew = Ray.new
			local vector3 = Vector3.new(0, 10, 0)
			local v1270 = v1267(Vector3.new(0, -1, 0))
			local ray = rayNew(vector3, unpack(v1270, 1, v1270.n))
			local v1272 = v1267(Vector3.new(0, 1, 0))
			local v1277 = v1267(ray:ClosestPoint(unpack(v1272, 1, v1272.n)))

			return typeof(unpack(v1277, 1, v1277.n)) == "Vector3"
		end,
	},
	{
		"RaycastParams.FilterType writable",
		function()
			local raycastParams = RaycastParams.new()

			raycastParams.FilterType = Enum.RaycastFilterType.Include

			return raycastParams.FilterType == Enum.RaycastFilterType.Include
		end,
	},
	{
		"OverlapParams.FilterType writable",
		function()
			local overlapParams = OverlapParams.new()

			overlapParams.FilterType = Enum.RaycastFilterType.Exclude

			return overlapParams.FilterType == Enum.RaycastFilterType.Exclude
		end,
	},
})
v25("Region3", {
	{
		"Region3.Size correct",
		function()
			return Region3.new(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)).Size.X == 2
		end,
	},
	{
		"Region3.CFrame.Position correct",
		function()
			return Region3.new(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)).CFrame.Position.X == 1
		end,
	},
	{
		"Region3:ExpandToGrid returns Region3",
		function()
			local function v1286(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local region3New = Region3.new
			local vector3 = Vector3.new(0, 0, 0)
			local v1289 = v1286(Vector3.new(2, 2, 2))
			local v1290 = v1286(region3New(vector3, unpack(v1289, 1, v1289.n)):ExpandToGrid(4))

			return typeof(unpack(v1290, 1, v1290.n)) == "Region3"
		end,
	},
})
v25("Random", {
	{
		"Random:NextInteger in range",
		function()
			local v1297 = Random.new():NextInteger(1, 10)
			local v1298

			if v1297 < 1 then
				v1298 = false
			else
				v1298 = v1297 <= 10
			end

			return v1298
		end,
	},
	{
		"Random:NextNumber in range",
		function()
			local v1299 = Random.new():NextNumber(0, 1)
			local v1300

			if v1299 < 0 then
				v1300 = false
			else
				v1300 = v1299 <= 1
			end

			return v1300
		end,
	},
	{
		"Random seeded result deterministic",
		function()
			return Random.new(12345):NextInteger(1, 100) == 91
		end,
	},
	{
		"Random:NextUnitVector returns Vector3",
		function()
			local v1301 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Random.new():NextUnitVector())

			return typeof(unpack(v1301, 1, v1301.n)) == "Vector3"
		end,
	},
	{
		"Random.new errors on non-number seed",
		function()
			return not pcall(function()
				Random.new("nuh uh")
			end)
		end,
	},
})
v25("FloatCurveKey", {
	{
		"FloatCurveKey.new returns correct type",
		function()
			local v1304 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant))

			return typeof(unpack(v1304, 1, v1304.n)) == "FloatCurveKey"
		end,
	},
	{
		"FloatCurveKey.Time correct",
		function()
			return FloatCurveKey.new(0.5, 1, Enum.KeyInterpolationMode.Constant).Time == 0.5
		end,
	},
	{
		"FloatCurveKey.Value correct",
		function()
			return FloatCurveKey.new(0, 42, Enum.KeyInterpolationMode.Constant).Value == 42
		end,
	},
	{
		"FloatCurveKey.Interpolation is EnumItem",
		function()
			local Interpolation = FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant).Interpolation

			return typeof(Interpolation) == "EnumItem"
		end,
	},
	{
		"FloatCurveKey.Interpolation correct",
		function()
			return FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Cubic).Interpolation == Enum.KeyInterpolationMode.Cubic
		end,
	},
})
v25("CatalogSearchParams", {
	{
		"CatalogSearchParams.new returns correct type",
		function()
			local v1310 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(CatalogSearchParams.new())

			unpack(v1310, 1, 1)

			return typeof(unpack(v1310, 1, v1310.n)) == "CatalogSearchParams"
		end,
	},
	{
		"CatalogSearchParams.SearchKeyword is string",
		function()
			local SearchKeyword = CatalogSearchParams.new().SearchKeyword

			return type(SearchKeyword) == "string"
		end,
	},
	{
		"CatalogSearchParams.SearchKeyword writable",
		function()
			local v1312 = CatalogSearchParams.new()

			v1312.SearchKeyword = "test"

			return v1312.SearchKeyword == "test"
		end,
	},
	{
		"CatalogSearchParams.MinPrice is number",
		function()
			local MinPrice = CatalogSearchParams.new().MinPrice

			return type(MinPrice) == "number"
		end,
	},
	{
		"CatalogSearchParams.MinPrice writable",
		function()
			local v1314 = CatalogSearchParams.new()

			v1314.MinPrice = 100

			return v1314.MinPrice == 100
		end,
	},
	{
		"CatalogSearchParams.MaxPrice is number",
		function()
			local MaxPrice = CatalogSearchParams.new().MaxPrice

			return type(MaxPrice) == "number"
		end,
	},
	{
		"CatalogSearchParams.MaxPrice writable",
		function()
			local v1316 = CatalogSearchParams.new()

			v1316.MaxPrice = 1000

			return v1316.MaxPrice == 1000
		end,
	},
	{
		"CatalogSearchParams.SortType is EnumItem",
		function()
			local SortType = CatalogSearchParams.new().SortType

			return typeof(SortType) == "EnumItem"
		end,
	},
	{
		"CatalogSearchParams.SortAggregation is EnumItem",
		function()
			local SortAggregation = CatalogSearchParams.new().SortAggregation

			return typeof(SortAggregation) == "EnumItem"
		end,
	},
	{
		"CatalogSearchParams.CategoryFilter is EnumItem",
		function()
			local CategoryFilter = CatalogSearchParams.new().CategoryFilter

			return typeof(CategoryFilter) == "EnumItem"
		end,
	},
	{
		"CatalogSearchParams.SalesTypeFilter is EnumItem",
		function()
			local SalesTypeFilter = CatalogSearchParams.new().SalesTypeFilter

			return typeof(SalesTypeFilter) == "EnumItem"
		end,
	},
	{
		"CatalogSearchParams.IncludeOffSale is boolean",
		function()
			local IncludeOffSale = CatalogSearchParams.new().IncludeOffSale

			return type(IncludeOffSale) == "boolean"
		end,
	},
	{
		"CatalogSearchParams.IncludeOffSale writable",
		function()
			local v1322 = CatalogSearchParams.new()

			v1322.IncludeOffSale = true

			return v1322.IncludeOffSale == true
		end,
	},
	{
		"CatalogSearchParams.CreatorName is string",
		function()
			local CreatorName = CatalogSearchParams.new().CreatorName

			return type(CreatorName) == "string"
		end,
	},
	{
		"CatalogSearchParams.CreatorId is number",
		function()
			local CreatorId = CatalogSearchParams.new().CreatorId

			return type(CreatorId) == "number"
		end,
	},
	{
		"CatalogSearchParams.Limit is number",
		function()
			local Limit = CatalogSearchParams.new().Limit

			return type(Limit) == "number"
		end,
	},
	{
		"CatalogSearchParams.BundleTypes is table",
		function()
			local BundleTypes = CatalogSearchParams.new().BundleTypes

			return type(BundleTypes) == "table"
		end,
	},
	{
		"CatalogSearchParams.AssetTypes is table",
		function()
			local AssetTypes = CatalogSearchParams.new().AssetTypes

			return type(AssetTypes) == "table"
		end,
	},
	{
		"CatalogSearchParams.BundleTypes writable",
		function()
			local v1328 = CatalogSearchParams.new()

			v1328.BundleTypes = { Enum.BundleType.Animations }

			local BundleTypes = v1328.BundleTypes

			return type(BundleTypes) == "table"
		end,
	},
	{
		"CatalogSearchParams.BundleTypes read-only after access",
		function()
			local v1330 = CatalogSearchParams.new()

			v1330.BundleTypes = { Enum.BundleType.Animations }

			local BundleTypes = v1330.BundleTypes

			return not pcall(function()
				local BodyParts = Enum.BundleType.BodyParts

				table.insert(BundleTypes, BodyParts)
			end)
		end,
	},
})
v25("Core functions [C]", {
	{
		"math.abs is C function",
		function()
			local v1334

			if debug.info(math.abs, "s") ~= "[C]" then
				v1334 = false
			else
				v1334 = debug.info(math.abs, "l") == -1
			end

			return v1334
		end,
	},
	{
		"math.abs logic correct",
		function()
			local v1335

			if math.abs(-10) ~= 10 then
				v1335 = false
			else
				v1335 = math.abs(10) == 10
			end

			return v1335
		end,
	},
	{
		"math.abs errors on string",
		function()
			local ok, result = pcall(math.abs, "fail")
			local v1338 = not ok

			if not v1338 then
				return v1338
			end

			v1338 = result:find("number expected") ~= nil

			return v1338
		end,
	},
	{
		"math.random is C function",
		function()
			local v1339

			if debug.info(math.random, "s") ~= "[C]" then
				v1339 = false
			else
				v1339 = debug.info(math.random, "l") == -1
			end

			return v1339
		end,
	},
	{
		"math.random logic correct",
		function()
			local v1340 = math.random(1, 10)
			local v1341

			if v1340 < 1 or v1340 > 10 then
				v1341 = false
			else
				v1341 = v1340 % 1 == 0
			end

			return v1341
		end,
	},
	{
		"math.random errors on empty interval",
		function()
			local ok, result = pcall(math.random, 10, 1)
			local v1344 = not ok

			if not v1344 then
				return v1344
			end

			v1344 = result:find("interval is empty") ~= nil

			return v1344
		end,
	},
	{
		"math.clamp is C function",
		function()
			local v1345

			if debug.info(math.clamp, "s") ~= "[C]" then
				v1345 = false
			else
				v1345 = debug.info(math.clamp, "l") == -1
			end

			return v1345
		end,
	},
	{
		"math.clamp logic correct",
		function()
			local v1346

			if math.clamp(10, 1, 5) ~= 5 then
				v1346 = false
			else
				v1346 = math.clamp(-5, 1, 5) == 1
			end

			return v1346
		end,
	},
	{
		"math.floor is C function",
		function()
			local v1347

			if debug.info(math.floor, "s") ~= "[C]" then
				v1347 = false
			else
				v1347 = debug.info(math.floor, "l") == -1
			end

			return v1347
		end,
	},
	{
		"math.floor logic correct",
		function()
			local v1348

			if math.floor(5.9) ~= 5 then
				v1348 = false
			else
				v1348 = math.floor(-5.1) == -6
			end

			return v1348
		end,
	},
	{
		"math.sign is C function",
		function()
			local v1349

			if debug.info(math.sign, "s") ~= "[C]" then
				v1349 = false
			else
				v1349 = debug.info(math.sign, "l") == -1
			end

			return v1349
		end,
	},
	{
		"math.sign logic correct",
		function()
			local v1350

			if math.sign(10) ~= 1 or math.sign(-10) ~= -1 then
				v1350 = false
			else
				v1350 = math.sign(0) == 0
			end

			return v1350
		end,
	},
	{
		"math.rad is C function",
		function()
			local v1351

			if debug.info(math.rad, "s") ~= "[C]" then
				v1351 = false
			else
				v1351 = debug.info(math.rad, "l") == -1
			end

			return v1351
		end,
	},
	{
		"math.rad logic correct",
		function()
			local v1352 = math.rad(180) - 3.14159

			return math.abs(v1352) < 0.001
		end,
	},
	{
		"math.deg is C function",
		function()
			local v1353

			if debug.info(math.deg, "s") ~= "[C]" then
				v1353 = false
			else
				v1353 = debug.info(math.deg, "l") == -1
			end

			return v1353
		end,
	},
	{
		"math.deg logic correct",
		function()
			local pi = math.pi
			local v1355 = math.deg(pi) - 180

			return math.abs(v1355) < 0.001
		end,
	},
	{
		"table.insert is C function",
		function()
			local v1356

			if debug.info(table.insert, "s") ~= "[C]" then
				v1356 = false
			else
				v1356 = debug.info(table.insert, "l") == -1
			end

			return v1356
		end,
	},
	{
		"table.insert logic correct",
		function()
			local t20 = {}

			table.insert(t20, "a")

			return t20[1] == "a"
		end,
	},
	{
		"table.insert errors on non-table",
		function()
			local ok, result = pcall(table.insert, "not a table", "val")
			local v1360 = not ok

			if not v1360 then
				return v1360
			end

			v1360 = result:find("table expected") ~= nil

			return v1360
		end,
	},
	{
		"table.find is C function",
		function()
			local v1361

			if debug.info(table.find, "s") ~= "[C]" then
				v1361 = false
			else
				v1361 = debug.info(table.find, "l") == -1
			end

			return v1361
		end,
	},
	{
		"table.find logic correct",
		function()
			local t21 = { "a", "b", "c" }
			local v1363

			if table.find(t21, "b") ~= 2 then
				v1363 = false
			else
				v1363 = table.find(t21, "missing") == nil
			end

			return v1363
		end,
	},
	{
		"table.concat is C function",
		function()
			local v1364

			if debug.info(table.concat, "s") ~= "[C]" then
				v1364 = false
			else
				v1364 = debug.info(table.concat, "l") == -1
			end

			return v1364
		end,
	},
	{
		"table.concat logic correct",
		function()
			return table.concat({ "a", "b" }, "-") == "a-b"
		end,
	},
	{
		"table.remove is C function",
		function()
			local v1365

			if debug.info(table.remove, "s") ~= "[C]" then
				v1365 = false
			else
				v1365 = debug.info(table.remove, "l") == -1
			end

			return v1365
		end,
	},
	{
		"table.remove logic correct",
		function()
			local t22 = { 10, 20, 30 }
			local v1367

			if table.remove(t22, 2) ~= 20 or #t22 ~= 2 then
				v1367 = false
			else
				v1367 = t22[2] == 30
			end

			return v1367
		end,
	},
	{
		"table.sort is C function",
		function()
			local v1368

			if debug.info(table.sort, "s") ~= "[C]" then
				v1368 = false
			else
				v1368 = debug.info(table.sort, "l") == -1
			end

			return v1368
		end,
	},
	{
		"table.sort logic correct",
		function()
			local t23 = { 1, 5, 2 }

			table.sort(t23, function(p20, p21)
				return p21 < p20
			end)
			local v1370

			if t23[1] ~= 5 then
				v1370 = false
			else
				v1370 = t23[3] == 1
			end

			return v1370
		end,
	},
	{
		"tostring is C function",
		function()
			local v1371

			if debug.info(tostring, "s") ~= "[C]" then
				v1371 = false
			else
				v1371 = debug.info(tostring, "l") == -1
			end

			return v1371
		end,
	},
	{
		"tostring logic correct",
		function()
			return tostring(123) == "123"
		end,
	},
	{
		"tonumber is C function",
		function()
			local v1372

			if debug.info(tonumber, "s") ~= "[C]" then
				v1372 = false
			else
				v1372 = debug.info(tonumber, "l") == -1
			end

			return v1372
		end,
	},
	{
		"tonumber logic correct",
		function()
			local v1373

			if tonumber("10") ~= 10 then
				v1373 = false
			else
				v1373 = tonumber("0xFF") == 255
			end

			return v1373
		end,
	},
	{
		"tonumber errors on bad base",
		function()
			local ok, result = pcall(tonumber, "10", 999)
			local v1376 = not ok

			if not v1376 then
				return v1376
			end

			v1376 = result:find("base out of range") ~= nil

			return v1376
		end,
	},
	{
		"string.len is C function",
		function()
			local v1377

			if debug.info(string.len, "s") ~= "[C]" then
				v1377 = false
			else
				v1377 = debug.info(string.len, "l") == -1
			end

			return v1377
		end,
	},
	{
		"string.len logic correct",
		function()
			return string.len("hello") == 5
		end,
	},
	{
		"pairs is C function",
		function()
			local v1378

			if debug.info(pairs, "s") ~= "[C]" then
				v1378 = false
			else
				v1378 = debug.info(pairs, "l") == -1
			end

			return v1378
		end,
	},
	{
		"pairs logic correct",
		function()
			local t24 = {
				x = 1,
			}
			local v1380, v1381, v1382 = pairs(t24)
			local v1383, v1384 = v1380(v1381, v1382)
			local v1385

			if v1383 == "x" and (v1384 == 1 and v1381 == t24) then
				v1385 = v1382 == nil
			else
				v1385 = false
			end

			return v1385
		end,
	},
	{
		"ipairs is C function",
		function()
			local v1386

			if debug.info(ipairs, "s") ~= "[C]" then
				v1386 = false
			else
				v1386 = debug.info(ipairs, "l") == -1
			end

			return v1386
		end,
	},
	{
		"ipairs logic correct",
		function()
			local t25 = { 10, 20 }
			local v1388, v1389, v1390 = ipairs(t25)
			local v1391, v1392 = v1388(v1389, v1390)
			local v1393

			if v1392 == 10 and (v1391 == 1 and v1390 == 0) then
				v1393 = v1389 == t25
			else
				v1393 = false
			end

			return v1393
		end,
	},
	{
		"next is C function",
		function()
			local v1394

			if debug.info(next, "s") ~= "[C]" then
				v1394 = false
			else
				v1394 = debug.info(next, "l") == -1
			end

			return v1394
		end,
	},
	{
		"next logic correct",
		function()
			local t26 = {
				a = 10,
			}
			local v1396

			if next(t26, nil) ~= "a" then
				v1396 = false
			else
				v1396 = next(t26, "a") == nil
			end

			return v1396
		end,
	},
	{
		"type is C function",
		function()
			local v1397

			if debug.info(type, "s") ~= "[C]" then
				v1397 = false
			else
				v1397 = debug.info(type, "l") == -1
			end

			return v1397
		end,
	},
	{
		"type logic correct",
		function()
			local v1398

			if type(1) ~= "number" or type("s") ~= "string" then
				v1398 = false
			else
				v1398 = type({}) == "table"
			end

			return v1398
		end,
	},
	{
		"typeof is C function",
		function()
			local v1399

			if debug.info(typeof, "s") ~= "[C]" then
				v1399 = false
			else
				v1399 = debug.info(typeof, "l") == -1
			end

			return v1399
		end,
	},
	{
		"typeof logic correct",
		function()
			local function v1400(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local v1401 = v1400(Vector3.new())

			unpack(v1401, 1, 1)
			local v1402

			if typeof(unpack(v1401, 1, v1401.n)) ~= "Vector3" then
				v1402 = false
			else
				local v1403 = v1400(CFrame.new())

				unpack(v1403, 1, 1)
				v1402 = typeof(unpack(v1403, 1, v1403.n)) == "CFrame"
			end

			return v1402
		end,
	},
	{
		"select is C function",
		function()
			local v1404

			if debug.info(select, "s") ~= "[C]" then
				v1404 = false
			else
				v1404 = debug.info(select, "l") == -1
			end

			return v1404
		end,
	},
	{
		"select logic correct",
		function()
			local v1405

			if select("#", 1, 2, 3) ~= 3 then
				v1405 = false
			else
				v1405 = select(2, "a", "b", "c") == "b"
			end

			return v1405
		end,
	},
	{
		"unpack is C function",
		function()
			local v1406

			if debug.info(unpack, "s") ~= "[C]" then
				v1406 = false
			else
				v1406 = debug.info(unpack, "l") == -1
			end

			return v1406
		end,
	},
	{
		"unpack logic correct",
		function()
			local value, v1408 = unpack({ 10, 20 })
			local v1409

			if value == 10 then
				v1409 = v1408 == 20
			else
				v1409 = false
			end

			return v1409
		end,
	},
	{
		"task.wait is C function",
		function()
			local v1410

			if debug.info(task.wait, "s") ~= "[C]" then
				v1410 = false
			else
				v1410 = debug.info(task.wait, "l") == -1
			end

			return v1410
		end,
	},
	{
		"task.wait timing correct",
		function()
			local now = os.clock()

			task.wait(0.05)

			return os.clock() - now >= 0.04
		end,
	},
	{
		"task.spawn is C function",
		function()
			local v1412

			if debug.info(task.spawn, "s") ~= "[C]" then
				v1412 = false
			else
				v1412 = debug.info(task.spawn, "l") == -1
			end

			return v1412
		end,
	},
	{
		"os.clock is C function",
		function()
			local v1413

			if debug.info(os.clock, "s") ~= "[C]" then
				v1413 = false
			else
				v1413 = debug.info(os.clock, "l") == -1
			end

			return v1413
		end,
	},
	{
		"os.clock logic correct",
		function()
			local now = os.clock()
			local now2 = os.clock()
			local v1416

			if type(now) ~= "number" then
				v1416 = false
			else
				v1416 = now <= now2
			end

			return v1416
		end,
	},
	{
		"os.time is C function",
		function()
			local v1417

			if debug.info(os.time, "s") ~= "[C]" then
				v1417 = false
			else
				v1417 = debug.info(os.time, "l") == -1
			end

			return v1417
		end,
	},
	{
		"os.time logic correct",
		function()
			local v1418 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(os.time())

			unpack(v1418, 1, 1)

			return type(unpack(v1418, 1, v1418.n)) == "number"
		end,
	},
	{
		"coroutine.create is C function",
		function()
			local v1419

			if debug.info(coroutine.create, "s") ~= "[C]" then
				v1419 = false
			else
				v1419 = debug.info(coroutine.create, "l") == -1
			end

			return v1419
		end,
	},
	{
		"coroutine.wrap is C function",
		function()
			local v1420

			if debug.info(coroutine.wrap, "s") ~= "[C]" then
				v1420 = false
			else
				v1420 = debug.info(coroutine.wrap, "l") == -1
			end

			return v1420
		end,
	},
	{
		"coroutine.wrap logic correct",
		function()
			return coroutine.wrap(function(p22)
				return p22 * 2
			end)(10) == 20
		end,
	},
	{
		"bit32.bxor is C function",
		function()
			local v1421

			if debug.info(bit32.bxor, "s") ~= "[C]" then
				v1421 = false
			else
				v1421 = debug.info(bit32.bxor, "l") == -1
			end

			return v1421
		end,
	},
	{
		"bit32.bxor logic correct",
		function()
			return true
		end,
	},
	{
		"bit32.band is C function",
		function()
			local v1422

			if debug.info(bit32.band, "s") ~= "[C]" then
				v1422 = false
			else
				v1422 = debug.info(bit32.band, "l") == -1
			end

			return v1422
		end,
	},
	{
		"bit32.band logic correct",
		function()
			return bit32.band(240, 204) == 192
		end,
	},
	{
		"bit32.rrotate is C function",
		function()
			local v1423

			if debug.info(bit32.rrotate, "s") ~= "[C]" then
				v1423 = false
			else
				v1423 = debug.info(bit32.rrotate, "l") == -1
			end

			return v1423
		end,
	},
	{
		"bit32.rrotate logic correct",
		function()
			return bit32.rrotate(8, 1) == 4
		end,
	},
	{
		"utf8.char is C function",
		function()
			local v1424

			if debug.info(utf8.char, "s") ~= "[C]" then
				v1424 = false
			else
				v1424 = debug.info(utf8.char, "l") == -1
			end

			return v1424
		end,
	},
	{
		"utf8.char logic correct",
		function()
			return utf8.char(97, 98, 99) == "abc"
		end,
	},
	{
		"utf8.char errors out of range",
		function()
			local ok, result = pcall(utf8.char, -1)
			local v1427 = not ok

			if not v1427 then
				return v1427
			end

			v1427 = result:find("out of range") ~= nil

			return v1427
		end,
	},
	{
		"Random.new is C function",
		function()
			local v1428

			if debug.info(Random.new, "s") ~= "[C]" then
				v1428 = false
			else
				v1428 = debug.info(Random.new, "l") == -1
			end

			return v1428
		end,
	},
	{
		"setmetatable is C function",
		function()
			local v1429

			if debug.info(setmetatable, "s") ~= "[C]" then
				v1429 = false
			else
				v1429 = debug.info(setmetatable, "l") == -1
			end

			return v1429
		end,
	},
	{
		"vector.cross is C function",
		function()
			local v1430

			if debug.info(vector.cross, "s") ~= "[C]" then
				v1430 = false
			else
				v1430 = debug.info(vector.cross, "l") == -1
			end

			return v1430
		end,
	},
	{
		"vector.cross logic correct",
		function()
			local v1431 = vector.create(1, 0, 0)
			local v1432 = vector.create(0, 1, 0)

			return vector.cross(v1431, v1432).Z == 1
		end,
	},
	{
		"vector.magnitude is C function",
		function()
			local v1433

			if debug.info(vector.magnitude, "s") ~= "[C]" then
				v1433 = false
			else
				v1433 = debug.info(vector.magnitude, "l") == -1
			end

			return v1433
		end,
	},
	{
		"vector.magnitude logic correct",
		function()
			local v1434 = vector.create(1, 1, 1)
			local v1435 = vector.magnitude(v1434) - 1.73205

			return math.abs(v1435) < 0.0001
		end,
	},
	{
		"CFrame.lookAt is C function",
		function()
			local v1436

			if debug.info(CFrame.lookAt, "s") ~= "[C]" then
				v1436 = false
			else
				v1436 = debug.info(CFrame.lookAt, "l") == -1
			end

			return v1436
		end,
	},
	{
		"CFrame.lookAt logic correct",
		function()
			local v1437 = CFrame.lookAt(Vector3.new(0, 10, 0), Vector3.new(0, 20, 0)).LookVector.Y - 1

			return math.abs(v1437) < 0.0001
		end,
	},
	{
		"TweenService:Create is C function",
		function()
			local v1438

			if debug.info(game:GetService("TweenService").Create, "s") ~= "[C]" then
				v1438 = false
			else
				v1438 = debug.info(game:GetService("TweenService").Create, "l") == -1
			end

			return v1438
		end,
	},
	{
		"PhysicalProperties.new is C function",
		function()
			local v1439

			if debug.info(PhysicalProperties.new, "s") ~= "[C]" then
				v1439 = false
			else
				v1439 = debug.info(PhysicalProperties.new, "l") == -1
			end

			return v1439
		end,
	},
})
v25("Faces", {
	{
		"Faces.new returns correct type",
		function()
			local v1440 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Faces.new(Enum.NormalId.Top))

			return typeof(unpack(v1440, 1, v1440.n)) == "Faces"
		end,
	},
	{
		"Faces.new empty returns correct type",
		function()
			local v1443 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Faces.new())

			unpack(v1443, 1, 1)

			return typeof(unpack(v1443, 1, v1443.n)) == "Faces"
		end,
	},
	{
		"Faces.Top is boolean",
		function()
			local Top = Faces.new(Enum.NormalId.Top).Top

			return type(Top) == "boolean"
		end,
	},
	{
		"Faces.Top true when set",
		function()
			return Faces.new(Enum.NormalId.Top).Top == true
		end,
	},
	{
		"Faces.Top false when not set",
		function()
			return Faces.new(Enum.NormalId.Bottom).Top == false
		end,
	},
	{
		"Faces.Bottom is boolean",
		function()
			local Bottom = Faces.new(Enum.NormalId.Bottom).Bottom

			return type(Bottom) == "boolean"
		end,
	},
	{
		"Faces.Bottom true when set",
		function()
			return Faces.new(Enum.NormalId.Bottom).Bottom == true
		end,
	},
	{
		"Faces.Left is boolean",
		function()
			local Left = Faces.new(Enum.NormalId.Left).Left

			return type(Left) == "boolean"
		end,
	},
	{
		"Faces.Left true when set",
		function()
			return Faces.new(Enum.NormalId.Left).Left == true
		end,
	},
	{
		"Faces.Right is boolean",
		function()
			local Right = Faces.new(Enum.NormalId.Right).Right

			return type(Right) == "boolean"
		end,
	},
	{
		"Faces.Right true when set",
		function()
			return Faces.new(Enum.NormalId.Right).Right == true
		end,
	},
	{
		"Faces.Back is boolean",
		function()
			local Back = Faces.new(Enum.NormalId.Back).Back

			return type(Back) == "boolean"
		end,
	},
	{
		"Faces.Back true when set",
		function()
			return Faces.new(Enum.NormalId.Back).Back == true
		end,
	},
	{
		"Faces.Front is boolean",
		function()
			local Front = Faces.new(Enum.NormalId.Front).Front

			return type(Front) == "boolean"
		end,
	},
	{
		"Faces.Front true when set",
		function()
			return Faces.new(Enum.NormalId.Front).Front == true
		end,
	},
	{
		"Faces multiple NormalIds correct",
		function()
			local v1450 = Faces.new(Enum.NormalId.Front, Enum.NormalId.Left)
			local v1451

			if v1450.Front ~= true or v1450.Left ~= true then
				v1451 = false
			else
				v1451 = v1450.Top == false
			end

			return v1451
		end,
	},
	{
		"Faces invalid args ignored silently",
		function()
			return pcall(function()
				Faces.new("invalid", 123, true)
			end)
		end,
	},
	{
		"Faces is immutable",
		function()
			local v1452 = Faces.new(Enum.NormalId.Top)

			return not pcall(function()
				v1452.Top = false
			end)
		end,
	},
})
v25("Secret", {
	{
		"HttpService:GetSecret exists",
		function()
			local GetSecret = game:GetService("HttpService").GetSecret

			return type(GetSecret) == "function"
		end,
	},
	{
		"Secret:AddPrefix exists",
		function()
			local ok, result = pcall(function()
				return game:GetService("HttpService"):GetSecret("eunc_test")
			end)

			if ok then
				local AddPrefix = result.AddPrefix

				return type(AddPrefix) == "function"
			else
				return true
			end
		end,
	},
	{
		"Secret:AddSuffix exists",
		function()
			local ok, result = pcall(function()
				return game:GetService("HttpService"):GetSecret("eunc_test")
			end)

			if ok then
				local AddSuffix = result.AddSuffix

				return type(AddSuffix) == "function"
			else
				return true
			end
		end,
	},
})
v25("PhysicalProperties", {
	{
		"PhysicalProperties.Density correct",
		function()
			local v1460 = PhysicalProperties.new(0.5, 0.3, 0.1).Density - 0.5

			return math.abs(v1460) < 0.001
		end,
	},
	{
		"PhysicalProperties.Friction correct",
		function()
			local v1461 = PhysicalProperties.new(0.5, 0.3, 0.1).Friction - 0.3

			return math.abs(v1461) < 0.001
		end,
	},
	{
		"PhysicalProperties from Material Density is number",
		function()
			local Density = PhysicalProperties.new(Enum.Material.Wood).Density

			return type(Density) == "number"
		end,
	},
})
v25("Font", {
	{
		"Font.new returns Font",
		function()
			local v1463 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Font.new("rbxasset://fonts/families/SourceSansPro.json"))

			return typeof(unpack(v1463, 1, v1463.n)) == "Font"
		end,
	},
	{
		"Font.Weight correct",
		function()
			return Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal).Weight == Enum.FontWeight.Bold
		end,
	},
})
v25("Axes", {
	{
		"Axes.new returns correct type",
		function()
			local v1466 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Axes.new(Enum.Axis.X))

			return typeof(unpack(v1466, 1, v1466.n)) == "Axes"
		end,
	},
	{
		"Axes.X is boolean",
		function()
			local X = Axes.new(Enum.Axis.X).X

			return type(X) == "boolean"
		end,
	},
	{
		"Axes.Y is boolean",
		function()
			local Y = Axes.new(Enum.Axis.Y).Y

			return type(Y) == "boolean"
		end,
	},
	{
		"Axes.Z is boolean",
		function()
			local Z = Axes.new(Enum.Axis.Z).Z

			return type(Z) == "boolean"
		end,
	},
	{
		"Axes.X true when X axis set",
		function()
			return Axes.new(Enum.Axis.X).X == true
		end,
	},
	{
		"Axes.Y false when only X set",
		function()
			return Axes.new(Enum.Axis.X).Y == false
		end,
	},
	{
		"Axes.Top is boolean",
		function()
			local Top = Axes.new(Enum.NormalId.Top).Top

			return type(Top) == "boolean"
		end,
	},
	{
		"Axes.Bottom is boolean",
		function()
			local Bottom = Axes.new(Enum.NormalId.Bottom).Bottom

			return type(Bottom) == "boolean"
		end,
	},
	{
		"Axes.Left is boolean",
		function()
			local Left = Axes.new(Enum.NormalId.Left).Left

			return type(Left) == "boolean"
		end,
	},
	{
		"Axes.Right is boolean",
		function()
			local Right = Axes.new(Enum.NormalId.Right).Right

			return type(Right) == "boolean"
		end,
	},
	{
		"Axes.Back is boolean",
		function()
			local Back = Axes.new(Enum.NormalId.Back).Back

			return type(Back) == "boolean"
		end,
	},
	{
		"Axes.Front is boolean",
		function()
			local Front = Axes.new(Enum.NormalId.Front).Front

			return type(Front) == "boolean"
		end,
	},
	{
		"Axes NormalId converted to axis",
		function()
			return Axes.new(Enum.NormalId.Top).Y == true
		end,
	},
})
v25("PathWaypoint", {
	{
		"PathWaypoint.new returns correct type",
		function()
			local v1478 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk))

			return typeof(unpack(v1478, 1, v1478.n)) == "PathWaypoint"
		end,
	},
	{
		"PathWaypoint.Position is Vector3",
		function()
			local Position = PathWaypoint.new(Vector3.new(10, 10, 10), Enum.PathWaypointAction.Walk).Position

			return typeof(Position) == "Vector3"
		end,
	},
	{
		"PathWaypoint.Position correct",
		function()
			return PathWaypoint.new(Vector3.new(10, 10, 10), Enum.PathWaypointAction.Walk).Position == Vector3.new(10, 10, 10)
		end,
	},
	{
		"PathWaypoint.Action is EnumItem",
		function()
			local Action = PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk).Action

			return typeof(Action) == "EnumItem"
		end,
	},
	{
		"PathWaypoint.Action correct",
		function()
			return PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Jump).Action == Enum.PathWaypointAction.Jump
		end,
	},
	{
		"PathWaypoint.Label is string",
		function()
			local Label = PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk, "TestLabel").Label

			return type(Label) == "string"
		end,
	},
	{
		"PathWaypoint.Label correct",
		function()
			return PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk, "TestLabel").Label == "TestLabel"
		end,
	},
	{
		"PathWaypoint.Label default is empty string",
		function()
			return PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk).Label == ""
		end,
	},
})
v25("RBXScriptConnection", {
	{
		"RBXScriptConnection.Connected is true after connect",
		function()
			local connection = game:GetService("RunService").Heartbeat:Connect(function() end)
			local v1488 = connection.Connected == true

			connection:Disconnect()

			return v1488
		end,
	},
	{
		"RBXScriptConnection.Connected is false after disconnect",
		function()
			local connection = game:GetService("RunService").Heartbeat:Connect(function() end)

			connection:Disconnect()

			return connection.Connected == false
		end,
	},
	{
		"RBXScriptConnection:Disconnect works",
		function()
			game:GetService("RunService").Heartbeat:Connect(function() end):Disconnect()

			return true
		end,
	},
})
v25("RBXScriptSignal", {
	{
		"RBXScriptSignal:Connect returns RBXScriptConnection",
		function()
			local connection = game:GetService("RunService").Heartbeat:Connect(function() end)
			local v1491 = typeof(connection) == "RBXScriptConnection"

			connection:Disconnect()

			return v1491
		end,
	},
	{
		"RBXScriptSignal:Once returns RBXScriptConnection",
		function()
			local connection = game:GetService("RunService").Heartbeat:Once(function() end)
			local v1493 = typeof(connection) == "RBXScriptConnection"

			connection:Disconnect()

			return v1493
		end,
	},
	{
		"RBXScriptSignal:Once fires only once",
		function()
			local n9 = 0

			game:GetService("RunService").Heartbeat:Once(function()
				n9 = n9 + 1
			end)
			task.wait()
			task.wait()

			return false
		end,
	},
	{
		"RBXScriptSignal:Wait returns value",
		function()
			local result = game:GetService("RunService").Heartbeat:Wait()

			return type(result) == "number"
		end,
	},
})
v25("Rect", {
	{
		"Rect.new empty returns correct type",
		function()
			local v1496 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Rect.new())

			unpack(v1496, 1, 1)

			return typeof(unpack(v1496, 1, v1496.n)) == "Rect"
		end,
	},
	{
		"Rect.new from Vector2 correct",
		function()
			local rect = Rect.new(Vector2.new(10, 10), Vector2.new(80, 80))
			local v1498

			if rect.Min.X ~= 10 then
				v1498 = false
			else
				v1498 = rect.Max.X == 80
			end

			return v1498
		end,
	},
	{
		"Rect.new from numbers correct",
		function()
			local rect = Rect.new(10, 10, 80, 80)
			local v1500

			if rect.Min.X ~= 10 then
				v1500 = false
			else
				v1500 = rect.Max.Y == 80
			end

			return v1500
		end,
	},
	{
		"Rect.Width correct",
		function()
			return Rect.new(10, 10, 80, 80).Width == 70
		end,
	},
	{
		"Rect.Height correct",
		function()
			return Rect.new(10, 10, 80, 80).Height == 70
		end,
	},
	{
		"Rect.Min is Vector2",
		function()
			local Min = Rect.new(10, 10, 80, 80).Min

			return typeof(Min) == "Vector2"
		end,
	},
	{
		"Rect.Max is Vector2",
		function()
			local Max = Rect.new(10, 10, 80, 80).Max

			return typeof(Max) == "Vector2"
		end,
	},
})
v25("Region3int16", {
	{
		"Region3int16.new returns correct type",
		function()
			local function v1503(...)
				return {
					...,
					n = select("#", ...),
				}
			end

			local region3int16New = Region3int16.new
			local v1505 = Vector3int16.new(0, 0, 0)
			local v1506 = v1503(Vector3int16.new(4, 4, 4))
			local v1507 = v1503(region3int16New(v1505, unpack(v1506, 1, v1506.n)))

			return typeof(unpack(v1507, 1, v1507.n)) == "Region3int16"
		end,
	},
	{
		"Region3int16.Min is Vector3int16",
		function()
			local Min = Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(4, 4, 4)).Min

			return typeof(Min) == "Vector3int16"
		end,
	},
	{
		"Region3int16.Max is Vector3int16",
		function()
			local Max = Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(4, 4, 4)).Max

			return typeof(Max) == "Vector3int16"
		end,
	},
	{
		"Region3int16.Min correct",
		function()
			local v1516 = Region3int16.new(Vector3int16.new(1, 2, 3), Vector3int16.new(4, 5, 6))
			local v1517

			if v1516.Min.X ~= 1 or v1516.Min.Y ~= 2 then
				v1517 = false
			else
				v1517 = v1516.Min.Z == 3
			end

			return v1517
		end,
	},
	{
		"Region3int16.Max correct",
		function()
			local v1518 = Region3int16.new(Vector3int16.new(1, 2, 3), Vector3int16.new(4, 5, 6))
			local v1519

			if v1518.Max.X ~= 4 or v1518.Max.Y ~= 5 then
				v1519 = false
			else
				v1519 = v1518.Max.Z == 6
			end

			return v1519
		end,
	},
})
v25("RotationCurveKey", {
	{
		"RotationCurveKey.new returns correct type",
		function()
			local v1520 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant))

			return typeof(unpack(v1520, 1, v1520.n)) == "RotationCurveKey"
		end,
	},
	{
		"RotationCurveKey.Time correct",
		function()
			return RotationCurveKey.new(0.5, CFrame.new(), Enum.KeyInterpolationMode.Constant).Time == 0.5
		end,
	},
	{
		"RotationCurveKey.Value is CFrame",
		function()
			local Value = RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant).Value

			return typeof(Value) == "CFrame"
		end,
	},
	{
		"RotationCurveKey.Interpolation is EnumItem",
		function()
			local Interpolation = RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant).Interpolation

			return typeof(Interpolation) == "EnumItem"
		end,
	},
	{
		"RotationCurveKey.Interpolation correct",
		function()
			return RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Cubic).Interpolation == Enum.KeyInterpolationMode.Cubic
		end,
	},
	{
		"RotationCurveKey.LeftTangent is number",
		function()
			local LeftTangent = RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant).LeftTangent

			return type(LeftTangent) == "number"
		end,
	},
})
v25("SecurityCapabilities", {
	{
		"SecurityCapabilities.new returns correct type",
		function()
			local v1528 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SecurityCapabilities.new())

			unpack(v1528, 1, 1)

			return typeof(unpack(v1528, 1, v1528.n)) == "SecurityCapabilities"
		end,
	},
	{
		"SecurityCapabilities.new with items correct",
		function()
			local v1529 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SecurityCapabilities.new(Enum.SecurityCapability.Basic))

			return typeof(unpack(v1529, 1, v1529.n)) == "SecurityCapabilities"
		end,
	},
	{
		"SecurityCapabilities.fromCurrent returns correct type",
		function()
			local v1532 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SecurityCapabilities.fromCurrent())

			unpack(v1532, 1, 1)

			return typeof(unpack(v1532, 1, v1532.n)) == "SecurityCapabilities"
		end,
	},
	{
		"SecurityCapabilities:Add returns SecurityCapabilities",
		function()
			local v1533 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SecurityCapabilities.new():Add(Enum.SecurityCapability.Basic))

			return typeof(unpack(v1533, 1, v1533.n)) == "SecurityCapabilities"
		end,
	},
	{
		"SecurityCapabilities:Remove returns SecurityCapabilities",
		function()
			local v1538 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SecurityCapabilities.new(Enum.SecurityCapability.Basic):Remove(Enum.SecurityCapability.Basic))

			return typeof(unpack(v1538, 1, v1538.n)) == "SecurityCapabilities"
		end,
	},
	{
		"SecurityCapabilities:Contains returns boolean",
		function()
			local v1541 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(SecurityCapabilities.new(Enum.SecurityCapability.Basic):Contains(Enum.SecurityCapability.Basic))

			return type(unpack(v1541, 1, v1541.n)) == "boolean"
		end,
	},
	{
		"SecurityCapabilities:Contains true when present",
		function()
			return SecurityCapabilities.new(Enum.SecurityCapability.Basic):Contains(Enum.SecurityCapability.Basic) == true
		end,
	},
	{
		"SecurityCapabilities:Contains false when not present",
		function()
			return SecurityCapabilities.new():Contains(Enum.SecurityCapability.Basic) == false
		end,
	},
	{
		"SecurityCapabilities:Add does not duplicate",
		function()
			return SecurityCapabilities.new(Enum.SecurityCapability.Basic):Add(Enum.SecurityCapability.Basic):Contains(Enum.SecurityCapability.Basic) == true
		end,
	},
})
v25("eDateTimes", {
	{
		"DateTime.now returns DateTime",
		function()
			local v1545 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(DateTime.now())

			unpack(v1545, 1, 1)

			return typeof(unpack(v1545, 1, v1545.n)) == "DateTime"
		end,
	},
	{
		"DateTime.fromUnixTimestamp returns DateTime",
		function()
			local v1546 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(DateTime.fromUnixTimestamp(0))

			return typeof(unpack(v1546, 1, v1546.n)) == "DateTime"
		end,
	},
	{
		"DateTime.fromIsoDate returns DateTime",
		function()
			local v1549 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(DateTime.fromIsoDate("2024-01-01T00:00:00Z"))

			return typeof(unpack(v1549, 1, v1549.n)) == "DateTime"
		end,
	},
	{
		"DateTime:ToIsoDate returns string",
		function()
			local ok, result = pcall(function()
				return DateTime.now():ToIsoDate()
			end)

			if not ok then
				return ok
			end

			ok = type(result) == "string"

			return ok
		end,
	},
	{
		"DateTime:ToLocalTime Year is number",
		function()
			local ok, result = pcall(function()
				return DateTime.now():ToLocalTime()
			end)

			if not ok then
				return ok
			end

			local Year = result.Year

			ok = type(Year) == "number"

			return ok
		end,
	},
	{
		"DateTime:ToUniversalTime Year is number",
		function()
			local ok, result = pcall(function()
				return DateTime.now():ToUniversalTime()
			end)

			if not ok then
				return ok
			end

			local Year = result.Year

			ok = type(Year) == "number"

			return ok
		end,
	},
	{
		"DateTime.UnixTimestampMillis is number",
		function()
			local UnixTimestampMillis = DateTime.now().UnixTimestampMillis

			return type(UnixTimestampMillis) == "number"
		end,
	},
	{
		"DateTime.UnixTimestampMillis is positive",
		function()
			return DateTime.now().UnixTimestampMillis > 0
		end,
	},
	{
		"DateTime:FormatUniversalTime epoch is 1970-01-01",
		function()
			local v1561 = DateTime.fromUnixTimestamp(0)
			local v1563 = v1561
			local ok, result = pcall(function()
				return v1563:FormatUniversalTime("YYYY-MM-DD", "en-us")
			end)

			if ok then
				local v1566 = string.split(result, "-")
				local v1567

				if #v1566 ~= 3 or (v1566[1] ~= "1970" or v1566[2] ~= "01") then
					v1567 = false
				else
					v1567 = v1566[3] == "01"
				end

				return v1567
			else
				return false
			end
		end,
	},
	{
		"DateTime pcall overhead is not faked",
		function()
			local UnixTimestampMillis = DateTime.now().UnixTimestampMillis

			local function v1569()
				return 1
			end

			local n10 = 0

			for _ = 1, 25000 do
				local ok, result = pcall(v1569)

				if ok then
					n10 = n10 + result
				end
			end
			local v1575

			if DateTime.now().UnixTimestampMillis - UnixTimestampMillis > 15 then
				v1575 = false
			else
				v1575 = n10 == 25000
			end

			return v1575
		end,
	},
})
v25("workspace raycasting", {
	{
		"workspace:Raycast returns RaycastResult or nil",
		function()
			local vector3 = Vector3.new(0, 100, 0)
			local v1577 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, -200, 0))
			local hit = workspace:Raycast(vector3, unpack(v1577, 1, v1577.n))

			return hit == nil and true or typeof(hit) == "RaycastResult"
		end,
	},
	{
		"RaycastResult.Position is Vector3",
		function()
			local Part = Instance.new("Part")

			Part.Anchored = true
			Part.Position = Vector3.new(0, 0, 0)
			Part.Size = Vector3.new(100, 1, 100)
			Part.Parent = workspace
			local vector3 = Vector3.new(0, 100, 0)
			local v1586 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, -200, 0))
			local hit = workspace:Raycast(vector3, unpack(v1586, 1, v1586.n))

			Part:Destroy()
			local v1592

			if hit == nil then
				v1592 = false
			else
				local Position = hit.Position

				v1592 = typeof(Position) == "Vector3"
			end

			return v1592
		end,
	},
	{
		"RaycastResult.Normal is Vector3",
		function()
			local Part = Instance.new("Part")

			Part.Anchored = true
			Part.Position = Vector3.new(0, 0, 0)
			Part.Size = Vector3.new(100, 1, 100)
			Part.Parent = workspace
			local vector3 = Vector3.new(0, 100, 0)
			local v1597 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, -200, 0))
			local hit = workspace:Raycast(vector3, unpack(v1597, 1, v1597.n))

			Part:Destroy()
			local v1603

			if hit == nil then
				v1603 = false
			else
				local Normal = hit.Normal

				v1603 = typeof(Normal) == "Vector3"
			end

			return v1603
		end,
	},
	{
		"RaycastResult.Distance is number",
		function()
			local Part = Instance.new("Part")

			Part.Anchored = true
			Part.Position = Vector3.new(0, 0, 0)
			Part.Size = Vector3.new(100, 1, 100)
			Part.Parent = workspace
			local vector3 = Vector3.new(0, 100, 0)
			local v1608 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, -200, 0))
			local hit = workspace:Raycast(vector3, unpack(v1608, 1, v1608.n))

			Part:Destroy()
			local v1614

			if hit == nil then
				v1614 = false
			else
				local Distance = hit.Distance

				v1614 = type(Distance) == "number"
			end

			return v1614
		end,
	},
	{
		"RaycastResult.Instance is Instance",
		function()
			local Part = Instance.new("Part")

			Part.Anchored = true
			Part.Position = Vector3.new(0, 0, 0)
			Part.Size = Vector3.new(100, 1, 100)
			Part.Parent = workspace
			local vector3 = Vector3.new(0, 100, 0)
			local v1619 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, -200, 0))
			local hit = workspace:Raycast(vector3, unpack(v1619, 1, v1619.n))

			Part:Destroy()
			local v1625

			if hit == nil then
				v1625 = false
			else
				local Instance_ = hit.Instance

				v1625 = typeof(Instance_) == "Instance"
			end

			return v1625
		end,
	},
	{
		"RaycastResult hits correct instance",
		function()
			local Part = Instance.new("Part")

			Part.Anchored = true
			Part.Position = Vector3.new(0, 0, 0)
			Part.Size = Vector3.new(100, 1, 100)
			Part.Parent = workspace
			task.wait(3)
			local vector3 = Vector3.new(0, 100, 0)
			local v1630 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Vector3.new(0, -200, 0))
			local hit = workspace:Raycast(vector3, unpack(v1630, 1, v1630.n))
			local v1636

			if hit == nil then
				v1636 = false
			else
				v1636 = hit.Instance == Part
			end

			Part:Destroy()

			return v1636
		end,
	},
	{
		"RaycastParams FilterDescendantsInstances works",
		function()
			local Part = Instance.new("Part")

			Part.Anchored = true
			Part.Position = Vector3.new(0, 0, 0)
			Part.Size = Vector3.new(100, 1, 100)
			Part.Parent = workspace

			local raycastParams = RaycastParams.new()

			raycastParams.FilterDescendantsInstances = { Part }
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude

			local hit = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), raycastParams)

			Part:Destroy()

			return hit == nil and true or hit.Instance ~= Part
		end,
	},
})

local v1640 = v9

v11("loadstring executes code (using an url)", function()
	local u1641 = nil
	local print_ = getfenv(0).print

	getfenv(0).print = function(...)
		local v1643 = (function(...)
			return {
				...,
				n = select("#", ...),
			}
		end)(select(1, ...))

		u1641 = tostring(unpack(v1643, 1, v1643.n))
	end

	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://pastefy.app/r6upMyCZ/raw"))
	end)

	if not (ok and type(result) == "function") then
		getfenv(0).print = print_
		v1308 = nil
		v1640(false, "loadstring remote script did not print 'hi!', got: " .. tostring(nil))

		return
	end

	pcall(result)
	getfenv(0).print = print_

	v1640(u1641 == "hi!", "loadstring remote script did not print 'hi!', got: " .. tostring(u1641))
end)

local v1650 = v9

v11("loadstring cannot load Luau bytecode", function()
	local ok, result = pcall(function()
		return game:GetService("Players").LocalPlayer.Character.Animate
	end)

	if not (ok and result) then
		return
	end
	local v1654 = result
	local ok2, result2 = pcall(function()
		return getscriptbytecode(v1654)
	end)

	if ok2 and result2 then
		local chunk = loadstring(result2)

		v1650(type(chunk) ~= "function", "Luau bytecode should not be loadable via loadstring")
	end
end)

local v1658 = v9

v11("Vector3 components are frozen", function()
	local Part = Instance.new("Part")
	local v1661 = Part

	v1658(not pcall(function()
		v1661.Position.X = 10
	end))
end)

local v1662 = v9

v11("Color3 components are frozen", function()
	local color3 = Color3.new(1, 1, 1)
	local v1665 = color3

	v1662(not pcall(function()
		v1665.R = 0
	end))
end)

local v1666 = v9

v11("rawlen works on string and table", function()
	v1666(rawlen("abc") == 3)
	v1666(rawlen({ 1, 2 }) == 2)
end)

local v1667 = v9

v11("Instance SetAttribute and GetAttribute", function()
	local Part = Instance.new("Part")

	Part:SetAttribute("T", 123)
	v1667(Part:GetAttribute("T") == 123)
end)

local v1669 = v9

v11("CollectionService AddTag and HasTag", function()
	local CollectionService = game:GetService("CollectionService")
	local Part = Instance.new("Part")

	CollectionService:AddTag(Part, "T")
	v1669(CollectionService:HasTag(Part, "T"))
end)

local v1672 = v9

v11("Humanoid.MoveDirection is Vector3", function()
	local Humanoid = Instance.new("Humanoid")
	local MoveDirection = Humanoid.MoveDirection

	v1672(typeof(MoveDirection) == "Vector3")
	Humanoid:Destroy()
end)

local v1676 = v9

v11("Camera.FieldOfView is writable", function()
	local CurrentCamera = workspace.CurrentCamera

	if CurrentCamera then
		local FieldOfView = CurrentCamera.FieldOfView

		CurrentCamera.FieldOfView = 70
		v1676(CurrentCamera.FieldOfView == 70)
		CurrentCamera.FieldOfView = FieldOfView
	end
end)
v25("Enum", {
	{
		"Enum.EasingStyle.Linear is EnumItem",
		function()
			local Linear = Enum.EasingStyle.Linear

			return typeof(Linear) == "EnumItem"
		end,
	},
	{
		"Enum.PartType is Enum userdata",
		function()
			local PartType = Enum.PartType
			local v1681

			if typeof(PartType) ~= "Enum" then
				v1681 = false
			else
				local PartType2 = Enum.PartType

				v1681 = type(PartType2) == "userdata"
			end

			return v1681
		end,
	},
	{
		"Enum.PartType is not writable",
		function()
			return not pcall(function()
				Enum.PartType = "N/A"
			end)
		end,
	},
	{
		"Enum:GetEnumItems returns table",
		function()
			local v1683 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(Enum.EasingStyle:GetEnumItems())

			return type(unpack(v1683, 1, v1683.n)) == "table"
		end,
	},
	{
		"EnumItem.Value is number",
		function()
			local Value = Enum.EasingStyle.Linear.Value

			return type(Value) == "number"
		end,
	},
	{
		"EnumItem.Name is string",
		function()
			local Name = Enum.EasingStyle.Linear.Name

			return type(Name) == "string"
		end,
	},
})
v25("buffer operations", {
	{
		"buffer.len correct",
		function()
			return buffer.len(buffer.create(16)) == 16
		end,
	},
	{
		"buffer.writeu8 and readu8 correct",
		function()
			local v1688 = buffer.create(4)

			buffer.writeu8(v1688, 0, 255)

			return buffer.readu8(v1688, 0) == 255
		end,
	},
	{
		"buffer.writef32 and readf32 correct",
		function()
			local v1689 = buffer.create(8)

			buffer.writef32(v1689, 4, 3.14)

			local v1690 = buffer.readf32(v1689, 4) - 3.14

			return math.abs(v1690) < 0.001
		end,
	},
	{
		"buffer.fill correct",
		function()
			local v1691 = buffer.create(16)

			buffer.fill(v1691, 8, 171, 4)
			local v1692

			if buffer.readu8(v1691, 8) ~= 171 then
				v1692 = false
			else
				v1692 = buffer.readu8(v1691, 11) == 171
			end

			return v1692
		end,
	},
	{
		"buffer.copy correct",
		function()
			local v1693 = buffer.create(4)

			buffer.writeu8(v1693, 0, 42)

			local v1694 = buffer.create(4)

			buffer.copy(v1694, 0, v1693, 0, 4)

			return buffer.readu8(v1694, 0) == 42
		end,
	},
	{
		"buffer.writestring and readstring correct",
		function()
			local v1695 = buffer.create(6)

			buffer.writestring(v1695, 0, "eUNC!!")

			return buffer.readstring(v1695, 0, 6) == "eUNC!!"
		end,
	},
})
v19("UI Library logging ", function()
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
	end)

	if not ok then
		return false
	end
	local v1699 = result
	local ok2, result2 = pcall(function()
		return v1699:MakeWindow({
			Name = "eUNC Test",
			HidePremium = true,
			SaveConfig = false,
		})
	end)

	if not (ok2 and result2) then
		return false
	end
	local v1703 = result

	pcall(function()
		v1703:Destroy()
	end)

	return true
end)

local v1704 = v9

v11("Enum singleton", function()
	v1704(Enum.Material.Plastic == Enum.Material.Plastic)
end)

local v1705 = v9

v11("Vector3 arithmetic is correct", function()
	local v1706 = Vector3.new(1, 2, 3) + Vector3.new(4, 5, 6)
	local v1707 = v1705
	local v1708

	if v1706.X ~= 5 or v1706.Y ~= 7 then
		v1708 = false
	else
		v1708 = v1706.Z == 9
	end

	v1707(v1708)
end)

local v1709 = v9

v11("GetService returns singleton", function()
	v1709(game:GetService("Players") == game:GetService("Players"))
end)

local v1710 = v9

v11("loadstring syntax error returns error", function()
	local ok = pcall(function()
		return loadstring("local a = if true then")()
	end)

	v1710(not ok)
end)

local v1713 = v9

v11("GetService matches property access", function()
	v1713(game:GetService("Players") == game.Players)
end)

local v1714 = v9

v11("require is not callable from global env", function()
	v1714(not pcall(require), "require succeeded without arguments (should error)")
end)
v25("RunService extended properties", {
	{
		"RunService.ClientGitHash is string",
		function()
			local ClientGitHash = game:GetService("RunService").ClientGitHash

			return typeof(ClientGitHash) == "string"
		end,
	},
	{
		"RunService.RunState is Running",
		function()
			return game:GetService("RunService").RunState == Enum.RunState.Running
		end,
	},
})
v25("game properties", {
	{
		"game.CreatorType is valid",
		function()
			return game.CreatorType == Enum.CreatorType.User and true or game.CreatorType == Enum.CreatorType.Group
		end,
	},
	{
		"game.PlaceVersion is not 0",
		function()
			return game.PlaceVersion ~= 0
		end,
	},
	{
		"Enum type is userdata not table",
		function()
			return type(Enum) ~= "table"
		end,
	},
})
v25("Players async methods", {
	{
		"GetNameFromUserIdAsync matches LocalPlayer",
		function()
			local Players = game:GetService("Players")
			local v1719 = Players
			local ok, result = pcall(function()
				return v1719:GetNameFromUserIdAsync(v1719.LocalPlayer.UserId)
			end)

			if not ok then
				return ok
			end

			ok = result == Players.LocalPlayer.Name

			return ok
		end,
	},
	{
		"GetNameFromUserIdAsync errors on invalid userId",
		function()
			return not pcall(function()
				return game:GetService("Players"):GetNameFromUserIdAsync(0)
			end)
		end,
	},
})
v25("CollectionService extended", {
	{
		"GetTags returns correct tags",
		function()
			local CollectionService = game:GetService("CollectionService")
			local Part = Instance.new("Part")

			CollectionService:AddTag(Part, "meowTest")
			task.wait(0.1)

			local tags = CollectionService:GetTags(Part)

			Part:Destroy()
			local v1725

			if #tags <= 0 then
				v1725 = false
			else
				v1725 = tags[1] == "meowTest"
			end

			return v1725
		end,
	},
	{
		"HasTag works on instance directly",
		function()
			local CollectionService = game:GetService("CollectionService")
			local Part = Instance.new("Part")

			CollectionService:AddTag(Part, "meowTest2")
			task.wait(0.1)

			local meowTest2 = Part:HasTag("meowTest2")

			Part:Destroy()

			return meowTest2 == true
		end,
	},
})
v25("Instance property type enforcement", {
	{
		"Orientation rejects string assignment",
		function()
			local Part = Instance.new("Part")
			local v1731 = Part
			local ok = pcall(function()
				v1731.Orientation = "meowTest"
			end)

			Part:Destroy()

			return not ok
		end,
	},
})
v25("Instance signals fire on property change", {
	{
		"Changed fires on Name change",
		function()
			local Part = Instance.new("Part")
			local u1734

			Part.Changed:Connect(function()
				u1734 = true
			end)
			Part.Name = "meowTest"
			task.wait(0.1)
			Part:Destroy()

			return false
		end,
	},
	{
		"GetPropertyChangedSignal fires on Name change",
		function()
			local Part = Instance.new("Part")
			local u1736

			Part:GetPropertyChangedSignal("Name"):Connect(function()
				u1736 = true
			end)
			Part.Name = "meowTest"
			task.wait(0.1)
			Part:Destroy()

			return false
		end,
	},
})
v25("gcinfo", {
	{
		"gcinfo returns positive number",
		function()
			local v1737 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(gcinfo())

			unpack(v1737, 1, 1)
			local v1738

			if type(unpack(v1737, 1, v1737.n)) ~= "number" then
				v1738 = false
			else
				v1738 = gcinfo() > 0
			end

			return v1738
		end,
	},
})
v25("HttpService.GetSecret", {
	{
		"GetSecret errors on invalid key",
		function()
			return not pcall(function()
				game:GetService("HttpService"):GetSecret("meowTest" .. string.rep("meow", 31))
			end)
		end,
	},
})
v25("Teams service", {
	{
		"Teams:GetTeams returns table",
		function()
			local v1739 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("Teams"):GetTeams())

			return typeof(unpack(v1739, 1, v1739.n)) == "table"
		end,
	},
})
v25("LogService", {
	{
		"LogService:GetLogHistory returns table",
		function()
			local v1743 = (function(...)
				return {
					...,
					n = select("#", ...),
				}
			end)(game:GetService("LogService"):GetLogHistory())

			return typeof(unpack(v1743, 1, v1743.n)) == "table"
		end,
	},
})
v25("Stats service properties", {
	{
		"Stats.ContactsCount is number",
		function()
			local ContactsCount = game:GetService("Stats").ContactsCount

			return type(ContactsCount) == "number"
		end,
	},
	{
		"Stats.DataReceiveKbps is number",
		function()
			local DataReceiveKbps = game:GetService("Stats").DataReceiveKbps

			return type(DataReceiveKbps) == "number"
		end,
	},
	{
		"Stats.DataSendKbps is number",
		function()
			local DataSendKbps = game:GetService("Stats").DataSendKbps

			return type(DataSendKbps) == "number"
		end,
	},
	{
		"Stats.FrameTime is number",
		function()
			local FrameTime = game:GetService("Stats").FrameTime

			return type(FrameTime) == "number"
		end,
	},
	{
		"Stats.HeartbeatTime is number",
		function()
			local HeartbeatTime = game:GetService("Stats").HeartbeatTime

			return type(HeartbeatTime) == "number"
		end,
	},
	{
		"Stats.HeartbeatTimeMs is number",
		function()
			local HeartbeatTimeMs = game:GetService("Stats").HeartbeatTimeMs

			return type(HeartbeatTimeMs) == "number"
		end,
	},
	{
		"Stats.InstanceCount is number",
		function()
			local InstanceCount = game:GetService("Stats").InstanceCount

			return type(InstanceCount) == "number"
		end,
	},
	{
		"Stats.MemoryTrackingEnabled is boolean",
		function()
			local MemoryTrackingEnabled = game:GetService("Stats").MemoryTrackingEnabled

			return type(MemoryTrackingEnabled) == "boolean"
		end,
	},
	{
		"Stats.MovingPrimitivesCount is number",
		function()
			local MovingPrimitivesCount = game:GetService("Stats").MovingPrimitivesCount

			return type(MovingPrimitivesCount) == "number"
		end,
	},
	{
		"Stats.PhysicsReceiveKbps is number",
		function()
			local PhysicsReceiveKbps = game:GetService("Stats").PhysicsReceiveKbps

			return type(PhysicsReceiveKbps) == "number"
		end,
	},
	{
		"Stats.PhysicsSendKbps is number",
		function()
			local PhysicsSendKbps = game:GetService("Stats").PhysicsSendKbps

			return type(PhysicsSendKbps) == "number"
		end,
	},
	{
		"Stats.PhysicsStepTime is number",
		function()
			local PhysicsStepTime = game:GetService("Stats").PhysicsStepTime

			return type(PhysicsStepTime) == "number"
		end,
	},
	{
		"Stats.PhysicsStepTimeMs is number",
		function()
			local PhysicsStepTimeMs = game:GetService("Stats").PhysicsStepTimeMs

			return type(PhysicsStepTimeMs) == "number"
		end,
	},
	{
		"Stats.PrimitivesCount is number",
		function()
			local PrimitivesCount = game:GetService("Stats").PrimitivesCount

			return type(PrimitivesCount) == "number"
		end,
	},
	{
		"Stats.RenderCPUFrameTime is number",
		function()
			local RenderCPUFrameTime = game:GetService("Stats").RenderCPUFrameTime

			return type(RenderCPUFrameTime) == "number"
		end,
	},
	{
		"Stats.RenderGPUFrameTime is number",
		function()
			local RenderGPUFrameTime = game:GetService("Stats").RenderGPUFrameTime

			return type(RenderGPUFrameTime) == "number"
		end,
	},
	{
		"Stats.SceneDrawcallCount is number",
		function()
			local SceneDrawcallCount = game:GetService("Stats").SceneDrawcallCount

			return type(SceneDrawcallCount) == "number"
		end,
	},
	{
		"Stats.SceneTriangleCount is number",
		function()
			local SceneTriangleCount = game:GetService("Stats").SceneTriangleCount

			return type(SceneTriangleCount) == "number"
		end,
	},
	{
		"Stats.ShadowsDrawcallCount is number",
		function()
			local ShadowsDrawcallCount = game:GetService("Stats").ShadowsDrawcallCount

			return type(ShadowsDrawcallCount) == "number"
		end,
	},
	{
		"Stats.ShadowsTriangleCount is number",
		function()
			local ShadowsTriangleCount = game:GetService("Stats").ShadowsTriangleCount

			return type(ShadowsTriangleCount) == "number"
		end,
	},
	{
		"Stats.UI2DDrawcallCount is number",
		function()
			local UI2DDrawcallCount = game:GetService("Stats").UI2DDrawcallCount

			return type(UI2DDrawcallCount) == "number"
		end,
	},
	{
		"Stats.UI2DTriangleCount is number",
		function()
			local UI2DTriangleCount = game:GetService("Stats").UI2DTriangleCount

			return type(UI2DTriangleCount) == "number"
		end,
	},
	{
		"Stats.UI3DDrawcallCount is number",
		function()
			local UI3DDrawcallCount = game:GetService("Stats").UI3DDrawcallCount

			return type(UI3DDrawcallCount) == "number"
		end,
	},
	{
		"Stats.UI3DTriangleCount is number",
		function()
			local UI3DTriangleCount = game:GetService("Stats").UI3DTriangleCount

			return type(UI3DTriangleCount) == "number"
		end,
	},
})

local v1771 = v9

v11("ENV LOGGER SHOULD BE REGULAR LUAU (not lune or anything else)", function()
	local n11 = 0
	local _VERSION_ = _VERSION or ""
	local v1774 = tostring(_VERSION_)

	if v1774 == "Lua 5.1" or (v1774 == "Lua 5.2" or (v1774 == "Lua 5.3" or v1774 == "Lua 5.4")) then
		n11 = 1
	end

	local ok, result = pcall(function()
		local v1777 = string.dump(function()
			return 1
		end)
		local v1778

		if type(v1777) ~= "string" then
			v1778 = false
		else
			v1778 = #v1777 > 4
		end

		return v1778
	end)

	if ok and result == true then
		n11 = n11 + 1
	end

	local ok2, result2 = pcall(function()
		local v1781 = load("return 1 + 1")
		local v1782

		if type(v1781) ~= "function" then
			v1782 = false
		else
			v1782 = v1781() == 2
		end

		return v1782
	end)

	if ok2 and result2 == true then
		n11 = n11 + 1
	end

	if math.tointeger ~= nil then
		n11 = n11 + 1
	end

	if task == nil then
		n11 = n11 + 1
	end

	local ok3, result3 = pcall(function()
		local v1785 = string.format("%p", 1)
		local v1786

		if type(v1785) ~= "string" then
			v1786 = false
		else
			v1786 = #v1785 > 0
		end

		return v1786
	end)

	if ok3 and result3 == true then
		n11 = n11 + 1
	end

	if math.type and math.type(1) == "integer" then
		n11 = n11 + 1
	end

	if type(unpack) == "function" then
		local unpack_2 = table.unpack

		if type(unpack_2) ~= "function" then
			n11 = n11 + 1
		end
	end

	local ok4, result4 = pcall(function()
		local thread = coroutine.create(function() end)

		if not tostring(thread):match("0x(%x+)$") then
			return false
		end

		return string
			.dump(function()
				return 1
			end)
			:sub(1, 1) == "\27"
	end)

	if ok4 and result4 == true then
		n11 = n11 + 1
	end

	local ok5, result5 = pcall(function()
		local v1794

		if tostring(1) ~= "1.0" then
			v1794 = false
		else
			v1794 = tostring(0) == "0.0"
		end

		return v1794
	end)

	if ok5 and result5 == true then
		n11 = n11 + 1
	end

	if type(io) == "table" then
		n11 = n11 + 1
	end

	if type(package) == "table" then
		n11 = n11 + 1
	end

	if debug then
		local sethook = debug.sethook

		if type(sethook) == "function" then
			n11 = n11 + 1
		end
	end

	if debug then
		local getlocal = debug.getlocal

		if type(getlocal) == "function" then
			n11 = n11 + 1
		end
	end

	local ok6, result6 = pcall(function()
		if math.type then
			local count = collectgarbage("count")

			return math.type(count) == "float"
		else
			return false
		end
	end)

	if ok6 and result6 == true then
		n11 = n11 + 1
	end

	local ok7, result7 = pcall(function()
		return #tostring(0.3333333333333333) == 16
	end)

	if ok7 and result7 == true then
		n11 = n11 + 1
	end

	if type(load) ~= "function" then
		v1771(n11 < 2, "ENV LOGGER SHOULD BE LUAU but standard Lua indicators detected (score=" .. n11 .. ")")

		return
	end

	n11 = n11 + 1
	v1771(n11 < 2, "ENV LOGGER SHOULD BE LUAU but standard Lua indicators detected (score=" .. n11 .. ")")
end);
({})[1] = {
	"Enum does not return proxy for fake enums",
	function()
		return not pcall(function()
			local _ = Enum.eUNCTest
		end)
	end,
}
v161, t8, v19 = ipairs({
	{
		"AccessModifierType",
		{ "Allow", "Deny" },
	},
	{
		"AccessoryType",
		{
			"Unknown",
			"Hat",
			"Hair",
			"Face",
			"Neck",
			"Shoulder",
			"Front",
			"Back",
			"Waist",
			"TShirt",
			"Shirt",
			"Pants",
			"Jacket",
			"Sweater",
			"Shorts",
			"LeftShoe",
			"RightShoe",
			"DressSkirt",
			"Eyebrow",
			"Eyelash",
		},
	},
	{
		"ActionType",
		{
			"Nothing",
			"Pause",
			"Lose",
			"Draw",
			"Win",
		},
	},
	{
		"ActuatorRelativeTo",
		{ "Attachment0", "Attachment1", "World" },
	},
	{
		"ActuatorType",
		{ "None", "Motor", "Servo" },
	},
	{
		"AdAvailabilityResult",
		{
			"IsAvailable",
			"DeviceIneligible",
			"ExperienceIneligible",
			"InternalError",
			"NoFill",
			"PlayerIneligible",
			"PublisherIneligible",
		},
	},
	{
		"AdEventType",
		{
			"RewardedAdLoaded",
			"RewardedAdGrant",
			"RewardedAdUnloaded",
			"VideoLoaded",
			"VideoRemoved",
			"UserCompletedVideo",
		},
	},
	{
		"AdFormat",
		{ "RewardedVideo" },
	},
	{
		"AdShape",
		{ "HorizontalRectangle" },
	},
	{
		"AdTeleportMethod",
		{
			"Undefined",
			"PortalForward",
			"InGameMenuBackButton",
			"UIBackButton",
		},
	},
	{
		"AdUIEventType",
		{
			"AdLabelClicked",
			"VolumeButtonClicked",
			"FullscreenButtonClicked",
			"PlayButtonClicked",
			"PauseButtonClicked",
			"CloseButtonClicked",
			"WhyThisAdClicked",
			"PlayEventTriggered",
			"PauseEventTriggered",
		},
	},
	{
		"AdUIType",
		{ "None", "Image", "Video" },
	},
	{
		"AdUnitStatus",
		{ "Inactive", "Active" },
	},
	{
		"AdornCullingMode",
		{ "Automatic", "Never" },
	},
	{
		"AdornShading",
		{
			"Default",
			"Shaded",
			"XRay",
			"XRayShaded",
			"AlwaysOnTop",
		},
	},
	{
		"AlignType",
		{
			"PrimaryAxisParallel",
			"PrimaryAxisPerpendicular",
			"PrimaryAxisLookAt",
			"AllAxes",
			"Parallel",
			"Perpendicular",
		},
	},
	{
		"AlphaMode",
		{
			"Overlay",
			"Transparency",
			"TintMask",
			"Opaque",
		},
	},
	{
		"AnalyticsCustomFieldKeys",
		{ "CustomField01", "CustomField02", "CustomField03" },
	},
	{
		"AnalyticsEconomyAction",
		{ "Default", "Acquire", "Spend" },
	},
	{
		"AnalyticsEconomyFlowType",
		{ "Sink", "Source" },
	},
	{
		"AnalyticsEconomyTransactionType",
		{
			"IAP",
			"Shop",
			"Gameplay",
			"ContextualPurchase",
			"TimedReward",
			"Onboarding",
		},
	},
	{
		"AnalyticsLogLevel",
		{
			"Trace",
			"Debug",
			"Information",
			"Warning",
			"Error",
			"Fatal",
		},
	},
	{
		"AnalyticsProgressionStatus",
		{
			"Default",
			"Begin",
			"Complete",
			"Abandon",
			"Fail",
		},
	},
	{
		"AnalyticsProgressionType",
		{
			"Custom",
			"Start",
			"Fail",
			"Complete",
		},
	},
	{
		"AnimationClipFromVideoStatus",
		{
			"Initializing",
			"Pending",
			"Processing",
			"ErrorGeneric",
			"Success",
			"ErrorVideoTooLong",
			"ErrorNoPersonDetected",
			"ErrorVideoUnstable",
			"Timeout",
			"Cancelled",
			"ErrorMultiplePeople",
			"ErrorUploadingVideo",
		},
	},
	{
		"AnimationNodeBlend2DInputMode",
		{ "Cartesian", "Polar" },
	},
	{
		"AnimationNodeInterruptible",
		{ "Always", "Finished", "Trigger" },
	},
	{
		"AnimationNodePlayMode",
		{
			"Loop",
			"PingPong",
			"OnceAndHold",
			"OnceAndReset",
		},
	},
	{
		"AnimationNodeTransitionType",
		{ "CrossFade", "InertialBlend", "DeadBlend" },
	},
	{
		"AnimationNodeWaitFor",
		{ "Finished", "Trigger" },
	},
	{
		"AnimationPriority",
		{
			"Core",
			"Idle",
			"Movement",
			"Action",
			"Action2",
			"Action3",
			"Action4",
		},
	},
	{
		"AnimatorRetargetingMode",
		{ "Default", "Disabled", "Enabled" },
	},
	{
		"AppLifecycleManagerState",
		{
			"Detached",
			"Active",
			"Inactive",
			"Hidden",
		},
	},
	{
		"AppShellActionType",
		{
			"None",
			"OpenApp",
			"TapChatTab",
			"TapConversationEntry",
			"TapAvatarTab",
			"ReadConversation",
			"TapGamePageTab",
			"TapHomePageTab",
			"GamePageLoaded",
			"HomePageLoaded",
			"AvatarEditorPageLoaded",
		},
	},
	{
		"AppShellFeature",
		{
			"None",
			"Chat",
			"AvatarEditor",
			"GamePage",
			"HomePage",
			"More",
			"Landing",
		},
	},
	{
		"AppUpdateStatus",
		{
			"Unknown",
			"NotSupported",
			"Failed",
			"NotAvailable",
			"Available",
			"AvailableBoundChannel",
			"AvailableBetaProgram",
		},
	},
	{
		"ApplyStrokeMode",
		{ "Contextual", "Border" },
	},
	{
		"AspectType",
		{ "FitWithinMaxSize", "ScaleWithParentSize" },
	},
	{
		"AssetCreatorType",
		{ "User", "Group" },
	},
	{
		"AssetFetchStatus",
		{
			"Success",
			"Failure",
			"None",
			"Loading",
			"TimedOut",
		},
	},
	{
		"AssetType",
		{
			"Image",
			"TShirt",
			"Audio",
			"Mesh",
			"Lua",
			"Hat",
			"Place",
			"Model",
			"Shirt",
			"Pants",
			"Decal",
			"Head",
			"Face",
			"Gear",
			"Badge",
			"Animation",
			"Torso",
			"RightArm",
			"LeftArm",
			"LeftLeg",
			"RightLeg",
			"Package",
			"GamePass",
			"Plugin",
			"MeshPart",
			"HairAccessory",
			"FaceAccessory",
			"NeckAccessory",
			"ShoulderAccessory",
			"FrontAccessory",
			"BackAccessory",
			"WaistAccessory",
			"ClimbAnimation",
			"DeathAnimation",
			"FallAnimation",
			"IdleAnimation",
			"JumpAnimation",
			"RunAnimation",
			"SwimAnimation",
			"WalkAnimation",
			"PoseAnimation",
			"EmoteAnimation",
			"Video",
			"TShirtAccessory",
			"ShirtAccessory",
			"PantsAccessory",
			"JacketAccessory",
			"SweaterAccessory",
			"ShortsAccessory",
			"LeftShoeAccessory",
			"RightShoeAccessory",
			"DressSkirtAccessory",
			"FontFamily",
			"EyebrowAccessory",
			"EyelashAccessory",
			"MoodAnimation",
			"DynamicHead",
			"FaceMakeup",
			"LipMakeup",
			"EyeMakeup",
			"EarAccessory",
			"EyeAccessory",
		},
	},
	{
		"AssetTypeVerification",
		{ "Default", "ClientOnly", "Always" },
	},
	{
		"AudioApiRollout",
		{ "Disabled", "Automatic", "Enabled" },
	},
	{
		"AudioCaptureMode",
		{},
	},
	{
		"AudioChannelLayout",
		{
			"Mono",
			"Stereo",
			"Quad",
			"Surround_5",
			"Surround_5_1",
			"Surround_7_1",
			"Surround_7_1_4",
		},
	},
	{
		"AudioFilterType",
		{
			"Peak",
			"LowShelf",
			"HighShelf",
			"Lowpass12dB",
			"Lowpass24dB",
			"Lowpass48dB",
			"Highpass12dB",
			"Highpass24dB",
			"Highpass48dB",
			"Bandpass",
			"Notch",
			"Lowpass6dB",
		},
	},
	{
		"AudioSimulationFidelity",
		{ "None", "Automatic" },
	},
	{
		"AudioSubType",
		{ "Music", "SoundEffect" },
	},
	{
		"AudioWindowSize",
		{ "Small", "Medium", "Large" },
	},
	{
		"AuthorityMode",
		{ "Server", "Automatic" },
	},
	{
		"AutomaticSize",
		{
			"None",
			"X",
			"Y",
			"XY",
		},
	},
	{
		"AvatarAssetType",
		{
			"TShirt",
			"Hat",
			"Shirt",
			"Pants",
			"Head",
			"Face",
			"Gear",
			"Torso",
			"RightArm",
			"LeftArm",
			"LeftLeg",
			"RightLeg",
			"HairAccessory",
			"FaceAccessory",
			"NeckAccessory",
			"ShoulderAccessory",
			"FrontAccessory",
			"BackAccessory",
			"WaistAccessory",
			"ClimbAnimation",
			"FallAnimation",
			"IdleAnimation",
			"JumpAnimation",
			"RunAnimation",
			"SwimAnimation",
			"WalkAnimation",
			"MoodAnimation",
			"EmoteAnimation",
			"TShirtAccessory",
			"ShirtAccessory",
			"PantsAccessory",
			"JacketAccessory",
			"SweaterAccessory",
			"ShortsAccessory",
			"LeftShoeAccessory",
			"RightShoeAccessory",
			"DressSkirtAccessory",
			"EyebrowAccessory",
			"EyelashAccessory",
			"DynamicHead",
			"FaceMakeup",
			"LipMakeup",
			"EyeMakeup",
		},
	},
	{
		"AvatarChatServiceFeature",
		{
			"None",
			"UniverseAudio",
			"UniverseVideo",
			"PlaceAudio",
			"PlaceVideo",
			"UserAudioEligible",
			"UserAudio",
			"UserVideoEligible",
			"UserVideo",
			"UserBanned",
			"UserVerifiedForVoice",
		},
	},
	{
		"AvatarContextMenuOption",
		{
			"Friend",
			"Chat",
			"Emote",
			"InspectMenu",
		},
	},
	{
		"AvatarGenerationError",
		{
			"None",
			"Unknown",
			"DownloadFailed",
			"Canceled",
			"Offensive",
			"Timeout",
			"JobNotFound",
		},
	},
	{
		"AvatarItemType",
		{ "Asset", "Bundle" },
	},
	{
		"AvatarPromptResult",
		{ "Success", "PermissionDenied", "Failed" },
	},
	{
		"AvatarSettingsAccessoryLimitMethod",
		{
			"Scale",
			"Remove",
			"PreviewScale",
			"PreviewRemove",
		},
	},
	{
		"AvatarSettingsAccessoryMode",
		{ "PlayerChoice", "CustomLimit" },
	},
	{
		"AvatarSettingsAnimationClipsMode",
		{ "PlayerChoice", "CustomClips" },
	},
	{
		"AvatarSettingsAnimationPacksMode",
		{ "PlayerChoice", "StandardR15", "StandardR6" },
	},
	{
		"ZIndexBehavior",
		{ "Global", "Sibling" },
	},
})
v15 = {}

while true do
	v19, v1573 = v161(t8, v19)

	if v19 == nil then
		break
	end

	v1574 = v1573[1]
	v1573 = v1573[2]
	v1539 = {}
	v1537 = v1574 .. " exists"

	local v1574_ = v1574

	v1578 = function()
		local v1807 = Enum[v1574_]

		return typeof(v1807) ~= "nil"
	end
	v1539[1] = v1537
	v1539[2] = v1578
	table.insert(v15, v1539)
	v1578 = {}
	v1537 = v1574 .. ":GetEnumItems returns table"

	local v1574_2 = v1574

	v1539 = function()
		local v1809 = (function(...)
			return {
				...,
				n = select("#", ...),
			}
		end)(Enum[v1574_2]:GetEnumItems())

		return type(unpack(v1809, 1, v1809.n)) == "table"
	end
	v1578[1] = v1537
	v1578[2] = v1539
	table.insert(v15, v1578)
	v1578 = {}
	v1537 = v1574 .. " has at least " .. #v1573 .. " items"

	local v1574_3 = v1574
	local v1573_ = v1573

	v1539 = function()
		return #Enum[v1574_3]:GetEnumItems() >= #v1573_
	end
	v1578[1] = v1537
	v1578[2] = v1539
	table.insert(v15, v1578)
	v1578, v1537, v1539 = ipairs(v1573)

	while true do
		v1539, v1573 = v1578(v1537, v1539)

		if v1539 == nil then
			break
		end

		v1535 = {}
		v1501 = v1574 .. "." .. v1573 .. " exists"

		local v1574_4 = v1574
		local v1573_2 = v1573

		v1573 = function()
			local v1817 = Enum[v1574_4][v1573_2]

			return typeof(v1817) == "EnumItem"
		end
		v1535[1] = v1501
		v1535[2] = v1573
		table.insert(v15, v1535)
	end
end

v25("All Enums.", v15)

local v1818 = v9

v11("tostring changes on rename", function()
	local Part = Instance.new("Part")
	local v1820 = tostring(Part)

	Part.Name = "renamed"

	local v1821 = tostring(Part)

	Part:Destroy()
	v1818(v1820 ~= v1821)
end)

local v1822 = v9

v11("IsDescendantOf works after parenting", function()
	local Folder = Instance.new("Folder")
	local Folder2 = Instance.new("Folder")

	Folder2.Parent = Folder
	Folder.Parent = workspace

	local v1825 = Folder2:IsDescendantOf(workspace)

	Folder:Destroy()
	v1822(v1825)
end)

local v1826 = v9

v11("child parent is nil after destroy", function()
	local Folder = Instance.new("Folder")
	local Folder2 = Instance.new("Folder")

	Folder2.Parent = Folder
	Folder.Parent = workspace
	Folder:Destroy()
	task.wait()
	v1826(Folder2.Parent == nil)
end)
v25("Instance and table edge cases", {
	{
		"random numeric index on Part does not succeed",
		function()
			return not pcall(function()
				return Instance.new("Part")[math.random(1000000, 9999999)]
			end)
		end,
	},
	{
		"game is not a valid table key",
		function()
			return ({})[game] == nil
		end,
	},
	{
		"newproxy __call returns typeof userdata",
		function()
			local proxy = newproxy(true)

			getmetatable(proxy).__call = typeof

			return proxy() == "userdata"
		end,
	},
	{
		"newproxy __metatable is preserved",
		function()
			local proxy = newproxy(true)

			getmetatable(proxy).__metatable = "test_metatable"

			return getmetatable(proxy) == "test_metatable"
		end,
	},
	{
		"string.split returns correct length",
		function()
			return #string.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789", "") == 63
		end,
	},
	{
		"tostring has zero fixed params and is vararg",
		function()
			local v1831, v1832 = debug.info(tostring, "a")
			local v1833

			if v1831 == 0 then
				v1833 = v1832 == true
			else
				v1833 = false
			end

			return v1833
		end,
	},
	{
		"tostring is not setfenv-able",
		function()
			return not pcall(setfenv, tostring, getfenv(tostring))
		end,
	},
	{
		"tostring on two tables returns different strings",
		function()
			local v1834 = tostring({})
			local v1835 = string.sub(v1834, 8, 15)
			local v1836 = tostring({})

			return v1835 ~= string.sub(v1836, 8, 15)
		end,
	},
})
v25("Physics work under a Part", {
	{
		"LocalPlayer exists for physics test",
		function()
			return game:GetService("Players").LocalPlayer ~= nil
		end,
	},
	{
		"unanchored part falls under gravity",
		function()
			local Part = Instance.new("Part")

			Part.Size = Vector3.new(1, 1, 1)
			Part.Position = Vector3.new(0, 120, 0)
			Part.Anchored = false
			Part.CanCollide = false
			Part.Transparency = 1
			Part.Parent = workspace

			local Y = Part.Position.Y

			task.wait(0.1)

			local v1839 = false

			for _ = 1, 10 do
				task.wait(0.05)

				local v1841 = Part.Position.Y - Y

				if not (math.abs(v1841) <= 0.05) then
					v1839 = true

					break
				end
			end

			Part:Destroy()

			return v1839
		end,
	},
	{
		"workspace.Gravity affects part fall speed",
		function()
			local Gravity = workspace.Gravity

			workspace.Gravity = 196.2

			local Part = Instance.new("Part")

			Part.Size = Vector3.new(1, 1, 1)
			Part.Position = Vector3.new(0, 200, 0)
			Part.Anchored = false
			Part.CanCollide = false
			Part.Transparency = 1
			Part.Parent = workspace

			local Y = Part.Position.Y

			task.wait(0.1)

			local v1845 = Y - Part.Position.Y

			Part:Destroy()
			workspace.Gravity = Gravity

			return v1845 > 0.1
		end,
	},
	{
		"Part.Velocity changes under gravity",
		function()
			local Part = Instance.new("Part")

			Part.Size = Vector3.new(1, 1, 1)
			Part.Position = Vector3.new(0, 100, 0)
			Part.Anchored = false
			Part.CanCollide = false
			Part.Transparency = 1
			Part.Parent = workspace
			task.wait(0.05)

			local AssemblyLinearVelocity = Part.AssemblyLinearVelocity

			Part:Destroy()
			local v1848

			if typeof(AssemblyLinearVelocity) ~= "Vector3" then
				v1848 = false
			else
				v1848 = AssemblyLinearVelocity.Y < 0
			end

			return v1848
		end,
	},
	{
		"Anchored part does not fall",
		function()
			local Part = Instance.new("Part")

			Part.Size = Vector3.new(1, 1, 1)
			Part.Position = Vector3.new(0, 50, 0)
			Part.Anchored = true
			Part.CanCollide = false
			Part.Transparency = 1
			Part.Parent = workspace

			local Y = Part.Position.Y

			task.wait(0.2)

			local v1851 = Part.Position.Y - Y
			local v1852 = math.abs(v1851) < 0.01

			Part:Destroy()

			return v1852
		end,
	},
})

local function v1853(p23)
	local ok, result = pcall(p23)

	if ok and result then
		return
	end

	u2 = false
end

v1853(function()
	local enums = Enum:GetEnums()
	local v1857, v1858, v1859 = ipairs(enums)
	local t27 = {}

	while true do
		local v1861

		v1859, v1861 = v1857(v1858, v1859)

		if v1859 == nil then
			break
		end

		local v1862 = tostring(v1861)

		if t27[v1862] then
			return false
		end

		t27[v1862] = true
	end

	return #enums > 50
end)
v1853(function()
	local font = Font.fromEnum(Enum.Font.GothamBold)
	local font2 = Font.fromEnum(Enum.Font.Gotham)
	local v1865

	if font.Weight ~= Enum.FontWeight.Bold or font2.Weight ~= Enum.FontWeight.Regular then
		v1865 = false
	else
		v1865 = font.Family == font2.Family
	end

	return v1865
end)
v1853(function()
	local function v1866(...)
		return {
			...,
			n = select("#", ...),
		}
	end

	local FloatCurve = Instance.new("FloatCurve")
	local v1868 = v1866(FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Constant))

	FloatCurve:InsertKey(unpack(v1868, 1, v1868.n))

	local v1873 = v1866(FloatCurveKey.new(0.5, 7, Enum.KeyInterpolationMode.Linear))

	FloatCurve:InsertKey(unpack(v1873, 1, v1873.n))

	local v1878 = v1866(FloatCurveKey.new(1, 3, Enum.KeyInterpolationMode.Cubic))

	FloatCurve:InsertKey(unpack(v1878, 1, v1878.n))

	local keyAtIndex = FloatCurve:GetKeyAtIndex(1)
	local keyAtIndex2 = FloatCurve:GetKeyAtIndex(2)
	local keyAtIndex3 = FloatCurve:GetKeyAtIndex(3)

	FloatCurve:Destroy()
	local v1886

	if keyAtIndex.Time ~= 0 or keyAtIndex2.Value ~= 7 then
		v1886 = false
	else
		v1886 = keyAtIndex3.Interpolation == Enum.KeyInterpolationMode.Cubic
	end

	return v1886
end)
v1853(function()
	local function v1887(...)
		return {
			...,
			n = select("#", ...),
		}
	end

	local FloatCurve = Instance.new("FloatCurve")
	local v1889 = v1887(FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Linear))

	FloatCurve:InsertKey(unpack(v1889, 1, v1889.n))

	local v1894 = v1887(FloatCurveKey.new(1, 10, Enum.KeyInterpolationMode.Linear))

	FloatCurve:InsertKey(unpack(v1894, 1, v1894.n))

	local valueAtTime = FloatCurve:GetValueAtTime(0)
	local valueAtTime2 = FloatCurve:GetValueAtTime(1)
	local valueAtTime3 = FloatCurve:GetValueAtTime(0.5)

	FloatCurve:Destroy()
	local v1902

	if valueAtTime == 0 and valueAtTime2 == 10 then
		local v1903 = valueAtTime3 - 5

		v1902 = math.abs(v1903) < 0.01
	else
		v1902 = false
	end

	return v1902
end)
v1853 = function(p24)
	return '"' .. tostring(p24):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r") .. '"'
end
local s4
local s5

pcall(function()
	local v1906, v1907 = identifyexecutor()

	s4 = tostring(v1906)
	s5 = tostring(v1907 or "unknown")
end)

local v1908, v1909, v1910 = ipairs(t1)
local v1911 = "unknown"
local t28 = {}

while true do
	v1910, v1574 = v1908(v1909, v1910)

	if v1910 == nil then
		break
	end

	t28[v1910] = '{"name":' .. v1853(v1574.name) .. ',"status":' .. v1853(v1574.status) .. ',"reason":' .. v1853(v1574.reason or "") .. "}"
end

v1853 = '{"executor":' .. v1853(v1911) .. ',"results":[' .. v3(t28, ",") .. "]}"
v1853, v1908, v1909 = ipairs(t1)
v1910 = 0

while true do
	v1909, t28 = v1853(v1908, v1909)

	if v1909 == nil then
		break
	end

	if t28.status == "success" then
		v1910 = v1910 + 1
	end
end

v1853 = #t1
v1908 = v1910 / v1853 * 100
v1908 = math.floor(v1908)
print(string.rep("-", 40))

if u2 then
	v1909 = v1911 .. " (ROBLOX)"
else
	v1909 = v1911 .. " (ENV)"
end

print(string.format("[eUNC] Score : %d / %d  (%d%%)", v1910, v1853, v1908))
print(string.format("[eUNC] Executor: %s", v1909))
print(string.format("[eUNC] Passed: %d  |  Failed: %d", v1910, v1853 - v1910))
print(string.rep("-", 40))
v1853, v1908, v1910 = ipairs(t1)

while true do
	v1910, t28 = v1853(v1908, v1910)

	if v1910 == nil then
		break
	end

	if t28.status == "failure" then
		v1574 = t28.reason and t28.reason ~= "" and (" ~ " .. t28.reason or "") or ""
		print(string.format("[ FAIL ] - %s%s", t28.name, v1574))
	end
end

print(string.rep("-", 40))

local v1913 = v3

v1853 = function(p25)
	local v1914 = #p25
	local t29 = {}

	for i = 1, v1914, 3 do
		local v1917 = p25:byte(i) or 0
		local v1918 = p25:byte(i + 1) or 0
		local v1919 = p25:byte(i + 2) or 0
		local v1920 = v1917 * 65536 + v1918 * 256 + v1919
		local v1921 = v1920 / 262144
		local v1922 = math.floor(v1921) % 64
		local v1923 = v1920 / 4096
		local v1924 = math.floor(v1923) % 64
		local v1925 = v1920 / 64
		local v1926 = math.floor(v1925) % 64
		local v1927 = v1920 % 64

		t29[#t29 + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v1922 + 1, v1922 + 1)
		t29[#t29 + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v1924 + 1, v1924 + 1)

		if i + 1 > v1914 then
			t29[#t29 + 1] = "="
		else
			t29[#t29 + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v1926 + 1, v1926 + 1)
		end

		if i + 2 > v1914 then
			t29[#t29 + 1] = "="
		else
			t29[#t29 + 1] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v1927 + 1, v1927 + 1)
		end
	end

	return v1913(t29, "")
end
v1908 = function(p26, p27)
	local n12 = 1
	local n13 = 0

	for _ = 1, 8 do
		if p26 % 2 ~= p27 % 2 then
			n13 = n13 + n12
		end

		local v1931 = p26 / 2

		p26 = math.floor(v1931)

		local v1932 = p27 / 2

		p27 = math.floor(v1932)
		n12 = n12 * 2
	end

	return n13
end

local v1933 = v1908
local v1934 = v3

v1910 = function(p28, p29)
	local v1935 = #p29
	local n14 = 0

	local function v1937(...)
		return {
			...,
			n = select("#", ...),
		}
	end

	local t30 = {}

	for i = 1, #p28 do
		local v1940 = v1937(v1933(p28:byte(i), (v1933(v1933(p29:byte((i - 1) % v1935 + 1), n14), i * 31 % 256))))

		t30[i] = string.char(unpack(v1940, 1, v1940.n))
		n14 = t30[i]:byte()
	end

	local v1944 = v1937(v1934(t30, ""))

	return unpack(v1944, 1, v1944.n)
end

local v1945, v1946

t28, v1946, v1945 = ipairs(t1)
v161 = {}

while true do
	v1945, t8 = t28(v1946, v1945)

	if v1945 == nil then
		break
	end

	v25 = t8.status ~= "success" and "0" or "1"
	v19 = (t8.reason or ""):gsub("[,|\n\r]", function(p30)
		return p30 == "," and ";" or "!"
	end)
	t8 = t8.name:gsub(",", ";"):gsub("|", "!")
	v161[#v161 + 1] = t8 .. "|" .. v25 .. "|" .. v19
end

t28 = 1

for i = 1, #v161 - 1, t28 do
	v1946 = i

	for i2 = i + 1, #v161 do
		if v161[i] > v161[i2] then
			v9 = v161[i2]
			t1 = v161[i]
			v161[i] = v9
			v161[i2] = t1
		end
	end
end

v1909 = v1909 .. "|" .. v3(v161, ",") .. "|euncv=v0.1"
v161 = 23100
t8 = 0

for i = 1, #t28 do
	v25 = ("mN7kR2pXqL9wT4vYcJ6"):byte((i - 1) % 19 + 1)
	v19 = t28:byte(i)
	v15 = v1908(v1908(v1908(v1908(v19, v25), (i * 7 + v25) % 256), (i * i * 13 + v19) % 256), v161 % 256)
	v161 = (v161 * 1103515245 + 12345) % 2147483648
	v25 = v15 * (i + 3) * v25 + v1908(v25, v19) * i
	t8 = (t8 * 31 + v25) % 999983
	t8 = (t8 + v1908(t8 * 17 % 256, t8 % 256)) % 999983
	v25 = t8 % 256
	v19 = t8 / 256
	t8 = (v1908(v25, math.floor(v19) % 256) + t8 % 999983) % 999983
end

local v1950 = "https://e-unc.vercel.app?id="
	.. v1853((v1910(t28 .. "|cs=" .. t8, "mN7kR2pXqL9wT4vYcJ6"))):gsub("%+", "-"):gsub("/", "_"):gsub("=+$", ""):gsub("=", "")

print("[eUNC] Results URL (shareable permalink):")
print(v1950)
pcall(function()
	setclipboard(v1950)
end)
