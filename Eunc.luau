-- eUNC - Environment Utility Benchmark
-- Cleaned up for readability.

local rawSelect = select

local function assignRange(tbl, startIndex, ...)
    local args = { ... }
    for i = 1, rawSelect("#", ...) do
        tbl[startIndex + i - 1] = args[i]
    end
end

print("Welcome to eUNC, your go-to utility benchmark for environment loggers " ..
      "(aka runtime loggers) - If you need questions or help dm @rxlumz on dc!~")

local results         = {}
local looksLikeRoblox = true

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────

local function assert_(value, message)
    if not value then
        error(message or "assertion failed", 2)
    end
    return value
end

-- Simple pass/fail recorder.
local function runTest(name, fn)
    print("[eUNC] running: " .. name)

    local ok = pcall(fn)
    table.insert(results, {
        name   = name,
        status = ok and "success" or "failure",
    })
end

-- Group runner. Each check is { name, fn } and every fn must return a truthy value.
local function runGroup(groupName, checks)
    print("[eUNC] running: " .. groupName)

    local passed = true

    for _, check in ipairs(checks) do
        local checkName = check[1]
        print("[eUNC]   check: " .. checkName)

        local ok, result = pcall(check[2])
        if not ok then
            passed = false
            break
        end
        if not result then
            passed = false
            break
        end
    end

    table.insert(results, {
        name   = groupName,
        status = passed and "success" or "failure",
        reason = "",
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Game / workspace integrity
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("game integrity checks", {
        { "game cannot be cloned",           function() return not pcall(function() game:Clone() end) end },
        { "game.Parent cannot be set",       function() return not pcall(function() game.Parent = workspace end) end },
        { "game cannot be destroyed",        function() return not pcall(function() game:Destroy() end) end },
        { "workspace cannot be destroyed",   function() return not pcall(function() workspace:Destroy() end) end },
        { "workspace cannot be cloned",      function() return not pcall(function() workspace:Clone() end) end },
        { "Players service cannot be destroyed", function() return not pcall(function() game:GetService("Players"):Destroy() end) end },
    })

    runGroup("game & workspace & services type/typeof/metatable/parent/ etc correct", {
        { "type(game) is userdata",                  function() return type(game) == "userdata" end },
        { "type(workspace) is userdata",             function() return type(workspace) == "userdata" end },
        { "getmetatable(game) is locked string",     function()
            local mt = getmetatable(game)
            return type(mt) == "string" and mt == "The metatable is locked"
        end },
        { "getmetatable(workspace) is string",       function() return type(getmetatable(workspace)) == "string" end },
        { "typeof(game) is Instance",                function() return typeof(game) == "Instance" end },
        { "typeof(workspace) is Instance",           function() return typeof(workspace) == "Instance" end },
        { "workspace.Parent is game",                function() return workspace.Parent == game end },
        { "game.Parent is nil",                      function() return game.Parent == nil end },
        { "game.PlaceId is valid number",            function()
            local id = game.PlaceId
            return type(id) == "number" and id >= 1 and id <= 1e16
        end },
        { "GetService Workspace == workspace",       function() return game:GetService("Workspace") == workspace end },
        { "core services return Instance",           function()
            for _, name in ipairs({ "RunService", "Players", "Workspace", "ReplicatedStorage" }) do
                if typeof(game:GetService(name)) ~= "Instance" then
                    return false
                end
            end
            return true
        end },
        { "fake service errors",                     function() return not pcall(function() game:GetService("EUncService") end) end },
        { "StudioService errors",                    function() return not pcall(function() game:GetService("StudioService") end) end },
        { "GetService matches property access",      function() return game:GetService("Players") == game.Players end },
    })

    runTest("Heartbeat:Connect returns RBXScriptConnection", function()
        local conn = game:GetService("RunService").Heartbeat:Connect(function() end)
        assert_(typeof(conn) == "RBXScriptConnection")
        conn:Disconnect()
    end)

    runTest("Heartbeat not writable", function()
        assert_(not pcall(function()
            game:GetService("RunService").Heartbeat = {}
        end))
    end)

    runTest("Heartbeat.Once exists", function()
        assert_(type(game:GetService("RunService").Heartbeat.Once) == "function")
    end)

    runTest("Heartbeat.Wait exists", function()
        assert_(type(game:GetService("RunService").Heartbeat.Wait) == "function")
    end)

    -- Expect Wait() to error without self.
    local ok = pcall(function()
        game:GetService("RunService").Heartbeat.Wait()
    end)
    table.insert(results, {
        name   = "Heartbeat.Wait() errors without self",
        status = not ok and "success" or "failure",
    })

    runTest("RunService signals are RBXScriptSignal", function()
        local RS = game:GetService("RunService")
        assert_(typeof(RS.Heartbeat) == "RBXScriptSignal")
        assert_(typeof(RS.Stepped) == "RBXScriptSignal")
        assert_(typeof(RS.RenderStepped) == "RBXScriptSignal")
    end)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- RunService / task / getfenv
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("RunService client checks", {
        { "RunService:IsClient returns true",  function() return game:GetService("RunService"):IsClient() == true end },
        { "RunService:IsServer returns false", function() return game:GetService("RunService"):IsServer() == false end },
        { "RunService:IsRunning returns boolean",
            function() return type(game:GetService("RunService"):IsRunning()) == "boolean" end },
        { "RunService:IsStudio returns boolean",
            function() return type(game:GetService("RunService"):IsStudio()) == "boolean" end },
    })

    runTest("ServiceAdded gives unique connections", function()
        local c1 = game.ServiceAdded:Connect(function() end)
        local c2 = game.ServiceAdded:Connect(function() end)
        local unique = c1 ~= c2
        c1:Disconnect()
        c2:Disconnect()
        assert_(unique)
    end)

    runTest("task is table", function() assert_(type(task) == "table") end)

    runTest("task.wait returns positive number", function()
        local elapsed = task.wait()
        assert_(type(elapsed) == "number" and elapsed > 0)
    end)

    runTest("task.spawn runs immediately", function()
        local ran = false
        task.spawn(function() ran = true end)
        assert_(ran == true)
    end)

    runTest("task.spawn returns thread", function()
        assert_(type(task.spawn(function() end)) == "thread")
    end)

    runTest("task.defer runs after yield", function()
        local ran = false
        task.defer(function() ran = true end)
        assert_(ran == false)
        task.wait()
        assert_(ran == true)
    end)

    runTest("task.cancel exists", function()
        assert_(type(task.cancel) == "function")
    end)

    runTest("task.cancel prevents deferred thread from running", function()
        local ran = false
        local thread = task.defer(function() ran = true end)
        task.cancel(thread)
        task.wait()
        assert_(ran == false)
    end)

    runTest("task.cancel prevents delayed thread from running", function()
        local ran = false
        local thread = task.delay(0.1, function() ran = true end)
        task.cancel(thread)
        task.wait(0.15)
        assert_(ran == false)
    end)

    runTest("task.wait respects minimum duration", function()
        local start = os.clock()
        task.wait(0.05)
        assert_(os.clock() - start >= 0.045)
    end)

    runTest("task.delay does not fire immediately", function()
        local ran = false
        task.delay(0, function() ran = true end)
        assert_(ran == false)
        task.wait(0.1)
        assert_(ran == true)
    end)

    runTest("task.cancel on already-ran thread does not error", function()
        local thread = task.defer(function() end)
        task.wait()
        assert_(pcall(task.cancel, thread))
    end)

    runGroup("getfenv and setfenv correctness", {
        { "getfenv exists", function() return type(getfenv) == "function" end },
        { "setfenv exists", function() return type(setfenv) == "function" end },
        { "setfenv on loadstring function works", function()
            local fn = loadstring("return getfenv()")
            local env = { getfenv = getfenv }
            setfenv(fn, env)
            local ok, result = pcall(fn)
            return ok and result == env
        end },
        { "setfenv isolates environment", function()
            local fn = loadstring("return x")
            setfenv(fn, { x = 42 })
            local ok, result = pcall(fn)
            return ok and result == 42
        end },
        { "setfenv does not leak into caller", function()
            local fn = loadstring("x=99")
            local env = {}
            setfenv(fn, env)
            pcall(fn)
            if env.x == 99 then
                return rawget(_G, "x") ~= 99
            end
            return false
        end },
        { "getfenv(0) returns global env", function()
            local ok, result = pcall(getfenv, 0)
            return ok and type(result) == "table"
        end },
        { "getfenv(1) returns current env", function()
            local ok, result = pcall(getfenv, 1)
            return ok and type(result) == "table"
        end },
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- utf8 / math.nan / task scheduling
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("utf8 graphemes and math.nan", {
        { "utf8.graphemes exists",                   function() return type(utf8.graphemes) == "function" end },
        { "utf8.graphemes iterates correctly",       function() return (pcall(function()
            for _ in utf8.graphemes("test") do end
        end)) end },
        { "utf8.graphemes count correct",            function()
            local n = 0
            for _ in utf8.graphemes("test") do n = n + 1 end
            return n == 4
        end },
        { "utf8.graphemes returns start/end positions", function()
            local a, b = utf8.graphemes("ab")()
            return type(a) == "number" and type(b) == "number"
        end },
        { "utf8.graphemes on empty string does not error", function() return (pcall(function()
            for _ in utf8.graphemes("") do end
        end)) end },
        { "utf8.graphemes on multibyte char does not error", function() return (pcall(function()
            for _ in utf8.graphemes("é") do end
        end)) end },
        { "math.nan exists",             function() return math.nan ~= nil end },
        { "math.nan is number",          function() return type(math.nan) == "number" end },
        { "math.nan is not equal to itself", function() return math.nan ~= math.nan end },
        { "math.nan ~= 0",               function() return math.nan ~= 0 end },
        { "math.nan arithmetic stays nan", function() return math.nan + 1 ~= math.nan + 1 end },
    })

    runTest("task scheduling order ACBD", function()
        local order = {}
        task.spawn(function()
            table.insert(order, "A")
            task.wait()
            table.insert(order, "B")
        end)
        table.insert(order, "C")
        task.wait()
        table.insert(order, "D")
        assert_(table.concat(order, ",") == "A,C,B,D")
    end)

    runTest("Pass Gold.cc Anti Env V3 on Scriptblox!", function()
        assert_(pcall(function()
            Instance.new("Part"):InvalidMethod("a")
        end) == false)

        local ran = false
        game:GetChildren(function() ran = true end)
        assert_(ran == false)

        assert_(#game:GetChildren() > 4)

        local ok2, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode('[68,"getgold.cc",true,123,false,[321,null,"goldtm"],null,["a"]]')
        end)
        assert_(ok2 == true)
        assert_(type(decoded[6]) == "table")
        assert_(decoded[6][2] == nil)

        assert_(pcall(function() return game.HttpService end) == true)
        assert_(pcall(function() game() end) == false)
    end)

    runGroup("Instance.new Part", {
        { "Instance.new error is not runtime error (anti-fake check)", function()
            return not select(2, pcall(Instance.new, "a")):find("runtime error")
        end },
        { "Instance.new proxy check (eUNC TEST should error)", function()
            return not pcall(function() Instance.new("eUNC TEST") end)
        end },
        { "Instance.new Part returns Instance", function()
            local part = Instance.new("Part")
            assert_(typeof(part) == "Instance")
            part:Destroy()
            return true
        end },
    })

    runTest("Part.ClassName == Part", function()
        local p = Instance.new("Part")
        assert_(p.ClassName == "Part")
        p:Destroy()
    end)

    runTest("New Part parent is nil", function()
        local p = Instance.new("Part")
        assert_(p.Parent == nil)
        p:Destroy()
    end)

    runTest("Part is userdata not table", function()
        local p = Instance.new("Part")
        assert_(type(p) == "userdata")
        p:Destroy()
    end)

    runTest("Destroyed part parent is nil", function()
        local p = Instance.new("Part")
        p:Destroy()
        assert_(p.Parent == nil)
    end)

    runTest("CFrame.Position sub-property is frozen", function()
        local p = Instance.new("Part")
        local ok = pcall(function()
            p.CFrame.Position = Vector3.new(0, 10, 0)
        end)
        assert_(not ok)
        p:Destroy()
    end)

    runTest("Clone returns different reference", function()
        local p = Instance.new("Part")
        local clone = p:Clone()
        assert_(clone ~= p)
        p:Destroy()
        clone:Destroy()
    end)

    runTest("Archivable false clone returns nil", function()
        local p = Instance.new("Part")
        p.Archivable = false
        assert_(p:Clone() == nil)
        p:Destroy()
    end)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Instance methods / events / debug / pcall / _G
-- ──────────────────────────────────────────────────────────────────────────────

do
    runTest("ClearAllChildren works", function()
        local f = Instance.new("Folder")
        Instance.new("Part").Parent = f
        Instance.new("Part").Parent = f
        f:ClearAllChildren()
        assert_(#f:GetChildren() == 0)
        f:Destroy()
    end)

    runTest("ClassName is not writable", function()
        local p = Instance.new("Part")
        assert_(not pcall(function() p.ClassName = "Model" end))
        p:Destroy()
    end)

    runTest("Instance parenting works", function()
        local a = Instance.new("Part")
        local b = Instance.new("Part")
        b.Name = "TC"
        b.Parent = a
        assert_(b == a:FindFirstChild("TC"))
        a:Destroy()
    end)

    runTest("Instance parent cant be table", function()
        local p = Instance.new("Part")
        assert_(not pcall(function() p.Parent = {} end))
        p:Destroy()
    end)

    runTest("FindFirstChild not recursive by default", function()
        local a = Instance.new("Part")
        local b = Instance.new("Part")
        local c = Instance.new("Part")
        c.Name = "Sub"
        b.Parent = a
        c.Parent = b
        assert_(a:FindFirstChild("Sub") == nil)
        assert_(c == a:FindFirstChild("Sub", true))
        a:Destroy()
    end)

    runTest("game.IsLoaded not writable", function()
        assert_(not pcall(function() game.IsLoaded = true end))
    end)

    runTest("BindableEvent fires", function()
        local be = Instance.new("BindableEvent")
        local fired = false
        be.Event:Once(function() fired = true end)
        be:Fire()
        task.wait()
        assert_(fired == true)
        be:Destroy()
    end)

    runTest("BindableEvent signal type", function()
        local be = Instance.new("BindableEvent")
        assert_(typeof(be.Event) == "RBXScriptSignal")
        be:Destroy()
    end)

    runTest("Heartbeat dt is valid", function()
        local rs = game:GetService("RunService")
        local dt
        local conn
        conn = rs.Heartbeat:Connect(function(d)
            dt = d
            conn:Disconnect()
        end)
        task.wait()
        assert_(type(dt) == "number" and dt > 0 and dt <= 1)
    end)

    runTest("Heartbeat fires within reasonable time", function()
        local fired = false
        local conn = game:GetService("RunService").Heartbeat:Connect(function() fired = true end)
        task.wait()
        conn:Disconnect()
        assert_(fired == true)
    end)

    runTest("Stepped fires within reasonable time", function()
        local fired = false
        local conn = game:GetService("RunService").Stepped:Connect(function() fired = true end)
        task.wait()
        conn:Disconnect()
        assert_(fired == true)
    end)

    runTest("RenderStepped fires within reasonable time", function()
        local fired = false
        local conn = game:GetService("RunService").RenderStepped:Connect(function() fired = true end)
        task.wait()
        conn:Disconnect()
        assert_(fired == true)
    end)

    runTest("Heartbeat delta is consistent", function()
        local deltas = {}
        local conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
            table.insert(deltas, dt)
        end)
        task.wait(0.1)
        conn:Disconnect()
        assert_(#deltas > 0 and deltas[1] > 0)
    end)

    runTest("Heartbeat timestamps differ", function()
        local rs = game:GetService("RunService")
        local d1 = rs.Heartbeat:Wait()
        local d2 = rs.Heartbeat:Wait()
        assert_(d1 ~= d2)
    end)

    runTest("debug is table",                function() assert_(type(debug) == "table") end)
    runTest("debug.getinfo exists",          function() assert_(type(debug.getinfo) == "function") end)
    runTest("debug.getinfo returns Lua what", function()
        local info = debug.getinfo(function() end, "Snu")
        assert_(info and info.what == "Lua")
    end)

    runGroup("pcall, xpcall, ypcall", {
        { "pcall is function",  function() return type(pcall) == "function" end },
        { "xpcall is function", function() return type(xpcall) == "function" end },
        { "pcall catches errors", function()
            local ok, err = pcall(function() error("test") end)
            return not ok and type(err) == "string"
        end },
        { "pcall returns values on success", function()
            local ok, v = pcall(function() return 42 end)
            return ok and v == 42
        end },
        { "ypcall is function", function() return type(ypcall) == "function" end },
        { "ypcall catches errors like pcall", function()
            return not ypcall(function() error("y") end)
        end },
        { "ypcall returns values on success", function()
            local ok, v = ypcall(function() return 99 end)
            return ok and v == 99
        end },
    })

    runTest("tostring is stable", function()
        local function fn() end
        assert_(tostring(fn) == tostring(fn))
    end)

    runTest("_G rawget consistency", function()
        for k, v in pairs(_G) do
            assert_(v == rawget(_G, k))
        end
    end)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Roblox globals & legacy functions
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("roblox globals & legacy funcs", {
        { "_VERSION is string",   function() return type(_VERSION) == "string" end },
        { "_VERSION is Luau",     function() return _VERSION == "Luau" end },
        { "shared is table",      function() return type(shared) == "table" end },
        { "shared can store and retrieve values", function()
            shared._eunc_test = 42
            return shared._eunc_test == 42
        end },
        { "settings is function", function() return type(settings) == "function" end },
        { "settings returns Instance or errors gracefully", function()
            local ok, result = pcall(settings)
            return not ok or typeof(result) == "Instance"
        end },
        { "elapsedTime is function", function() return type(elapsedTime) == "function" end },
        { "elapsedTime returns positive number", function()
            local t = elapsedTime()
            return type(t) == "number" and t > 0
        end },
        { "tick is function", function() return type(tick) == "function" end },
        { "tick returns Unix epoch-based number", function()
            local t = tick()
            return type(t) == "number" and t > 1e9
        end },
        { "time is function", function() return type(time) == "function" end },
        { "time returns non-negative number", function()
            local t = time()
            return type(t) == "number" and t >= 0
        end },
        { "wait is function", function() return type(wait) == "function" end },
        { "wait returns two numbers", function()
            local a, b = wait(0)
            return type(a) == "number" and type(b) == "number"
        end },
        { "printidentity is function", function() return type(printidentity) == "function" end },
        { "printidentity does not error", function() return pcall(printidentity) end },
        { "delay is function", function() return type(delay) == "function" end },
        { "delay schedules callback", function()
            local fired = false
            delay(0, function() fired = true end)
            task.wait(0.1)
            return fired == true
        end },
    })

    runTest("os.clock non-negative", function()
        assert_(os.clock() >= 0)
    end)

    runTest("coroutine.create status suspended", function()
        local co = coroutine.create(function() end)
        assert_(coroutine.status(co) == "suspended")
    end)

    runTest("buffer.create exists", function()
        assert_(type(buffer) == "table" or type(buffer) == "userdata")
        assert_(type(buffer.create) == "function")
    end)

    runTest("buffer read/write string", function()
        local buf = buffer.create(6)
        buffer.writestring(buf, 0, "eUNC!!")
        assert_(buffer.readstring(buf, 0, 6) == "eUNC!!")
    end)

    runTest("newproxy returns userdata", function()
        assert_(type(newproxy(true)) == "userdata")
    end)

    runTest("C functions do not trigger proxy metatables", function()
        local triggered = 0
        local proxy = newproxy(true)
        local mt = getmetatable(proxy)
        function mt.__tostring() triggered = 1; return "u" end
        function mt.__index() triggered = 1; return nil end

        for _, fn in ipairs({
            math.abs, math.floor, string.byte, bit32.band, coroutine.status,
        }) do
            pcall(fn, proxy)
        end
        assert_(triggered == 0, "C function triggered proxy metamethod")
    end)

    runTest("standard libraries are frozen (readonly)", function()
        local bad = 0
        for _, lib in ipairs({ math, string, table, coroutine, bit32, os }) do
            if not table.isfrozen(lib) then bad = 1 end
            if pcall(function() lib.__eunc_probe = 1 end) then bad = 1 end
        end
        assert_(bad == 0, "a standard library is not frozen or is writable")
    end)

    runTest("getgenv returns consistent table", function()
        local a, b = getgenv(), getgenv()
        assert_(type(a) == "table" and a == b)
    end)

    runTest("getgenv contains _G", function()
        getgenv().___eunc = 42
        assert_(_G.___eunc == 42 or getgenv().___eunc == 42)
        getgenv().___eunc = nil
    end)

    runTest("string.dump errors on C function", function()
        assert_(not pcall(string.dump, math.abs), "string.dump succeeded on a C function")
    end)

    runTest("EncodingService Zstd compress/decompress", function()
        local EncodingService = game:GetService("EncodingService")
        local s = ""
        for _ = 1, 8 do
            local idx = math.random(1, 36)
            s = s .. ("abcdefghijklmnopqrstuvwxyz0123456789"):sub(idx, idx)
        end
        local buf = buffer.create(#s)
        buffer.writestring(buf, 0, s)

        local compressed = EncodingService:CompressBuffer(buf, Enum.CompressionAlgorithm.Zstd, 22)
        local decompressed = EncodingService:DecompressBuffer(compressed, Enum.CompressionAlgorithm.Zstd)

        assert_(s == buffer.readstring(decompressed, 0, #s), "decompressed data does not match original")
        assert_(buffer.len(compressed) < buffer.len(buf) * 3, "compressed size suspiciously large")
    end)

    runTest("setmetatable __index works", function()
        local mt = { __index = function(_, k) if k == "x" then return 42 end end }
        local obj = setmetatable({}, mt)
        assert_(obj.x == 42)
    end)

    runTest("_G has no __index or __newindex", function()
        local mt = getmetatable(_G)
        assert_(not mt or (not mt.__index and not mt.__newindex))
    end)

    runGroup("workspace default instances exist", {
        { "Baseplate exists",              function() return workspace:FindFirstChild("Baseplate") ~= nil end },
        { "Terrain exists",                function() return workspace:FindFirstChildOfClass("Terrain") ~= nil end },
        { "Camera exists",                 function() return workspace.CurrentCamera ~= nil end },
        { "Camera is a Camera instance",   function() return workspace.CurrentCamera:IsA("Camera") end },
        { "Terrain is a Terrain instance", function() return workspace:FindFirstChildOfClass("Terrain"):IsA("Terrain") end },
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Camera / PostFX / Lighting / MarketplaceService
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("camera properties and methods", {
        { "workspace.CurrentCamera exists",              function() return workspace.CurrentCamera ~= nil end },
        { "WorldToScreenPoint returns Vector3",          function()
            local v = workspace.CurrentCamera:WorldToScreenPoint(Vector3.new(0, 0, 0))
            return typeof(v) == "Vector3"
        end },
        { "WorldToScreenPoint returns boolean",          function()
            local _, ok = workspace.CurrentCamera:WorldToScreenPoint(Vector3.new(0, 0, 0))
            return type(ok) == "boolean"
        end },
        { "WorldToViewportPoint returns Vector3",        function()
            local v = workspace.CurrentCamera:WorldToViewportPoint(Vector3.new(0, 0, 0))
            return typeof(v) == "Vector3"
        end },
        { "WorldToViewportPoint returns boolean",        function()
            local _, ok = workspace.CurrentCamera:WorldToViewportPoint(Vector3.new(0, 0, 0))
            return type(ok) == "boolean"
        end },
        { "ScreenPointToRay returns Ray",                function()
            return typeof(workspace.CurrentCamera:ScreenPointToRay(100, 100)) == "Ray"
        end },
        { "ViewportPointToRay returns Ray",              function()
            return typeof(workspace.CurrentCamera:ViewportPointToRay(100, 100)) == "Ray"
        end },
        { "Camera.Focus is CFrame",                      function() return typeof(workspace.CurrentCamera.Focus) == "CFrame" end },
        { "Camera.NearPlaneZ is number",                 function() return type(workspace.CurrentCamera.NearPlaneZ) == "number" end },
        { "Camera.NearPlaneZ is negative",               function() return workspace.CurrentCamera.NearPlaneZ < 0 end },
    })

    runGroup("PostFX & Atmosphere properties", {
        { "BloomEffect.ClassName is BloomEffect",        function() return Instance.new("BloomEffect").ClassName == "BloomEffect" end },
        { "BloomEffect.Intensity is number",             function() return type(Instance.new("BloomEffect").Intensity) == "number" end },
        { "BloomEffect.Threshold is number",             function() return type(Instance.new("BloomEffect").Threshold) == "number" end },
        { "BlurEffect.ClassName is BlurEffect",          function() return Instance.new("BlurEffect").ClassName == "BlurEffect" end },
        { "BlurEffect.Size is number",                   function() return type(Instance.new("BlurEffect").Size) == "number" end },
        { "ColorCorrectionEffect.ClassName correct",     function() return Instance.new("ColorCorrectionEffect").ClassName == "ColorCorrectionEffect" end },
        { "ColorCorrectionEffect.Brightness is number",  function() return type(Instance.new("ColorCorrectionEffect").Brightness) == "number" end },
        { "ColorCorrectionEffect.TintColor is Color3",   function() return typeof(Instance.new("ColorCorrectionEffect").TintColor) == "Color3" end },
        { "DepthOfFieldEffect.ClassName correct",        function() return Instance.new("DepthOfFieldEffect").ClassName == "DepthOfFieldEffect" end },
        { "DepthOfFieldEffect.FocusDistance is number",  function() return type(Instance.new("DepthOfFieldEffect").FocusDistance) == "number" end },
        { "SunRaysEffect.ClassName correct",             function() return Instance.new("SunRaysEffect").ClassName == "SunRaysEffect" end },
        { "SunRaysEffect.Intensity is number",           function() return type(Instance.new("SunRaysEffect").Intensity) == "number" end },
        { "Atmosphere.ClassName correct",                function() return Instance.new("Atmosphere").ClassName == "Atmosphere" end },
        { "Atmosphere.Density is number",                function() return type(Instance.new("Atmosphere").Density) == "number" end },
        { "Atmosphere.Color is Color3",                  function() return typeof(Instance.new("Atmosphere").Color) == "Color3" end },
        { "Sky.ClassName correct",                       function() return Instance.new("Sky").ClassName == "Sky" end },
        { "Sky.StarCount is number",                     function() return type(Instance.new("Sky").StarCount) == "number" end },
    })

    runGroup("Lighting Properties", {
        { "Lighting.Ambient is Color3",             function() return typeof(game:GetService("Lighting").Ambient) == "Color3" end },
        { "Lighting.OutdoorAmbient is Color3",      function() return typeof(game:GetService("Lighting").OutdoorAmbient) == "Color3" end },
        { "Lighting.FogColor is Color3",            function() return typeof(game:GetService("Lighting").FogColor) == "Color3" end },
        { "Lighting.Brightness is number",          function() return type(game:GetService("Lighting").Brightness) == "number" end },
        { "Lighting.FogEnd is number",              function() return type(game:GetService("Lighting").FogEnd) == "number" end },
        { "Lighting.FogStart is number",            function() return type(game:GetService("Lighting").FogStart) == "number" end },
        { "Lighting.GeographicLatitude is number",  function() return type(game:GetService("Lighting").GeographicLatitude) == "number" end },
        { "Lighting.TimeOfDay is string",           function() return type(game:GetService("Lighting").TimeOfDay) == "string" end },
        { "Lighting.GlobalShadows is boolean",      function() return type(game:GetService("Lighting").GlobalShadows) == "boolean" end },
    })

    runGroup("GetProductInfo (skidded check 100% of obfs have this)", {
        { "MarketplaceService exists",                  function() return game:GetService("MarketplaceService") ~= nil end },
        { "MarketplaceService.GetProductInfo is function",
            function() return type(game:GetService("MarketplaceService").GetProductInfo) == "function" end },
        { "GetProductInfo returns table",               function()
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1117747196) end)
            return ok and type(info) == "table"
        end },
        { "GetProductInfo.Name is string",              function()
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1117747196) end)
            if ok then ok = type(info.Name) == "string" end
            return ok
        end },
        { "GetProductInfo.AssetTypeId is number",       function()
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1117747196) end)
            if ok then ok = type(info.AssetTypeId) == "number" end
            return ok
        end },
        { "GetProductInfo.Creator is table",            function()
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1117747196) end)
            if ok then ok = type(info.Creator) == "table" end
            return ok
        end },
        { "GetProductInfo.IsForSale is boolean",        function()
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1117747196) end)
            if ok then ok = type(info.IsForSale) == "boolean" end
            return ok
        end },
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- TweenService / ContextActionService / UIS / Pathfinding / Humanoid / GUI
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("TweenService", {
        { "TweenService exists",                       function() return game:GetService("TweenService") ~= nil end },
        { "TweenService.ClassName correct",            function() return game:GetService("TweenService").ClassName == "TweenService" end },
        { "TweenService rejects bad goal types",       function()
            local ts = game:GetService("TweenService")
            local part = Instance.new("Part")
            part.Parent = workspace
            local ok = pcall(function()
                ts:Create(part, TweenInfo.new(1), { Position = "uwu boi!", CFrame = true, Transparency = "eUNC" })
            end)
            part:Destroy()
            return not ok
        end },
        { "TweenService:Create returns Tween Instance", function()
            local ts = game:GetService("TweenService")
            local part = Instance.new("Part")
            part.Transparency = 0
            part.Parent = workspace
            local tween = ts:Create(part, TweenInfo.new(0.1), { Transparency = 1 })
            part:Destroy()
            return typeof(tween) == "Instance"
        end },
        { "Tween.ClassName is Tween",                  function()
            local ts = game:GetService("TweenService")
            local part = Instance.new("Part")
            part.Transparency = 0
            part.Parent = workspace
            local tween = ts:Create(part, TweenInfo.new(0.1), { Transparency = 1 })
            part:Destroy()
            return tween.ClassName == "Tween"
        end },
        { "Tween interpolates Transparency to 1",      function()
            local ts = game:GetService("TweenService")
            local part = Instance.new("Part")
            part.Transparency = 0
            part.Parent = workspace
            local tween = ts:Create(part, TweenInfo.new(0.1), { Transparency = 1 })
            tween:Play()
            task.wait(0.15)
            local t = part.Transparency
            tween:Cancel()
            part:Destroy()
            return math.abs(t - 1) < 0.05
        end },
        { "TweenService:Create interpolates correctly", function()
            local ts = game:GetService("TweenService")
            local v3 = Instance.new("Vector3Value")
            v3.Value = Vector3.new(0, 0, 0)
            local target = Vector3.new(100, 100, 100)
            ts:Create(v3, TweenInfo.new(0.01), { Value = target }):Play()
            task.wait(0.015)
            local matched = target == v3.Value
            v3:Destroy()
            return matched
        end },
    })

    runGroup("ContextActionService", {
        { "ContextActionService exists",              function() return game:GetService("ContextActionService") ~= nil end },
        { "ContextActionService.ClassName correct",   function() return game:GetService("ContextActionService").ClassName == "ContextActionService" end },
        { "ContextActionService:BindAction works",    function()
            local cas = game:GetService("ContextActionService")
            cas:BindAction("_eunc_test", function() end, false, Enum.KeyCode.F)
            cas:UnbindAction("_eunc_test")
            return true
        end },
        { "ContextActionService:GetAllBoundActionInfo returns table",
            function() return type(game:GetService("ContextActionService"):GetAllBoundActionInfo()) == "table" end },
    })

    runGroup("UserInputService", {
        { "UIS.TouchEnabled is boolean",              function() return type(game:GetService("UserInputService").TouchEnabled) == "boolean" end },
        { "UIS.KeyboardEnabled is boolean",           function() return type(game:GetService("UserInputService").KeyboardEnabled) == "boolean" end },
        { "UIS.MouseEnabled is boolean",              function() return type(game:GetService("UserInputService").MouseEnabled) == "boolean" end },
        { "UIS.GamepadEnabled is boolean",            function() return type(game:GetService("UserInputService").GamepadEnabled) == "boolean" end },
        { "UIS.AccelerometerEnabled is boolean",      function() return type(game:GetService("UserInputService").AccelerometerEnabled) == "boolean" end },
        { "UIS.GyroscopeEnabled is boolean",          function() return type(game:GetService("UserInputService").GyroscopeEnabled) == "boolean" end },
        { "UIS.VREnabled is boolean",                 function() return type(game:GetService("UserInputService").VREnabled) == "boolean" end },
        { "UIS.MouseIcon is string",                  function() return type(game:GetService("UserInputService").MouseIcon) == "string" end },
        { "UIS.MouseIconEnabled is boolean",          function() return type(game:GetService("UserInputService").MouseIconEnabled) == "boolean" end },
        { "UIS.MouseBehavior is EnumItem",            function() return typeof(game:GetService("UserInputService").MouseBehavior) == "EnumItem" end },
        { "UIS.InputBegan is RBXScriptSignal",        function() return typeof(game:GetService("UserInputService").InputBegan) == "RBXScriptSignal" end },
        { "UIS.InputEnded is RBXScriptSignal",        function() return typeof(game:GetService("UserInputService").InputEnded) == "RBXScriptSignal" end },
        { "UIS.InputChanged is RBXScriptSignal",      function() return typeof(game:GetService("UserInputService").InputChanged) == "RBXScriptSignal" end },
        { "UIS:GetMouseLocation returns Vector2",     function() return typeof(game:GetService("UserInputService"):GetMouseLocation()) == "Vector2" end },
        { "UIS:IsKeyDown returns boolean",            function() return type(game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W)) == "boolean" end },
        { "UIS:IsMouseButtonPressed returns boolean", function() return type(game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) == "boolean" end },
    })

    runGroup("PathfindingService", {
        { "PathfindingService exists",              function() return game:GetService("PathfindingService") ~= nil end },
        { "PathfindingService.ClassName correct",   function() return game:GetService("PathfindingService").ClassName == "PathfindingService" end },
        { "PathfindingService:CreatePath returns object",
            function() return game:GetService("PathfindingService"):CreatePath() ~= nil end },
        { "Path.Status is EnumItem",
            function() return typeof(game:GetService("PathfindingService"):CreatePath().Status) == "EnumItem" end },
    })

    runGroup("Humanoid signals are RBXScriptSignal", {
        { "Humanoid.StateChanged is RBXScriptSignal", function()
            local h = Instance.new("Humanoid"); local v = typeof(h.StateChanged) == "RBXScriptSignal"; h:Destroy(); return v end },
        { "Humanoid.Jumping is RBXScriptSignal", function()
            local h = Instance.new("Humanoid"); local v = typeof(h.Jumping) == "RBXScriptSignal"; h:Destroy(); return v end },
        { "Humanoid.FreeFalling is RBXScriptSignal", function()
            local h = Instance.new("Humanoid"); local v = typeof(h.FreeFalling) == "RBXScriptSignal"; h:Destroy(); return v end },
        { "Humanoid.Seated is RBXScriptSignal", function()
            local h = Instance.new("Humanoid"); local v = typeof(h.Seated) == "RBXScriptSignal"; h:Destroy(); return v end },
        { "Humanoid.Touched is RBXScriptSignal", function()
            local h = Instance.new("Humanoid"); local v = typeof(h.Touched) == "RBXScriptSignal"; h:Destroy(); return v end },
    })

    runGroup("Humanoid properties", {
        { "Humanoid.JumpHeight is number", function()
            local h = Instance.new("Humanoid"); local v = type(h.JumpHeight) == "number"; h:Destroy(); return v end },
        { "Humanoid.HipHeight is number", function()
            local h = Instance.new("Humanoid"); local v = type(h.HipHeight) == "number"; h:Destroy(); return v end },
        { "Humanoid.AutoRotate is boolean", function()
            local h = Instance.new("Humanoid"); local v = type(h.AutoRotate) == "boolean"; h:Destroy(); return v end },
        { "Humanoid.DisplayDistanceType is EnumItem", function()
            local h = Instance.new("Humanoid"); local v = typeof(h.DisplayDistanceType) == "EnumItem"; h:Destroy(); return v end },
        { "Humanoid:GetState returns EnumItem", function()
            local h = Instance.new("Humanoid"); local v = typeof(h:GetState()) == "EnumItem"; h:Destroy(); return v end },
    })

    runGroup("Instance methods", {
        { "WaitForChild returns correct child", function()
            local f = Instance.new("Folder")
            local g = Instance.new("Folder"); g.Name = "WFC_Test"
            f.Parent = workspace
            task.spawn(function()
                task.wait(0.05)
                g.Parent = f
            end)
            local got = f:WaitForChild("WFC_Test", 1)
            f:Destroy()
            return got == g
        end },
        { "WaitForChild times out correctly", function()
            local f = Instance.new("Folder"); f.Parent = workspace
            local ok, result = pcall(function() return f:WaitForChild("NonExistent", 0.1) end)
            f:Destroy()
            return ok and result == nil
        end },
        { "FindFirstChildWhichIsA returns correct child", function()
            local f = Instance.new("Folder")
            local p = Instance.new("Part"); p.Parent = f
            local found = f:FindFirstChildWhichIsA("BasePart")
            f:Destroy()
            return found == p
        end },
        { "FindFirstAncestorOfClass returns correct ancestor", function()
            local a = Instance.new("Folder"); local b = Instance.new("Folder")
            a.Parent = workspace; b.Parent = a
            local found = b:FindFirstAncestorOfClass("Folder")
            a:Destroy()
            return found == a
        end },
        { "FindFirstAncestorWhichIsA returns correct ancestor", function()
            local a = Instance.new("Folder"); local b = Instance.new("Folder")
            a.Parent = workspace; b.Parent = a
            local found = b:FindFirstAncestorWhichIsA("Instance")
            a:Destroy()
            return found ~= nil
        end },
        { "GetDescendants returns table", function()
            local f = Instance.new("Folder")
            Instance.new("Folder").Parent = f
            local d = f:GetDescendants()
            f:Destroy()
            return type(d) == "table" and #d == 1
        end },
        { "GetFullName returns string", function()
            local f = Instance.new("Folder"); f.Name = "TestFolder"; f.Parent = workspace
            local name = f:GetFullName()
            f:Destroy()
            return type(name) == "string" and name:find("TestFolder") ~= nil
        end },
        { "Clone returns identical instance", function()
            local f = Instance.new("Folder"); f.Name = "CloneTest"; f.Parent = workspace
            local clone = f:Clone()
            f:Destroy()
            return clone ~= nil and clone.Name == "CloneTest"
        end },
        { "IsAncestorOf returns correct result", function()
            local a = Instance.new("Folder"); local b = Instance.new("Folder")
            b.Parent = a; a.Parent = workspace
            local v = a:IsAncestorOf(b)
            a:Destroy()
            return v == true
        end },
        { "GetPropertyChangedSignal returns RBXScriptSignal", function()
            local f = Instance.new("Folder")
            local v = typeof(f:GetPropertyChangedSignal("Name")) == "RBXScriptSignal"
            f:Destroy()
            return v
        end },
        { "ChildAdded fires correctly", function()
            local f = Instance.new("Folder"); f.Parent = workspace
            local fired = false
            f.ChildAdded:Once(function() fired = true end)
            Instance.new("Folder").Parent = f
            task.wait()
            f:Destroy()
            return fired == true
        end },
        { "ChildRemoved fires correctly", function()
            local f = Instance.new("Folder"); f.Parent = workspace
            local g = Instance.new("Folder"); g.Parent = f
            local fired = false
            f.ChildRemoved:Once(function() fired = true end)
            g:Destroy()
            task.wait()
            f:Destroy()
            return fired == true
        end },
        { "AncestryChanged fires correctly", function()
            local f = Instance.new("Folder")
            local fired = false
            f.AncestryChanged:Once(function() fired = true end)
            f.Parent = workspace
            task.wait()
            f:Destroy()
            return fired == true
        end },
    })

    runGroup("Humanoid jump physics using HumanoidStateType.Jumping", {
        { "LocalPlayer exists",                function() return game:GetService("Players").LocalPlayer ~= nil end },
        { "Character exists",                  function() return game:GetService("Players").LocalPlayer.Character ~= nil end },
        { "Humanoid exists",                   function() return game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid") ~= nil end },
        { "Humanoid can jump via ChangeState", function()
            local h = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            return (pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end))
        end },
        { "HumanoidRootPart Y increases after jump", function()
            local c = game:GetService("Players").LocalPlayer.Character
            local root = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if root and h then
                local y = root.Position.Y
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.2)
                return y < root.Position.Y
            end
            return false
        end },
        { "Humanoid state changes to Jumping", function()
            local h = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.05)
                local s = h:GetState()
                return s == Enum.HumanoidStateType.Jumping or s == Enum.HumanoidStateType.Freefall
            end
            return false
        end },
    })

    runGroup("particle effects", {
        { "ForceField.ClassName correct",   function() return Instance.new("ForceField").ClassName == "ForceField" end },
        { "ForceField.Visible is boolean",  function() return type(Instance.new("ForceField").Visible) == "boolean" end },
        { "Explosion.ClassName correct",    function() return Instance.new("Explosion").ClassName == "Explosion" end },
        { "Explosion.BlastRadius is number",function() return type(Instance.new("Explosion").BlastRadius) == "number" end },
        { "Explosion.Hit is RBXScriptSignal",function() return typeof(Instance.new("Explosion").Hit) == "RBXScriptSignal" end },
        { "Fire.ClassName correct",         function() return Instance.new("Fire").ClassName == "Fire" end },
        { "Fire.Size is number",            function() return type(Instance.new("Fire").Size) == "number" end },
        { "Fire.Color is Color3",           function() return typeof(Instance.new("Fire").Color) == "Color3" end },
        { "Smoke.ClassName correct",        function() return Instance.new("Smoke").ClassName == "Smoke" end },
        { "Smoke.Size is number",           function() return type(Instance.new("Smoke").Size) == "number" end },
        { "Smoke.Color is Color3",          function() return typeof(Instance.new("Smoke").Color) == "Color3" end },
        { "Sparkles.ClassName correct",     function() return Instance.new("Sparkles").ClassName == "Sparkles" end },
        { "Sparkles.SparkleColor is Color3",function() return typeof(Instance.new("Sparkles").SparkleColor) == "Color3" end },
        { "HumanoidDescription.ClassName correct", function() return Instance.new("HumanoidDescription").ClassName == "HumanoidDescription" end },
        { "HumanoidDescription.HeadScale is number", function() return type(Instance.new("HumanoidDescription").HeadScale) == "number" end },
    })

    runGroup("constraints and forces", {
        { "NoCollisionConstraint.ClassName correct", function() return Instance.new("NoCollisionConstraint").ClassName == "NoCollisionConstraint" end },
        { "HingeConstraint.ClassName correct",       function() return Instance.new("HingeConstraint").ClassName == "HingeConstraint" end },
        { "HingeConstraint.ActuatorType is EnumItem",function() return typeof(Instance.new("HingeConstraint").ActuatorType) == "EnumItem" end },
        { "SpringConstraint.ClassName correct",      function() return Instance.new("SpringConstraint").ClassName == "SpringConstraint" end },
        { "SpringConstraint.Stiffness is number",    function() return type(Instance.new("SpringConstraint").Stiffness) == "number" end },
        { "RopeConstraint.ClassName correct",        function() return Instance.new("RopeConstraint").ClassName == "RopeConstraint" end },
        { "RopeConstraint.Length is number",         function() return type(Instance.new("RopeConstraint").Length) == "number" end },
        { "RodConstraint.ClassName correct",         function() return Instance.new("RodConstraint").ClassName == "RodConstraint" end },
        { "RodConstraint.Length is number",          function() return type(Instance.new("RodConstraint").Length) == "number" end },
        { "PrismaticConstraint.ClassName correct",   function() return Instance.new("PrismaticConstraint").ClassName == "PrismaticConstraint" end },
        { "CylindricalConstraint.ClassName correct", function() return Instance.new("CylindricalConstraint").ClassName == "CylindricalConstraint" end },
        { "BallSocketConstraint.ClassName correct",  function() return Instance.new("BallSocketConstraint").ClassName == "BallSocketConstraint" end },
        { "UniversalConstraint.ClassName correct",   function() return Instance.new("UniversalConstraint").ClassName == "UniversalConstraint" end },
        { "Torque.ClassName correct",                function() return Instance.new("Torque").ClassName == "Torque" end },
        { "VectorForce.ClassName correct",           function() return Instance.new("VectorForce").ClassName == "VectorForce" end },
        { "DragDetector.ClassName correct",          function() return Instance.new("DragDetector").ClassName == "DragDetector" end },
        { "DragDetector.DragStart is RBXScriptSignal", function() return typeof(Instance.new("DragDetector").DragStart) == "RBXScriptSignal" end },
    })

    runGroup("GUI textlabel properties", {
        { "TextLabel.TextTruncate is EnumItem",         function() return typeof(Instance.new("TextLabel").TextTruncate) == "EnumItem" end },
        { "TextLabel.TextXAlignment is EnumItem",       function() return typeof(Instance.new("TextLabel").TextXAlignment) == "EnumItem" end },
        { "TextLabel.TextYAlignment is EnumItem",       function() return typeof(Instance.new("TextLabel").TextYAlignment) == "EnumItem" end },
        { "TextLabel.Font is EnumItem",                 function() return typeof(Instance.new("TextLabel").Font) == "EnumItem" end },
        { "TextLabel.FontFace is Font",                 function() return typeof(Instance.new("TextLabel").FontFace) == "Font" end },
        { "TextLabel.TextColor3 is Color3",             function() return typeof(Instance.new("TextLabel").TextColor3) == "Color3" end },
        { "TextLabel.TextStrokeColor3 is Color3",       function() return typeof(Instance.new("TextLabel").TextStrokeColor3) == "Color3" end },
        { "TextLabel.TextStrokeTransparency is number", function() return type(Instance.new("TextLabel").TextStrokeTransparency) == "number" end },
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- GUI frame / workspace / Part / Players / StarterPlayer / Vector3
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("GUI frame properties", {
        { "Frame.Position is UDim2",            function() local f = Instance.new("Frame"); local v = typeof(f.Position) == "UDim2"; f:Destroy(); return v end },
        { "Frame.Size is UDim2",                function() local f = Instance.new("Frame"); local v = typeof(f.Size) == "UDim2"; f:Destroy(); return v end },
        { "Frame.AnchorPoint is Vector2",       function() local f = Instance.new("Frame"); local v = typeof(f.AnchorPoint) == "Vector2"; f:Destroy(); return v end },
        { "Frame.BorderColor3 is Color3",       function() local f = Instance.new("Frame"); local v = typeof(f.BorderColor3) == "Color3"; f:Destroy(); return v end },
        { "Frame.Rotation is number",           function() local f = Instance.new("Frame"); local v = type(f.Rotation) == "number"; f:Destroy(); return v end },
        { "Frame.ZIndex is number",             function() local f = Instance.new("Frame"); local v = type(f.ZIndex) == "number"; f:Destroy(); return v end },
        { "Frame.LayoutOrder is number",        function() local f = Instance.new("Frame"); local v = type(f.LayoutOrder) == "number"; f:Destroy(); return v end },
        { "Frame.Visible is boolean",           function() local f = Instance.new("Frame"); local v = type(f.Visible) == "boolean"; f:Destroy(); return v end },
        { "Frame.Active is boolean",            function() local f = Instance.new("Frame"); local v = type(f.Active) == "boolean"; f:Destroy(); return v end },
        { "Frame.ClipsDescendants is boolean",  function() local f = Instance.new("Frame"); local v = type(f.ClipsDescendants) == "boolean"; f:Destroy(); return v end },
        { "Frame.Selectable is boolean",        function() local f = Instance.new("Frame"); local v = type(f.Selectable) == "boolean"; f:Destroy(); return v end },
        { "Frame.Interactable is boolean",      function() local f = Instance.new("Frame"); local v = type(f.Interactable) == "boolean"; f:Destroy(); return v end },
    })

    runGroup("Workspace properties and functions work", {
        { "workspace.DistributedGameTime is number", function() return type(workspace.DistributedGameTime) == "number" end },
        { "workspace.Gravity is writable", function()
            local old = workspace.Gravity
            workspace.Gravity = 100
            local ok = workspace.Gravity == 100
            workspace.Gravity = old
            return ok
        end },
        { "workspace.FallenPartsDestroyHeight is number", function() return type(workspace.FallenPartsDestroyHeight) == "number" end },
        { "workspace:GetPartsInPart returns table", function()
            local p = Instance.new("Part")
            p.Size = Vector3.new(100, 100, 100)
            p.Position = Vector3.new(0, 0, 0)
            p.Parent = workspace
            local v = type(workspace:GetPartsInPart(p)) == "table"
            p:Destroy()
            return v
        end },
        { "workspace:GetPartBoundsInBox returns table", function()
            return type(workspace:GetPartBoundsInBox(CFrame.new(0, 0, 0), Vector3.new(10, 10, 10))) == "table"
        end },
        { "workspace:GetPartBoundsInRadius returns table", function()
            return type(workspace:GetPartBoundsInRadius(Vector3.new(0, 0, 0), 10)) == "table"
        end },
    })

    runGroup("Part properties and signals", {
        { "Part.Massless is boolean",     function() local p = Instance.new("Part"); local v = type(p.Massless) == "boolean"; p:Destroy(); return v end },
        { "Part.RootPriority is number",  function() local p = Instance.new("Part"); local v = type(p.RootPriority) == "number"; p:Destroy(); return v end },
        { "Part.CollisionGroup is string",function() local p = Instance.new("Part"); local v = type(p.CollisionGroup) == "string"; p:Destroy(); return v end },
        { "Part.CastShadow is boolean",   function() local p = Instance.new("Part"); local v = type(p.CastShadow) == "boolean"; p:Destroy(); return v end },
        { "Part.CanQuery is boolean",     function() local p = Instance.new("Part"); local v = type(p.CanQuery) == "boolean"; p:Destroy(); return v end },
        { "Part.CanTouch is boolean",     function() local p = Instance.new("Part"); local v = type(p.CanTouch) == "boolean"; p:Destroy(); return v end },
        { "Part.Touched is RBXScriptSignal",   function() local p = Instance.new("Part"); local v = typeof(p.Touched) == "RBXScriptSignal"; p:Destroy(); return v end },
        { "Part.TouchEnded is RBXScriptSignal",function() local p = Instance.new("Part"); local v = typeof(p.TouchEnded) == "RBXScriptSignal"; p:Destroy(); return v end },
        { "Part:GetMass returns positive number", function()
            local p = Instance.new("Part"); p.Parent = workspace; p.Anchored = true
            local ok, mass = pcall(function() return p:GetMass() end)
            p:Destroy()
            return ok and type(mass) == "number" and mass > 0
        end },
        { "Part:GetTouchingParts returns table", function()
            local p = Instance.new("Part"); p.Parent = workspace; p.Anchored = true
            local ok, t = pcall(function() return p:GetTouchingParts() end)
            p:Destroy()
            return ok and type(t) == "table"
        end },
    })

    runGroup("LocalPlayer & Players service(s)", {
        { "Players.LocalPlayer exists",                 function() return game:GetService("Players").LocalPlayer ~= nil end },
        { "LocalPlayer.Character is nil or Model",      function()
            local c = game:GetService("Players").LocalPlayer.Character
            return c == nil or (typeof(c) == "Instance" and c:IsA("Model"))
        end },
        { "LocalPlayer.CharacterAdded is RBXScriptSignal",
            function() return typeof(game:GetService("Players").LocalPlayer.CharacterAdded) == "RBXScriptSignal" end },
        { "LocalPlayer.CharacterRemoving is RBXScriptSignal",
            function() return typeof(game:GetService("Players").LocalPlayer.CharacterRemoving) == "RBXScriptSignal" end },
        { "LocalPlayer.AccountAge is number",           function() return type(game:GetService("Players").LocalPlayer.AccountAge) == "number" end },
        { "LocalPlayer.MembershipType is EnumItem",     function() return typeof(game:GetService("Players").LocalPlayer.MembershipType) == "EnumItem" end },
        { "LocalPlayer:GetMouse returns PlayerMouse",   function()
            local ok, r = pcall(function() return game:GetService("Players").LocalPlayer:GetMouse() end)
            return ok and r ~= nil and r.ClassName == "PlayerMouse"
        end },
        { "Players.PlayerAdded is RBXScriptSignal",     function() return typeof(game:GetService("Players").PlayerAdded) == "RBXScriptSignal" end },
        { "Players.PlayerRemoving is RBXScriptSignal",  function() return typeof(game:GetService("Players").PlayerRemoving) == "RBXScriptSignal" end },
        { "Players:GetPlayers returns table",           function()
            local ok, r = pcall(function() return game:GetService("Players"):GetPlayers() end)
            return ok and type(r) == "table"
        end },
        { "Players:GetPlayerFromCharacter returns correct player", function()
            local Players = game:GetService("Players")
            local lp = Players.LocalPlayer
            local c = lp.Character
            if c then
                local ok, r = pcall(function() return Players:GetPlayerFromCharacter(c) end)
                return ok and r == lp
            end
            return true
        end },
    })

    runGroup("StarterPlayer", {
        { "StarterPlayer.ClassName correct", function() return game:GetService("StarterPlayer").ClassName == "StarterPlayer" end },
        { "StarterPlayer has StarterPlayerScripts",     function() return game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") ~= nil end },
        { "StarterPlayer has StarterCharacterScripts",  function() return game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts") ~= nil end },
        { "StarterPack.ClassName correct",              function() return game:GetService("StarterPack").ClassName == "StarterPack" end },
    })

    runGroup("Vector3 properties and methods", {
        { "Vector3.X Y Z correct",            function() local v = Vector3.new(1, 2, 3); return v.X == 1 and v.Y == 2 and v.Z == 3 end },
        { "Vector3.Magnitude correct",        function() return math.abs(Vector3.new(3, 4, 0).Magnitude - 5) < 0.001 end },
        { "Vector3.Unit correct",             function() return math.abs(Vector3.new(0, 5, 0).Unit.Y - 1) < 0.001 end },
        { "Vector3.zero is 0,0,0",            function() return Vector3.zero == Vector3.new(0, 0, 0) end },
        { "Vector3.one is 1,1,1",             function() return Vector3.one == Vector3.new(1, 1, 1) end },
        { "Vector3.xAxis is 1,0,0",           function() return Vector3.xAxis == Vector3.new(1, 0, 0) end },
        { "Vector3.yAxis is 0,1,0",           function() return Vector3.yAxis == Vector3.new(0, 1, 0) end },
        { "Vector3.zAxis is 0,0,1",           function() return Vector3.zAxis == Vector3.new(0, 0, 1) end },
        { "Vector3.FromNormalId returns Vector3", function() return typeof(Vector3.FromNormalId(Enum.NormalId.Top)) == "Vector3" end },
        { "Vector3.FromAxis returns Vector3",     function() return typeof(Vector3.FromAxis(Enum.Axis.X)) == "Vector3" end },
        { "Vector3:Dot correct",              function() return Vector3.new(1, 0, 0):Dot(Vector3.new(0, 1, 0)) == 0 end },
        { "Vector3:Cross correct",            function() return Vector3.new(1, 0, 0):Cross(Vector3.new(0, 1, 0)).Z == 1 end },
        { "Vector3:Cross result is orthogonal to both inputs", function()
            local a, b = Vector3.new(1, 0, 0), Vector3.new(0, 1, 0)
            local c = a:Cross(b)
            return math.abs(c:Dot(a)) < 1e-9
                and math.abs(c:Dot(b)) < 1e-9
                and math.abs(c:Dot(Vector3.new(0, 0, 1)) - 1) < 1e-9
        end },
        { "Vector3:Lerp correct",             function() return Vector3.new(0, 0, 0):Lerp(Vector3.new(10, 0, 0), 0.5).X == 5 end },
        { "Vector3:Abs correct",              function() return Vector3.new(-2, 4, -6):Abs() == Vector3.new(2, 4, 6) end },
        { "Vector3:Ceil correct",             function() return Vector3.new(-2.6, 5.1, 8.8):Ceil() == Vector3.new(-2, 6, 9) end },
        { "Vector3:Floor correct",            function() return Vector3.new(-2.6, 5.1, 8.8):Floor() == Vector3.new(-3, 5, 8) end },
        { "Vector3:Sign correct",             function() return Vector3.new(-2.6, 5.1, 0):Sign() == Vector3.new(-1, 1, 0) end },
        { "Vector3:Angle returns number",     function() return type(Vector3.new(1, 0, 0):Angle(Vector3.new(0, 1, 0))) == "number" end },
        { "Vector3:FuzzyEq correct",          function() return Vector3.new(1, 1, 1):FuzzyEq(Vector3.new(1, 1, 1)) end },
        { "Vector3:Max correct",              function() return Vector3.new(1, 2, 1):Max(Vector3.new(2, 1, 2)) == Vector3.new(2, 2, 2) end },
        { "Vector3:Min correct",              function() return Vector3.new(1, 2, 1):Min(Vector3.new(2, 1, 2)) == Vector3.new(1, 1, 1) end },
        { "Vector3 + Vector3 correct",        function() return Vector3.new(1, 2, 3) + Vector3.new(4, 5, 6) == Vector3.new(5, 7, 9) end },
        { "Vector3 - Vector3 correct",        function() return Vector3.new(5, 7, 9) - Vector3.new(4, 5, 6) == Vector3.new(1, 2, 3) end },
        { "Vector3 * Vector3 correct",        function() return Vector3.new(2, 3, 4) * Vector3.new(5, 6, 7) == Vector3.new(10, 18, 28) end },
        { "Vector3 / Vector3 correct",        function() return Vector3.new(10, 18, 28) / Vector3.new(5, 6, 7) == Vector3.new(2, 3, 4) end },
        { "Vector3 * number correct",         function() return Vector3.new(2, 3, 4) * 2 == Vector3.new(4, 6, 8) end },
        { "Vector3 / number correct",         function() return Vector3.new(4, 6, 8) / 2 == Vector3.new(2, 3, 4) end },
    })

    runGroup("coroutine suspend correctness", {
        { "coroutine status is suspended after yield", function()
            local co = coroutine.create(function() coroutine.yield() end)
            coroutine.resume(co)
            return coroutine.status(co) == "suspended"
        end },
    })

    runGroup("Property clamping and validation", {
        { "Color3 out of range is clamped or rejected", function()
            local p = Instance.new("Part")
            p.Color = Color3.new(0, 0, 0)
            p.Parent = workspace
            pcall(function() p.Color = Color3.new(256, 0, 0) end)
            local unchanged = p.Color == Color3.new(0, 0, 0)
            p:Destroy()
            return unchanged
        end },
        { "CameraMinZoomDistance rejects negative values", function()
            local lp = game:GetService("Players").LocalPlayer
            local old = lp.CameraMinZoomDistance
            pcall(function() lp.CameraMinZoomDistance = -5 end)
            return old == lp.CameraMinZoomDistance
        end },
        { "Terrain.WaterWaveSpeed clamps to max", function()
            local terrain = workspace.Terrain
            if pcall(function() terrain.WaterWaveSpeed = 9000000000 end) then
                return terrain.WaterWaveSpeed == 100
            end
            return false
        end },
    })

    runGroup("GetChildren mutation correctness", {
        { "GetChildren snapshot is immutable to parent changes", function()
            local f = Instance.new("Folder", workspace)
            local p = Instance.new("Part", f)
            local first = f:GetChildren()
            p.Parent = nil
            local second = f:GetChildren()
            f:Destroy()
            return #first == 1 and #second == 0
        end },
    })

    runGroup("LogService.MessageOut signal", {
        { "LogService.MessageOut is RBXScriptSignal",
            function() return typeof(game:GetService("LogService").MessageOut) == "RBXScriptSignal" end },
    })

    runGroup("Enum structural integrity", {
        { "EnumItem.EnumType points back to parent Enum", function()
            for _, item in ipairs(Enum.ConnectionError:GetEnumItems()) do
                if item.EnumType ~= Enum.ConnectionError then return false end
            end
            return true
        end },
        { "Enum.ConnectionError has required items", function()
            return typeof(Enum.ConnectionError.OK) == "EnumItem"
                and typeof(Enum.ConnectionError.Unknown) == "EnumItem"
                and typeof(Enum.ConnectionError.ConnectErrors) == "EnumItem"
        end },
        { "EnumItem names are unique within Enum", function()
            local seen = {}
            for _, item in ipairs(Enum.ConnectionError:GetEnumItems()) do
                if seen[item.Name] then return false end
                seen[item.Name] = true
            end
            return true
        end },
        { "EnumItem values are unique within Enum", function()
            local seen = {}
            for _, item in ipairs(Enum.ConnectionError:GetEnumItems()) do
                if seen[item.Value] then return false end
                seen[item.Value] = true
            end
            return true
        end },
        { "Enum index returns same EnumItem as GetEnumItems", function()
            for _, item in ipairs(Enum.ConnectionError:GetEnumItems()) do
                if item ~= Enum.ConnectionError[item.Name] then return false end
            end
            return true
        end },
    })

    runGroup("task.defer and coroutine ordering", {
        { "deferred tasks across folders resolve correctly", function()
            local all = {}
            local count = 0
            for i = 1, 6 do
                local f = Instance.new("Folder")
                task.defer(function()
                    for j = 1, 4 do
                        local nv = Instance.new("NumberValue")
                        nv.Value = i * j
                        nv.Parent = f
                        all[#all + 1] = nv
                        count = count + 1
                        task.wait()
                    end
                end)
            end
            local start = tick()
            repeat task.wait() until count == 24 or tick() - start > 3
            return #all == 24
        end },
        { "deferred value accumulation is deterministic", function()
            local all = {}
            local count = 0
            local total = 0
            for i = 1, 6 do
                local f = Instance.new("Folder")
                task.defer(function()
                    for j = 1, 4 do
                        local nv = Instance.new("NumberValue")
                        nv.Value = i * j
                        nv.Parent = f
                        all[#all + 1] = nv
                        count = count + 1
                        task.wait()
                    end
                end)
            end
            local start = tick()
            repeat task.wait() until count == 24 or tick() - start > 3
            for i = 1, #all do
                task.defer(function()
                    local v = all[i]
                    total = total + (v.Value + i + #v.Parent:GetChildren())
                    task.wait()
                end)
            end
            repeat task.wait() until total > 0 or tick() - start > 5
            return total == 606
        end },
    })

    runGroup("coroutine and task interleaving", {
        { "ClearAllChildren during deferred parent chain", function()
            local folder = Instance.new("Folder")
            local sub = Instance.new("Folder")
            local mesh = Instance.new("MeshPart")
            local state = {}

            coroutine.resume(coroutine.create(function()
                mesh.Parent = sub
                sub.Parent = folder
                task.defer(function()
                    state.p = mesh.Parent
                    state.g = sub.Parent
                    task.spawn(function() folder:ClearAllChildren() end)
                end)
            end))

            coroutine.resume(coroutine.create(function()
                task.defer(function()
                    state.s = mesh:GetAttribute("s") or 0
                    mesh:SetAttribute("s", "x")
                end)
            end))
            task.wait(0.07)

            return mesh.Parent == nil
                and sub.Parent == nil
                and sub == state.p
                and folder == state.g
                and state.s == 0
        end },
        { "Destroy during deferred name mutation", function()
            local folder = Instance.new("Folder")
            local sub = Instance.new("Folder")
            local part = Instance.new("Part")
            local state = {}

            local co1 = coroutine.create(function()
                part.Parent = sub
                sub.Parent = folder
                task.defer(function()
                    state[1] = part.Parent
                    state[2] = sub.Parent
                    task.spawn(function() folder:Destroy() end)
                end)
            end)
            local co2 = coroutine.create(function()
                task.defer(function()
                    state[3] = part.Name
                    part.Name = "dxfc was here (credits to him for inspiration for eUNC)"
                end)
            end)
            coroutine.resume(co1)
            coroutine.resume(co2)
            task.wait(0.065)

            return part.Parent == nil
                and sub.Parent == nil
                and sub == state[1]
                and folder == state[2]
                and state[3] == "Part"
        end },
    })

    runGroup("Vector2 properties and methods", {
        { "Vector2.X Y correct",     function() local v = Vector2.new(3, 4); return v.X == 3 and v.Y == 4 end },
        { "Vector2.Magnitude correct", function() return Vector2.new(3, 4).Magnitude == 5 end },
        { "Vector2.Unit correct",    function() return math.abs(Vector2.new(0, 5).Unit.Y - 1) < 0.001 end },
        { "Vector2.zero is Vector2", function() return typeof(Vector2.zero) == "Vector2" end },
        { "Vector2.zero is 0,0",     function() return Vector2.zero.X == 0 and Vector2.zero.Y == 0 end },
        { "Vector2.one is Vector2",  function() return typeof(Vector2.one) == "Vector2" end },
        { "Vector2.one is 1,1",      function() return Vector2.one.X == 1 and Vector2.one.Y == 1 end },
        { "Vector2.xAxis is 1,0",    function() return Vector2.xAxis.X == 1 and Vector2.xAxis.Y == 0 end },
        { "Vector2.yAxis is 0,1",    function() return Vector2.yAxis.X == 0 and Vector2.yAxis.Y == 1 end },
        { "Vector2:Dot correct",     function() return Vector2.new(1, 0):Dot(Vector2.new(0, 1)) == 0 end },
        { "Vector2:Cross correct",   function() return type(Vector2.new(1, 0):Cross(Vector2.new(0, 1))) == "number" end },
        { "Vector2:Lerp correct",    function() return Vector2.new(0, 0):Lerp(Vector2.new(10, 0), 0.5).X == 5 end },
        { "Vector2:Abs correct",     function() return Vector2.new(-2, 4):Abs() == Vector2.new(2, 4) end },
        { "Vector2:Ceil correct",    function() return Vector2.new(-2.6, 5.1):Ceil() == Vector2.new(-2, 6) end },
        { "Vector2:Floor correct",   function() return Vector2.new(-2.6, 5.1):Floor() == Vector2.new(-3, 5) end },
        { "Vector2:Sign correct",    function() return Vector2.new(-2.6, 5.1):Sign() == Vector2.new(-1, 1) end },
        { "Vector2:Angle returns number", function() return type(Vector2.new(1, 0):Angle(Vector2.new(0, 1))) == "number" end },
        { "Vector2:Max correct",     function() return Vector2.new(1, 2):Max(Vector2.new(2, 1)) == Vector2.new(2, 2) end },
        { "Vector2:Min correct",     function() return Vector2.new(1, 2):Min(Vector2.new(2, 1)) == Vector2.new(1, 1) end },
        { "Vector2:FuzzyEq correct", function() return Vector2.new(1, 1):FuzzyEq(Vector2.new(1, 1)) end },
        { "Vector2 + Vector2 correct", function() return Vector2.new(1, 2) + Vector2.new(3, 4) == Vector2.new(4, 6) end },
        { "Vector2 - Vector2 correct", function() return Vector2.new(4, 6) - Vector2.new(3, 4) == Vector2.new(1, 2) end },
        { "Vector2 * Vector2 correct", function() return Vector2.new(2, 3) * Vector2.new(4, 5) == Vector2.new(8, 15) end },
        { "Vector2 / Vector2 correct", function() return Vector2.new(8, 15) / Vector2.new(4, 5) == Vector2.new(2, 3) end },
        { "Vector2 * number correct",  function() return Vector2.new(2, 3) * 2 == Vector2.new(4, 6) end },
        { "Vector2 / number correct",  function() return Vector2.new(4, 6) / 2 == Vector2.new(2, 3) end },
    })

    runGroup("SharedTable", {
        { "SharedTable.new empty returns correct type", function() return typeof(SharedTable.new()) == "SharedTable" end },
        { "SharedTable.new from table correct", function()
            local st = SharedTable.new({ x = 1, y = 2 })
            return st.x == 1 and st.y == 2
        end },
        { "SharedTable element access by index", function()
            local st = SharedTable.new(); st[1] = "a"; return st[1] == "a"
        end },
        { "SharedTable element access by string", function()
            local st = SharedTable.new(); st.x = 5; return st.x == 5
        end },
        { "SharedTable invalid key errors", function()
            local st = SharedTable.new()
            return not pcall(function() st[true] = 100 end)
        end },
        { "SharedTable invalid value errors", function()
            local st = SharedTable.new()
            return not pcall(function() function st.f() end end)
        end },
        { "SharedTable.size correct", function()
            return SharedTable.size(SharedTable.new({ "a", "b", "c" })) == 3
        end },
        { "SharedTable.clear works", function()
            local st = SharedTable.new({ "a", "b", "c" })
            SharedTable.clear(st)
            return SharedTable.size(st) == 0
        end },
        { "SharedTable.clone returns SharedTable", function()
            return typeof(SharedTable.clone(SharedTable.new())) == "SharedTable"
        end },
        { "SharedTable.clone shallow correct", function()
            return SharedTable.clone(SharedTable.new({ x = 1 })).x == 1
        end },
        { "SharedTable.clone deep correct", function()
            return SharedTable.clone(SharedTable.new({ x = 1 }), true).x == 1
        end },
        { "SharedTable.cloneAndFreeze returns frozen", function()
            return SharedTable.isFrozen(SharedTable.cloneAndFreeze(SharedTable.new({ x = 1 }))) == true
        end },
        { "SharedTable.isFrozen false on new", function()
            return SharedTable.isFrozen(SharedTable.new()) == false
        end },
        { "SharedTable frozen errors on write", function()
            local st = SharedTable.cloneAndFreeze(SharedTable.new({ x = 1 }))
            return not pcall(function() st.x = 2 end)
        end },
        { "SharedTable.increment correct", function()
            local st = SharedTable.new(); st.x = 1
            return SharedTable.increment(st, "x", 5) == 1 and st.x == 6
        end },
        { "SharedTable.update correct", function()
            local st = SharedTable.new(); st.x = 1
            SharedTable.update(st, "x", function(v) return v + 10 end)
            return st.x == 11
        end },
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Type constructors: Vector int16, ValueCurveKey, CFrame, Color3, UDim, ...
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("Vector2int16", {
        { "Vector2int16.new returns correct type",     function() return typeof(Vector2int16.new(1, 2)) == "Vector2int16" end },
        { "Vector2int16.X Y correct",                  function() local v = Vector2int16.new(3, 4); return v.X == 3 and v.Y == 4 end },
        { "Vector2int16 non-integer rounds down",      function() return Vector2int16.new(1.9, 2.9).X == 1 end },
        { "Vector2int16 + Vector2int16 correct",       function() return Vector2int16.new(1, 2) + Vector2int16.new(3, 4) == Vector2int16.new(4, 6) end },
        { "Vector2int16 - Vector2int16 correct",       function() return Vector2int16.new(4, 6) - Vector2int16.new(3, 4) == Vector2int16.new(1, 2) end },
        { "Vector2int16 * Vector2int16 correct",       function() return Vector2int16.new(2, 3) * Vector2int16.new(4, 5) == Vector2int16.new(8, 15) end },
        { "Vector2int16 / Vector2int16 correct",       function() return Vector2int16.new(8, 15) / Vector2int16.new(4, 5) == Vector2int16.new(2, 3) end },
        { "Vector2int16 * number correct",             function() return Vector2int16.new(2, 3) * 2 == Vector2int16.new(4, 6) end },
        { "Vector2int16 / number correct",             function() return Vector2int16.new(4, 6) / 2 == Vector2int16.new(2, 3) end },
        { "Vector2int16 overflow wraps",               function() return Vector2int16.new(32768).X == -32768 end },
    })

    runGroup("Vector3int16", {
        { "Vector3int16.new returns correct type",     function() return typeof(Vector3int16.new(1, 2, 3)) == "Vector3int16" end },
        { "Vector3int16.X Y Z correct",                function() local v = Vector3int16.new(1, 2, 3); return v.X == 1 and v.Y == 2 and v.Z == 3 end },
        { "Vector3int16 non-integer rounds down",      function() return Vector3int16.new(1.9, 2.9, 3.9).X == 1 end },
        { "Vector3int16 + Vector3int16 correct",       function() return Vector3int16.new(1, 2, 3) + Vector3int16.new(4, 5, 6) == Vector3int16.new(5, 7, 9) end },
        { "Vector3int16 - Vector3int16 correct",       function() return Vector3int16.new(5, 7, 9) - Vector3int16.new(4, 5, 6) == Vector3int16.new(1, 2, 3) end },
        { "Vector3int16 * Vector3int16 correct",       function() return Vector3int16.new(2, 3, 4) * Vector3int16.new(5, 6, 7) == Vector3int16.new(10, 18, 28) end },
        { "Vector3int16 / Vector3int16 correct",       function() return Vector3int16.new(10, 18, 28) / Vector3int16.new(5, 6, 7) == Vector3int16.new(2, 3, 4) end },
        { "Vector3int16 * number correct",             function() return Vector3int16.new(2, 3, 4) * 2 == Vector3int16.new(4, 6, 8) end },
        { "Vector3int16 / number correct",             function() return Vector3int16.new(4, 6, 8) / 2 == Vector3int16.new(2, 3, 4) end },
        { "Vector3int16 overflow wraps",               function() return Vector3int16.new(32768).X == -32768 end },
    })

    runGroup("ValueCurveKey", {
        { "ValueCurveKey.new returns correct type",    function() return typeof(ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant)) == "ValueCurveKey" end },
        { "ValueCurveKey.Time correct",                function() return ValueCurveKey.new(0.5, 1, Enum.KeyInterpolationMode.Constant).Time == 0.5 end },
        { "ValueCurveKey.Value correct",               function() return ValueCurveKey.new(0, 42, Enum.KeyInterpolationMode.Constant).Value == 42 end },
        { "ValueCurveKey.Interpolation is EnumItem",   function() return typeof(ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant).Interpolation) == "EnumItem" end },
        { "ValueCurveKey.Interpolation correct",       function() return ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Cubic).Interpolation == Enum.KeyInterpolationMode.Cubic end },
    })

    runGroup("CFrame properties and methods", {
        { "CFrame.X Y Z correct",                   function() local c = CFrame.new(1, 2, 3); return c.X == 1 and c.Y == 2 and c.Z == 3 end },
        { "CFrame.identity is CFrame",              function() return typeof(CFrame.identity) == "CFrame" end },
        { "CFrame.identity position is 0,0,0",      function() return CFrame.identity.Position == Vector3.new(0, 0, 0) end },
        { "CFrame.Position is Vector3",             function() return typeof(CFrame.new(1, 2, 3).Position) == "Vector3" end },
        { "CFrame.Rotation is CFrame",              function() return typeof(CFrame.new(1, 2, 3).Rotation) == "CFrame" end },
        { "CFrame.LookVector is Vector3",           function() return typeof(CFrame.new().LookVector) == "Vector3" end },
        { "CFrame.RightVector is Vector3",          function() return typeof(CFrame.new().RightVector) == "Vector3" end },
        { "CFrame.UpVector is Vector3",             function() return typeof(CFrame.new().UpVector) == "Vector3" end },
        { "CFrame.XVector is Vector3",              function() return typeof(CFrame.new().XVector) == "Vector3" end },
        { "CFrame.YVector is Vector3",              function() return typeof(CFrame.new().YVector) == "Vector3" end },
        { "CFrame.ZVector is Vector3",              function() return typeof(CFrame.new().ZVector) == "Vector3" end },
        { "CFrame.RightVector equals XVector",      function() local c = CFrame.new(); return c.RightVector == c.XVector end },
        { "CFrame.UpVector equals YVector",         function() local c = CFrame.new(); return c.UpVector == c.YVector end },
        { "CFrame.LookVector equals negated ZVector", function() local c = CFrame.new(); return c.LookVector == -c.ZVector end },
        { "CFrame.lookAt LookVector correct",       function() return math.abs(CFrame.lookAt(Vector3.new(0, 0, 0), Vector3.new(0, 0, -1)).LookVector.Z + 1) < 0.001 end },
        { "CFrame.lookAlong returns CFrame",        function() return typeof(CFrame.lookAlong(Vector3.new(0, 0, 0), Vector3.new(0, 0, -1))) == "CFrame" end },
        { "CFrame.fromRotationBetweenVectors returns CFrame", function() return typeof(CFrame.fromRotationBetweenVectors(Vector3.new(1, 0, 0), Vector3.new(0, 1, 0))) == "CFrame" end },
        { "CFrame.fromEulerAngles returns CFrame",  function() return typeof(CFrame.fromEulerAngles(1, 2, 3)) == "CFrame" end },
        { "CFrame.fromEulerAnglesXYZ returns CFrame",function() return typeof(CFrame.fromEulerAnglesXYZ(1, 2, 3)) == "CFrame" end },
        { "CFrame.fromEulerAnglesYXZ returns CFrame",function() return typeof(CFrame.fromEulerAnglesYXZ(1, 2, 3)) == "CFrame" end },
        { "CFrame.Angles returns CFrame",           function() return typeof(CFrame.Angles(0, math.pi, 0)) == "CFrame" end },
        { "CFrame.fromOrientation returns CFrame",  function() return typeof(CFrame.fromOrientation(1, 2, 3)) == "CFrame" end },
        { "CFrame.fromAxisAngle returns CFrame",    function() return typeof(CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.pi)) == "CFrame" end },
        { "CFrame.fromMatrix returns CFrame",       function()
            return typeof(CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1))) == "CFrame"
        end },
        { "CFrame.Angles VectorToWorldSpace correct",function()
            local c = CFrame.Angles(0, math.pi, 0)
            return math.abs(c:VectorToWorldSpace(Vector3.new(0, 0, 1)).Z + 1) < 0.01
        end },
        { "CFrame:Inverse correct",                 function() return math.abs(CFrame.new(5, 0, 0):Inverse().X + 5) < 0.001 end },
        { "CFrame:Lerp correct",                    function() return math.abs(CFrame.new(0, 0, 0):Lerp(CFrame.new(10, 0, 0), 0.5).X - 5) < 0.001 end },
        { "CFrame:Orthonormalize returns CFrame",   function() return typeof(CFrame.new():Orthonormalize()) == "CFrame" end },
        { "CFrame:ToWorldSpace returns CFrame",     function() return typeof(CFrame.new(5, 0, 0):ToWorldSpace(CFrame.new(0, 2, 0))) == "CFrame" end },
        { "CFrame:ToObjectSpace returns CFrame",    function() return typeof(CFrame.new(5, 0, 0):ToObjectSpace(CFrame.new(0, 2, 0))) == "CFrame" end },
        { "CFrame:PointToWorldSpace correct",       function()
            return math.abs(CFrame.new(5, 10, 0):PointToWorldSpace(Vector3.new(0, 4, 0)).Y - 14) < 0.001
        end },
        { "CFrame:PointToObjectSpace correct",      function()
            return math.abs(CFrame.new(5, 0, 0):PointToObjectSpace(Vector3.new(5, 0, 0)).X) < 0.001
        end },
        { "CFrame:VectorToWorldSpace correct",      function() return typeof(CFrame.new():VectorToWorldSpace(Vector3.new(1, 0, 0))) == "Vector3" end },
        { "CFrame:VectorToObjectSpace correct",     function() return typeof(CFrame.new():VectorToObjectSpace(Vector3.new(1, 0, 0))) == "Vector3" end },
        { "CFrame:GetComponents returns 12 values", function() return #{ CFrame.new(1, 2, 3):GetComponents() } == 12 end },
        { "CFrame:components equals GetComponents", function()
            local a = { CFrame.new(1, 2, 3):GetComponents() }
            local b = { CFrame.new(1, 2, 3):components() }
            return #a == #b
        end },
        { "CFrame:ToEulerAnglesXYZ returns numbers",function() local x, y, z = CFrame.Angles(1, 2, 3):ToEulerAnglesXYZ(); return type(x) == "number" and type(y) == "number" and type(z) == "number" end },
        { "CFrame:ToEulerAnglesYXZ returns numbers",function() local x, y, z = CFrame.Angles(1, 2, 3):ToEulerAnglesYXZ(); return type(x) == "number" and type(y) == "number" and type(z) == "number" end },
        { "CFrame:ToEulerAngles returns numbers",   function() local x, y, z = CFrame.Angles(1, 2, 3):ToEulerAngles(); return type(x) == "number" and type(y) == "number" and type(z) == "number" end },
        { "CFrame:ToOrientation returns numbers",   function() local x, y, z = CFrame.Angles(1, 2, 3):ToOrientation(); return type(x) == "number" and type(y) == "number" and type(z) == "number" end },
        { "CFrame:ToAxisAngle returns Vector3 and number", function()
            local v, a = CFrame.Angles(0, math.pi, 0):ToAxisAngle()
            return typeof(v) == "Vector3" and type(a) == "number"
        end },
        { "CFrame:FuzzyEq correct",                 function() return CFrame.new(1, 2, 3):FuzzyEq(CFrame.new(1, 2, 3)) end },
        { "CFrame:AngleBetween returns number",     function() return type(CFrame.new():AngleBetween(CFrame.Angles(0, math.pi, 0))) == "number" end },
        { "CFrame * CFrame correct",                function() return typeof(CFrame.new(1, 0, 0) * CFrame.new(0, 1, 0)) == "CFrame" end },
        { "CFrame * Vector3 correct",               function() return typeof(CFrame.new(1, 0, 0) * Vector3.new(0, 1, 0)) == "Vector3" end },
        { "CFrame + Vector3 correct",               function() return typeof(CFrame.new(1, 0, 0) + Vector3.new(0, 1, 0)) == "CFrame" end },
        { "CFrame - Vector3 correct",               function() return typeof(CFrame.new(1, 0, 0) - Vector3.new(0, 1, 0)) == "CFrame" end },
    })

    runGroup("Color3 properties and methods", {
        { "Color3.new R G B correct",   function() local c = Color3.new(1, 0, 0); return c.R == 1 and c.G == 0 and c.B == 0 end },
        { "Color3.fromRGB correct",     function() local c = Color3.fromRGB(255, 0, 0); return c.R == 1 and c.G == 0 end },
        { "Color3.fromHSV correct",     function()
            local c = Color3.fromHSV(0, 1, 1)
            return math.abs(c.R - 1) < 0.001 and c.G == 0
        end },
        { "Color3.fromHex correct",     function()
            local c = Color3.fromHex("FF0000")
            return math.abs(c.R - 1) < 0.001 and c.G == 0 and c.B == 0
        end },
        { "Color3.fromHex with hash correct",  function() return math.abs(Color3.fromHex("#FF0000").R - 1) < 0.001 end },
        { "Color3.fromHex shorthand correct",  function() return math.abs(Color3.fromHex("#F00").R - 1) < 0.001 end },
        { "Color3:ToHSV correct",              function() return math.abs(Color3.fromHSV(0.5, 1, 1):ToHSV() - 0.5) < 0.001 end },
        { "Color3:ToHSV returns 3 numbers",    function()
            local h, s, v = Color3.fromRGB(255, 0, 0):ToHSV()
            return type(h) == "number" and type(s) == "number" and type(v) == "number"
        end },
        { "Color3:ToHex returns string",       function() return type(Color3.fromRGB(255, 0, 0):ToHex()) == "string" end },
        { "Color3:ToHex correct value",        function() return Color3.fromRGB(255, 0, 0):ToHex() == "ff0000" end },
        { "Color3:ToHex and fromHex roundtrip",function()
            local c = Color3.fromRGB(236, 0, 140)
            return Color3.fromHex(c:ToHex()).R == c.R
        end },
        { "Color3:Lerp correct",               function() return math.abs(Color3.new(0, 0, 0):Lerp(Color3.new(1, 0, 0), 0.5).R - 0.5) < 0.001 end },
    })

    runGroup("UDim and UDim2", {
        { "UDim.Scale and Offset correct",    function() local u = UDim.new(0.5, 10); return u.Scale == 0.5 and u.Offset == 10 end },
        { "UDim + UDim correct",              function() local u = UDim.new(0.5, 10) + UDim.new(0.5, 10); return u.Scale == 1 and u.Offset == 20 end },
        { "UDim - UDim correct",              function() local u = UDim.new(1, 20) - UDim.new(0.5, 10); return u.Scale == 0.5 and u.Offset == 10 end },
        { "UDim2.X.Scale and Y.Offset correct", function() local u = UDim2.new(0.5, 10, 0.2, 5); return u.X.Scale == 0.5 and u.Y.Offset == 5 end },
        { "UDim2.Width equals X",             function() local u = UDim2.new(0.5, 10, 0.2, 5); return u.Width.Scale == u.X.Scale and u.Width.Offset == u.X.Offset end },
        { "UDim2.Height equals Y",            function() local u = UDim2.new(0.5, 10, 0.2, 5); return u.Height.Scale == u.Y.Scale and u.Height.Offset == u.Y.Offset end },
        { "UDim2.fromScale correct",          function() local u = UDim2.fromScale(0.5, 0.5); return u.X.Scale == 0.5 and u.X.Offset == 0 end },
        { "UDim2.fromOffset correct",         function() local u = UDim2.fromOffset(100, 200); return u.X.Offset == 100 and u.Y.Offset == 200 end },
        { "UDim2 + UDim2 correct",            function() local u = UDim2.new(0.5, 10, 0.5, 10) + UDim2.new(0.5, 10, 0.5, 10); return u.X.Scale == 1 and u.X.Offset == 20 end },
        { "UDim2.new from UDim objects correct", function() local u = UDim2.new(UDim.new(0.5, 10), UDim.new(0.2, 5)); return u.X.Scale == 0.5 and u.Y.Offset == 5 end },
        { "UDim2 - UDim2 correct",            function() local u = UDim2.new(1, 20, 1, 20) - UDim2.new(0.5, 10, 0.5, 10); return u.X.Scale == 0.5 and u.X.Offset == 10 end },
        { "UDim2:Lerp correct",               function() return UDim2.new(0, 0, 0, 0):Lerp(UDim2.new(1, 0, 0, 0), 0.5).X.Scale == 0.5 end },
        { "UDim2 tostring format correct",    function() return tostring(UDim2.new(0.5, 10, 0.2, 5)) == "{0.5, 10}, {0.200000003, 5}" end },
    })

    runGroup("BrickColor", {
        { "BrickColor.new by name correct",   function() return BrickColor.new("Bright red").Name == "Bright red" end },
        { "BrickColor.new by number correct", function() return BrickColor.new(21).Number == 21 end },
        { "BrickColor.new by RGB correct",    function() return typeof(BrickColor.new(1, 0, 0)) == "BrickColor" end },
        { "BrickColor.new by Color3 correct", function() return typeof(BrickColor.new(Color3.new(1, 0, 0))) == "BrickColor" end },
        { "BrickColor.Color is Color3",       function() return typeof(BrickColor.new("Bright red").Color) == "Color3" end },
        { "BrickColor.r g b are numbers",     function()
            local bc = BrickColor.new("Bright red")
            return type(bc.r) == "number" and type(bc.g) == "number" and type(bc.b) == "number"
        end },
        { "BrickColor.random returns BrickColor", function() return typeof(BrickColor.random()) == "BrickColor" end },
        { "BrickColor.palette returns BrickColor", function() return typeof(BrickColor.palette(0)) == "BrickColor" end },
        { "BrickColor.White correct",         function() return BrickColor.White().Name == "White" end },
        { "BrickColor.Gray correct",          function() return BrickColor.Gray().Name == "Medium stone grey" end },
        { "BrickColor.DarkGray correct",      function() return BrickColor.DarkGray().Name == "Dark stone grey" end },
        { "BrickColor.Black correct",         function() return BrickColor.Black().Name == "Black" end },
        { "BrickColor.Red correct",           function() return BrickColor.Red().Name == "Bright red" end },
        { "BrickColor.Yellow correct",        function() return BrickColor.Yellow().Name == "Bright yellow" end },
        { "BrickColor.Green correct",         function() return BrickColor.Green().Name == "Dark green" end },
        { "BrickColor.Blue correct",          function() return BrickColor.Blue().Name == "Bright blue" end },
    })

    runGroup("TweenInfo", {
        { "TweenInfo.Time correct",                       function() return TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0).Time == 1.5 end },
        { "TweenInfo.EasingStyle correct",                function() return TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0).EasingStyle == Enum.EasingStyle.Quad end },
        { "TweenInfo.EasingDirection correct",            function() return TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0).EasingDirection == Enum.EasingDirection.InOut end },
        { "TweenInfo.DelayTime correct",                  function() return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.5).DelayTime == 0.5 end },
        { "TweenInfo.RepeatCount correct",                function() return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 3, false, 0).RepeatCount == 3 end },
        { "TweenInfo.RepeatCount indefinite correct",     function() return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0).RepeatCount == -1 end },
        { "TweenInfo.Reverses correct",                   function() return TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true).Reverses == true end },
        { "TweenInfo default EasingDirection is Out",     function() return TweenInfo.new(1).EasingDirection == Enum.EasingDirection.Out end },
        { "TweenInfo default EasingStyle is Quad",        function() return TweenInfo.new(1).EasingStyle == Enum.EasingStyle.Quad end },
        { "TweenInfo default RepeatCount is 0",           function() return TweenInfo.new(1).RepeatCount == 0 end },
        { "TweenInfo default Reverses is false",          function() return TweenInfo.new(1).Reverses == false end },
        { "TweenInfo default DelayTime is 0",             function() return TweenInfo.new(1).DelayTime == 0 end },
        { "TweenInfo default Time is 1",                  function() return TweenInfo.new(1).Time == 1 end },
    })

    runGroup("NumberRange, NumberSequence, ColorSequence", {
        { "NumberRange.Min and Max correct",           function() local r = NumberRange.new(1, 5); return r.Min == 1 and r.Max == 5 end },
        { "NumberRange single value Min==Max",         function() local r = NumberRange.new(3); return r.Min == 3 and r.Max == 3 end },
        { "NumberRange min must be <= max errors",     function() return not pcall(function() NumberRange.new(5, 1) end) end },
        { "NumberSequence single value constructor correct", function()
            local s = NumberSequence.new(0.5)
            return s.Keypoints[1].Value == 0.5 and s.Keypoints[2].Value == 0.5
        end },
        { "NumberSequence keypoints correct",          function()
            local s = NumberSequence.new(0, 1)
            return s.Keypoints[1].Value == 0 and s.Keypoints[2].Value == 1
        end },
        { "NumberSequence from keypoints correct",     function()
            return #NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }).Keypoints == 2
        end },
        { "NumberSequence from 3 keypoints correct",   function()
            return #NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0.5),
                NumberSequenceKeypoint.new(1, 1),
            }).Keypoints == 3
        end },
        { "NumberSequenceKeypoint.Time correct",       function() return NumberSequenceKeypoint.new(0.5, 1).Time == 0.5 end },
        { "NumberSequenceKeypoint.Value correct",      function() return NumberSequenceKeypoint.new(0.5, 1).Value == 1 end },
        { "NumberSequenceKeypoint.Envelope correct",   function() return NumberSequenceKeypoint.new(0.5, 1, 0.25).Envelope == 0.25 end },
        { "ColorSequence single color constructor correct", function()
            local s = ColorSequence.new(Color3.new(1, 0, 0))
            return s.Keypoints[1].Value.R == 1 and s.Keypoints[2].Value.R == 1
        end },
        { "ColorSequence first keypoint R correct",    function()
            return ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)).Keypoints[1].Value.R == 1
        end },
        { "ColorSequence last keypoint B correct",     function()
            return ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)).Keypoints[2].Value.B == 1
        end },
        { "ColorSequence from 3 keypoints correct",    function()
            return #ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1)),
            }).Keypoints == 3
        end },
        { "ColorSequenceKeypoint.Time and Value correct", function()
            local k = ColorSequenceKeypoint.new(0.5, Color3.new(1, 0, 0))
            return k.Time == 0.5 and k.Value.R == 1
        end },
    })

    runGroup("Ray and RaycastParams and OverlapParams", {
        { "Ray.Origin correct",              function() return Ray.new(Vector3.new(0, 10, 0), Vector3.new(0, -1, 0)).Origin.Y == 10 end },
        { "Ray.Direction correct",           function() return Ray.new(Vector3.new(0, 10, 0), Vector3.new(0, -1, 0)).Direction.Y == -1 end },
        { "Ray:ClosestPoint returns Vector3",function()
            return typeof(Ray.new(Vector3.new(0, 10, 0), Vector3.new(0, -1, 0)):ClosestPoint(Vector3.new(0, 1, 0))) == "Vector3"
        end },
        { "RaycastParams.FilterType writable", function()
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Include
            return rp.FilterType == Enum.RaycastFilterType.Include
        end },
        { "OverlapParams.FilterType writable", function()
            local op = OverlapParams.new()
            op.FilterType = Enum.RaycastFilterType.Exclude
            return op.FilterType == Enum.RaycastFilterType.Exclude
        end },
    })

    runGroup("Region3", {
        { "Region3.Size correct",             function() return Region3.new(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)).Size.X == 2 end },
        { "Region3.CFrame.Position correct",  function() return Region3.new(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)).CFrame.Position.X == 1 end },
        { "Region3:ExpandToGrid returns Region3", function()
            return typeof(Region3.new(Vector3.new(0, 0, 0), Vector3.new(2, 2, 2)):ExpandToGrid(4)) == "Region3"
        end },
    })

    runGroup("Random", {
        { "Random:NextInteger in range",             function() local v = Random.new():NextInteger(1, 10); return v >= 1 and v <= 10 end },
        { "Random:NextNumber in range",              function() local v = Random.new():NextNumber(0, 1); return v >= 0 and v <= 1 end },
        { "Random seeded result deterministic",      function() return Random.new(12345):NextInteger(1, 100) == 91 end },
        { "Random:NextUnitVector returns Vector3",   function() return typeof(Random.new():NextUnitVector()) == "Vector3" end },
        { "Random.new errors on non-number seed",    function() return not pcall(function() Random.new("nuh uh") end) end },
    })

    runGroup("FloatCurveKey", {
        { "FloatCurveKey.new returns correct type",   function() return typeof(FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant)) == "FloatCurveKey" end },
        { "FloatCurveKey.Time correct",               function() return FloatCurveKey.new(0.5, 1, Enum.KeyInterpolationMode.Constant).Time == 0.5 end },
        { "FloatCurveKey.Value correct",              function() return FloatCurveKey.new(0, 42, Enum.KeyInterpolationMode.Constant).Value == 42 end },
        { "FloatCurveKey.Interpolation is EnumItem",  function() return typeof(FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Constant).Interpolation) == "EnumItem" end },
        { "FloatCurveKey.Interpolation correct",      function() return FloatCurveKey.new(0, 1, Enum.KeyInterpolationMode.Cubic).Interpolation == Enum.KeyInterpolationMode.Cubic end },
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Catalog, C-function purity, misc constructors
-- ──────────────────────────────────────────────────────────────────────────────

do
    runGroup("CatalogSearchParams", {
        { "CatalogSearchParams.new returns correct type",     function() return typeof(CatalogSearchParams.new()) == "CatalogSearchParams" end },
        { "CatalogSearchParams.SearchKeyword is string",      function() return type(CatalogSearchParams.new().SearchKeyword) == "string" end },
        { "CatalogSearchParams.SearchKeyword writable",       function()
            local c = CatalogSearchParams.new()
            c.SearchKeyword = "test"
            return c.SearchKeyword == "test"
        end },
        { "CatalogSearchParams.MinPrice is number",           function() return type(CatalogSearchParams.new().MinPrice) == "number" end },
        { "CatalogSearchParams.MinPrice writable",            function()
            local c = CatalogSearchParams.new(); c.MinPrice = 100; return c.MinPrice == 100
        end },
        { "CatalogSearchParams.MaxPrice is number",           function() return type(CatalogSearchParams.new().MaxPrice) == "number" end },
        { "CatalogSearchParams.MaxPrice writable",            function()
            local c = CatalogSearchParams.new(); c.MaxPrice = 1000; return c.MaxPrice == 1000
        end },
        { "CatalogSearchParams.SortType is EnumItem",         function() return typeof(CatalogSearchParams.new().SortType) == "EnumItem" end },
        { "CatalogSearchParams.SortAggregation is EnumItem",  function() return typeof(CatalogSearchParams.new().SortAggregation) == "EnumItem" end },
        { "CatalogSearchParams.CategoryFilter is EnumItem",   function() return typeof(CatalogSearchParams.new().CategoryFilter) == "EnumItem" end },
        { "CatalogSearchParams.SalesTypeFilter is EnumItem",  function() return typeof(CatalogSearchParams.new().SalesTypeFilter) == "EnumItem" end },
        { "CatalogSearchParams.IncludeOffSale is boolean",    function() return type(CatalogSearchParams.new().IncludeOffSale) == "boolean" end },
        { "CatalogSearchParams.IncludeOffSale writable",      function()
            local c = CatalogSearchParams.new(); c.IncludeOffSale = true; return c.IncludeOffSale == true
        end },
        { "CatalogSearchParams.CreatorName is string",        function() return type(CatalogSearchParams.new().CreatorName) == "string" end },
        { "CatalogSearchParams.CreatorId is number",          function() return type(CatalogSearchParams.new().CreatorId) == "number" end },
        { "CatalogSearchParams.Limit is number",              function() return type(CatalogSearchParams.new().Limit) == "number" end },
        { "CatalogSearchParams.BundleTypes is table",         function() return type(CatalogSearchParams.new().BundleTypes) == "table" end },
        { "CatalogSearchParams.AssetTypes is table",          function() return type(CatalogSearchParams.new().AssetTypes) == "table" end },
        { "CatalogSearchParams.BundleTypes writable",         function()
            local c = CatalogSearchParams.new()
            c.BundleTypes = { Enum.BundleType.Animations }
            return type(c.BundleTypes) == "table"
        end },
        { "CatalogSearchParams.BundleTypes read-only after access", function()
            local c = CatalogSearchParams.new()
            c.BundleTypes = { Enum.BundleType.Animations }
            local b = c.BundleTypes
            return not pcall(function() table.insert(b, Enum.BundleType.BodyParts) end)
        end },
    })

    runGroup("Core functions [C]", {
        { "math.abs is C function",       function() return debug.info(math.abs, "s") == "[C]" and debug.info(math.abs, "l") == -1 end },
        { "math.abs logic correct",       function() return math.abs(-10) == 10 and math.abs(10) == 10 end },
        { "math.abs errors on string",    function()
            local ok, err = pcall(math.abs, "fail")
            return not ok and err:find("number expected") ~= nil
        end },
        { "math.random is C function",    function() return debug.info(math.random, "s") == "[C]" and debug.info(math.random, "l") == -1 end },
        { "math.random logic correct",    function() local v = math.random(1, 10); return v >= 1 and v <= 10 and v % 1 == 0 end },
        { "math.random errors on empty interval", function()
            local ok, err = pcall(math.random, 10, 1)
            return not ok and err:find("interval is empty") ~= nil
        end },
        { "math.clamp is C function",     function() return debug.info(math.clamp, "s") == "[C]" and debug.info(math.clamp, "l") == -1 end },
        { "math.clamp logic correct",     function() return math.clamp(10, 1, 5) == 5 and math.clamp(-5, 1, 5) == 1 end },
        { "math.floor is C function",     function() return debug.info(math.floor, "s") == "[C]" and debug.info(math.floor, "l") == -1 end },
        { "math.floor logic correct",     function() return math.floor(5.9) == 5 and math.floor(-5.1) == -6 end },
        { "math.sign is C function",      function() return debug.info(math.sign, "s") == "[C]" and debug.info(math.sign, "l") == -1 end },
        { "math.sign logic correct",      function() return math.sign(10) == 1 and math.sign(-10) == -1 and math.sign(0) == 0 end },
        { "math.rad is C function",       function() return debug.info(math.rad, "s") == "[C]" and debug.info(math.rad, "l") == -1 end },
        { "math.rad logic correct",       function() return math.abs(math.rad(180) - 3.14159) < 0.001 end },
        { "math.deg is C function",       function() return debug.info(math.deg, "s") == "[C]" and debug.info(math.deg, "l") == -1 end },
        { "math.deg logic correct",       function() return math.abs(math.deg(math.pi) - 180) < 0.001 end },
        { "table.insert is C function",   function() return debug.info(table.insert, "s") == "[C]" and debug.info(table.insert, "l") == -1 end },
        { "table.insert logic correct",   function() local t = {}; table.insert(t, "a"); return t[1] == "a" end },
        { "table.insert errors on non-table", function()
            local ok, err = pcall(table.insert, "not a table", "val")
            return not ok and err:find("table expected") ~= nil
        end },
        { "table.find is C function",     function() return debug.info(table.find, "s") == "[C]" and debug.info(table.find, "l") == -1 end },
        { "table.find logic correct",     function()
            local t = { "a", "b", "c" }
            return table.find(t, "b") == 2 and table.find(t, "missing") == nil
        end },
        { "table.concat is C function",   function() return debug.info(table.concat, "s") == "[C]" and debug.info(table.concat, "l") == -1 end },
        { "table.concat logic correct",   function() return table.concat({ "a", "b" }, "-") == "a-b" end },
        { "table.remove is C function",   function() return debug.info(table.remove, "s") == "[C]" and debug.info(table.remove, "l") == -1 end },
        { "table.remove logic correct",   function()
            local t = { 10, 20, 30 }
            return table.remove(t, 2) == 20 and #t == 2 and t[2] == 30
        end },
        { "table.sort is C function",     function() return debug.info(table.sort, "s") == "[C]" and debug.info(table.sort, "l") == -1 end },
        { "table.sort logic correct",     function()
            local t = { 1, 5, 2 }
            table.sort(t, function(a, b) return b < a end)
            return t[1] == 5 and t[3] == 1
        end },
        { "tostring is C function",       function() return debug.info(tostring, "s") == "[C]" and debug.info(tostring, "l") == -1 end },
        { "tostring logic correct",       function() return tostring(123) == "123" end },
        { "tonumber is C function",       function() return debug.info(tonumber, "s") == "[C]" and debug.info(tonumber, "l") == -1 end },
        { "tonumber logic correct",       function() return tonumber("10") == 10 and tonumber("0xFF") == 255 end },
        { "tonumber errors on bad base",  function()
            local ok, err = pcall(tonumber, "10", 999)
            return not ok and err:find("base out of range") ~= nil
        end },
        { "string.len is C function",     function() return debug.info(string.len, "s") == "[C]" and debug.info(string.len, "l") == -1 end },
        { "string.len logic correct",     function() return string.len("hello") == 5 end },
        { "pairs is C function",          function() return debug.info(pairs, "s") == "[C]" and debug.info(pairs, "l") == -1 end },
        { "pairs logic correct",          function()
            local t = { x = 1 }
            local iter, state, init = pairs(t)
            local k, v = iter(state, init)
            return k == "x" and v == 1 and state == t and init == nil
        end },
        { "ipairs is C function",         function() return debug.info(ipairs, "s") == "[C]" and debug.info(ipairs, "l") == -1 end },
        { "ipairs logic correct",         function()
            local t = { 10, 20 }
            local iter, state, init = ipairs(t)
            local k, v = iter(state, init)
            return v == 10 and k == 1 and init == 0 and state == t
        end },
        { "next is C function",           function() return debug.info(next, "s") == "[C]" and debug.info(next, "l") == -1 end },
        { "next logic correct",           function()
            local t = { a = 10 }
            return next(t, nil) == "a" and next(t, "a") == nil
        end },
        { "type is C function",           function() return debug.info(type, "s") == "[C]" and debug.info(type, "l") == -1 end },
        { "type logic correct",           function() return type(1) == "number" and type("s") == "string" and type({}) == "table" end },
        { "typeof is C function",         function() return debug.info(typeof, "s") == "[C]" and debug.info(typeof, "l") == -1 end },
        { "typeof logic correct",         function() return typeof(Vector3.new()) == "Vector3" and typeof(CFrame.new()) == "CFrame" end },
        { "select is C function",         function() return debug.info(select, "s") == "[C]" and debug.info(select, "l") == -1 end },
        { "select logic correct",         function() return select("#", 1, 2, 3) == 3 and select(2, "a", "b", "c") == "b" end },
        { "unpack is C function",         function() return debug.info(unpack, "s") == "[C]" and debug.info(unpack, "l") == -1 end },
        { "unpack logic correct",         function() local a, b = unpack({ 10, 20 }); return a == 10 and b == 20 end },
        { "task.wait is C function",      function() return debug.info(task.wait, "s") == "[C]" and debug.info(task.wait, "l") == -1 end },
        { "task.wait timing correct",     function()
            local start = os.clock()
            task.wait(0.05)
            return os.clock() - start >= 0.04
        end },
        { "task.spawn is C function",     function() return debug.info(task.spawn, "s") == "[C]" and debug.info(task.spawn, "l") == -1 end },
        { "os.clock is C function",       function() return debug.info(os.clock, "s") == "[C]" and debug.info(os.clock, "l") == -1 end },
        { "os.clock logic correct",       function()
            local a, b = os.clock(), os.clock()
            return type(a) == "number" and a <= b
        end },
        { "os.time is C function",        function() return debug.info(os.time, "s") == "[C]" and debug.info(os.time, "l") == -1 end },
        { "os.time logic correct",        function() return type(os.time()) == "number" end },
        { "coroutine.create is C function",function() return debug.info(coroutine.create, "s") == "[C]" and debug.info(coroutine.create, "l") == -1 end },
        { "coroutine.wrap is C function", function() return debug.info(coroutine.wrap, "s") == "[C]" and debug.info(coroutine.wrap, "l") == -1 end },
        { "coroutine.wrap logic correct", function() return coroutine.wrap(function(x) return x * 2 end)(10) == 20 end },
        { "bit32.bxor is C function",     function() return debug.info(bit32.bxor, "s") == "[C]" and debug.info(bit32.bxor, "l") == -1 end },
        { "bit32.band is C function",     function() return debug.info(bit32.band, "s") == "[C]" and debug.info(bit32.band, "l") == -1 end },
        { "bit32.band logic correct",     function() return bit32.band(240, 204) == 192 end },
        { "bit32.rrotate is C function",  function() return debug.info(bit32.rrotate, "s") == "[C]" and debug.info(bit32.rrotate, "l") == -1 end },
        { "bit32.rrotate logic correct",  function() return bit32.rrotate(8, 1) == 4 end },
        { "utf8.char is C function",      function() return debug.info(utf8.char, "s") == "[C]" and debug.info(utf8.char, "l") == -1 end },
        { "utf8.char logic correct",      function() return utf8.char(97, 98, 99) == "abc" end },
        { "utf8.char errors out of range",function()
            local ok, err = pcall(utf8.char, -1)
            return not ok and err:find("out of range") ~= nil
        end },
        { "Random.new is C function",     function() return debug.info(Random.new, "s") == "[C]" and debug.info(Random.new, "l") == -1 end },
        { "setmetatable is C function",   function() return debug.info(setmetatable, "s") == "[C]" and debug.info(setmetatable, "l") == -1 end },
        { "vector.cross is C function",   function() return debug.info(vector.cross, "s") == "[C]" and debug.info(vector.cross, "l") == -1 end },
        { "vector.cross logic correct",   function() return vector.cross(vector.create(1, 0, 0), vector.create(0, 1, 0)).Z == 1 end },
        { "vector.magnitude is C function",function() return debug.info(vector.magnitude, "s") == "[C]" and debug.info(vector.magnitude, "l") == -1 end },
        { "vector.magnitude logic correct",function()
            return math.abs(vector.magnitude(vector.create(1, 1, 1)) - 1.73205) < 0.0001
        end },
        { "CFrame.lookAt is C function",  function() return debug.info(CFrame.lookAt, "s") == "[C]" and debug.info(CFrame.lookAt, "l") == -1 end },
        { "CFrame.lookAt logic correct",  function()
            return math.abs(CFrame.lookAt(Vector3.new(0, 10, 0), Vector3.new(0, 20, 0)).LookVector.Y - 1) < 0.0001
        end },
        { "TweenService:Create is C function", function()
            return debug.info(game:GetService("TweenService").Create, "s") == "[C]" and debug.info(game:GetService("TweenService").Create, "l") == -1
        end },
        { "PhysicalProperties.new is C function", function()
            return debug.info(PhysicalProperties.new, "s") == "[C]" and debug.info(PhysicalProperties.new, "l") == -1
        end },
    })

    runGroup("Faces", {
        { "Faces.new returns correct type",            function() return typeof(Faces.new(Enum.NormalId.Top)) == "Faces" end },
        { "Faces.new empty returns correct type",      function() return typeof(Faces.new()) == "Faces" end },
        { "Faces.Top is boolean",                      function() return type(Faces.new(Enum.NormalId.Top).Top) == "boolean" end },
        { "Faces.Top true when set",                   function() return Faces.new(Enum.NormalId.Top).Top == true end },
        { "Faces.Top false when not set",              function() return Faces.new(Enum.NormalId.Bottom).Top == false end },
        { "Faces.Bottom is boolean",                   function() return type(Faces.new(Enum.NormalId.Bottom).Bottom) == "boolean" end },
        { "Faces.Bottom true when set",                function() return Faces.new(Enum.NormalId.Bottom).Bottom == true end },
        { "Faces.Left is boolean",                     function() return type(Faces.new(Enum.NormalId.Left).Left) == "boolean" end },
        { "Faces.Left true when set",                  function() return Faces.new(Enum.NormalId.Left).Left == true end },
        { "Faces.Right is boolean",                    function() return type(Faces.new(Enum.NormalId.Right).Right) == "boolean" end },
        { "Faces.Right true when set",                 function() return Faces.new(Enum.NormalId.Right).Right == true end },
        { "Faces.Back is boolean",                     function() return type(Faces.new(Enum.NormalId.Back).Back) == "boolean" end },
        { "Faces.Back true when set",                  function() return Faces.new(Enum.NormalId.Back).Back == true end },
        { "Faces.Front is boolean",                    function() return type(Faces.new(Enum.NormalId.Front).Front) == "boolean" end },
        { "Faces.Front true when set",                 function() return Faces.new(Enum.NormalId.Front).Front == true end },
        { "Faces multiple NormalIds correct",          function()
            local f = Faces.new(Enum.NormalId.Front, Enum.NormalId.Left)
            return f.Front == true and f.Left == true and f.Top == false
        end },
        { "Faces invalid args ignored silently",       function() return (pcall(function()
            Faces.new("invalid", 123, true)
        end)) end },
        { "Faces is immutable",                        function()
            local f = Faces.new(Enum.NormalId.Top)
            return not pcall(function() f.Top = false end)
        end },
    })

    runGroup("Secret", {
        { "HttpService:GetSecret exists", function() return type(game:GetService("HttpService").GetSecret) == "function" end },
        { "Secret:AddPrefix exists", function()
            local ok, secret = pcall(function() return game:GetService("HttpService"):GetSecret("eunc_test") end)
            if ok then return type(secret.AddPrefix) == "function" end
            return true
        end },
        { "Secret:AddSuffix exists", function()
            local ok, secret = pcall(function() return game:GetService("HttpService"):GetSecret("eunc_test") end)
            if ok then return type(secret.AddSuffix) == "function" end
            return true
        end },
    })

    runGroup("PhysicalProperties", {
        { "PhysicalProperties.Density correct",       function() return math.abs(PhysicalProperties.new(0.5, 0.3, 0.1).Density - 0.5) < 0.001 end },
        { "PhysicalProperties.Friction correct",      function() return math.abs(PhysicalProperties.new(0.5, 0.3, 0.1).Friction - 0.3) < 0.001 end },
        { "PhysicalProperties from Material Density is number",
            function() return type(PhysicalProperties.new(Enum.Material.Wood).Density) == "number" end },
    })

    runGroup("Font", {
        { "Font.new returns Font",     function() return typeof(Font.new("rbxasset://fonts/families/SourceSansPro.json")) == "Font" end },
        { "Font.Weight correct",       function()
            return Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal).Weight == Enum.FontWeight.Bold
        end },
    })

    runGroup("Axes", {
        { "Axes.new returns correct type",        function() return typeof(Axes.new(Enum.Axis.X)) == "Axes" end },
        { "Axes.X is boolean",                    function() return type(Axes.new(Enum.Axis.X).X) == "boolean" end },
        { "Axes.Y is boolean",                    function() return type(Axes.new(Enum.Axis.Y).Y) == "boolean" end },
        { "Axes.Z is boolean",                    function() return type(Axes.new(Enum.Axis.Z).Z) == "boolean" end },
        { "Axes.X true when X axis set",          function() return Axes.new(Enum.Axis.X).X == true end },
        { "Axes.Y false when only X set",         function() return Axes.new(Enum.Axis.X).Y == false end },
        { "Axes.Top is boolean",                  function() return type(Axes.new(Enum.NormalId.Top).Top) == "boolean" end },
        { "Axes.Bottom is boolean",               function() return type(Axes.new(Enum.NormalId.Bottom).Bottom) == "boolean" end },
        { "Axes.Left is boolean",                 function() return type(Axes.new(Enum.NormalId.Left).Left) == "boolean" end },
        { "Axes.Right is boolean",                function() return type(Axes.new(Enum.NormalId.Right).Right) == "boolean" end },
        { "Axes.Back is boolean",                 function() return type(Axes.new(Enum.NormalId.Back).Back) == "boolean" end },
        { "Axes.Front is boolean",                function() return type(Axes.new(Enum.NormalId.Front).Front) == "boolean" end },
        { "Axes NormalId converted to axis",      function() return Axes.new(Enum.NormalId.Top).Y == true end },
    })

    runGroup("PathWaypoint", {
        { "PathWaypoint.new returns correct type", function() return typeof(PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk)) == "PathWaypoint" end },
        { "PathWaypoint.Position is Vector3",      function() return typeof(PathWaypoint.new(Vector3.new(10, 10, 10), Enum.PathWaypointAction.Walk).Position) == "Vector3" end },
        { "PathWaypoint.Position correct",         function() return PathWaypoint.new(Vector3.new(10, 10, 10), Enum.PathWaypointAction.Walk).Position == Vector3.new(10, 10, 10) end },
        { "PathWaypoint.Action is EnumItem",       function() return typeof(PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk).Action) == "EnumItem" end },
        { "PathWaypoint.Action correct",           function() return PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Jump).Action == Enum.PathWaypointAction.Jump end },
        { "PathWaypoint.Label is string",          function() return type(PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk, "TestLabel").Label) == "string" end },
        { "PathWaypoint.Label correct",            function() return PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk, "TestLabel").Label == "TestLabel" end },
        { "PathWaypoint.Label default is empty string", function() return PathWaypoint.new(Vector3.new(0, 0, 0), Enum.PathWaypointAction.Walk).Label == "" end },
    })

    runGroup("RBXScriptConnection", {
        { "RBXScriptConnection.Connected is true after connect", function()
            local c = game:GetService("RunService").Heartbeat:Connect(function() end)
            local v = c.Connected == true
            c:Disconnect()
            return v
        end },
        { "RBXScriptConnection.Connected is false after disconnect", function()
            local c = game:GetService("RunService").Heartbeat:Connect(function() end)
            c:Disconnect()
            return c.Connected == false
        end },
        { "RBXScriptConnection:Disconnect works", function()
            game:GetService("RunService").Heartbeat:Connect(function() end):Disconnect()
            return true
        end },
    })

    runGroup("RBXScriptSignal", {
        { "RBXScriptSignal:Connect returns RBXScriptConnection", function()
            local c = game:GetService("RunService").Heartbeat:Connect(function() end)
            local v = typeof(c) == "RBXScriptConnection"
            c:Disconnect()
            return v
        end },
        { "RBXScriptSignal:Once returns RBXScriptConnection", function()
            local c = game:GetService("RunService").Heartbeat:Once(function() end)
            local v = typeof(c) == "RBXScriptConnection"
            c:Disconnect()
            return v
        end },
        { "RBXScriptSignal:Once fires only once", function()
            local n = 0
            game:GetService("RunService").Heartbeat:Once(function() n = n + 1 end)
            task.wait()
            task.wait()
            return n == 1
        end },
        { "RBXScriptSignal:Wait returns value", function()
            return type(game:GetService("RunService").Heartbeat:Wait()) == "number"
        end },
    })

    runGroup("Rect", {
        { "Rect.new empty returns correct type", function() return typeof(Rect.new()) == "Rect" end },
        { "Rect.new from Vector2 correct",       function() local r = Rect.new(Vector2.new(10, 10), Vector2.new(80, 80)); return r.Min.X == 10 and r.Max.X == 80 end },
        { "Rect.new from numbers correct",       function() local r = Rect.new(10, 10, 80, 80); return r.Min.X == 10 and r.Max.Y == 80 end },
        { "Rect.Width correct",                  function() return Rect.new(10, 10, 80, 80).Width == 70 end },
        { "Rect.Height correct",                 function() return Rect.new(10, 10, 80, 80).Height == 70 end },
        { "Rect.Min is Vector2",                 function() return typeof(Rect.new(10, 10, 80, 80).Min) == "Vector2" end },
        { "Rect.Max is Vector2",                 function() return typeof(Rect.new(10, 10, 80, 80).Max) == "Vector2" end },
    })

    runGroup("Region3int16", {
        { "Region3int16.new returns correct type", function()
            return typeof(Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(4, 4, 4))) == "Region3int16"
        end },
        { "Region3int16.Min is Vector3int16",      function() return typeof(Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(4, 4, 4)).Min) == "Vector3int16" end },
        { "Region3int16.Max is Vector3int16",      function() return typeof(Region3int16.new(Vector3int16.new(0, 0, 0), Vector3int16.new(4, 4, 4)).Max) == "Vector3int16" end },
        { "Region3int16.Min correct",              function()
            local r = Region3int16.new(Vector3int16.new(1, 2, 3), Vector3int16.new(4, 5, 6))
            return r.Min.X == 1 and r.Min.Y == 2 and r.Min.Z == 3
        end },
        { "Region3int16.Max correct",              function()
            local r = Region3int16.new(Vector3int16.new(1, 2, 3), Vector3int16.new(4, 5, 6))
            return r.Max.X == 4 and r.Max.Y == 5 and r.Max.Z == 6
        end },
    })

    runGroup("RotationCurveKey", {
        { "RotationCurveKey.new returns correct type", function() return typeof(RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant)) == "RotationCurveKey" end },
        { "RotationCurveKey.Time correct",             function() return RotationCurveKey.new(0.5, CFrame.new(), Enum.KeyInterpolationMode.Constant).Time == 0.5 end },
        { "RotationCurveKey.Value is CFrame",          function() return typeof(RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant).Value) == "CFrame" end },
        { "RotationCurveKey.Interpolation is EnumItem",function() return typeof(RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant).Interpolation) == "EnumItem" end },
        { "RotationCurveKey.Interpolation correct",    function() return RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Cubic).Interpolation == Enum.KeyInterpolationMode.Cubic end },
        { "RotationCurveKey.LeftTangent is number",    function() return type(RotationCurveKey.new(0, CFrame.new(), Enum.KeyInterpolationMode.Constant).LeftTangent) == "number" end },
    })

    runGroup("SecurityCapabilities", {
        { "SecurityCapabilities.new returns correct type",     function() return typeof(SecurityCapabilities.new()) == "SecurityCapabilities" end },
        { "SecurityCapabilities.new with items correct",       function() return typeof(SecurityCapabilities.new(Enum.SecurityCapability.Basic)) == "SecurityCapabilities" end },
        { "SecurityCapabilities.fromCurrent returns correct type", function() return typeof(SecurityCapabilities.fromCurrent()) == "SecurityCapabilities" end },
        { "SecurityCapabilities:Add returns SecurityCapabilities", function() return typeof(SecurityCapabilities.new():Add(Enum.SecurityCapability.Basic)) == "SecurityCapabilities" end },
        { "SecurityCapabilities:Remove returns SecurityCapabilities", function()
            return typeof(SecurityCapabilities.new(Enum.SecurityCapability.Basic):Remove(Enum.SecurityCapability.Basic)) == "SecurityCapabilities"
        end },
        { "SecurityCapabilities:Contains returns boolean",      function() return type(SecurityCapabilities.new(Enum.SecurityCapability.Basic):Contains(Enum.SecurityCapability.Basic)) == "boolean" end },
        { "SecurityCapabilities:Contains true when present",   function() return SecurityCapabilities.new(Enum.SecurityCapability.Basic):Contains(Enum.SecurityCapability.Basic) == true end },
        { "SecurityCapabilities:Contains false when not present", function() return SecurityCapabilities.new():Contains(Enum.SecurityCapability.Basic) == false end },
        { "SecurityCapabilities:Add does not duplicate",       function()
            return SecurityCapabilities.new(Enum.SecurityCapability.Basic):Add(Enum.SecurityCapability.Basic):Contains(Enum.SecurityCapability.Basic) == true
        end },
    })

    runGroup("eDateTimes", {
        { "DateTime.now returns DateTime",                function() return typeof(DateTime.now()) == "DateTime" end },
        { "DateTime.fromUnixTimestamp returns DateTime",  function() return typeof(DateTime.fromUnixTimestamp(0)) == "DateTime" end },
        { "DateTime.fromIsoDate returns DateTime",        function() return typeof(DateTime.fromIsoDate("2024-01-01T00:00:00Z")) == "DateTime" end },
        { "DateTime:ToIsoDate returns string",            function()
            local ok, s = pcall(function() return DateTime.now():ToIsoDate() end)
            return ok and type(s) == "string"
        end },
        { "DateTime:ToLocalTime Year is number",          function()
            local ok, t = pcall(function() return DateTime.now():ToLocalTime() end)
            if ok then ok = type(t.Year) == "number" end
            return ok
        end },
        { "DateTime:ToUniversalTime Year is number",      function()
            local ok, t = pcall(function() return DateTime.now():ToUniversalTime() end)
            if ok then ok = type(t.Year) == "number" end
            return ok
        end },
        { "DateTime.UnixTimestampMillis is number",       function() return type(DateTime.now().UnixTimestampMillis) == "number" end },
        { "DateTime.UnixTimestampMillis is positive",     function() return DateTime.now().UnixTimestampMillis > 0 end },
        { "DateTime:FormatUniversalTime epoch is 1970-01-01", function()
            local dt = DateTime.fromUnixTimestamp(0)
            local ok, s = pcall(function() return dt:FormatUniversalTime("YYYY-MM-DD", "en-us") end)
            if ok then
                local parts = string.split(s, "-")
                return #parts == 3 and parts[1] == "1970" and parts[2] == "01" and parts[3] == "01"
            end
            return false
        end },
        { "DateTime pcall overhead is not faked",         function()
            local start = DateTime.now().UnixTimestampMillis
            local sum = 0
            for _ = 1, 25000 do
                local ok, v = pcall(function() return 1 end)
                if ok then sum = sum + v end
            end
            return DateTime.now().UnixTimestampMillis - start <= 15 and sum == 25000
        end },
    })

    runGroup("workspace raycasting", {
        { "workspace:Raycast returns RaycastResult or nil", function()
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
            return r == nil or typeof(r) == "RaycastResult"
        end },
        { "RaycastResult.Position is Vector3", function()
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(0, 0, 0)
            p.Size = Vector3.new(100, 1, 100)
            p.Parent = workspace
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
            p:Destroy()
            return r ~= nil and typeof(r.Position) == "Vector3"
        end },
        { "RaycastResult.Normal is Vector3", function()
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(0, 0, 0)
            p.Size = Vector3.new(100, 1, 100)
            p.Parent = workspace
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
            p:Destroy()
            return r ~= nil and typeof(r.Normal) == "Vector3"
        end },
        { "RaycastResult.Distance is number", function()
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(0, 0, 0)
            p.Size = Vector3.new(100, 1, 100)
            p.Parent = workspace
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
            p:Destroy()
            return r ~= nil and type(r.Distance) == "number"
        end },
        { "RaycastResult.Instance is Instance", function()
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(0, 0, 0)
            p.Size = Vector3.new(100, 1, 100)
            p.Parent = workspace
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
            p:Destroy()
            return r ~= nil and typeof(r.Instance) == "Instance"
        end },
        { "RaycastResult hits correct instance", function()
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(0, 0, 0)
            p.Size = Vector3.new(100, 1, 100)
            p.Parent = workspace
            task.wait(3)
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
            local ok = r ~= nil and p == r.Instance
            p:Destroy()
            return ok
        end },
        { "RaycastParams FilterDescendantsInstances works", function()
            local p = Instance.new("Part")
            p.Anchored = true
            p.Position = Vector3.new(0, 0, 0)
            p.Size = Vector3.new(100, 1, 100)
            p.Parent = workspace
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = { p }
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local r = workspace:Raycast(Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), rp)
            p:Destroy()
            return r == nil or p ~= r.Instance
        end },
    })

    -- Remote loadstring sanity check.
    runTest("loadstring executes code (using an url)", function()
        local captured
        local globalPrint = getfenv(0).print
        getfenv(0).print = function(...)
            captured = tostring(select(1, ...))
        end

        local ok, fn = pcall(function()
            return loadstring(game:HttpGet("https://pastefy.app/r6upMyCZ/raw"))
        end)
        if ok and type(fn) == "function" then
            pcall(fn)
        end
        getfenv(0).print = globalPrint
        assert_(captured == "hi!", "loadstring remote script did not print 'hi!', got: " .. tostring(captured))
    end)

    runTest("loadstring cannot load Luau bytecode", function()
        local ok, animate = pcall(function()
            return game:GetService("Players").LocalPlayer.Character.Animate
        end)
        if ok and animate then
            local ok2, bytecode = pcall(function() return getscriptbytecode(animate) end)
            if ok2 and bytecode then
                local fn = loadstring(bytecode)
                assert_(type(fn) ~= "function", "Luau bytecode should not be loadable via loadstring")
            end
        end
    end)

    runTest("Vector3 components are frozen", function()
        local p = Instance.new("Part")
        assert_(not pcall(function() p.Position.X = 10 end))
    end)

    runTest("Color3 components are frozen", function()
        local c = Color3.new(1, 1, 1)
        assert_(not pcall(function() c.R = 0 end))
    end)

    runTest("rawlen works on string and table", function()
        assert_(rawlen("abc") == 3)
        assert_(rawlen({ 1, 2 }) == 2)
    end)

    runTest("Instance SetAttribute and GetAttribute", function()
        local p = Instance.new("Part")
        p:SetAttribute("T", 123)
        assert_(p:GetAttribute("T") == 123)
    end)

    runTest("CollectionService AddTag and HasTag", function()
        local cs = game:GetService("CollectionService")
        local p = Instance.new("Part")
        cs:AddTag(p, "T")
        assert_(cs:HasTag(p, "T"))
    end)

    runTest("Humanoid.MoveDirection is Vector3", function()
        local h = Instance.new("Humanoid")
        assert_(typeof(h.MoveDirection) == "Vector3")
        h:Destroy()
    end)

    runTest("Camera.FieldOfView is writable", function()
        local cam = workspace.CurrentCamera
        if cam then
            local old = cam.FieldOfView
            cam.FieldOfView = 70
            assert_(cam.FieldOfView == 70)
            cam.FieldOfView = old
        end
    end)

    runGroup("Enum", {
        { "Enum.EasingStyle.Linear is EnumItem",   function() return typeof(Enum.EasingStyle.Linear) == "EnumItem" end },
        { "Enum.PartType is Enum userdata",        function() return typeof(Enum.PartType) == "Enum" and type(Enum.PartType) == "userdata" end },
        { "Enum.PartType is not writable",         function() return not pcall(function() Enum.PartType = "N/A" end) end },
        { "Enum:GetEnumItems returns table",       function() return type(Enum.EasingStyle:GetEnumItems()) == "table" end },
        { "EnumItem.Value is number",              function() return type(Enum.EasingStyle.Linear.Value) == "number" end },
        { "EnumItem.Name is string",               function() return type(Enum.EasingStyle.Linear.Name) == "string" end },
    })

    runGroup("buffer operations", {
        { "buffer.len correct",                    function() return buffer.len(buffer.create(16)) == 16 end },
        { "buffer.writeu8 and readu8 correct",     function()
            local b = buffer.create(4); buffer.writeu8(b, 0, 255); return buffer.readu8(b, 0) == 255
        end },
        { "buffer.writef32 and readf32 correct",   function()
            local b = buffer.create(8); buffer.writef32(b, 4, 3.14)
            return math.abs(buffer.readf32(b, 4) - 3.14) < 0.001
        end },
        { "buffer.fill correct",                   function()
            local b = buffer.create(16); buffer.fill(b, 8, 171, 4)
            return buffer.readu8(b, 8) == 171 and buffer.readu8(b, 11) == 171
        end },
        { "buffer.copy correct",                   function()
            local a = buffer.create(4); buffer.writeu8(a, 0, 42)
            local b = buffer.create(4); buffer.copy(b, 0, a, 0, 4)
            return buffer.readu8(b, 0) == 42
        end },
        { "buffer.writestring and readstring correct", function()
            local b = buffer.create(6); buffer.writestring(b, 0, "eUNC!!")
            return buffer.readstring(b, 0, 6) == "eUNC!!"
        end },
    })

    -- UI library logging test (fetches Orion).
    do
        print("[eUNC] running: UI Library logging ")
        local ok, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
        end)
        local reason = ""
        local passed = false
        if ok and result then
            local ok2, window = pcall(function()
                return result:MakeWindow({ Name = "eUNC Test", HidePremium = true, SaveConfig = false })
            end)
            if ok2 and window then
                pcall(function() result:Destroy() end)
                passed = true
            else
                reason = "MakeWindow failed"
            end
        else
            reason = "loadstring failed: " .. tostring(result)
        end
        table.insert(results, {
            name   = "UI Library logging ",
            status = passed and "success" or "failure",
            reason = reason,
        })
    end

    runTest("Enum singleton", function()
        assert_(Enum.Material.Plastic == Enum.Material.Plastic)
    end)

    runTest("Vector3 arithmetic is correct", function()
        local v = Vector3.new(1, 2, 3) + Vector3.new(4, 5, 6)
        assert_(v.X == 5 and v.Y == 7 and v.Z == 9)
    end)

    runTest("GetService returns singleton", function()
        assert_(game:GetService("Players") == game:GetService("Players"))
    end)

    runTest("loadstring syntax error returns error", function()
        local ok = pcall(function()
            return loadstring("local a = if true then")()
        end)
        assert_(not ok)
    end)

    runTest("GetService matches property access", function()
        assert_(game:GetService("Players") == game.Players)
    end)

    runTest("require is not callable from global env", function()
        local ok = pcall(require)
        assert_(not ok, "require succeeded without arguments (should error)")
    end)

    runGroup("RunService extended properties", {
        { "RunService.ClientGitHash is string", function() return typeof(game:GetService("RunService").ClientGitHash) == "string" end },
        { "RunService.RunState is Running",     function() return game:GetService("RunService").RunState == Enum.RunState.Running end },
    })

    runGroup("game properties", {
        { "game.CreatorType is valid", function()
            return game.CreatorType == Enum.CreatorType.User or game.CreatorType == Enum.CreatorType.Group
        end },
        { "game.PlaceVersion is not 0", function() return game.PlaceVersion ~= 0 end },
        { "Enum type is userdata not table", function() return type(Enum) ~= "table" end },
    })

    runGroup("Players async methods", {
        { "GetNameFromUserIdAsync matches LocalPlayer", function()
            local Players = game:GetService("Players")
            local ok, name = pcall(function()
                return Players:GetNameFromUserIdAsync(Players.LocalPlayer.UserId)
            end)
            return ok and name == Players.LocalPlayer.Name
        end },
        { "GetNameFromUserIdAsync errors on invalid userId", function()
            return not pcall(function()
                return game:GetService("Players"):GetNameFromUserIdAsync(0)
            end)
        end },
    })

    runGroup("CollectionService extended", {
        { "GetTags returns correct tags", function()
            local cs = game:GetService("CollectionService")
            local p = Instance.new("Part")
            cs:AddTag(p, "meowTest")
            task.wait(0.1)
            local tags = cs:GetTags(p)
            p:Destroy()
            return #tags > 0 and tags[1] == "meowTest"
        end },
        { "HasTag works on instance directly", function()
            local cs = game:GetService("CollectionService")
            local p = Instance.new("Part")
            cs:AddTag(p, "meowTest2")
            task.wait(0.1)
            local ok = p:HasTag("meowTest2")
            p:Destroy()
            return ok == true
        end },
    })

    runGroup("Instance property type enforcement", {
        { "Orientation rejects string assignment", function()
            local p = Instance.new("Part")
            local ok = pcall(function() p.Orientation = "meowTest" end)
            p:Destroy()
            return not ok
        end },
    })

    runGroup("Instance signals fire on property change", {
        { "Changed fires on Name change", function()
            local p = Instance.new("Part")
            local fired = false
            p.Changed:Connect(function() fired = true end)
            p.Name = "meowTest"
            task.wait(0.1)
            p:Destroy()
            return fired == true
        end },
        { "GetPropertyChangedSignal fires on Name change", function()
            local p = Instance.new("Part")
            local fired = false
            p:GetPropertyChangedSignal("Name"):Connect(function() fired = true end)
            p.Name = "meowTest"
            task.wait(0.1)
            p:Destroy()
            return fired == true
        end },
    })

    runGroup("gcinfo", {
        { "gcinfo returns positive number", function()
            local v = gcinfo()
            return type(v) == "number" and v > 0
        end },
    })

    runGroup("HttpService.GetSecret", {
        { "GetSecret errors on invalid key", function()
            return not pcall(function()
                game:GetService("HttpService"):GetSecret("meowTest" .. string.rep("meow", 31))
            end)
        end },
    })

    runGroup("Teams service", {
        { "Teams:GetTeams returns table", function()
            return typeof(game:GetService("Teams"):GetTeams()) == "table"
        end },
    })

    runGroup("LogService", {
        { "LogService:GetLogHistory returns table", function()
            return typeof(game:GetService("LogService"):GetLogHistory()) == "table"
        end },
    })

    runGroup("Stats service properties", {
        { "Stats.ContactsCount is number",       function() return type(game:GetService("Stats").ContactsCount) == "number" end },
        { "Stats.DataReceiveKbps is number",     function() return type(game:GetService("Stats").DataReceiveKbps) == "number" end },
        { "Stats.DataSendKbps is number",        function() return type(game:GetService("Stats").DataSendKbps) == "number" end },
        { "Stats.FrameTime is number",           function() return type(game:GetService("Stats").FrameTime) == "number" end },
        { "Stats.HeartbeatTime is number",       function() return type(game:GetService("Stats").HeartbeatTime) == "number" end },
        { "Stats.HeartbeatTimeMs is number",     function() return type(game:GetService("Stats").HeartbeatTimeMs) == "number" end },
        { "Stats.InstanceCount is number",       function() return type(game:GetService("Stats").InstanceCount) == "number" end },
        { "Stats.MemoryTrackingEnabled is boolean", function() return type(game:GetService("Stats").MemoryTrackingEnabled) == "boolean" end },
        { "Stats.MovingPrimitivesCount is number", function() return type(game:GetService("Stats").MovingPrimitivesCount) == "number" end },
        { "Stats.PhysicsReceiveKbps is number",  function() return type(game:GetService("Stats").PhysicsReceiveKbps) == "number" end },
        { "Stats.PhysicsSendKbps is number",     function() return type(game:GetService("Stats").PhysicsSendKbps) == "number" end },
        { "Stats.PhysicsStepTime is number",     function() return type(game:GetService("Stats").PhysicsStepTime) == "number" end },
        { "Stats.PhysicsStepTimeMs is number",   function() return type(game:GetService("Stats").PhysicsStepTimeMs) == "number" end },
        { "Stats.PrimitivesCount is number",     function() return type(game:GetService("Stats").PrimitivesCount) == "number" end },
        { "Stats.RenderCPUFrameTime is number",  function() return type(game:GetService("Stats").RenderCPUFrameTime) == "number" end },
        { "Stats.RenderGPUFrameTime is number",  function() return type(game:GetService("Stats").RenderGPUFrameTime) == "number" end },
        { "Stats.SceneDrawcallCount is number",  function() return type(game:GetService("Stats").SceneDrawcallCount) == "number" end },
        { "Stats.SceneTriangleCount is number",  function() return type(game:GetService("Stats").SceneTriangleCount) == "number" end },
        { "Stats.ShadowsDrawcallCount is number",function() return type(game:GetService("Stats").ShadowsDrawcallCount) == "number" end },
        { "Stats.ShadowsTriangleCount is number",function() return type(game:GetService("Stats").ShadowsTriangleCount) == "number" end },
        { "Stats.UI2DDrawcallCount is number",   function() return type(game:GetService("Stats").UI2DDrawcallCount) == "number" end },
        { "Stats.UI2DTriangleCount is number",   function() return type(game:GetService("Stats").UI2DTriangleCount) == "number" end },
        { "Stats.UI3DDrawcallCount is number",   function() return type(game:GetService("Stats").UI3DDrawcallCount) == "number" end },
        { "Stats.UI3DTriangleCount is number",   function() return type(game:GetService("Stats").UI3DTriangleCount) == "number" end },
    })

    runTest("ENV LOGGER SHOULD BE REGULAR LUAU (not lune or anything else)", function()
        local score = 0

        local versionString = tostring(_VERSION or "")
        if versionString == "Lua 5.1" or versionString == "Lua 5.2"
            or versionString == "Lua 5.3" or versionString == "Lua 5.4" then
            score = 1
        end

        do
            local ok, ok2 = pcall(function()
                local dump = string.dump(function() return 1 end)
                return type(dump) == "string" and #dump > 4
            end)
            if ok and ok2 then score = score + 1 end
        end

        do
            local ok, ok2 = pcall(function()
                local fn = load("return 1 + 1")
                return type(fn) == "function" and fn() == 2
            end)
            if ok and ok2 then score = score + 1 end
        end

        if math.tointeger ~= nil then score = score + 1 end
        if task == nil then score = score + 1 end

        do
            local ok, ok2 = pcall(function()
                local s = string.format("%p", 1)
                return type(s) == "string" and #s > 0
            end)
            if ok and ok2 then score = score + 1 end
        end

        if math.type and math.type(1) == "integer" then score = score + 1 end
        if type(unpack) == "function" and type(table.unpack) ~= "function" then score = score + 1 end

        do
            local ok, ok2 = pcall(function()
                local co = coroutine.create(function() end)
                if tostring(co):match("0x(%x+)$") then
                    return string.dump(function() return 1 end):sub(1, 1) == "\027"
                end
                return false
            end)
            if ok and ok2 then score = score + 1 end
        end

        do
            local ok, ok2 = pcall(function()
                return tostring(1) == "1.0" and tostring(0) == "0.0"
            end)
            if ok and ok2 then score = score + 1 end
        end

        if type(io) == "table" then score = score + 1 end
        if type(package) == "table" then score = score + 1 end
        if debug and type(debug.sethook) == "function" then score = score + 1 end
        if debug and type(debug.getlocal) == "function" then score = score + 1 end

        do
            local ok, ok2 = pcall(function()
                if math.type then
                    return math.type(collectgarbage("count")) == "float"
                end
                return false
            end)
            if ok and ok2 then score = score + 1 end
        end

        do
            local ok, ok2 = pcall(function()
                return #tostring(0.3333333333333333) == 16
            end)
            if ok and ok2 then score = score + 1 end
        end

        if type(load) == "function" then score = score + 1 end

        assert_(score < 2, "ENV LOGGER SHOULD BE LUAU but standard Lua indicators detected (score=" .. score .. ")")
    end)

    runGroup("All Enums", (function()
        -- Pseudo table of enum names -> expected item names.
        local enumData = {
            { "AccessModifierType", { "Allow", "Deny" } },
            { "AccessoryType", {
                "Unknown", "Hat", "Hair", "Face", "Neck", "Shoulder", "Front", "Back",
                "Waist", "TShirt", "Shirt", "Pants", "Jacket", "Sweater", "Shorts",
                "LeftShoe", "RightShoe", "DressSkirt", "Eyebrow", "Eyelash",
            } },
            { "ActionType", { "Nothing", "Pause", "Lose", "Draw", "Win" } },
            { "ActuatorRelativeTo", { "Attachment0", "Attachment1", "World" } },
            { "ActuatorType", { "None", "Motor", "Servo" } },
            { "AdAvailabilityResult", {
                "IsAvailable", "DeviceIneligible", "ExperienceIneligible", "InternalError",
                "NoFill", "PlayerIneligible", "PublisherIneligible",
            } },
            { "AdEventType", {
                "RewardedAdLoaded", "RewardedAdGrant", "RewardedAdUnloaded",
                "VideoLoaded", "VideoRemoved", "UserCompletedVideo",
            } },
            { "AdFormat", { "RewardedVideo" } },
            { "AdShape", { "HorizontalRectangle" } },
            { "AdTeleportMethod", { "Undefined", "PortalForward", "InGameMenuBackButton", "UIBackButton" } },
            { "AdUIEventType", {
                "AdLabelClicked", "VolumeButtonClicked", "FullscreenButtonClicked",
                "PlayButtonClicked", "PauseButtonClicked", "CloseButtonClicked",
                "WhyThisAdClicked", "PlayEventTriggered", "PauseEventTriggered",
            } },
            { "AdUIType", { "None", "Image", "Video" } },
            { "AdUnitStatus", { "Inactive", "Active" } },
            { "AdornCullingMode", { "Automatic", "Never" } },
            { "AdornShading", { "Default", "Shaded", "XRay", "XRayShaded", "AlwaysOnTop" } },
            { "AlignType", {
                "PrimaryAxisParallel", "PrimaryAxisPerpendicular", "PrimaryAxisLookAt",
                "AllAxes", "Parallel", "Perpendicular",
            } },
            { "AlphaMode", { "Overlay", "Transparency", "TintMask", "Opaque" } },
            { "AnalyticsCustomFieldKeys", { "CustomField01", "CustomField02", "CustomField03" } },
            { "AnalyticsEconomyAction", { "Default", "Acquire", "Spend" } },
            { "AnalyticsEconomyFlowType", { "Sink", "Source" } },
            { "AnalyticsEconomyTransactionType", {
                "IAP", "Shop", "Gameplay", "ContextualPurchase", "TimedReward", "Onboarding",
            } },
            { "AnalyticsLogLevel", { "Trace", "Debug", "Information", "Warning", "Error", "Fatal" } },
            { "AnalyticsProgressionStatus", { "Default", "Begin", "Complete", "Abandon", "Fail" } },
            { "AnalyticsProgressionType", { "Custom", "Start", "Fail", "Complete" } },
            { "AnimationClipFromVideoStatus", {
                "Initializing", "Pending", "Processing", "ErrorGeneric", "Success",
                "ErrorVideoTooLong", "ErrorNoPersonDetected", "ErrorVideoUnstable",
                "Timeout", "Cancelled", "ErrorMultiplePeople", "ErrorUploadingVideo",
            } },
            { "AnimationNodeBlend2DInputMode", { "Cartesian", "Polar" } },
            { "AnimationNodeInterruptible", { "Always", "Finished", "Trigger" } },
            { "AnimationNodePlayMode", { "Loop", "PingPong", "OnceAndHold", "OnceAndReset" } },
            { "AnimationNodeTransitionType", { "CrossFade", "InertialBlend", "DeadBlend" } },
            { "AnimationNodeWaitFor", { "Finished", "Trigger" } },
            { "AnimationPriority", { "Core", "Idle", "Movement", "Action", "Action2", "Action3", "Action4" } },
            { "AnimatorRetargetingMode", { "Default", "Disabled", "Enabled" } },
            { "AppLifecycleManagerState", { "Detached", "Active", "Inactive", "Hidden" } },
            { "AppShellActionType", {
                "None", "OpenApp", "TapChatTab", "TapConversationEntry", "TapAvatarTab",
                "ReadConversation", "TapGamePageTab", "TapHomePageTab",
                "GamePageLoaded", "HomePageLoaded", "AvatarEditorPageLoaded",
            } },
            { "AppShellFeature", { "None", "Chat", "AvatarEditor", "GamePage", "HomePage", "More", "Landing" } },
            { "AppUpdateStatus", {
                "Unknown", "NotSupported", "Failed", "NotAvailable",
                "Available", "AvailableBoundChannel", "AvailableBetaProgram",
            } },
            { "ApplyStrokeMode", { "Contextual", "Border" } },
            { "AspectType", { "FitWithinMaxSize", "ScaleWithParentSize" } },
            { "AssetCreatorType", { "User", "Group" } },
            { "AssetFetchStatus", { "Success", "Failure", "None", "Loading", "TimedOut" } },
            { "AssetType", {
                "Image", "TShirt", "Audio", "Mesh", "Lua", "Hat", "Place", "Model",
                "Shirt", "Pants", "Decal", "Head", "Face", "Gear", "Badge", "Animation",
                "Torso", "RightArm", "LeftArm", "LeftLeg", "RightLeg", "Package",
                "GamePass", "Plugin", "MeshPart", "HairAccessory", "FaceAccessory",
                "NeckAccessory", "ShoulderAccessory", "FrontAccessory", "BackAccessory",
                "WaistAccessory", "ClimbAnimation", "DeathAnimation", "FallAnimation",
                "IdleAnimation", "JumpAnimation", "RunAnimation", "SwimAnimation",
                "WalkAnimation", "PoseAnimation", "EmoteAnimation", "Video",
                "TShirtAccessory", "ShirtAccessory", "PantsAccessory", "JacketAccessory",
                "SweaterAccessory", "ShortsAccessory", "LeftShoeAccessory",
                "RightShoeAccessory", "DressSkirtAccessory", "FontFamily",
                "EyebrowAccessory", "EyelashAccessory", "MoodAnimation", "DynamicHead",
                "FaceMakeup", "LipMakeup", "EyeMakeup", "EarAccessory", "EyeAccessory",
            } },
            { "AssetTypeVerification", { "Default", "ClientOnly", "Always" } },
            { "AudioApiRollout", { "Disabled", "Automatic", "Enabled" } },
            { "AudioCaptureMode", {} },
            { "AudioChannelLayout", { "Mono", "Stereo", "Quad", "Surround_5", "Surround_5_1", "Surround_7_1", "Surround_7_1_4" } },
            { "AudioFilterType", {
                "Peak", "LowShelf", "HighShelf", "Lowpass12dB", "Lowpass24dB",
                "Lowpass48dB", "Highpass12dB", "Highpass24dB", "Highpass48dB",
                "Bandpass", "Notch", "Lowpass6dB",
            } },
            { "AudioSimulationFidelity", { "None", "Automatic" } },
            { "AudioSubType", { "Music", "SoundEffect" } },
            { "AudioWindowSize", { "Small", "Medium", "Large" } },
            { "AuthorityMode", { "Server", "Automatic" } },
            { "AutomaticSize", { "None", "X", "Y", "XY" } },
            { "AvatarAssetType", {
                "TShirt", "Hat", "Shirt", "Pants", "Head", "Face", "Gear", "Torso",
                "RightArm", "LeftArm", "LeftLeg", "RightLeg", "HairAccessory",
                "FaceAccessory", "NeckAccessory", "ShoulderAccessory", "FrontAccessory",
                "BackAccessory", "WaistAccessory", "ClimbAnimation", "FallAnimation",
                "IdleAnimation", "JumpAnimation", "RunAnimation", "SwimAnimation",
                "WalkAnimation", "MoodAnimation", "EmoteAnimation", "TShirtAccessory",
                "ShirtAccessory", "PantsAccessory", "JacketAccessory", "SweaterAccessory",
                "ShortsAccessory", "LeftShoeAccessory", "RightShoeAccessory",
                "DressSkirtAccessory", "EyebrowAccessory", "EyelashAccessory",
                "DynamicHead", "FaceMakeup", "LipMakeup", "EyeMakeup",
            } },
            { "AvatarChatServiceFeature", {
                "None", "UniverseAudio", "UniverseVideo", "PlaceAudio", "PlaceVideo",
                "UserAudioEligible", "UserAudio", "UserVideoEligible", "UserVideo",
                "UserBanned", "UserVerifiedForVoice",
            } },
            { "AvatarContextMenuOption", { "Friend", "Chat", "Emote", "InspectMenu" } },
            { "AvatarGenerationError", {
                "None", "Unknown", "DownloadFailed", "Canceled",
                "Offensive", "Timeout", "JobNotFound",
            } },
            { "AvatarItemType", { "Asset", "Bundle" } },
            { "AvatarPromptResult", { "Success", "PermissionDenied", "Failed" } },
            { "AvatarSettingsAccessoryLimitMethod", { "Scale", "Remove", "PreviewScale", "PreviewRemove" } },
            { "AvatarSettingsAccessoryMode", { "PlayerChoice", "CustomLimit" } },
            { "AvatarSettingsAnimationClipsMode", { "PlayerChoice", "CustomClips" } },
            { "AvatarSettingsAnimationPacksMode", { "PlayerChoice", "StandardR15", "StandardR6" } },
            { "ZIndexBehavior", { "Global", "Sibling" } },
        }

        local checks = {}
        for _, entry in ipairs(enumData) do
            local enumName  = entry[1]
            local itemNames = entry[2]

            table.insert(checks, {
                enumName .. " exists",
                function() return typeof(Enum[enumName]) ~= "nil" end,
            })
            table.insert(checks, {
                enumName .. ":GetEnumItems returns table",
                function() return type(Enum[enumName]:GetEnumItems()) == "table" end,
            })
            table.insert(checks, {
                enumName .. " has at least " .. #itemNames .. " items",
                function() return #Enum[enumName]:GetEnumItems() >= #itemNames end,
            })
            for _, itemName in ipairs(itemNames) do
                table.insert(checks, {
                    enumName .. "." .. itemName .. " exists",
                    function() return typeof(Enum[enumName][itemName]) == "EnumItem" end,
                })
            end
        end
        return checks
    end)())

    runTest("tostring changes on rename", function()
        local p = Instance.new("Part")
        local s1 = tostring(p)
        p.Name = "renamed"
        local s2 = tostring(p)
        p:Destroy()
        assert_(s1 ~= s2)
    end)

    runTest("IsDescendantOf works after parenting", function()
        local a = Instance.new("Folder")
        local b = Instance.new("Folder")
        b.Parent = a
        a.Parent = workspace
        local ok = b:IsDescendantOf(workspace)
        a:Destroy()
        assert_(ok)
    end)

    runTest("child parent is nil after destroy", function()
        local a = Instance.new("Folder")
        local b = Instance.new("Folder")
        b.Parent = a
        a.Parent = workspace
        a:Destroy()
        task.wait()
        assert_(b.Parent == nil)
    end)

    runGroup("Instance and table edge cases", {
        { "random numeric index on Part does not succeed", function()
            return not pcall(function()
                return Instance.new("Part")[math.random(1000000, 9999999)]
            end)
        end },
        { "game is not a valid table key", function()
            return ({})[game] == nil
        end },
        { "newproxy __call returns typeof userdata", function()
            local p = newproxy(true)
            getmetatable(p).__call = typeof
            return p() == "userdata"
        end },
        { "newproxy __metatable is preserved", function()
            local p = newproxy(true)
            getmetatable(p).__metatable = "test_metatable"
            return getmetatable(p) == "test_metatable"
        end },
        { "string.split returns correct length", function()
            return #string.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789", "") == 63
        end },
        { "tostring has zero fixed params and is vararg", function()
            local params, isVararg = debug.info(tostring, "a")
            return params == 0 and isVararg == true
        end },
        { "tostring is not setfenv-able", function()
            return not pcall(setfenv, tostring, getfenv(tostring))
        end },
        { "tostring on two tables returns different strings", function()
            local a = string.sub(tostring({}), 8, 15)
            local b = string.sub(tostring({}), 8, 15)
            return a ~= b
        end },
    })

    runGroup("Physics work under a Part", {
        { "LocalPlayer exists for physics test", function()
            return game:GetService("Players").LocalPlayer ~= nil
        end },
        { "unanchored part falls under gravity", function()
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            p.Position = Vector3.new(0, 120, 0)
            p.Anchored = false
            p.CanCollide = false
            p.Transparency = 1
            p.Parent = workspace

            local y = p.Position.Y
            local fell = false
            task.wait(0.1)
            for _ = 1, 10 do
                task.wait(0.05)
                if math.abs(p.Position.Y - y) > 0.05 then
                    fell = true
                    break
                end
            end
            p:Destroy()
            return fell
        end },
        { "workspace.Gravity affects part fall speed", function()
            local old = workspace.Gravity
            workspace.Gravity = 196.2

            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            p.Position = Vector3.new(0, 200, 0)
            p.Anchored = false
            p.CanCollide = false
            p.Transparency = 1
            p.Parent = workspace

            local y = p.Position.Y
            task.wait(0.1)
            local delta = y - p.Position.Y
            p:Destroy()
            workspace.Gravity = old
            return delta > 0.1
        end },
        { "Part.Velocity changes under gravity", function()
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            p.Position = Vector3.new(0, 100, 0)
            p.Anchored = false
            p.CanCollide = false
            p.Transparency = 1
            p.Parent = workspace
            task.wait(0.05)
            local v = p.AssemblyLinearVelocity
            p:Destroy()
            return typeof(v) == "Vector3" and v.Y < 0
        end },
        { "Anchored part does not fall", function()
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            p.Position = Vector3.new(0, 50, 0)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 1
            p.Parent = workspace
            local y = p.Position.Y
            task.wait(0.2)
            local still = math.abs(p.Position.Y - y) < 0.01
            p:Destroy()
            return still
        end },
    })

    -- Additional Roblox-specific sanity checks. If any of these fail, we
    -- conclude we aren't running on a genuine Roblox environment.
    local function assertRobloxBehaviour(fn)
        local ok, result = pcall(fn)
        if not ok or not result then
            looksLikeRoblox = false
        end
    end

    assertRobloxBehaviour(function()
        local enums = Enum:GetEnums()
        local seen = {}
        for _, e in ipairs(enums) do
            local s = tostring(e)
            if seen[s] then return false end
            seen[s] = true
        end
        return #enums > 50
    end)

    assertRobloxBehaviour(function()
        local bold = Font.fromEnum(Enum.Font.GothamBold)
        local reg  = Font.fromEnum(Enum.Font.Gotham)
        return bold.Weight == Enum.FontWeight.Bold
            and reg.Weight == Enum.FontWeight.Regular
            and bold.Family == reg.Family
    end)

    assertRobloxBehaviour(function()
        local curve = Instance.new("FloatCurve")
        curve:InsertKey(FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Constant))
        curve:InsertKey(FloatCurveKey.new(0.5, 7, Enum.KeyInterpolationMode.Linear))
        curve:InsertKey(FloatCurveKey.new(1, 3, Enum.KeyInterpolationMode.Cubic))

        local k1 = curve:GetKeyAtIndex(1)
        local k2 = curve:GetKeyAtIndex(2)
        local k3 = curve:GetKeyAtIndex(3)
        curve:Destroy()

        return k1.Time == 0 and k2.Value == 7 and k3.Interpolation == Enum.KeyInterpolationMode.Cubic
    end)

    assertRobloxBehaviour(function()
        local curve = Instance.new("FloatCurve")
        curve:InsertKey(FloatCurveKey.new(0, 0, Enum.KeyInterpolationMode.Linear))
        curve:InsertKey(FloatCurveKey.new(1, 10, Enum.KeyInterpolationMode.Linear))

        local v0 = curve:GetValueAtTime(0)
        local v1 = curve:GetValueAtTime(1)
        local vh = curve:GetValueAtTime(0.5)
        curve:Destroy()

        return v0 == 0 and v1 == 10 and math.abs(vh - 5) < 0.01
    end)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Reporting
-- ──────────────────────────────────────────────────────────────────────────────

local function jsonString(value)
    return '"' .. tostring(value)
        :gsub("\\", "\\\\")
        :gsub('"', '\\"')
        :gsub("\n", "\\n")
        :gsub("\r", "\\r") .. '"'
end

local executorName = "unknown"
local executorVersion

pcall(function()
    local name, version = identifyexecutor()
    executorName = tostring(name)
    executorVersion = tostring(version or "unknown")
end)

local jsonParts = {}
for i, entry in ipairs(results) do
    jsonParts[i] = '{"name":' .. jsonString(entry.name)
        .. ',"status":' .. jsonString(entry.status)
        .. ',"reason":' .. jsonString(entry.reason or "") .. "}"
end
local _ = '{"executor":' .. jsonString(executorName) .. ',"results":[' .. table.concat(jsonParts, ",") .. "]}"

local passed = 0
for _, entry in ipairs(results) do
    if entry.status == "success" then passed = passed + 1 end
end

local total     = #results
local percent   = math.floor(passed / total * 100)
local label     = looksLikeRoblox and (executorName .. " (ROBLOX)") or (executorName .. " (ENV)")

print(string.rep("-", 40))
print(string.format("[eUNC] Score : %d / %d  (%d%%)", passed, total, percent))
print(string.format("[eUNC] Executor: %s", label))
print(string.format("[eUNC] Passed: %d  |  Failed: %d", passed, total - passed))
print(string.rep("-", 40))

for _, entry in ipairs(results) do
    if entry.status == "failure" then
        local reason = entry.reason and entry.reason ~= "" and " ~ " .. entry.reason or ""
        print(string.format("[ FAIL ] - %s%s", entry.name, reason))
    end
end

print(string.rep("-", 40))

-- ──────────────────────────────────────────────────────────────────────────────
-- Shareable results URL (base64 + obfuscation)
-- ──────────────────────────────────────────────────────────────────────────────

local function xorByte(a, b)
    local out, bit = 0, 1
    for _ = 1, 8 do
        if a % 2 ~= b % 2 then out = out + bit end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bit = bit * 2
    end
    return out
end

local function xorCipher(data, key)
    local out = {}
    local keyLen = #key
    local prev = 0
    for i = 1, #data do
        local byte  = data:byte(i)
        local kByte = key:byte((i - 1) % keyLen + 1)
        local mixed = xorByte(kByte, prev)
        local mixed2 = xorByte(mixed, i * 31 % 256)
        out[i] = string.char(xorByte(byte, mixed2))
        prev = out[i]:byte()
    end
    return table.concat(out, "")
end

local sortedRows = {}
for _, entry in ipairs(results) do
    local statusBit = entry.status == "success" and "1" or "0"
    local reasonClean = (entry.reason or ""):gsub("[,|\n\r]", function(c)
        return c == "," and ";" or "!"
    end)
    local nameClean = entry.name:gsub(",", ";"):gsub("|", "!")
    sortedRows[#sortedRows + 1] = nameClean .. "|" .. statusBit .. "|" .. reasonClean
end
table.sort(sortedRows)

local payload = label .. "|" .. table.concat(sortedRows, ",") .. "|euncv=v0.1"

-- Simple checksum
local checksum = 23100
for i = 1, #payload do
    local k = ("mN7kR2pXqL9wT4vYcJ6"):byte((i - 1) % 19 + 1)
    local b = payload:byte(i)
    local v = xorByte(xorByte(xorByte(xorByte(b, k), (i * 7 + k) % 256), (i * i * 13 + b) % 256), checksum % 256)
    checksum = (checksum * 1103515245 + 12345) % 2147483648
    checksum = (xorByte(v, payload:byte(i)) + v) % 999983
end

local input = payload .. "|cs=" .. checksum
local key   = "mN7kR2pXqL9wT4vYcJ6"
local cipher = xorCipher(input, key)

-- Base64 encode.
local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local out = {}
for i = 1, #cipher, 3 do
    local a = cipher:byte(i) or 0
    local b = cipher:byte(i + 1) or 0
    local c = cipher:byte(i + 2) or 0
    local combined = a * 65536 + b * 256 + c

    out[#out + 1] = base64Chars:sub(math.floor(combined / 262144) % 64 + 1, math.floor(combined / 262144) % 64 + 1)
    out[#out + 1] = base64Chars:sub(math.floor(combined / 4096) % 64 + 1, math.floor(combined / 4096) % 64 + 1)
    out[#out + 1] = #cipher >= i + 1 and base64Chars:sub(math.floor(combined / 64) % 64 + 1, math.floor(combined / 64) % 64 + 1) or "="
    out[#out + 1] = #cipher >= i + 2 and base64Chars:sub(combined % 64 + 1, combined % 64 + 1) or "="
end

local b64 = table.concat(out, "")
    :gsub("%+", "-")
    :gsub("/", "_")
    :gsub("=+$", "")

local url = "https://e-unc.vercel.app?id=" .. b64

print("[eUNC] Results URL (shareable permalink):")
print(url)
pcall(function() setclipboard(url) end)
