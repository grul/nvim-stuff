-- Clone lazy nvim if it does not exist already
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- { "plugins.rustyrust" },
		{ import = "lazyvim.plugins.extras.lang.typescript" },
		{
			"ellisonleao/gruvbox.nvim",
			lazy = false, -- make sure we load this during startup if it is your main colorscheme
			priority = 1000, -- make sure to load this before all the other start plugins
			config = function()
				require("gruvbox").setup({
					italic = {
						strings = false,
						comments = false,
						operators = false,
						folds = false,
					},
				})
				vim.cmd([[colorscheme gruvbox]])
			end,
		},
	},
})
