-- ============================================================================
--  LSP Configuration
--  Stack: TS/JS, C++, Go, CSS, Lua, JSON/JSONC, SQL, Bash, Docker
--  Plugins: mason + mason-lspconfig + nvim-lspconfig + blink.cmp + fidget + lsp_singnature + schemastore + mason-tool-installer 
-- =============================================================================

return {
  -- ── Signature hints while typing function args ────────────────────────────
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      hint_enable = false,      -- virtual-text hints (can be noisy, toggle as you like)
      floating_window = true,
      handler_opts = { border = "rounded" },
    },
  },

  -- more completions for package.json like files
  { "b0o/schemastore.nvim" },

  -- ── Core LSP setup ────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim",                opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim",                   opts = {} },
      "saghen/blink.cmp",
    },

    config = function()

      -- ── Keymaps (attached per-buffer on LspAttach) ────────────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("samir-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func,
              { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Navigation
          map("gd", function() Snacks.picker.lsp_definitions() end,     "Goto Definition")
          map("gD", function() Snacks.picker.lsp_declarations() end,    "Goto Declaration")
          map("gr", function() Snacks.picker.lsp_references() end,      "Goto References")
          map("gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
          map("gt", function() Snacks.picker.lsp_type_definitions() end,"Goto Type Definition")

          -- Symbols
          map("<leader>ds", function() Snacks.picker.lsp_symbols() end,           "Document Symbols")
          map("<leader>ws", function() Snacks.picker.lsp_workspace_symbols() end, "Workspace Symbols")

          -- Actions
          map("<leader>rn", vim.lsp.buf.rename,       "Rename")
          map("<leader>ca", vim.lsp.buf.code_action,  "Code Action", { "n", "x" })
          map("<leader>cd", vim.lsp.buf.hover,        "Documentation")

          -- ── Compat helper: nvim 0.10 vs 0.11 ─────────────────────────────
          local function supports(client, method)
            if vim.fn.has("nvim-0.11") == 1 then
              return client:supports_method(method, event.buf)
            end
            return client.supports_method(method, { bufnr = event.buf })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- ── Document highlight on CursorHold ─────────────────────────────
          if client and supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local hl_group = vim.api.nvim_create_augroup("samir-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf, group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf, group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("samir-lsp-detach", { clear = true }),
              callback = function(e)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "samir-lsp-highlight", buffer = e.buf }
              end,
            })
          end

          -- ── Inlay hints toggle (<leader>th) ───────────────────────────────
          if client and supports(client, vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, "Toggle Inlay Hints")
          end
        end,
      })

      -- ── Diagnostics UI ────────────────────────────────────────────────────
      vim.diagnostic.config {
        severity_sort = true,
        float  = { border = "rounded", source = "if_many" },
        signs  = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN]  = "󰀪 ",
            [vim.diagnostic.severity.INFO]  = "󰋽 ",
            [vim.diagnostic.severity.HINT]  = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source  = "if_many",
          spacing = 2,
          format  = function(d) return d.message end,
        },
      }

      -- ── blink.cmp capabilities ────────────────────────────────────────────
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- ── Server definitions ────────────────────────────────────────────────
      --
      --  Each key = mason/lspconfig server name.
      --  `settings` goes under the server's root namespace.
      --  Empty table {} = use defaults, still gets capabilities injected.
      --
      local servers = {

        -- ── TypeScript / JavaScript ──────────────────────────────────────────
        -- ts_ls is the official MS server (replaces old tsserver name)
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints         = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints          = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints         = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints          = true,
              },
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
            },
          },
        },

        -- ── C / C++ ──────────────────────────────────────────────────────────
        -- clangd covers both. Needs compile_commands.json (cmake/bear) or a
        -- .clangd file at project root for best results.
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
          },
          -- clangd ships its own offsetEncoding; tell blink.cmp to match
          capabilities = { offsetEncoding = "utf-16" },
        },

        -- ── Go ───────────────────────────────────────────────────────────────
        -- gopls is the official Go LSP. Install Go first, then mason installs gopls.
        gopls = {
          settings = {
            gopls = {
              analyses  = { unusedparams = true, shadow = true },
              staticcheck = true,
              gofumpt     = true,   -- stricter gofmt (optional, needs gofumpt binary)
              hints = {
                assignVariableTypes    = true,
                compositeLiteralFields = true,
                compositeLiteralTypes  = true,
                constantValues         = true,
                functionTypeParameters = true,
                parameterNames         = true,
                rangeVariableTypes     = true,
              },
            },
          },
        },

        -- ── CSS / SCSS / Less ────────────────────────────────────────────────
        -- Covers Waybar CSS, web styling, etc.
        cssls = {
          settings = {
            css  = { validate = true, lint = { unknownAtRules = "ignore" } },
            scss = { validate = true, lint = { unknownAtRules = "ignore" } },
            less = { validate = true },
          },
        },

        -- ── Lua ──────────────────────────────────────────────────────────────
        -- lua_ls knows about Neovim globals (vim.*) via the library setting.
        lua_ls = {
          settings = {
            Lua = {
              runtime  = { version = "LuaJIT" },
              diagnostics = {
                globals = { "vim", "Snacks" },  -- suppress "undefined global" noise
              },
              workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true),
              },
              completion = { callSnippet = "Replace" },
              telemetry  = { enable = false },
            },
          },
        },

        -- ── JSON & JSONC ─────────────────────────────────────────────────────
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
          filetypes = { "json", "jsonc" },
        },

        -- ── SQL ───────────────────────────────────────────────────────────────
        -- sqls works but is limited. sqlfluff is better for linting but needs
        -- manual formatter setup. This gives basic completion + go-to.
        sqls = {},

        -- ── Bash / Shell scripting ────────────────────────────────────────────
        bashls = {
          filetypes = { "sh", "bash", "zsh" },  -- also catches .zshrc if you want
          settings = {
            bashIde = {
              globPattern = "*@(.sh|.inc|.bash|.command)",
            },
          },
        },

        -- ── Docker ───────────────────────────────────────────────────────────
        dockerls = {},
        docker_compose_language_service = {},

        -- ── Markdown ─────────────────────────────────────────────────────────
        marksman = {},

        -- ── NOT included (removed): ───────────────────────────────────────────
        -- jdtls  → Java, مش محتاجه
        -- stylua → formatter مش LSP server، بيتنصب تحت في ensure_installed بس
      }

      -- ── Apply capabilities and register each server ───────────────────────
      for name, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend(
          "force", {}, capabilities, config.capabilities or {}
        )
        vim.lsp.config(name, config)
      end

      -- ── mason-tool-installer: auto-install all servers + formatters ────────
      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, {
        -- Formatters (used by conform.nvim or vim.lsp.buf.format)
        "stylua",       -- Lua
        "prettierd",    -- JS/TS/CSS/JSON/Markdown (faster prettier daemon)
        "shfmt",        -- Bash
        "gofumpt",      -- Go (stricter gofmt)
        "golines",      -- Go (line-length wrapper)
        "clang-format", -- C/C++
        -- Linters (used by nvim-lint or null-ls if you have it)
        "eslint_d",     -- JS/TS linting daemon
        "shellcheck",   -- Bash static analysis
        "hadolint",     -- Dockerfile linting
      })
      require("mason-tool-installer").setup {
        ensure_installed = ensure_installed,
        auto_update      = false,
        run_on_start     = true,
      }

      require("mason-lspconfig").setup {
        ensure_installed    = {},   -- mason-tool-installer handles this
        automatic_installation = false,
      }
    end,
  },
}
