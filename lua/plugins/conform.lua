return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "lewis6991/gitsigns.nvim" },
	config = function()
		local conform = require("conform")

	local function format_changed_sections(bufnr)
		bufnr = bufnr or vim.api.nvim_get_current_buf()
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		if filepath == "" then
			conform.format({ bufnr = bufnr, async = false, lsp_format = "fallback" })
			return
		end

		local ranges = nil
		local ok_gs, gs = pcall(require, "gitsigns")
		if ok_gs then
			local hunks = gs.get_hunks(bufnr)
			if hunks and #hunks > 0 then
				ranges = {}
				for _, hunk in ipairs(hunks) do
					if hunk.type ~= "delete" and hunk.added and hunk.added.count > 0 then
						table.insert(ranges, {
							start_line = hunk.added.start,
							end_line = hunk.added.start + hunk.added.count - 1,
						})
					end
				end
			elseif hunks and #hunks == 0 then
				-- Tracked file with no changes: do nothing
				return
			end
		end

		-- If gitsigns wasn't available or hasn't attached yet, compute diff directly via git & vim.diff
		if ranges == nil then
			local dir = vim.fs.dirname(filepath)
			local relpath = vim.fn.systemlist({ "git", "-C", dir, "ls-files", "--full-name", filepath })[1]
			if vim.v.shell_error == 0 and relpath and relpath ~= "" then
				local git_base = vim.fn.system({ "git", "-C", dir, "show", ":" .. relpath })
				if vim.v.shell_error == 0 then
					local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
					local current_text = table.concat(current_lines, "\n") .. "\n"
					local diff_indices = vim.diff(git_base, current_text, { result_type = "indices" })
					ranges = {}
					for _, diff in ipairs(diff_indices) do
						local start_b, count_b = diff[3], diff[4]
						if count_b > 0 then
							table.insert(ranges, {
								start_line = start_b,
								end_line = start_b + count_b - 1,
							})
						end
					end
				end
			end
		end

		-- Untracked new file or not in a git repo: format full file
		if ranges == nil then
			conform.format({ bufnr = bufnr, async = false, lsp_format = "fallback" })
			return
		end

		if #ranges == 0 then
			return
		end

		-- Format ranges in reverse order to preserve line numbering of earlier ranges
		for i = #ranges, 1, -1 do
			local r = ranges[i]
			local total_lines = vim.api.nvim_buf_line_count(bufnr)
			local start_line = math.max(1, math.min(r.start_line, total_lines))
			local end_line = math.max(1, math.min(r.end_line, total_lines))
			local last_line_content = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, true)[1]
			local end_col = last_line_content and #last_line_content or 0

			conform.format({
				bufnr = bufnr,
				async = false,
				lsp_format = "fallback",
				timeout_ms = 1000,
				range = {
					start = { start_line, 0 },
					["end"] = { end_line, end_col },
				},
			})
		end
	end

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
				python = { "ruff_organize_imports", "ruff_format" },
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
				end
		format_changed_sections(bufnr)
		return nil
			end,
		})

		-- Configure individual formatters
		conform.formatters.prettier = {
			args = {
				"--stdin-filepath",
				"$FILENAME",
				"--tab-width",
				"2",
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

	-- Keymaps
	vim.keymap.set("n", "<leader>mp", function()
		format_changed_sections()
	end, { desc = "Format changed sections (or file if untracked)" })

		vim.keymap.set("v", "<leader>mp", function()
		conform.format({
			lsp_format = "fallback",
			async = false,
			timeout_ms = 1000,
		})
		end, { desc = "Format visual selection" })

	vim.keymap.set("n", "<leader>mP", function()
		conform.format({
			lsp_format = "fallback",
			async = false,
			timeout_ms = 1000,
		})
	end, { desc = "Format entire file" })

	-- User commands
	vim.api.nvim_create_user_command("FormatChanged", function()
		format_changed_sections()
	end, { desc = "Format changed lines/hunks in buffer" })

		vim.api.nvim_create_user_command("FormatFile", function()
			conform.format({
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format entire file" })
	end,
}
