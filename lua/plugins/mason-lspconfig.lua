return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"pyright",
			"ruff",
      "mypy",
      "angularls",
      "tombi",
      "protols",
      "taplo",
      "codelldb",
      "rust_analyzer",
      "copilot",
		},
		automatic_enable = true,
	},
}
