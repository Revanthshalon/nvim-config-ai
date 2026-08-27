return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufWritePost", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			python = { "mypy" },
		}

		-- Configure dynamic resolution for mypy (.venv and mypy.ini / pyproject.toml)
		local function get_mypy_linter(linter)
			if linter.name ~= "mypy" then
				return linter
			end

			local bufnr = vim.api.nvim_get_current_buf()
			local bufpath = vim.api.nvim_buf_get_name(bufnr)
			local search_path = #bufpath > 0 and vim.fs.dirname(bufpath) or vim.fn.getcwd()

			-- 1. Determine mypy executable (local .venv or $VIRTUAL_ENV or fallback to system/mason)
			local mypy_bin = "mypy"
			if vim.env.VIRTUAL_ENV then
				local venv_mypy = vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "mypy")
				if vim.uv.fs_stat(venv_mypy) then
					mypy_bin = venv_mypy
				end
			end
			if mypy_bin == "mypy" then
				local match = vim.fs.find({ ".venv", "venv" }, { path = search_path, upward = true, type = "directory" })[1]
				if match then
					local venv_mypy = vim.fs.joinpath(match, "bin", "mypy")
					if vim.uv.fs_stat(venv_mypy) then
						mypy_bin = venv_mypy
					end
				end
			end
			linter.cmd = mypy_bin

			-- 2. Build args
			local args = {
				"--show-column-numbers",
				"--show-error-codes",
				"--hide-error-context",
				"--no-color-output",
				"--no-error-summary",
			}

			-- Check for config file: mypy.ini, .mypy.ini, pyproject.toml, or setup.cfg
			local config_file = vim.fs.find({ "mypy.ini", ".mypy.ini", "pyproject.toml", "setup.cfg" }, {
				path = search_path,
				upward = true,
				type = "file",
			})[1]

			if config_file then
				table.insert(args, "--config-file")
				table.insert(args, config_file)
			end

			-- If mypy is not the venv's mypy, pass --python-executable to use the virtualenv
			local venv_python = nil
			if vim.env.VIRTUAL_ENV then
				local p = vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
				if vim.uv.fs_stat(p) then
					venv_python = p
				end
			end
			if not venv_python then
				local venv_dir = vim.fs.find({ ".venv", "venv" }, {
					path = search_path,
					upward = true,
					type = "directory",
				})[1]
				if venv_dir then
					local p = vim.fs.joinpath(venv_dir, "bin", "python")
					if vim.uv.fs_stat(p) then
						venv_python = p
					end
				end
			end

			if venv_python then
				table.insert(args, "--python-executable")
				table.insert(args, venv_python)
			end

			linter.args = args
			return linter
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if #bufname > 0 and vim.uv.fs_stat(bufname) then
					lint.try_lint(nil, {
						wrap_linter = get_mypy_linter,
					})
				end
			end,
		})
	end,
}
