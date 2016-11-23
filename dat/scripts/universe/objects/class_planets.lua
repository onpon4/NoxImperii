include('dat/scripts/general_helper.lua')
include('universe/objects/class_settlements.lua')
include('luadata.lua')

planet_class = {}

local planet_c_debug_prototype = {
	setDescSettlements=function(self,desc)
	
	end,
	setDescHistory=function(self,desc)

	end,
	addService=function(self)

	end,
	removeService=function(self)

	end,
	addTechGroup=function(self)

	end,
	removeTechGroup=function(self)

	end,
	setFactionExtraPresence=function(self)

	end,
	addOrUpdateTradeData=function(self,com,price,supply,demand)
	self.tradedata[com]={price=price,supply=supply,demand=demand}
	end,
	faction=function(self)
	local f={name=function() return self.faction end}
	end,
	setTradeBuySellRation=function(self,tradeBuySellRatio)
	self.tradeBuySellRatio=tradeBuySellRatio
	end,
	displayTradeData=function(self)
	local desc
	if (self.tradeBuySellRatio) then
		desc="tradeBuySellRatio: "..gh.floorTo(self.tradeBuySellRatio,3)
	else
		desc="tradeBuySellRatio: nil"
	end
	for k,v in pairs(self.tradedata) do
		desc=desc.."\nCommodity "..k..": price: "..gh.floorTo(v.price,3)..", supply: "..gh.floorTo(v.supply)..", demand: "..gh.floorTo(v.demand)
	end
	return desc
end
}

planet_c_debug_prototype.__index = planet_c_debug_prototype

local planet_prototype = {
	isCivilized=function(self)
		if (not self.lua or not self.lua.settlements) then
			return false
		end
		return (gh.countMembers(self.lua.settlements)>0)
	end,
	civilizationName=function(self)
		for k,v in pairs (self.lua.settlements) do
			return k
		end
		return nil
	end,
	areNativeCivilized=function(self)
		return (self.star.populationTemplate.nativeCivilization>0.5)
	end,
	addHistory=function(self,msg)
		if (not self.lua.worldHistory) then
			self.lua.worldHistory={}
		end
	self.lua.worldHistory[#self.lua.worldHistory+1]={time=time.get():tonumber(),msg=msg}
	end,
	addTag=function(self,tag)
		for k,v in pairs(self.lua.tags) do
			if v==tag then return end
		end
		self.lua.tags[#self.lua.tags+1]=tag
		if (self.c) then
			self.c:addTag(tag)
		end
	end,
	removeTag=function(self,tag)
		for k,v in pairs(self.lua.tags) do--assumes tag present only once
			if (v==tag) then
				table.remove(self.lua.tags, k)
			end
		end
		if (self.c) then
			self.c:clearTag(tag)
		end
	end,
	hasTag=function(self,tag)
		for k,v in pairs(self.lua.tags) do
			if (v==tag) then
				return true
			end
		end
		return false
	end,
	addSettlementTag=function(self,settlement,tag)
		if (settlement == "natives" and self.lua.natives) then
			self.lua.natives:addTag(tag)
		elseif (self.lua.settlements[settlement]) then
			self.lua.settlements[settlement]:addTag(tag)
		end

		if (self.c) then
			self.c:addTag(tag)
		end
	end,
	removeSettlementTag=function(self,settlement,tag)
		if (settlement == "natives" and self.lua.natives) then
			self.lua.natives:removeTag(tag)
		elseif (self.lua.settlements[settlement]) then
			self.lua.settlements[settlement]:removeTag(tag)
		end

		if (self.c) then
			self.c:clearTag(tag)
		end
	end,
	initTags=function(self)
		--loop through settlements to copie tags to planet (for faster C-side references)
		for _,v in pairs(self.lua.settlements) do
			for _,tag in pairs(v.tags) do
				self.c:addTag(tag)
			end
		end

		if (self.lua.natives) then
			for _,tag in pairs(self.lua.natives.tags) do
				self.c:addTag(tag)
			end
		end
	end,
	addActiveEffect=function(self,settlement,desc,timeLimit,event_type)
		local s
		if (settlement == "natives" and self.lua.natives) then
			s=self.lua.natives
		elseif (self.lua.settlements[settlement]) then
			s=self.lua.settlements[settlement]
		end

		if not s then
			error("Unknown settlement "..settlement.." for world: "..self.c:name())
		else
			s:addActiveEffect(desc,timeLimit,event_type)
			if event_type then
				self.c:addTag("event_"..event_type)
			end
		end
	end,
	save=function (self)
		setPlanetLuaData(self.c,self.lua)
	end
}

planet_prototype.__index = planet_prototype

function planet_class.createNew()
	local o={}
	setmetatable(o, planet_prototype)
	o.lua={}
	o.lua.tags={}
	o.lua.settlements={}
	o.lua.worldHistory={}
	o.lua.humanFertility=0
	o.lua.nativeFertility=0
	o.lua.minerals=0
	o.settlementTypes={}
	o.settlementSpecialities={}
	o.services={fuel=0,missions=0,bar=0,commodity=0,outfits=0,shipyard=0}
	o.faction=""
	o.factionPresence=0
	o.factionRange=0

	local c={}
	setmetatable(c, planet_c_debug_prototype)
	c.tradedata={}
	o.c=c

	return o
end

function planet_class.load(c_planet)
	local planet=planet_class.createNew()
	planet.c=c_planet
	planet.lua=getPlanetLuaData(planet.c)

	if (not planet.lua.settlements) then
		planet.lua.settlements={}
	else
		for k,v in pairs(planet.lua.settlements) do
			settlement_class.applyToObject(v)
		end
	end

	if (planet.lua.natives) then
		settlement_class.applyToObject(planet.lua.natives)
	end

	if (not planet.lua.tags) then
		planet.lua.tags={}
	end

	return planet
end

