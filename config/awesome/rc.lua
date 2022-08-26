-----------------------------------------------------------------------------------------------------------------------
--                                                   Base setup                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Configuration file selection
-----------------------------------------------------------------------------------------------------------------------

-- run startup scripts
local awful = require("awful")
os.execute(os.getenv("HOME") .. "/.config/awesome/startup.sh")

--local rc = "colorless.rc-colorless"

-- local rc = "color.red.rc-red"
--local rc = "color.blue.rc-blue"
--local rc = "color.orange.rc-orange"
--local rc = "color.green.rc-green"

local rc = "shade.ruby.rc-ruby"
--local rc = "shade.steel.rc-steel"

require(rc)
