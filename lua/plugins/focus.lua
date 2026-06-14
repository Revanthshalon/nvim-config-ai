return {
	"nvim-focus/focus.nvim",
	version = false,
	opts = {},
	config = function()
		local focus = require("focus")
		focus.setup()
	end,
}
