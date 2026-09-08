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
			docker_compose_language_service = {
				cmd = { "docker-compose-langserver", "--stdio" },
				filetypes = { "yaml" },
				root_markers = { "docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml" },
			},
			postgres_lsp = {},
			ts_ls = {},
			pyright = {
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "openFilesOnly",
							typeCheckingMode = "basic",
						},
					},
				},
				before_init = function(_, config)
					local function get_python_path(workspace)
						-- 1. Check $VIRTUAL_ENV
						if vim.env.VIRTUAL_ENV then
							local venv_python = vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
							if vim.uv.fs_stat(venv_python) then
								return venv_python
							end
						end

						-- 2. Search for .venv or venv in workspace or parent directories
						local match = vim.fs.find({ ".venv", "venv" }, { path = workspace, upward = true, type = "directory" })[1]
						if match then
							local venv_python = vim.fs.joinpath(match, "bin", "python")
							if vim.uv.fs_stat(venv_python) then
								return venv_python
							end
						end

						-- 3. Fallback to system python
						return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
					end

					local root = config.root_dir or vim.fn.getcwd()
					local python_path = get_python_path(root)
					config.settings = config.settings or {}
					config.settings.python = config.settings.python or {}
					config.settings.python.pythonPath = python_path
				end,
			},
			ruff = {
				on_attach = function(client, _)
					-- Disable hover in favor of Pyright
					client.server_capabilities.hoverProvider = false
				end,
			},
			tofu_ls = {
				cmd = { "tofu-ls", "serve" },
				filetypes = { "opentofu", "opentofu-vars" },
				root_dir = vim.fs.root(0, { ".terraform", ".git" }),
			},
			svelte = {},
			clangd = {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},
			},
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
