return {
	"saecki/crates.nvim",
	event = { "BufReadPost", "BufWritePost", "BufNewFile", "BufRead Cargo.toml" },
	tag = "stable",
	opts = {
		completion = {
			blink = {
				use_custom_kind = true,
				kind_text = {
					version = "Version",
					feature = "Feature",
				},
				kind_highlight = {
					version = "BlinkCmpKindVersion",
					feature = "BlinkCmpKindFeature",
				},
				kind_icon = {
					version = " ",
					feature = " ",
				},
			},
			crates = {
				enabled = true,
				min_chars = 3,
				max_results = 8,
			},
		},
		lsp = {
			enabled = true,
			on_attach = function(client, bufnr) end,
			actions = true,
			completion = true,
			hover = true,
		},
	},
}
