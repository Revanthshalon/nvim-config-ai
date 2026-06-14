return {
	"mrjones2014/smart-splits.nvim",
	lazy = false, -- Recommended to load immediately for UI stability, or use keys below
	keys = {
		-- Moving between splits
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			desc = "Move cursor left",
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			desc = "Move cursor down",
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			desc = "Move cursor up",
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			desc = "Move cursor right",
		},
		-- Resizing splits
		{
			"<A-h>",
			function()
				require("smart-splits").resize_left()
			end,
			desc = "Resize left",
		},
		{
			"<A-j>",
			function()
				require("smart-splits").resize_down()
			end,
			desc = "Resize down",
		},
		{
			"<A-k>",
			function()
				require("smart-splits").resize_up()
			end,
			desc = "Resize up",
		},
		{
			"<A-l>",
			function()
				require("smart-splits").resize_right()
			end,
			desc = "Resize right",
		},
		-- Swapping buffers
		{
			"<leader><leader>h",
			function()
				require("smart-splits").swap_buf_left()
			end,
			desc = "Swap buffer left",
		},
		{
			"<leader><leader>j",
			function()
				require("smart-splits").swap_buf_down()
			end,
			desc = "Swap buffer down",
		},
		{
			"<leader><leader>k",
			function()
				require("smart-splits").swap_buf_up()
			end,
			desc = "Swap buffer up",
		},
		{
			"<leader><leader>l",
			function()
				require("smart-splits").swap_buf_right()
			end,
			desc = "Swap buffer right",
		},
	},
	opts = {
		ignored_filetypes = { "nofile", "quickfix", "prompt" },
		ignored_buftypes = { "nofile" },
		at_edge = "wrap",
		move_cursor_same_row = true,
	},
	config = function(_, opts)
		require("smart-splits").setup(opts)

		-- HACK: Fix for Netrw hijacking <C-l>
		-- This autocommand ensures smart-splits works even inside the file explorer
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "netrw",
			callback = function()
				vim.keymap.set("n", "<C-l>", function()
					require("smart-splits").move_cursor_right()
				end, { buffer = true, desc = "Move cursor right" })
			end,
		})
	end,
}
