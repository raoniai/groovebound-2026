local H = require("tests.helpers")
local WorldTourSession = require("src.meta.world_tour_session")

local T = {}

T["World Tour build carry-over is volatile and character scoped"] = function()
  local app = {}
  local build = { weapons = { { id = "kazoo_pistol", level = 7 } } }
  WorldTourSession.capture(app, "joe", build)
  H.eq(WorldTourSession.get(app, "joe"), build)
  H.is_nil(WorldTourSession.get(app, "lyra"))
  WorldTourSession.clear(app)
  H.is_nil(WorldTourSession.get(app, "joe"))
end

return T
