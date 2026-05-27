return {
  {

  "folke/tokyonight.nvim",
  lazy = false,
  priority = 10000,
  config = function()
    require("tokyonight").setup({ style = "night" })
    vim.cmd("colorscheme tokyonight")
  end,
},
  { "rafi/awesome-vim-colorschemes", lazy = true },

    -- Catppuccin (very popular, pastel)
  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- Rose Pine (minimal, warm)
  { "rose-pine/neovim", name = "rose-pine", lazy = true },

  -- Kanagawa (inspired by Japanese art)
  { "rebelot/kanagawa.nvim", lazy = true },

  -- Gruvbox
  { "ellisonleao/gruvbox.nvim", lazy = true },

  -- Nightfox (multiple variants)
  { "EdenEast/nightfox.nvim", lazy = true },

  -- Onedark
  { "navarasu/onedark.nvim", lazy = true },

  -- Dracula
  { "Mofiqul/dracula.nvim", lazy = true },

  -- Nord
  { "shaunsingh/nord.nvim", lazy = true },

  -- Monokai
  { "tanvirtin/monokai.nvim", lazy = true },

  -- Cyberpunk (neon green, cyan, yellow on black)
  { "taigrr/cyberpunk.nvim", lazy = true, opts = {} },

  -- 2077 (Cyberpunk 2077 inspired)
  { "akai54/2077.nvim", lazy = true },

  -- vim-cyberpunk (classic, also has "silverhand" variant)
  { "thedenisnikulin/vim-cyberpunk", lazy = true },

  -- NeoCyberVim (SCARLET protocol inspired)
  { "DonJulve/NeoCyberVim", lazy = true },

  -- Neon (Tokyonight variants with cyberpunk vibes)
  { "Zeioth/neon.nvim", lazy = true },
}
