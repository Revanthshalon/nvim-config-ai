return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPost", "BufWritePost", "BufNewFile" },
	branch = "master",
	dependencies = {
		"j-hui/fidget.nvim",
		"saghen/blink.cmp",
	},
	opts = {
		servers = {
			lua_ls = {},
			protols = {
				root_dir = vim.fs.root(0, { "protols.toml", "buf.yaml", ".git" }),
			},
			postgres_lsp = {},
			ts_ls = {},
			tofu_ls = {
				cmd = { "tofu-ls", "serve" },
				filetypes = { "opentofu", "opentofu-vars" },
				root_dir = vim.fs.root(0, { ".terraform", ".git" }),
			},
			svelte = {},
			emmet_language_server = {},
			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						check = {
							command = "clippy",
						},
						checkOnSave = true,
						diagnostics = {
							enable = true,
						},
						inlayHints = {
							enable = true,
							parameterHints = true,
							typeHints = true,
							chainingHints = true,
						},
						hover = {
							actions = {
								enable = true,
							},
						},
						cargo = {
							allFeatures = true, -- Enable all features for cargo
						},
						procMacro = {
							enable = true, -- Enable proc-macro support
						},
					},
				},
			},
		},
	},
	keys = {
		{ "<leader>rn", vim.lsp.buf.rename, mode = "n", desc = "Lsp Rename" },
		{ "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "Lsp Code Action" },
		{ "<leader>gD", vim.lsp.buf.declaration, mode = "n", desc = "Go To Declaration" },
		{ "<leader>gd", vim.lsp.buf.definition, mode = "n", desc = "Go To Definition" },
		{ "<leader>gi", vim.lsp.buf.implementation, mode = "n", desc = "Go To Implementation" },
		{ "<leader>gr", vim.lsp.buf.references, mode = "n", desc = "Go To References" },
		{ "<leader>D", vim.lsp.buf.type_definition, mode = "n", desc = "Type Definition" },
		{ "K", vim.lsp.buf.signature_help, mode = "n", desc = "Signature Help" },
		{
			"<leader>ih",
			function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end,
			mode = "n",
			desc = "Inlay Hints",
		},
	},
	config = function(_, opts)
		vim.diagnostic.config({
			virtual_text = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})
		-- local sk = LazyVim.opts("sidekick.nvim")
		-- if vim.tbl_get(sk, "nes", "enabled") ~= false then
		-- 	opts.servers = opts.servers or {}
		-- 	opts.servers.copilot = opts.servers.copilot or {}
		-- end
		local cmp = require("blink.cmp")
		local capabilities = cmp.get_lsp_capabilities()
		-- Configure servers using the new vim.lsp.config API
		for server, config in pairs(opts.servers) do
			config.capabilities = cmp.get_lsp_capabilities(config.capabilities or capabilities)
			vim.lsp.config[server] = config
		end
	end,
}
