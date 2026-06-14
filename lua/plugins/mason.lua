return {
	"mason-org/mason.nvim",
	keys = {
		{ "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
	},
	opts = {
		ui = {
			border = "rounded",
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "x",
		},
	},
}
