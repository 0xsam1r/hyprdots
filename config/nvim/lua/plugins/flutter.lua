-- ============================================================================
--  Flutter / Dart support
--  Plugin: flutter-tools.nvim (manages its own dartls instance — do not
--  register dartls separately in nvim-lsp.lua, they will conflict)
-- ============================================================================

return {
  {
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- reuse the same capabilities source as your other LSPs
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      require("flutter-tools").setup({
        flutter_path = "/opt/flutter/bin/flutter", -- يتخطى /usr/bin wrapper نهائيًا
        lsp = {
          capabilities = capabilities,
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
          },
        },
        widget_guides = { enabled = true },
        closing_tags = { enabled = true, prefix = "// " },
        debugger = { enabled = false },
        outline = {
          open_cmd = "30vnew",
        },
      })

      -- Keymaps
      local map = vim.keymap.set
      map("n", "<leader>fr", "<cmd>FlutterRun<CR>",         { desc = "Flutter: Run" })
      map("n", "<leader>fR", "<cmd>FlutterRestart<CR>",     { desc = "Flutter: Restart" })
      map("n", "<leader>fh", "<cmd>FlutterHotReload<CR>",   { desc = "Flutter: Hot Reload" })
      map("n", "<leader>fq", "<cmd>FlutterQuit<CR>",        { desc = "Flutter: Quit" })
      map("n", "<leader>fd", "<cmd>FlutterDevices<CR>",     { desc = "Flutter: Devices" })
      map("n", "<leader>fo", "<cmd>FlutterOutlineToggle<CR>",{ desc ="Flutter: Outline" })
    end,
  },
}
