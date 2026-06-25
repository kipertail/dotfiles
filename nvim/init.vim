:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a
:set background=dark

call plug#begin()

" Визуальные плагины
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'whatyouhide/vim-gotham'
Plug 'cj/vim-webdevicons'
Plug 'nvim-lualine/lualine.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'diegoulloao/neofusion.nvim'
Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
Plug 'olimorris/onedarkpro.nvim'
Plug 'dasupradyumna/midnight.nvim'
Plug 'm4xshen/autoclose.nvim'
Plug 'EdenEast/nightfox.nvim'
Plug 'metalelf0/base16-black-metal-scheme'
Plug 'loctvl842/monokai-pro.nvim'

" Go плагины
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }

" LSP и сопутствующие плагины
Plug 'neovim/nvim-lspconfig'                          " Конфигурация LSP (пока нужен для некоторых функций)
Plug 'williamboman/mason.nvim'                        " Менеджер установки LSP серверов
Plug 'williamboman/mason-lspconfig.nvim'              " Мост между mason и lspconfig
Plug 'hrsh7th/nvim-cmp'                                " Автодополнение
Plug 'hrsh7th/cmp-nvim-lsp'                            " Источник для LSP
Plug 'hrsh7th/cmp-buffer'                              " Источник из буфера
Plug 'hrsh7th/cmp-path'                                " Источник для путей
Plug 'hrsh7th/cmp-cmdline'                             " Источник для командной строки
Plug 'L3MON4D3/LuaSnip'                                " Поддержка сниппетов
Plug 'saadparwaiz1/cmp_luasnip'                        " Источник для сниппетов
Plug 'nvim-lua/plenary.nvim'                           " Зависимость для многих плагинов
Plug 'nvimtools/none-ls.nvim'                          " Для форматирования и линтинга (замена null-ls)
Plug 'jay-babu/mason-null-ls.nvim'                     " Установка форматтеров через mason
Plug 'nvim-tree/nvim-web-devicons'                      " Иконки для LSP

" Терминал
Plug 'https://github.com/tc50cal/vim-terminal.git'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

call plug#end()

" Настройки vim-go (упрощенные, так как LSP будет основным)
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 0  " Отключаем автоформатирование vim-go, будет через none-ls
let g:go_imports_autosave = 0
let g:go_metalinter_autosave = 0
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'

colorscheme monokai-pro-spectrum 

" Настройка Mason для установки LSP серверов
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls" },  -- Устанавливаем gopls автоматически
  automatic_installation = true,
})

-- Настройка LSP для Go с использованием нового API vim.lsp.config
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Регистрируем конфигурацию для gopls
vim.lsp.config['gopls'] = {
  cmd = {'gopls'},
  filetypes = {'go', 'gomod', 'gowork', 'gotmpl'},
  root_markers = {'go.work', 'go.mod', '.git'},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,  -- Использовать gofumpt для форматирования
    },
  },
  capabilities = capabilities,
}

-- Включаем LSP для файлов Go
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'go', 'gomod', 'gowork', 'gotmpl'},
  callback = function()
    vim.lsp.start('gopls')
  end,
})

-- Настройка none-ls для форматирования и линтинга (замена null-ls)
local null_ls = require("null-ls")  -- none-ls использует тот же API
local mason_null_ls = require("mason-null-ls")

mason_null_ls.setup({
  ensure_installed = {
    "gofumpt",      -- Форматтер (более строгая версия gofmt)
    "goimports",    -- Управление импортами
    "golangci-lint", -- Линтер
  },
  automatic_installation = true,
})

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.gofumpt,    -- Форматирование
    null_ls.builtins.formatting.goimports,  -- Импорты
    null_ls.builtins.diagnostics.golangci_lint, -- Линтинг
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
EOF

" Настройка автодополнения nvim-cmp
lua << EOF
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- Настройка автодополнения для командной строки
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
EOF

" Базовые LSP маппинги
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> <space>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <space>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> [d <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> <space>e <cmd>lua vim.diagnostic.open_float()<CR>

" Настройки toggleterm и lualine
lua require("toggleterm").setup()
lua << EOF
require('lualine').setup({
  options = {
    theme = require('neofusion.lualine'),
    component_separators = { left = '|', right = '|'},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
})
EOF

lua << EOF
require("autoclose").setup()
EOF

" Ваши настройки навигации
nnoremap <C-m> :NERDTreeFind<CR>
nnoremap <C-,> :NERDTreeToggle<CR>
nnoremap <C-n> :ToggleTerm<CR>
tnoremap <C-n> <C-\><C-n>:ToggleTerm<CR>
tnoremap <C-space> <C-\><C-n><C-w>p
nnoremap <C-space> <C-w>p

nnoremap <A-1> 1gt
nnoremap <A-2> 2gt
nnoremap <A-3> 3gt
nnoremap <A-4> 4gt
nnoremap <A-5> 5gt
nnoremap <A-6> 6gt
nnoremap <A-7> 7gt
nnoremap <A-8> 8gt
nnoremap <A-9> 9gt
nnoremap <A-0> :tablast<CR>

nnoremap <A-t> :tab split<CR>
nnoremap <A-d> :tab split<CR>:tabnext<
