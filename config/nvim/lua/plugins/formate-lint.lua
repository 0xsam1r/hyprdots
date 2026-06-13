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
				},

				default_format_opts = {
					lsp_format = "fallback",
				},
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

	-- ── Linter ─────────────────────────────────────────────────────────────────
	{
		"mfussenegger/nvim-lint",
		event = { "BufWritePost", "BufReadPost", "InsertLeave" },

		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				c = { "cppcheck" },
				cpp = { "cppcheck" },
				go = { "staticcheck" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				dockerfile = { "hadolint" },
				lua = { "luacheck" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("samir-lint", { clear = true }),
				callback = function()
					local ft = vim.bo.filetype
					local linters = lint.linters_by_ft[ft] or {}
					local available = vim.tbl_filter(function(l)
						local linter = lint.linters[l]
						if not linter then
							return false
						end
						local cmd = linter.cmd
						-- cmd ممكن يكون string أو function
						if type(cmd) == "function" then
							cmd = l
						end
						if type(cmd) ~= "string" then
							return false
						end
						return vim.fn.executable(cmd) == 1
					end, linters)
					if #available > 0 then
						lint.try_lint()
					end
				end,
			})
		end,
	},
}
