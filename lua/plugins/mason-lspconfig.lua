return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"pyright",
			"ruff",
		},
		automatic_enable = true,
	},
}
