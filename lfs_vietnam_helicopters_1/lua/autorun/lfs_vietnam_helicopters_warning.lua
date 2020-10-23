AddCSLuaFile()

if SERVER then
	util.AddNetworkString("gred_net_getserverprop")
	util.AddNetworkString("gred_apache_tail")
	util.AddNetworkString("gred_apache_request_tail")
	util.AddNetworkString("gred_apache_tail_destroyed")
	util.AddNetworkString("gred_apache_rotor_destroyed")
end

PrecacheParticleSystem("ins_m203_explosion")


sound.Add( 	{
	name = "M134_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/m134_shoot.wav"
} )
sound.Add( 	{
	name = "M134_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/m134_stop.wav"
} )

sound.Add( 	{
	name = "M60_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/m60_shoot.wav"
} )
sound.Add( 	{
	name = "M60_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/m60_stop.wav"
} )

sound.Add( 	{
	name = "UPK23_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/UPK23_shoot.wav"
} )
sound.Add( 	{
	name = "UPK23_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/UPK23_stop.wav"
} )

sound.Add( 	{
	name = "A127_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/A127_shoot.wav"
} )
sound.Add( 	{
	name = "A127_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/A127_stop.wav"
} )

sound.Add( 	{
	name = "PKT_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/pkt_shoot.wav"
} )
sound.Add( 	{
	name = "PKT_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/pkt_stop.wav"
} )
sound.Add( 	{
	name = "M61_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/m61_shoot.wav"
} )
sound.Add( 	{
	name = "M61_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/m61_stop.wav"
} )
sound.Add( {
	name = "GRED_SHOOT_40MM",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	pitch = {100},
	sound = "/gredwitch/40mm.wav"
} )

sound.Add( {
	name = "AH1G_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = {100},
	sound = "^wac/ah1g/engine.wav"
} )

sound.Add( {
	name = "AH1G_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100},
	sound = "wac/ah1g/start.wav"
} )
sound.Add( {
	name = "UH1_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100},
	sound = "wac/uh1d/start.wav"
} )
sound.Add( {
	name = "UH1_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = {100},
	sound = "^wac/uh1d/engine.wav"
} )
sound.Add( {
	name = "OH6_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100},
	sound = "wac/OH6/start.wav"
} )
sound.Add( {
	name = "OH6_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = {100},
	sound = "^wac/OH6/engine.wav"
} )

if CLIENT then
	net.Receive("gred_net_getserverprop",function()
		local tail = net.ReadEntity()
		local self = net.ReadEntity()
		self:SetNWEntity("Tail",tail)
	end)
end