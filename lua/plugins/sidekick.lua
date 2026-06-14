return {
	"folke/sidekick.nvim",
	opts = {
		-- add any options here
		cli = {
			mux = {
				backend = "zellij",
				enabled = true,
			},
		},
		nes = {
			enabled = true,
		},
	},
	keys = {
		{
			"<tab>",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>" -- fallback to normal tab
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<c-.>",
			function()
				require("sidekick.cli").focus()
			end,
			desc = "Sidekick Focus",
			mode = { "n", "t", "i", "x" },
		},
		-- Sidekick CLI management under <leader>sk prefix (avoids conflict with claudecode.nvim <leader>a* keys)
		{
			"<leader>ska",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>sks",
			function()
				require("sidekick.cli").select()
			end,
			desc = "Sidekick Select CLI",
		},
		{
			"<leader>skd",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Sidekick Detach Session",
		},
		{
			"<leader>skt",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Sidekick Send This",
		},
		{
			"<leader>skf",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Sidekick Send File",
		},
		{
			"<leader>skv",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Sidekick Send Visual Selection",
		},
		{
			"<leader>skp",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
	},
}
