-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

-- Settings
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })
vim.opt.updatetime = 200
vim.opt.laststatus = 3 -- global statusline
vim.opt.undofile = true -- persistent undo
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.opt.foldtext = "" -- keep syntax highlighting on folded lines
vim.opt.list = true
vim.opt.listchars = { nbsp = "␣", tab = "→ ", trail = "·" }
vim.opt.clipboard = "unnamedplus" -- macOS - integration
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.smoothscroll = true -- scroll wrapped lines by screen row, not whole line
vim.opt.inccommand = "split" -- live :s preview, including off-screen matches
vim.opt.scrolloff = 4
vim.opt.confirm = true -- prompt instead of error on :q with unsaved changes
vim.opt.backupcopy = "yes" -- avoids issues with Bun's file watcher
vim.o.winborder = "solid" -- global default border for floats that don't set their own

-- Diagnostics
local diag_icons = { error = "\u{f015a}", warn = "\u{f002a}", info = "\u{f02fd}", hint = "\u{f0336}" }
vim.diagnostic.config({
  virtual_text = false, -- off by default; <leader>ud toggles
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diag_icons.error,
      [vim.diagnostic.severity.WARN] = diag_icons.warn,
      [vim.diagnostic.severity.INFO] = diag_icons.info,
      [vim.diagnostic.severity.HINT] = diag_icons.hint,
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = { " ", " ", " ", " ", " ", " ", " ", " " }, source = true, header = "", prefix = "" },
})

-- Keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = ","
local map = vim.keymap.set
map("n", "Q", function()
  if vim.fn.reg_recording() == "" then
    vim.api.nvim_feedkeys("qq", "n", false)
  else
    vim.api.nvim_feedkeys("q", "n", false)
  end
end, { desc = "Toggle macro record (q)" })
map("n", "q", function()
  if vim.fn.reg_recording() == "" then
    vim.cmd("silent normal! " .. vim.v.count1 .. "@q")
  else
    vim.api.nvim_feedkeys("q", "n", false)
  end
end, { desc = "Replay/stop macro (q)" })
map("n", "<leader>q", function() Snacks.bufdelete() end, { desc = "Delete buffer" })
map("n", "<M-Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<M-S-Tab>", "<cmd>bprev<CR>", { desc = "Previous buffer" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlight" })
map("n", "<BS>", "za", { desc = "Toggle fold" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map({ "n", "v" }, "<Up>", "gk") -- use arrow up/down to navigate in visible lines
map({ "n", "v" }, "<Down>", "gj")
map("i", "<Up>", "<C-o>gk")
map("i", "<Down>", "<C-o>gj")
map("v", "<C-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "<C-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
map("v", "<", "<gv", { noremap = true, desc = "Indent left and reselect" })
map("v", ">", ">gv", { noremap = true, desc = "Indent right and reselect" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>wq", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>ww", "<C-w>w", { desc = "Next window" })
map("n", "<leader>wh", "<C-w>h", { desc = "Focus left" })
map("n", "<leader>wj", "<C-w>j", { desc = "Focus down" })
map("n", "<leader>wk", "<C-w>k", { desc = "Focus up" })
map("n", "<leader>wl", "<C-w>l", { desc = "Focus right" })
map({ "n", "x", "o" }, "ö", "[", { remap = true, desc = "[ prefix" })
map({ "n", "x", "o" }, "ä", "]", { remap = true, desc = "] prefix" })
map("n", "<leader>e", function() vim.diagnostic.open_float() end, { desc = "Diagnostic float" })
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>ud", function()
  local vt = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not vt and { current_line = true } })
end, { desc = "Toggle diagnostic virtual text" })
map(
  "n",
  "<leader>uh",
  function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 }) end,
  { desc = "Toggle inlay hints" }
)
map("n", "<leader>an", function()
  local enable = not vim.lsp.is_enabled("copilot")
  vim.lsp.enable("copilot", enable)
  vim.lsp.inline_completion.enable(enable)
  vim.notify("Copilot " .. (enable and "enabled" or "disabled"))
end, { desc = "Toggle Copilot NES" })
map("n", "<leader>ul", function()
  local enable = not vim.lsp.is_enabled("ltex_plus")
  vim.lsp.enable("ltex_plus", enable)
  vim.notify("ltex_plus " .. (enable and "enabled" or "disabled"))
end, { desc = "Toggle ltex_plus LSP" })

map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto definition" })
map("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "References" })
map("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Goto implementation" })
map("n", "<leader>E", function() Snacks.picker.explorer() end, { desc = "Toggle explorer" })
map("n", "<leader>f", function() Snacks.picker.grep() end, { desc = "Grep" })
map("x", "<leader>f", function() Snacks.picker.grep_word() end, { desc = "Grep" })
map("n", "<leader>.", function() Snacks.picker.resume() end, { desc = "Resume last picker" })
map("n", "<D-p>", function() Snacks.picker.smart() end, { desc = "Find files" })
map("n", "<C-p>", function() Snacks.picker.smart() end, { desc = "Find files" })
map("n", "<C-q>", function()
  local is_open = vim.iter(vim.fn.getwininfo()):any(function(w) return w.quickfix == 1 end)
  vim.cmd(is_open and "cclose" or "copen")
end, { desc = "Toggle quickfix" })
map("n", "<leader>p", function() Snacks.picker.projects() end, { desc = "Open projects" })
map({ "n", "t" }, "<D-j>", function() Snacks.terminal.toggle() end, { desc = "Toggle terminal" }) -- Cmd+J
map({ "n", "t" }, "<C-j>", function() Snacks.terminal.toggle() end, { desc = "Toggle terminal" }) -- Ctrl+J fallback
map({ "n", "v" }, "<leader>ca", function() require("tiny-code-action").code_action({}) end, { desc = "Code Actions" })
map("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff" })
map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })

-- LSP keymaps (attached per buffer)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    map("n", "<leader>R", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
    map("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help" })
  end,
})

-- Darker background for help & quickfix buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "qf" },
  callback = function() vim.wo.winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat" end,
})

-- blend WinSeparator fg/bg with Normal; bqf preview matches NormalFloat;
-- FloatBorder matches NormalFloat so the global solid winborder blends in
local function set_hl_overrides()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = bg, bg = bg })
  vim.api.nvim_set_hl(0, "BqfPreviewFloat", { link = "NormalFloat" })
  local float_bg = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = float_bg, bg = float_bg })
end
set_hl_overrides()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl_overrides })

-- Filetype detection
vim.filetype.add({
  pattern = { [".*/%.github/workflows/.*%.ya?ml"] = "yaml.github" },
})

-- Big files (Snacks.bigfile): cheaper wrap and capped regex syntax for long lines, no undo file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "bigfile",
  callback = function(ev)
    -- linebreak/list cost a per-char check on every redraw of a wrapped line
    vim.wo[0][0].linebreak = false
    vim.wo[0][0].list = false
    vim.bo[ev.buf].synmaxcol = 200
    vim.bo[ev.buf].undofile = false
  end,
})

-- :Qf <source> — run a tool and send results to quickfix (live: refreshes on save, R to refresh)
local qf_sources = {
  typos = { cmd = "typos --format brief", efm = "%f:%l:%c: %m" },
  oxlint = { cmd = "oxlint --format unix | grep -v '^[0-9]\\+ problem' | grep -v '^$'", efm = "%f:%l:%c: %m" },
  ts = { cmd = "tsc --noEmit --pretty false", efm = "%f(%l\\,%c): %m" },
  fallow = {
    cmd = "fallow --format compact | grep -E '^(circular-dependency|unresolved-import|clone-group|high-complexity)' | sed \"s/^\\([^:]*\\):\\(.*\\):\\([0-9][0-9-]*\\):\\(.*\\)/\\2:\\3: [\\1] \\4/\"",
    efm = "%f:%l: %m",
  },
  fallow_refactor = {
    cmd = "fallow --format compact | grep -E '^(refactoring-target)' | sed \"s/^refactoring-target:\\([^:]*\\):\\([^:]*\\):\\(.*\\)/\\1:1: [refactoring-target] \\2: \\3/\"",
    efm = "%f:%l: %m",
  },
}
local function run_qf_source(name, open)
  local src = qf_sources[name]
  if not src then
    vim.notify("Qf: unknown source '" .. name .. "'", vim.log.levels.ERROR)
    return
  end
  local lines = vim.fn.systemlist(src.cmd)
  vim.fn.setqflist({}, "r", { title = name, lines = lines, efm = src.efm })
  if open then vim.cmd("copen") end
end
vim.api.nvim_create_user_command("Qf", function(opts) run_qf_source(opts.args, true) end, {
  nargs = 1,
  complete = function() return vim.tbl_keys(qf_sources) end,
  desc = "Run a qf source",
})
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    local title = vim.fn.getqflist({ title = 0 }).title
    if qf_sources[title] then run_qf_source(title, false) end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(ev)
    map("n", "R", function()
      local title = vim.fn.getqflist({ title = 0 }).title
      if qf_sources[title] then run_qf_source(title, false) end
    end, { buffer = ev.buf, desc = "Refresh qf source" })
  end,
})

-- LSP servers: base configs from nvim-lspconfig, Mason auto-installs and
-- auto-enables them (mason-lspconfig automatic_enable); overrides below
local vtsls_inlay_hints = {
  parameterNames = { enabled = "literals" },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = true },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}
vim.lsp.config("vtsls", {
  settings = {
    typescript = {
      inlayHints = vtsls_inlay_hints,
      tsdk = "node_modules/typescript/lib",
    },
    javascript = { inlayHints = vtsls_inlay_hints },
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@astrojs/ts-plugin",
            location = vim.fn.expand(
              "~/.local/share/nvim/mason/packages/astro-language-server/node_modules/@astrojs/ts-plugin"
            ),
            enableForWorkspaceTypeScriptVersions = true,
          },
          {
            name = "typescript-svelte-plugin",
            location = vim.fn.expand(
              "~/.local/share/nvim/mason/packages/svelte-language-server/node_modules/typescript-svelte-plugin"
            ),
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
})
vim.lsp.config("gh_actions_ls", { filetypes = { "yaml.github" } })
vim.lsp.config("cssls", { settings = { css = { lint = { unknownAtRules = "ignore" } } } })
vim.lsp.config("ltex_plus", {
  settings = {
    ltex = { language = "auto" },
  },
  on_attach = function()
    require("ltex_extra").setup({ load_langs = { "de-DE", "en-US" }, path = vim.fn.stdpath("config") .. "/ltex" })
  end,
})
vim.lsp.enable("sourcekit") -- ships with Xcode, not Mason-managed
-- vim.lsp.enable("fallow") -- not Mason-managed

-- LSP servers Mason installs & keeps updated (mason-lspconfig auto-enables
-- them; mason-tool-installer's MasonToolsUpdate keeps them updated)
local mason_lsp_servers = {
  "ty",
  "vtsls",
  "lua_ls",
  "rust_analyzer",
  "astro",
  "ltex_plus",
  "harper_ls",
  -- "mdx_analyzer",
  "cssls",
  "tailwindcss",
  "eslint",
  "gh_actions_ls",
  "typos_lsp",
  "jsonls",
  "svelte",
  "bashls",
}

-- Plugins
require("lazy").setup({

  -- Themes
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function() vim.cmd("colorscheme tokyonight-moon") end,
  },
  { "marko-cerovac/material.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },

  -- Treesitter parser for syntax highlighting, indentation, text-objects, folding, etc
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      require("nvim-treesitter").install({
        "vim",
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "astro",
        "python",
        "rust",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "bash",
        "html",
        "css",
        "scss",
        "http",
        "svelte",
        "mermaid",
      })
      vim.treesitter.language.register("tsx", "typescriptreact")
      vim.treesitter.language.register("tsx", "javascriptreact")
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
      })
    end,
  },

  -- MDX syntax highlighting
  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Base LSP server configs (lsp/*.lua on the runtimepath)
  { "neovim/nvim-lspconfig", lazy = false },

  -- Code actions for ltex_plus (add to dictionary, disable rule, ...)
  { "barreiroleo/ltex_extra.nvim", lazy = true },

  -- Mason: auto-install LSP servers & tools
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = mason_lsp_servers,
      automatic_enable = {
        exclude = {
          "copilot", -- off by default; <leader>an toggles
          "typos_lsp",
          "harper_ls",
          -- formatting-only LSP modes; conform runs these directly
          "oxfmt",
          "stylua",
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "tree-sitter-cli",
        "copilot-language-server",
        "oxfmt",
        "oxlint",
        "prettier",
        "actionlint",
        "stylua",
        "ruff",
        "swiftformat",
        "swiftlint",
        "typos",
        "shellcheck",
        -- for update coverage via MasonToolsUpdate
        unpack(mason_lsp_servers),
      },
      -- rustfmt omitted: comes with rustup, not in Mason
      auto_update = true,
      debounce_hours = 5,
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      -- only tools without an LSP mode; python/js/ts are covered by the
      -- ruff, oxlint and eslint LSP servers
      lint.linters_by_ft = {
        swift = { "swiftlint" },
        ["yaml.github"] = { "actionlint" },
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- Formatting (tools auto-installed via Mason; rustfmt comes with rustup)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "x" },
        desc = "Format",
      },
    },
    config = function()
      -- Snacks.bigfile: the real filetype (vim.filetype.match skips the bigfile check)
      local function real_ft(bufnr)
        local ft = vim.bo[bufnr].filetype
        return ft == "bigfile" and vim.filetype.match({ buf = bufnr }) or ft
      end
      local function oxfmt_or_prettier(bufnr)
        local root = vim.fs.root(bufnr, { "package.json", ".git" })
        if root and vim.uv.fs_stat(root .. "/node_modules/.bin/oxfmt") then return { "oxfmt" } end
        return { "prettier" }
      end
      require("conform").setup({
        formatters = {
          stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          },
          prettier = {
            prepend_args = function(_, ctx)
              if vim.bo[ctx.buf].filetype == "astro" then return { "--plugin", "prettier-plugin-astro" } end
              return {}
            end,
          },
        },
        formatters_by_ft = {
          javascript = oxfmt_or_prettier,
          typescript = oxfmt_or_prettier,
          typescriptreact = oxfmt_or_prettier,
          svelte = oxfmt_or_prettier,
          astro = oxfmt_or_prettier,
          mdx = oxfmt_or_prettier,
          css = oxfmt_or_prettier,
          json = oxfmt_or_prettier,
          yaml = oxfmt_or_prettier,
          toml = oxfmt_or_prettier,
          markdown = oxfmt_or_prettier,
          python = { "ruff_format" },
          rust = { "rustfmt" },
          swift = { "swiftformat" },
          lua = { "stylua" },
          -- Snacks.bigfile: use the real filetype's formatters
          bigfile = function(bufnr)
            local f = require("conform").formatters_by_ft[real_ft(bufnr)]
            if type(f) == "function" then return f(bufnr) end
            return f or {}
          end,
        },
        -- big files only via <leader>cf (async), never on save
        format_on_save = function(bufnr)
          if vim.bo[bufnr].filetype == "bigfile" then return end
          return { timeout_ms = 2000, lsp_format = "fallback" }
        end,
      })
    end,
  },

  -- Snacks: picker, terminal, ...
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      bigfile = {}, -- >1.5MB or minified: ft=bigfile (no treesitter/LSP/folds), see FileType bigfile autocmd
      input = {},
      terminal = {
        win = { wo = { winbar = "" }, keys = { term_normal = { "<Esc>", "<C-\\><C-n>", mode = "t" } } },
      },
      image = {}, -- requires brew install imagemagick
      statuscolumn = {
        left = { "mark", "sign" }, -- priority of signs on the left (high to low)
        right = { "git" }, -- "fold" priority of signs on the right (high to low)
        folds = {
          open = true, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        git = {
          -- patterns to match Git signs
          patterns = { "GitSign", "MiniDiffSign" },
        },
        refresh = 50, -- refresh at most every 50ms
      },
      picker = {
        ui_select = true,
        layout = "sidebar_custom",
        win = { preview = { wo = { wrap = true } } },
        previewers = { file = { max_line_length = 15000 } },
        sources = {
          explorer = { layout = { preset = "sidebar_custom" }, hidden = true },
          smart = { layout = "vscode_custom", hidden = true },
          files = { layout = "vscode_custom", hidden = true },
          projects = { layout = "vscode_custom", hidden = true },
          grep = { hidden = true },
        },
        layouts = {
          vscode_custom = {
            hidden = { "preview" },
            layout = {
              backdrop = false,
              row = 1,
              width = 0.4,
              min_width = 80,
              height = 0.4,
              border = "none",
              box = "vertical",
              {
                box = "vertical",
                border = "hpad",
                height = 3,
                wo = { winhighlight = "Normal:TabLineFill,FloatBorder:TabLineFill" },
                {
                  win = "input",
                  height = 1,
                  border = { " ", " ", " ", " ", " ", " ", " ", " " },
                  title = "",
                  wo = { winhighlight = "Normal:TabLineFill,FloatBorder:TabLineFill" },
                },
              },
              { win = "list", border = "hpad", wo = { winhighlight = "Normal:TabLineFill,FloatBorder:TabLineFill" } },
              { win = "preview", title = "{preview}", border = true },
            },
          },
          sidebar_custom = {
            preview = "main",
            layout = {
              backdrop = false,
              width = 40,
              min_width = 40,
              height = 0,
              position = "left",
              border = "none",
              box = "vertical",
              {
                win = "input",
                height = 1,
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
                title = "", -- {title} {live} {flags}
                title_pos = "center",
                wo = { winhighlight = "FloatBorder:NormalFloat" },
              },
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", height = 0.4, border = "top" },
            },
          },
        },
      },
    },
  },

  -- Completion
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "*",
    dependencies = {
      "saghen/blink.lib",
    },
    build = function()
      -- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
      -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
      ---@diagnostic disable-next-line: undefined-field
      require("blink.cmp").build():pwait()
    end,
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = {
          function(cmp)
            -- Confirm active snippet or accept selected completion item
            if cmp.snippet_active() then return cmp.accept() end
            if cmp.is_visible() then return cmp.select_and_accept() end
            -- NES only gets <Tab> when the completion menu is closed
            return require("sidekick").nes_jump_or_apply()
          end,
          "snippet_forward",
          -- Accept native Copilot inline completion (ghost text)
          function() return vim.lsp.inline_completion.get() end,
          "fallback",
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        -- no ghost text: Copilot's native inline completion owns the inline preview
        ghost_text = { enabled = false },
      },
    },
  },

  -- Find and replace
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>F",
        function() require("grug-far").open({ visualSelectionUsage = "auto-detect" }) end,
        mode = { "n", "x" },
        desc = "Find and replace",
      },
    },
    opts = {
      keymaps = { close = { n = "q" } },
    },
    config = function(_, opts)
      require("grug-far").setup(opts)
      -- Sidebar background consistency
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "grug-far", "grug-far-history", "grug-far-help" },
        callback = function() vim.wo.winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat" end,
      })
    end,
  },

  -- Async :Dispatch / :Make with compiler errorformat auto-detection
  { "tpope/vim-dispatch", cmd = { "Dispatch", "Make", "Start", "Spawn" } },

  -- Task runner with auto-detected templates (package.json scripts, Makefile, …)
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerToggle", "OverseerRun" },
    keys = {
      { "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "Task list" },
      { "<leader>or", "<cmd>OverseerRun<CR>", desc = "Run task" },
    },
    opts = {},
  },

  -- Quickfix enhancements (preview window, editable buffer)
  { "kevinhwang91/nvim-bqf", ft = "qf", opts = { auto_resize_height = true } },
  { "stevearc/quicker.nvim", ft = "qf", opts = {} },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            { "mode", fmt = function(str) return str:sub(1, 3) end },
            {
              function() return "[@]" end,
              cond = function() return vim.fn.reg_recording() ~= "" end,
              color = "DiagnosticWarn",
            },
            { "buffers", icons_enabled = false, symbols = { alternate_file = "" } },
          },
          lualine_x = { "diagnostics", { "lsp_status", icons_enabled = false, color = "lualine_c_inactive" } },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      { "antosha417/nvim-lsp-file-operations", opts = {} },
    },
    keys = {
      { "<C-b>", function() require("neo-tree.command").execute({ toggle = true }) end },
      { "<D-b>", function() require("neo-tree.command").execute({ toggle = true }) end },
    },
    config = function()
      require("neo-tree").setup({
        window = {
          width = 40,
          mappings = {
            ["<C-b>"] = "close_window",
            ["<D-b>"] = "close_window",
          },
        },
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = false,
            never_show = { ".DS_Store" },
          },
        },
      })
      -- Picker ↔ Neo-tree mutual exclusion
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "snacks_picker_list",
        callback = function() require("neo-tree.command").execute({ action = "close" }) end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function()
          for _, picker in ipairs(Snacks.picker.get()) do
            picker:close()
          end
        end,
      })
    end,
  },

  -- Edit folders as buffers
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Cmdline
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- "rcarriga/nvim-notify",
    },
    opts = {
      views = {
        cmdline_popup = {
          position = { row = 2, col = "50%" },
          border = { style = "none", padding = { 1, 2 } },
          filter_options = {},
          win_options = {
            winhighlight = {
              Normal = "TabLineFill",
              FloatBorder = "TabLineFill",
              FloatTitle = "TabLineFill",
            },
          },
        },
      },
    },
  },

  -- Outline
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    keys = { { "<leader>O", "<cmd>Outline<CR>", desc = "Toggle Outline" } },
    opts = {
      outline_window = { winhl = "Normal:NormalFloat,NormalNC:NormalFloat" },
    },
  },

  -- Git change indicators in the sign column (like Helix)
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- Highlight TODO/FIXME/HACK/NOTE comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPre",
    keys = {
      -- source is registered dynamically by todo-comments setup, unknown to lua_ls
      ---@diagnostic disable-next-line: undefined-field
      { "<leader>T", function() Snacks.picker.todo_comments() end, desc = "Todos" },
    },
    opts = { highlight = { exclude = { "bigfile" } } },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    keys = { { "<leader>ui", "<cmd>IBLToggle<CR>", desc = "Toggle indent guides" } },
    opts = { enabled = false, indent = { char = "│" } },
  },

  -- Color highlighting (like vscode-ext-color-highlight)
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = { render = "background", enable_tailwind = true, exclude_filetypes = { "bigfile" } },
  },

  -- Auto pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },

  -- Surround (wrap/change/delete quotes, brackets, tags)
  { "nvim-mini/mini.surround", event = "VeryLazy", version = false, opts = {} },

  -- Text objects (vif = inside function, vac = around class, daa = delete argument,
  -- viq = inside quotes, vib = inside brackets, ...)
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    version = false,
    -- provides the textobjects.scm queries used by gen_spec.treesitter
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        custom_textobjects = {
          -- f/c target definitions via treesitter (default f = function call, F unused)
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        },
      }
    end,
  },

  -- Multi-cursor
  { "mg979/vim-visual-multi", event = "VeryLazy" },

  -- Jump to any visible location with <CR> + 2 chars
  {
    "folke/flash.nvim",
    keys = {
      { "ü", function() require("flash").jump() end, desc = "Flash jump" },
      {
        "<CR>",
        mode = { "n", "x", "o" },
        function()
          -- keep native <CR> in quickfix, cmdline window, plugin buffers
          if vim.bo.buftype ~= "" then
            return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
          end
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
    },
    opts = {
      modes = {
        char = { enabled = false }, -- keep stock f/F/t/T/;/,
      },
    },
  },

  -- Which-key: popup showing available keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>a", group = "AI" },
        { "<leader>c", group = "Code" },
        { "<leader>f", icon = { icon = "󰍉", hl = "SnacksPickerInputTitle" } },
        { "<leader>r", icon = { icon = "󰌹", hl = "DiagnosticInfo" } },
        { "<leader>s", icon = { icon = "󰫧", hl = "DiagnosticWarn" } },
        { "<leader>g", group = "Git", icon = { cat = "file", name = ".gitignore" } },
        { "<leader>t", group = "Test", icon = { cat = "file", name = "spec.ts" } },
        { "<leader>o", group = "Overseer" },
        { "<leader>w", group = "Window" },
        { "<leader>u", group = "UI" },
        {
          "<leader>b",
          group = "Buffers",
          expand = function() return require("which-key.extras").expand.buf() end,
        },
      },
    },
  },

  -- Code actions with live preview
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "LspAttach",
    opts = {
      -- backend = "delta",
      picker = {
        "snacks",
        opts = {
          layout = {
            preset = "sidebar_custom",
          },
        },
      },
    },
  },

  -- Diagnostics
  {
    "folke/trouble.nvim",
    opts = {
      keys = {
        ["<BS>"] = "fold_toggle",
        ["<C-q>"] = function(view)
          local bufnr = view.opts and view.opts.filter and view.opts.filter.buf ~= nil and 0 or nil
          vim.diagnostic.setqflist({ open = true, bufnr = bufnr })
        end,
      },
    },
    cmd = "Trouble",
    keys = {
      { "<leader>d", "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>", desc = "Diagnostics" },
      { "<leader>D", "<cmd>Trouble diagnostics toggle focus=true<cr>", desc = "Diagnostics All" },
      { "<leader>s", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>r", "<cmd>Trouble lsp toggle focus=true win.position=right<cr>", desc = "References (Trouble)" },
    },
  },

  -- Test runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "marilari88/neotest-vitest",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run test file" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle test output" },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup({
        adapters = {
          require("neotest-vitest"),
        },
      })
    end,
  },

  -- Zen mode
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>uz", "<cmd>ZenMode<CR>", desc = "Toggle Zen Mode" },
    },
    opts = {
      window = {
        backdrop = 1,
        width = 100,
        options = {
          number = false,
          signcolumn = "no",
        },
      },
      plugins = {
        options = {
          laststatus = 0, -- turn off the statusline in zen mode
        },
      },
    },
  },

  -- AI CLI integration + Copilot NES rendering
  {
    "folke/sidekick.nvim",
    opts = {
      cli = { focus = true, filter = { installed = true } },
    },
    keys = function()
      local function sidekick() return require("sidekick.cli") end
      local function toggle() sidekick().toggle({ focus = true, filter = { installed = true } }) end
      return {
        {
          "<Tab>",
          function()
            if not require("sidekick").nes_jump_or_apply() then return "<Tab>" end
          end,
          expr = true,
          desc = "Apply NES edit",
        },
        { "<leader>aa", toggle, desc = "Toggle agent" },
        { "<C-D-i>", toggle, mode = { "n", "i", "t" }, desc = "Toggle agent" },
        { "<leader>af", function() sidekick().send({ msg = "{file}" }) end, desc = "Send file to agent" },
        { "<leader>ap", function() sidekick().prompt() end, mode = { "n", "x" }, desc = "Prompt picker" },
        { "<leader>as", function() sidekick().select({ filter = { installed = true } }) end, desc = "Select AI tool" },
        { "<leader>at", function() sidekick().send({ msg = "{this}" }) end, mode = { "n", "x" }, desc = "Send this" },
        { "<leader>av", function() sidekick().send({ msg = "{selection}" }) end, mode = "x", desc = "Send selection" },
      }
    end,
  },

  -- Undo tree
  {
    "XXiaoA/atone.nvim",
    cmd = "Atone",
    keys = { { "<leader>uu", "<cmd>Atone<CR>", desc = "Undo Tree" } },
    opts = {},
    config = function(_, opts)
      require("atone").setup(opts)
      -- Sidebar background consistency (atone sets the buffer's filetype
      -- before a window shows it, so FileType + vim.wo would miss)
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function(ev)
          if vim.bo[ev.buf].filetype == "atone" then
            for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
              vim.wo[win].winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat"
            end
          end
        end,
      })
    end,
  },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    opts = {},
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function(ev)
          map("n", "<leader>ur", "<cmd>RenderMarkdown buf_toggle<CR>", { buffer = ev.buf, desc = "Toggle render (md)" })
        end,
      })
    end,
  },

  -- CSV rendering
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    opts = {
      view = {
        display_mode = "border",
      },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    config = function(_, opts)
      require("csvview").setup(opts)
      local function set_csv_hl() vim.api.nvim_set_hl(0, "CsvViewHeaderLine", { link = "Title" }) end
      set_csv_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_csv_hl })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "csv", "tsv" },
        callback = function(ev)
          map("n", "<leader>ur", "<cmd>CsvViewToggle<CR>", { buffer = ev.buf, desc = "Toggle render (csv)" })
        end,
      })
    end,
  },

  -- Neovim API + plugin types for lua_ls
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  -- Todo UI
  {
    "atiladefreitas/dooing",
    keys = { { "<leader>td", desc = "Open Global Todo List" } },
    config = function() require("dooing").setup({}) end,
  },

  -- Mermaid previews
  {
    "kevalin/mermaid.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "MermaidPreview", "MermaidRender", "MermaidFormat" },
    config = function() require("mermaid").setup() end,
  },
})

-- Auto-update lazy.nvim plugins on every startup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function() require("lazy").sync({ show = false }) end)
  end,
})
