-- Generic equipping routines, helper functions and outfit definitions.
include("dat/factions/equip/generic.lua")

--[[
-- @brief Does empire pilot equipping
--
--    @param p Pilot to equip
--]]
function equip( p )
   -- Start with an empty ship
   p:rmOutfit("all")
   p:rmOutfit("cores")

   -- Get ship info
   local shiptype, shipsize = equip_getShipBroad( p:ship():class() )

   -- Split by type
   if shiptype == "civilian" then
      equip_civilian( p, shipsize )
      cargo_civilian(p)
      p:setCredits( rnd.int(p:ship():price()/10 , p:ship():price()/5) )
   elseif shiptype == "merchant"  then
      equip_merchant( p, shipsize )
      cargo_merchant(p)
      p:setCredits( rnd.int(p:ship():price()/10 , p:ship():price()/5) )
   elseif shiptype == "military" then
      equip_military( p, shipsize )
      cargo_military(p)
      p:setCredits( rnd.int(p:ship():price()/20 , p:ship():price()/10) )
   end
end

function cargo_civilian(p)
   cargo_fill(p,{C.FOOD,C.CONSUMER_GOODS},{C.GOURMET_FOOD,C.LUXURY_GOODS,C.EXOTIC_FOOD},2,0.2,1)
end

function cargo_merchant(p)
   cargo_fill(p,{C.FOOD,C.CONSUMER_GOODS,C.PRIMITIVE_CONSUMER,C.ORE,C.PRIMITIVE_INDUSTRIAL,C.INDUSTRIAL,C.ARMAMENT,C.PRIMITIVE_ARMAMENT,C.PRIMITIVE_CONSUMER},{C.LUXURY_GOODS,C.GOURMET_FOOD,C.EXOTIC_FURS,C.EXOTIC_ORGANIC,C.NATIVE_ARTWORK,C.NATIVE_TECHNOLOGY,C.NATIVE_WEAPONS,C.NATIVE_SCULPTURES},4,0.7,1)
end

function cargo_military(p)
   cargo_fill(p,{C.ARMAMENT,C.MODERN_ARMAMENT},{C.ARMAMENT,C.MODERN_ARMAMENT},2,0.2,0.5)
end

function equip_military( p, shipsize )
   local nbSlotTurrets, nbSlotWeapons, nSlotUtilities, nbSlotStructures = equip_getSlotNumbers(p:ship())
   local nbTurrets,nbForwards,nbSecondaries,nbStructures,nbUtilities

   nbTurrets=0
   nbForwards=0
   nbSecondaries=0
   nbStructures=0
   nbUtilities=0

   -- Number of each type of outfits
   if shipsize == "small" then
      local class = p:ship():class()

      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      -- Scout
      if class == "Scout" then
         nbForwards    = rnd.rnd(1,nbSlotWeapons)

      -- Fighter
      elseif class == "Fighter" then
         nbForwards    = rnd.rnd(nbSlotWeapons/2,nbSlotWeapons)

      -- Bomber
      elseif class == "Bomber" then
         nbSecondaries  = rnd.rnd(1,2)
         nbForwards    = nbSlotWeapons-use_secondary

      else
         nbForwards    = rnd.rnd(nbSlotWeapons/2,nbSlotWeapons)

      end

   elseif shipsize == "medium" then
      
      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      nbSecondaries  = rnd.rnd(0,nbSlotWeapons/3)
      nbForwards     = rnd.rnd(1,nbSlotWeapons-nbSecondaries)
   else      
      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      nbSecondaries  = rnd.rnd(1,nbSlotWeapons/3)
      nbForwards     = rnd.rnd(1,nbSlotWeapons-nbSecondaries)
   end

   nbStructures  = rnd.rnd(nbSlotStructures/3,nbSlotStructures)
   nbUtilities  = rnd.rnd(nSlotUtilities/3,nSlotUtilities)

   local outfits={}

   equip_fillTurretsBySlotSize(p:ship(),outfits,nbTurrets,equip_defaultTurretsBetelgeuse())
   equip_fillWeaponsBySlotSize(p:ship(),outfits,nbForwards,nbSecondaries,equip_defaultForwardBetelgeuse(),equip_defaultSecondaryBetelgeuse())
   equip_fillUtilitiesBySlotSize(p:ship(),outfits,nbUtilities,equip_defaultUtilitiesBetelgeuse())
   equip_fillStructuresBySlotSize(p:ship(),outfits,nbStructures,equip_defaultStructuresBetelgeuse())

   equip_ship( p, outfits )
end


function equip_civilian( p, shipsize )
   local nbSlotTurrets, nbSlotWeapons, nSlotUtilities, nbSlotStructures = equip_getSlotNumbers(p:ship())
   local nbTurrets,nbForwards,nbSecondaries,nbStructures,nbUtilities

   nbTurrets=0
   nbForwards=0
   nbSecondaries=0
   nbStructures=0
   nbUtilities=0

   -- Number of each type of outfits
   if shipsize == "small" then
      local class = p:ship():class()

      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)
      nbForwards    = rnd.rnd(1,nbSlotWeapons)

   elseif shipsize == "medium" then
      
      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      nbSecondaries  = rnd.rnd(0,nbSlotWeapons/3)
      nbForwards     = rnd.rnd(1,nbSlotWeapons-nbSecondaries)
   else      
      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      nbSecondaries  = rnd.rnd(1,nbSlotWeapons/3)
      nbForwards     = rnd.rnd(1,nbSlotWeapons-nbSecondaries)
   end

   nbStructures  = rnd.rnd(nbSlotStructures/3,nbSlotStructures)
   nbUtilities  = rnd.rnd(nSlotUtilities/3,nSlotUtilities)

   local outfits={}

   equip_fillTurretsBySlotSize(p:ship(),outfits,nbTurrets,equip_defaultTurretsBetelgeuse())
   equip_fillWeaponsBySlotSize(p:ship(),outfits,nbForwards,nbSecondaries,equip_defaultForwardBetelgeuse(),equip_defaultSecondaryBetelgeuse())
   equip_fillUtilitiesBySlotSize(p:ship(),outfits,nbUtilities,equip_defaultUtilitiesBetelgeuse())
   equip_fillStructuresBySlotSize(p:ship(),outfits,nbStructures,equip_defaultStructuresBetelgeuseMerchant())

   equip_ship( p, outfits )
end


function equip_merchant( p, shipsize )
   local nbSlotTurrets, nbSlotWeapons, nSlotUtilities, nbSlotStructures = equip_getSlotNumbers(p:ship())
   local nbTurrets,nbForwards,nbSecondaries,nbStructures,nbUtilities

   nbTurrets=0
   nbForwards=0
   nbSecondaries=0
   nbStructures=0
   nbUtilities=0

   -- Number of each type of outfits
   if shipsize == "small" then
      local class = p:ship():class()

      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)
      nbForwards    = rnd.rnd(1,nbSlotWeapons)

   elseif shipsize == "medium" then
      
      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      nbSecondaries  = rnd.rnd(0,nbSlotWeapons/3)
      nbForwards     = rnd.rnd(1,nbSlotWeapons-nbSecondaries)
   else      
      nbTurrets=rnd.rnd(nbSlotTurrets/2,nbSlotTurrets)

      nbSecondaries  = rnd.rnd(1,nbSlotWeapons/3)
      nbForwards     = rnd.rnd(1,nbSlotWeapons-nbSecondaries)
   end

   nbStructures  = rnd.rnd(nbSlotStructures/3,nbSlotStructures)
   nbUtilities  = rnd.rnd(nSlotUtilities/3,nSlotUtilities)

   local outfits={}

   equip_fillTurretsBySlotSize(p:ship(),outfits,nbTurrets,equip_defaultTurretsBetelgeuse())
   equip_fillWeaponsBySlotSize(p:ship(),outfits,nbForwards,nbSecondaries,equip_defaultForwardBetelgeuse(),equip_defaultSecondaryBetelgeuse())
   equip_fillUtilitiesBySlotSize(p:ship(),outfits,nbUtilities,equip_defaultUtilitiesBetelgeuse())
   equip_fillStructuresBySlotSize(p:ship(),outfits,nbStructures,equip_defaultStructuresBetelgeuseMerchant())

   equip_ship( p, outfits )
end

