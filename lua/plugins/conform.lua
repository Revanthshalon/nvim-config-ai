return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "biome-check" },
				typescript = { "biome-check" },
				javascriptreact = { "biome-check" },
				typescriptreact = { "biome-check" },
				css = { "biome-check" },
				html = { "biome-check" },
				svelte = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				toml = { "taplo" },
				sql = { "pg_format" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		-- Configure individual formatters
		conform.formatters.prettier = {
			args = {
				"--stdin-filepath",
				"$FILENAME",
				"--tab-width",
				"4",
				"--use-tabs",
				"false",
				"--config-precedence",
				"prefer-file",
			},
		}
		conform.formatters.shfmt = {
			prepend_args = { "-i", "4" },
		}
		conform.formatters.pg_format = {
			command = "pg_format",
			args = {
				"-k", -- Fixes your issue: preserves manual blank lines
				"--inplace",
				"--wrap-limit",
				"0", -- Disables automatic line wrapping
				"--tabs",
				"--spaces",
				"1",
				"--keyword-case",
				"2", -- 1 = lowercase (2 is uppercase, 0 is unchanged)
				"--type-case",
				"2",
			},
			stdin = true,
		}

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format whole file or range (in visual mode) with" })
	end,
}
