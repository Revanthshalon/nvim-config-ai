-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.netrw_liststyle = 1
vim.g.netrw_sort_by = "exten"

vim.o.guifont = "MesloLGM Nerd Font:h13"

local keymap = vim.keymap

keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert mode with jk" })
keymap.set("n", "<leader>pv", "<cmd>Ex<cr>", { desc = "Explore" })
keymap.set("n", "<leader>nh", "<cmd>nohl<cr>", { desc = "Clear Highlights" })

local opt = vim.opt

opt.relativenumber = true
opt.number = true
opt.cursorline = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.background = "dark"
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.foldmethod = "expr"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = {},
	-- automatically check for plugin updates
	checker = { enabled = true },
})
