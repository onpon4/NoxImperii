include("dat/ai/tpl/generic.lua")
include("dat/ai/personality/trader.lua")


-- Sends a distress signal which causes faction loss
function sos ()
   msg = {
      "Calling all Betelgian fleets! Under assault!",
      "Requesting assistance from all Betelgian traders!",
      "Calling all forces of the Doge for assistance!",
      string.format("Betelgian %s being assaulted!", string.lower( ai.pilot():ship():class() ))
   }
   ai.settarget( ai.target() )
   ai.distress( msg[ rnd.int(1,#msg) ])
end


mem.shield_run = 100
mem.armour_run = 100
mem.defensive  = false
mem.enemyclose = 500
mem.distressmsgfunc = sos
mem.careful   = true


function create ()

   -- Probably the ones with the most money
   --ai.setcredits( rnd.int(ai.pilot():ship():price()/100, ai.pilot():ship():price()/25) )

   -- Communication stuff
   mem.bribe_no = "\"We Betelgians do not sell our fuel to the like of you.\""
   mem.refuel = rnd.rnd( 3000, 5000 )
   p = player.pilot()
   if p:exists() then
      standing = ai.getstanding( p ) or -1
      if standing > 50 then mem.refuel = mem.refuel * 0.75
      elseif standing > 80 then mem.refuel = mem.refuel * 0.5
      end
      mem.refuel_msg = string.format("\"I'll supply your ship with fuel for %d credits.\"",
            mem.refuel);
   end

   -- Finish up creation
   create_post()
end
