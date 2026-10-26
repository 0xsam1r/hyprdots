-- =============================================================================
--  Formatting (conform.nvim) + Linting (nvim-lint)
--  Keybinds:
--    <Space>f  → format whole file (normal mode)
--    <Space>f  → format selection  (visual mode)
--
--  NOTE: == is kept as-is (vim's built-in indent) — we don't override it
-- =============================================================================

return {

    -- ── Formatter ──────────────────────────────────────────────────────────────
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },

        config = function()
            local conform = require("conform")

            conform.setup({
                -- ── Which formatter runs on which filetype ──────────────────────────
                formatters_by_ft = {
                    javascript = { "prettierd" },
                    javascriptreact = { "prettierd" },
                    typescript = { "prettierd" },
                    typescriptreact = { "prettierd" },
                    css = { "prettierd" },
                    scss = { "prettierd" },
                    json = { "prettierd" },
                    jsonc = { "prettierd" },
                    markdown = { "prettierd" },
                    lua = { "stylua" },
                    sh = { "shfmt" },
                    bash = { "shfmt" },
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                    go = { "gofumpt" },
                    sql = { lsp_format = "prefer" },
                    mysql = { lsp_format = "prefer" },
                    python = { "ruff_format" },
                    dart = { "dart_format" },
                },

                default_format_opts = {
                    lsp_format = "fallback",
                },
            })

            -- ── Auto-format on InsertLeave & Auto-fix ESLint ────────────────────────
            vim.api.nvim_create_autocmd("InsertLeave", {
                pattern = "*",
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()

                    -- 1. Run Conform auto-formatting for any recognized filetype
                    conform.format({
                        bufnr = bufnr,
                        async = true,
                        lsp_fallback = true,
                    })

                    -- 2. Auto-fix ESLint errors silently on exit to normal mode
                    local ft = vim.bo[bufnr].filetype
                    if ft == "typescript" or ft == "javascript" or ft == "typescriptreact" or ft == "javascriptreact" then
                        vim.cmd("silent! EslintFixAll")
                    end
                end,
            })

            -- ── <Space>f → format buffer (normal mode) ────────────────────────────
            vim.keymap.set("n", "<leader>f", function()
                conform.format({ async = true, lsp_format = "fallback" })
                vim.notify("Formatted: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
            end, { desc = "Format: buffer" })

            -- ── <Space>f → format selection (visual mode) ─────────────────────────
            vim.keymap.set("v", "<leader>f", function()
                local start_pos = vim.fn.getpos("v")
                local end_pos = vim.fn.getpos(".")
                local start_line = math.min(start_pos[2], end_pos[2])
                local end_line = math.max(start_pos[2], end_pos[2])
                vim.cmd("normal! \27") -- اطلع من visual mode عشان الـ marks تتسجل
                conform.format({
                    async = true,
                    lsp_format = "fallback",
                    range = {
                        start = { start_line, 0 },
                        ["end"] = { end_line, 0 },
                    },
                })
            end, { desc = "Format: selection" })
        end,
    },

    -- ── Linter (Disabled / Commented Out) ───────────────────────────────────────
    -- {
    --     "mfussenegger/nvim-lint",
    --     event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    --
    --     config = function()
    --         local lint = require("lint")
    --
    --         -- 👈 تحويل كل أخطاء eslint_d إلى WARN بشكل دائم ومباشر
    --         lint.linters.eslint_d = require("lint.util").wrap(lint.linters.eslint_d, function(diagnostic)
    --             diagnostic.severity = vim.diagnostic.severity.WARN
    --             return diagnostic
    --         end)
    --
    --         lint.linters_by_ft = {
    --             javascript = { "eslint_d" },
    --             javascriptreact = { "eslint_d" },
    --             typescript = { "eslint_d" },
    --             typescriptreact = { "eslint_d" },
    --             c = { "cppcheck" },
    --             cpp = { "cppcheck" },
    --             go = { "staticcheck" },
    --             sh = { "shellcheck" },
    --             bash = { "shellcheck" },
    --             dockerfile = { "hadolint" },
    --             lua = { "luacheck" },
    --             python = { "ruff" },
    --         }
    --
    --         vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    --             group = vim.api.nvim_create_augroup("format-lint", { clear = true }),
    --             callback = function()
    --                 local ft = vim.bo.filetype
    --                 local linters = lint.linters_by_ft[ft] or {}
    --                 local available = vim.tbl_filter(function(l)
    --                     local linter = lint.linters[l]
    --                     if not linter then
    --                         return false
    --                     end
    --                     local cmd = linter.cmd
    --                     if type(cmd) == "function" then
    --                         cmd = l
    --                     end
    --                     if type(cmd) ~= "string" then
    --                         return false
    --                     end
    --                     return vim.fn.executable(cmd) == 1
    --                 end, linters)
    --
    --                 if #available > 0 then
    --                     lint.try_lint()
    --
    --                     -- 👈 انتظار 120 مللي ثانية حتى ينتهي eslint_d ثم تعديل الـ Severity إلى WARN
    --                     vim.defer_fn(function()
    --                         local bufnr = vim.api.nvim_get_current_buf()
    --                         local ns = lint.get_namespace("eslint_d")
    --                         local diagnostics = vim.diagnostic.get(bufnr, { namespace = ns })
    --
    --                         if #diagnostics > 0 then
    --                             for _, d in ipairs(diagnostics) do
    --                                 d.severity = vim.diagnostic.severity.WARN
    --                             end
    --                             vim.diagnostic.set(ns, bufnr, diagnostics)
    --                         end
    --                     end, 120)
    --                 end
    --             end,
    --         })
    --     end,
    -- },
}
