include "jumpdist.lua"
include "pilot/pirate.lua"

-- Gets a system with strong pirate influence
function get_nearby_pirate_system( sys, sysTaken )
   local systems=getsysatdistance(system.cur(), 1, 2,
        function(s)
            if (s:presence(G.PIRATES)<10 or s:presence(G.PIRATES)*3<s:presence(G.EMPIRE)) then
               return false
            end
            local taken=false
            if sysTaken then               
               for _,k in pairs(sysTaken) do
                  if k==s then
                     taken=true
                  end
               end
            end
           return not taken
        end)

   -- Make sure system has pirates
   if #systems == 0 then
      return nil
   else
      return systems[ rnd.rnd(1,#systems) ]
   end
end


--[[
Functions to create pirates based on difficulty more easily.
--]]
function pir_generate ()
   -- Get the pirate name
   pir_name = pirate_name()

   -- Get the pirate details
   rating = player.getRating()
   if rating < 50 then
      pir_ship, pir_outfits = pir_easy()
   elseif rating < 150 then
      pir_ship, pir_outfits = pir_medium()
   else
      pir_ship, pir_outfits = pir_hard()
   end

   -- Make sure to save the outfits.
   pir_outfits["__save"] = true

   return pir_name, pir_ship, pir_outfits,"pirate",G.PIRATES
end
function pir_easy ()
   if rnd.rnd() < 0.5 then
      return pirate_createDelta()
   else
      return pirate_createVendetta()
   end
end
function pir_medium ()
   if rnd.rnd() < 0.5 then
      return pirate_createAdmonisher()
   else
      return pir_easy()
   end
end
function pir_hard ()
   if rnd.rnd() < 0.5 then
      return pirate_createKestrel()
   else
      return pir_medium()
   end
end