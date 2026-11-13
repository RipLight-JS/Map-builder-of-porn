-- MAP v2 (modern hub + long biome run). Paste ALL of this into the Command Bar (View > Command Bar), press Ctrl+Enter.
-- It deletes the old map automatically. Run in EDIT mode.
local ws = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local rng = Random.new()

local function mk(class, name, parent, props)
	local o = Instance.new(class); o.Name = name
	for k, v in props or {} do o[k] = v end
	o.Parent = parent
	return o
end
local function part(name, parent, size, cf, color, mat, extra)
	local p = mk("Part", name, parent, { Size = size, CFrame = cf, Color = color, Anchored = true,
		Material = mat or Enum.Material.SmoothPlastic, TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth })
	if extra then for k, v in extra do p[k] = v end end
	return p
end
local function neon(name, parent, size, cf, color)
	return part(name, parent, size, cf, color, Enum.Material.Neon, { CanCollide = false })
end
local function glow(parent, color, range, brightness)
	mk("PointLight", "Glow", parent, { Color = color, Range = range, Brightness = brightness or 2 })
end
local function disc(name, parent, diameter, height, cf, color, mat)
	local p = part(name, parent, Vector3.new(height, diameter, diameter), cf * CFrame.Angles(0, 0, math.rad(90)), color, mat)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function ball(name, parent, size, pos, color, mat, extra)
	local p = part(name, parent, Vector3.new(size, size, size), CFrame.new(pos), color, mat, extra)
	p.Shape = Enum.PartType.Ball
	return p
end
local function label(parent, text, color, offset, w, h)
	local bb = mk("BillboardGui", "Label", parent, { Size = UDim2.fromOffset(w or 240, h or 50), StudsOffset = offset or Vector3.new(0, 5, 0), AlwaysOnTop = true, MaxDistance = 300 })
	mk("TextLabel", "T", bb, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = text, TextColor3 = color or Color3.new(1, 1, 1),
		Font = Enum.Font.FredokaOne, TextScaled = true, TextStrokeTransparency = 0 })
end
local function sparkles(parent, color, rate, speed, size)
	mk("ParticleEmitter", "FX", parent, { Color = ColorSequence.new(color), Rate = rate, Lifetime = NumberRange.new(3, 6),
		Speed = NumberRange.new(speed * 0.5, speed), LightEmission = 1, Size = NumberSequence.new(size, 0), SpreadAngle = Vector2.new(180, 180),
		Transparency = NumberSequence.new(0.1, 1) })
end

-- clean old map
for _, n in { "Baseplate", "Ground", "Bases", "SafeZone", "Biomes", "MapWalls", "MapDecor" } do
	local o = ws:FindFirstChild(n); if o then o:Destroy() end
end

-- ==================== LIGHTING ====================
pcall(function() Lighting.Technology = Enum.Technology.Future end)
Lighting.ClockTime = 17.2
Lighting.Brightness = 2.5
Lighting.OutdoorAmbient = Color3.fromRGB(90, 90, 120)
local function fx(class)
	local o = Lighting:FindFirstChildOfClass(class) or Instance.new(class)
	o.Parent = Lighting
	return o
end
local atm = fx("Atmosphere"); atm.Density = 0.28; atm.Haze = 1.6; atm.Glare = 0.3; atm.Color = Color3.fromRGB(200, 190, 255); atm.Decay = Color3.fromRGB(255, 160, 140)
local bloom = fx("BloomEffect"); bloom.Intensity = 0.9; bloom.Size = 36; bloom.Threshold = 0.9
local cc = fx("ColorCorrectionEffect"); cc.Saturation = 0.25; cc.Contrast = 0.1; cc.TintColor = Color3.fromRGB(255, 245, 255)
local sr = fx("SunRaysEffect"); sr.Intensity = 0.12
local dof = fx("DepthOfFieldEffect"); dof.FarIntensity = 0.12; dof.FocusDistance = 120; dof.InFocusRadius = 80; dof.NearIntensity = 0

-- ==================== GROUND + WALLS ====================
-- map runs along +Z, about 4000 studs
part("Ground", ws, Vector3.new(1000, 2, 4000), CFrame.new(0, -1, 1600), Color3.fromRGB(60, 100, 70), Enum.Material.Grass)
local walls = mk("Folder", "MapWalls", ws)
for _, sx in { -1, 1 } do
	part("SideWall", walls, Vector3.new(4, 120, 4000), CFrame.new(sx * 502, 60, 1600), Color3.fromRGB(120, 200, 255), Enum.Material.ForceField)
end
part("BackWall", walls, Vector3.new(1008, 120, 4), CFrame.new(0, 60, -402), Color3.fromRGB(120, 200, 255), Enum.Material.ForceField)
part("EndWall", walls, Vector3.new(1008, 120, 4), CFrame.new(0, 60, 3602), Color3.fromRGB(120, 200, 255), Enum.Material.ForceField)

local decor = mk("Folder", "MapDecor", ws)

-- ==================== SAFE ZONE ====================
local safe = mk("Folder", "SafeZone", ws)
part("SafeFloor", safe, Vector3.new(560, 0.6, 640), CFrame.new(0, 0.3, 0), Color3.fromRGB(34, 36, 48), Enum.Material.Concrete)
disc("PlazaRing", safe, 134, 0.1, CFrame.new(0, 0.62, 0), Color3.fromRGB(0, 230, 255), Enum.Material.Neon).CanCollide = false
disc("PlazaDisc", safe, 124, 0.15, CFrame.new(0, 0.66, 0), Color3.fromRGB(24, 26, 36), Enum.Material.Concrete)
mk("SpawnLocation", "LobbySpawn", safe, { Size = Vector3.new(8, 1, 8), Position = Vector3.new(0, 1, 40), Anchored = true, Neutral = true, Transparency = 0.6 })

-- center fountain + floating crystal
disc("FountainBase", safe, 34, 2, CFrame.new(0, 1.6, 0), Color3.fromRGB(230, 235, 245), Enum.Material.Marble)
disc("FountainWater", safe, 30, 0.4, CFrame.new(0, 2.7, 0), Color3.fromRGB(60, 190, 255), Enum.Material.Neon).CanCollide = false
disc("FountainPillar", safe, 5, 14, CFrame.new(0, 8, 0), Color3.fromRGB(230, 235, 245), Enum.Material.Marble)
local core = ball("FountainCore", safe, 9, Vector3.new(0, 24, 0), Color3.fromRGB(0, 230, 255), Enum.Material.Neon, { CanCollide = false })
glow(core, Color3.fromRGB(0, 230, 255), 90, 3)
sparkles(core, Color3.fromRGB(120, 255, 255), 40, 12, 0.6)
label(core, "★ TREE CLIMBERS ★", Color3.fromRGB(120, 255, 255), Vector3.new(0, 8, 0), 360, 70)

-- sell stand
local sell = part("SellStand", safe, Vector3.new(14, 7, 9), CFrame.new(0, 4.1, -110), Color3.fromRGB(40, 200, 110), Enum.Material.SmoothPlastic)
neon("SellRoof", safe, Vector3.new(16, 0.6, 11), CFrame.new(0, 7.9, -110), Color3.fromRGB(120, 255, 160))
label(sell, "💰 SELL FRUITS", Color3.fromRGB(150, 255, 170), Vector3.new(0, 7, 0), 280, 60)

-- gym
local ex = mk("Folder", "Exercises", safe)
for _, g in { { "Pushups", -70, 1 }, { "Weights", 0, 3 }, { "Pullups", 70, 6 } } do
	local p = part(g[1], ex, Vector3.new(14, 2, 14), CFrame.new(g[2], 1.6, 190), Color3.fromRGB(255, 150, 50), Enum.Material.SmoothPlastic)
	p:SetAttribute("Gain", g[3])
	neon("Rim", safe, Vector3.new(15, 0.2, 15), CFrame.new(g[2], 0.7, 190), Color3.fromRGB(255, 200, 80))
	label(p, "💪 " .. g[1] .. "  +" .. g[3] .. " STR", Color3.fromRGB(255, 200, 100), Vector3.new(0, 5, 0), 280, 50)
end

-- giant billboard over the exit
for _, sx in { -1, 1 } do part("BillboardPole", safe, Vector3.new(3, 52, 3), CFrame.new(sx * 42, 26, 300), Color3.fromRGB(25, 26, 34), Enum.Material.Metal) end
part("Billboard", safe, Vector3.new(80, 24, 2), CFrame.new(0, 42, 300), Color3.fromRGB(20, 21, 30), Enum.Material.SmoothPlastic)
neon("BillboardGlow", safe, Vector3.new(82, 0.8, 0.8), CFrame.new(0, 54.4, 299), Color3.fromRGB(0, 230, 255))
neon("BillboardGlow2", safe, Vector3.new(82, 0.8, 0.8), CFrame.new(0, 29.6, 299), Color3.fromRGB(255, 60, 200))

-- plaza lamps + floating crystals
for i = 0, 9 do
	local a = math.rad(i * 36)
	local x, z = math.cos(a) * 80, math.sin(a) * 80
	part("PlazaPole", safe, Vector3.new(1, 14, 1), CFrame.new(x, 7, z), Color3.fromRGB(30, 30, 38), Enum.Material.Metal)
	local head = ball("PlazaLamp", safe, 3, Vector3.new(x, 14.5, z), Color3.fromRGB(0, 230, 255), Enum.Material.Neon, { CanCollide = false })
	glow(head, Color3.fromRGB(0, 230, 255), 30, 1.5)
end
for i = 1, 14 do
	local x = rng:NextNumber(-250, 250); local z = rng:NextNumber(-250, 270)
	if math.abs(x) > 70 or math.abs(z) > 70 then
		local h = rng:NextNumber(6, 16)
		local c = part("HubCrystal", decor, Vector3.new(3, h, 3), CFrame.new(x, h / 2 + rng:NextNumber(0, 20), z) * CFrame.Angles(0, rng:NextNumber(0, 6), math.rad(rng:NextNumber(-15, 15))),
			Color3.fromHSV(rng:NextNumber(), 0.6, 1), Enum.Material.Neon, { Transparency = 0.2, CanCollide = false })
		sparkles(c, c.Color, 6, 4, 0.5)
	end
end

-- ==================== 12 MODERN BASES ====================
local bases = mk("Folder", "Bases", ws)
local accents = { Color3.fromRGB(0, 230, 255), Color3.fromRGB(255, 60, 200), Color3.fromRGB(120, 255, 90), Color3.fromRGB(255, 170, 40) }
local T = 1.6
for i = 1, 12 do
	local side = i <= 6 and -1 or 1
	local idx = (i - 1) % 6
	local pos = Vector3.new(side * 220, 0, -250 + idx * 100)
	local cf = CFrame.lookAt(pos, Vector3.new(0, 0, pos.Z))
	local acc = accents[(i - 1) % 4 + 1]
	local m = mk("Model", "Base" .. i, bases)
	local function L(name, size, off, color, mat, extra) return part(name, m, size, cf * CFrame.new(off), color, mat, extra) end
	local function N(name, size, off, color) return neon(name, m, size, cf * CFrame.new(off), color) end

	L("Floor", Vector3.new(70, 1, 70), Vector3.new(0, 1.1, 0), Color3.fromRGB(30, 32, 42), Enum.Material.Concrete)
	L("BackWall", Vector3.new(70, 22, 2), Vector3.new(0, T + 11, 34), Color3.fromRGB(235, 238, 245), Enum.Material.Concrete)
	L("Window", Vector3.new(40, 14, 0.5), Vector3.new(0, T + 10, 32.8), Color3.fromRGB(120, 200, 255), Enum.Material.Glass, { Transparency = 0.5 })
	L("SideWallA", Vector3.new(2, 22, 44), Vector3.new(-34, T + 11, 12), Color3.fromRGB(235, 238, 245), Enum.Material.Concrete)
	L("SideWallB", Vector3.new(2, 22, 44), Vector3.new(34, T + 11, 12), Color3.fromRGB(235, 238, 245), Enum.Material.Concrete)
	local roof = L("Roof", Vector3.new(74, 2, 48), Vector3.new(0, T + 23, 11), Color3.fromRGB(25, 27, 35), Enum.Material.Concrete)
	N("RoofNeon", Vector3.new(74, 0.6, 0.6), Vector3.new(0, T + 21.7, -13), acc)
	N("RoofNeonTop", Vector3.new(74, 0.6, 0.6), Vector3.new(0, T + 24.2, -13), acc)
	N("FloorStrip", Vector3.new(70, 0.2, 0.8), Vector3.new(0, T + 0.1, -34.5), acc)
	N("WallStripA", Vector3.new(0.6, 18, 0.6), Vector3.new(-34, T + 10, -12.5), acc)
	N("WallStripB", Vector3.new(0.6, 18, 0.6), Vector3.new(34, T + 10, -12.5), acc)
	L("PillarA", Vector3.new(2, 22, 2), Vector3.new(-34, T + 11, -12), Color3.fromRGB(235, 238, 245), Enum.Material.Concrete)
	L("PillarB", Vector3.new(2, 22, 2), Vector3.new(34, T + 11, -12), Color3.fromRGB(235, 238, 245), Enum.Material.Concrete)
	glow(roof, acc, 50, 1.5)
	label(roof, "BASE " .. i, acc, Vector3.new(0, 8, 0), 240, 50)
	L("Spawn", Vector3.new(8, 0.6, 8), Vector3.new(0, T + 0.3, 14), acc, Enum.Material.Neon)
	-- garden lamps
	for _, sx in { -30, 30 } do
		local lamp = part("Lamp", m, Vector3.new(1, 6, 1), cf * CFrame.new(sx, T + 3, -30), Color3.fromRGB(30, 30, 38), Enum.Material.Metal)
		local head = ball("LampHead", m, 2, (cf * CFrame.new(sx, T + 6.5, -30)).Position, acc, Enum.Material.Neon, { CanCollide = false })
		glow(head, acc, 24, 1.5)
	end
	local plots = mk("Folder", "Plots", m)
	for r = 0, 1 do
		for c = 0, 3 do
			part("Plot" .. (r * 4 + c + 1), plots, Vector3.new(9, 0.5, 9), cf * CFrame.new(-21 + c * 14, T + 0.25, 0 - r * 14),
				Color3.fromRGB(92, 64, 40), Enum.Material.Ground)
		end
	end
end

-- ==================== 7 BIOMES (long run) ====================
local styles = {
	{ "Common",    Color3.fromRGB(190, 190, 190), Enum.Material.Grass,       Color3.fromRGB(70, 140, 70) },
	{ "Rare",      Color3.fromRGB(70, 140, 255),  Enum.Material.Snow,        Color3.fromRGB(170, 205, 240) },
	{ "Epic",      Color3.fromRGB(170, 80, 255),  Enum.Material.Slate,       Color3.fromRGB(90, 60, 140) },
	{ "Legendary", Color3.fromRGB(255, 170, 30),  Enum.Material.Sand,        Color3.fromRGB(214, 170, 80) },
	{ "Mythical",  Color3.fromRGB(255, 60, 90),   Enum.Material.CrackedLava, Color3.fromRGB(140, 30, 40) },
	{ "Godly",     Color3.fromRGB(255, 255, 120), Enum.Material.Marble,      Color3.fromRGB(235, 230, 200) },
	{ "Secret",    Color3.fromRGB(20, 255, 200),  Enum.Material.Basalt,      Color3.fromRGB(20, 45, 50) },
}
local biomes = mk("Folder", "Biomes", ws)
local Z0, LEN = 350, 450

local function side() return (rng:NextNumber() < 0.5 and -1 or 1) end

-- unique scenery per biome (always kept off the road: |x| > 50)
local scenery = {
	Common = function(f, color, z0)
		for _ = 1, 18 do -- small bushes
			local x, z = side() * rng:NextNumber(55, 330), z0 + rng:NextNumber(20, LEN - 20)
			ball("Bush", f, rng:NextNumber(5, 9), Vector3.new(x, 2.5, z), Color3.fromRGB(50, 150, 60), Enum.Material.Grass, { CanCollide = false })
		end
	end,
	Rare = function(f, color, z0) -- ice spikes
		for _ = 1, 22 do
			local x, z, h = side() * rng:NextNumber(55, 330), z0 + rng:NextNumber(20, LEN - 20), rng:NextNumber(10, 34)
			part("IceSpike", f, Vector3.new(rng:NextNumber(3, 6), h, rng:NextNumber(3, 6)), CFrame.new(x, h / 2, z) * CFrame.Angles(0, rng:NextNumber(0, 6), math.rad(rng:NextNumber(-10, 10))),
				Color3.fromRGB(180, 225, 255), Enum.Material.Ice, { Transparency = 0.2, CanCollide = false })
		end
	end,
	Epic = function(f, color, z0) -- floating islands
		for _ = 1, 9 do
			local x, z, y = side() * rng:NextNumber(70, 320), z0 + rng:NextNumber(30, LEN - 30), rng:NextNumber(35, 80)
			local d = rng:NextNumber(18, 34)
			disc("Island", f, d, 4, CFrame.new(x, y, z), Color3.fromRGB(70, 50, 110), Enum.Material.Slate).CanCollide = false
			disc("IslandTop", f, d - 3, 1, CFrame.new(x, y + 2.5, z), color, Enum.Material.Neon).CanCollide = false
			local c = part("IslandCrystal", f, Vector3.new(3, 12, 3), CFrame.new(x, y + 8, z), color, Enum.Material.Neon, { CanCollide = false, Transparency = 0.2 })
			sparkles(c, color, 8, 4, 0.6)
		end
	end,
	Legendary = function(f, color, z0) -- golden pillars + dunes
		for _ = 1, 14 do
			local x, z, h = side() * rng:NextNumber(60, 330), z0 + rng:NextNumber(20, LEN - 20), rng:NextNumber(16, 44)
			part("GoldPillar", f, Vector3.new(6, h, 6), CFrame.new(x, h / 2, z), Color3.fromRGB(255, 205, 80), Enum.Material.Metal, { CanCollide = false })
			neon("PillarTop", f, Vector3.new(8, 0.8, 8), CFrame.new(x, h + 0.4, z), color)
		end
		for _ = 1, 10 do
			local x, z = side() * rng:NextNumber(80, 340), z0 + rng:NextNumber(20, LEN - 20)
			ball("Dune", f, rng:NextNumber(30, 60), Vector3.new(x, 0, z), Color3.fromRGB(226, 186, 100), Enum.Material.Sand, { CanCollide = false })
		end
	end,
	Mythical = function(f, color, z0) -- lava pools (decor only, no damage) + spikes
		for _ = 1, 10 do
			local x, z = side() * rng:NextNumber(70, 320), z0 + rng:NextNumber(30, LEN - 30)
			local d = rng:NextNumber(18, 36)
			local pool = disc("LavaPool", f, d, 0.4, CFrame.new(x, 0.6, z), Color3.fromRGB(255, 80, 30), Enum.Material.Neon)
			pool.CanCollide = false; glow(pool, color, 40, 2); sparkles(pool, Color3.fromRGB(255, 150, 60), 10, 8, 0.7)
		end
		for _ = 1, 16 do
			local x, z, h = side() * rng:NextNumber(60, 330), z0 + rng:NextNumber(20, LEN - 20), rng:NextNumber(14, 40)
			part("ObsidianSpike", f, Vector3.new(rng:NextNumber(4, 8), h, rng:NextNumber(4, 8)), CFrame.new(x, h / 2, z) * CFrame.Angles(0, rng:NextNumber(0, 6), math.rad(rng:NextNumber(-8, 8))),
				Color3.fromRGB(25, 15, 20), Enum.Material.Basalt, { CanCollide = false })
		end
	end,
	Godly = function(f, color, z0) -- marble columns with halos
		for _ = 1, 12 do
			local x, z, h = side() * rng:NextNumber(65, 330), z0 + rng:NextNumber(20, LEN - 20), rng:NextNumber(30, 60)
			part("Column", f, Vector3.new(7, h, 7), CFrame.new(x, h / 2, z), Color3.fromRGB(245, 242, 230), Enum.Material.Marble, { CanCollide = false })
			local ring = disc("Halo", f, 22, 0.8, CFrame.new(x, h + 6, z) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.Angles(0, 0, 0), color, Enum.Material.Neon)
			ring.CanCollide = false; ring.CFrame = CFrame.new(x, h + 6, z); ring.Orientation = Vector3.new(0, 0, 0)
			glow(ring, color, 60, 2)
		end
	end,
	Secret = function(f, color, z0) -- obsidian monoliths with cyan veins + embers
		for _ = 1, 14 do
			local x, z, h = side() * rng:NextNumber(60, 330), z0 + rng:NextNumber(20, LEN - 20), rng:NextNumber(24, 70)
			local mono = part("Monolith", f, Vector3.new(10, h, 4), CFrame.new(x, h / 2, z) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), Color3.fromRGB(8, 14, 16), Enum.Material.Glass, { CanCollide = false })
			neon("Vein", f, Vector3.new(0.5, h * 0.85, 4.2), mono.CFrame, color)
			glow(mono, color, 50, 2)
			sparkles(mono, color, 10, 6, 0.8)
		end
	end,
}

for i, s in styles do
	local name, color, mat, ground = s[1], s[2], s[3], s[4]
	local z0 = Z0 + (i - 1) * LEN
	local zc = z0 + LEN / 2
	local f = mk("Folder", name, biomes)

	part("Pad", f, Vector3.new(1000, 0.4, LEN), CFrame.new(0, 0.2, zc), ground, mat)
	part("Road", f, Vector3.new(60, 0.6, LEN), CFrame.new(0, 0.3, zc), Color3.fromRGB(34, 35, 44), Enum.Material.Asphalt)
	for _, sx in { -1, 1 } do neon("RoadEdge", f, Vector3.new(1.2, 0.2, LEN), CFrame.new(sx * 30.6, 0.65, zc), color) end
	for k = 0, 8 do neon("RoadDash", f, Vector3.new(1, 0.1, 14), CFrame.new(0, 0.65, z0 + 30 + k * 48), color) end

	-- giant gate
	local gate = mk("Model", "Gate", f)
	for _, sx in { -1, 1 } do
		part("Pillar", gate, Vector3.new(12, 70, 12), CFrame.new(sx * 480, 35, z0 + 5), Color3.fromRGB(22, 23, 30), Enum.Material.Concrete)
		neon("PillarGlow", gate, Vector3.new(1.2, 64, 1.2), CFrame.new(sx * 480, 35, z0 - 1), color)
	end
	local beam = part("Beam", gate, Vector3.new(1000, 16, 6), CFrame.new(0, 66, z0 + 5), Color3.fromRGB(18, 19, 26), Enum.Material.Metal, { CanCollide = false })
	neon("BeamGlowTop", gate, Vector3.new(1000, 0.9, 0.9), CFrame.new(0, 74.5, z0 - 0.2), color)
	neon("BeamGlowBottom", gate, Vector3.new(1000, 0.9, 0.9), CFrame.new(0, 57.5, z0 - 0.2), color)
	local sg = mk("SurfaceGui", "G", beam, { Face = Enum.NormalId.Front, SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud, PixelsPerStud = 8 })
	mk("TextLabel", "T", sg, { Size = UDim2.fromScale(0.5, 1), Position = UDim2.fromScale(0.25, 0), BackgroundTransparency = 1, Text = "✦ " .. name:upper() .. " BIOME ✦",
		TextColor3 = color, Font = Enum.Font.FredokaOne, TextScaled = true })
	-- arch over the road
	for _, sx in { -1, 1 } do part("ArchPost", gate, Vector3.new(4, 40, 4), CFrame.new(sx * 36, 20, z0 + 2), Color3.fromRGB(22, 23, 30), Enum.Material.Metal) end
	part("ArchBeam", gate, Vector3.new(80, 4, 4), CFrame.new(0, 41, z0 + 2), Color3.fromRGB(22, 23, 30), Enum.Material.Metal, { CanCollide = false })
	neon("ArchNeon", gate, Vector3.new(80, 0.8, 0.8), CFrame.new(0, 38.8, z0), color)

	-- sign board (server script fills text with recommended strength/speed)
	part("Sign", f, Vector3.new(26, 12, 1), CFrame.new(-60, 12, z0 + 30), Color3.fromRGB(22, 24, 32), Enum.Material.SmoothPlastic)
	for _, px in { -70, -50 } do part("Pole", f, Vector3.new(1.5, 12, 1.5), CFrame.new(px, 6, z0 + 30), Color3.fromRGB(40, 40, 50), Enum.Material.Metal) end

	-- tree spots
	local spawns = mk("Folder", "TreeSpawns", f)
	local placed = {}
	for n = 1, 14 do
		local x, z
		for _ = 1, 25 do
			x = side() * rng:NextNumber(70, 320)
			z = z0 + rng:NextNumber(70, LEN - 40)
			local ok = true
			for _, p in placed do if (p - Vector3.new(x, 0, z)).Magnitude < 40 then ok = false break end end
			if ok then break end
		end
		table.insert(placed, Vector3.new(x, 0, z))
		part("Spot" .. n, spawns, Vector3.new(4, 1, 4), CFrame.new(x, 0.9, z), Color3.fromRGB(70, 50, 30), Enum.Material.Ground, { Transparency = 0.5, CanCollide = false })
	end

	-- glowing crystals
	for _ = 1, 26 do
		local x, z, h = side() * rng:NextNumber(50, 340), z0 + rng:NextNumber(10, LEN - 10), rng:NextNumber(4, 14)
		part("Crystal", f, Vector3.new(rng:NextNumber(2, 4), h, rng:NextNumber(2, 4)),
			CFrame.new(x, h / 2, z) * CFrame.Angles(math.rad(rng:NextNumber(-12, 12)), rng:NextNumber(0, 6.28), math.rad(rng:NextNumber(-12, 12))),
			color, Enum.Material.Neon, { Transparency = 0.15, CanCollide = false })
	end

	-- lamps along the road
	for k = 0, 5 do
		for _, sx in { -1, 1 } do
			local lz = z0 + 40 + k * 70
			part("LampPole", f, Vector3.new(1, 16, 1), CFrame.new(sx * 38, 8, lz), Color3.fromRGB(30, 30, 38), Enum.Material.Metal)
			local head = neon("LampHead", f, Vector3.new(3, 1, 3), CFrame.new(sx * 38, 16.5, lz), color)
			glow(head, color, 40, 1.5)
		end
	end

	-- unique scenery + ambient particles
	scenery[name](f, color, z0)
	local amb = part("Ambient", f, Vector3.new(900, 2, LEN), CFrame.new(0, 40, zc), color, Enum.Material.SmoothPlastic, { Transparency = 1, CanCollide = false, CanQuery = false })
	sparkles(amb, color, 25, 3, 0.5)
end

print("MAP v2 BUILT! Now add the BiomeBanner LocalScript and press Play.")
