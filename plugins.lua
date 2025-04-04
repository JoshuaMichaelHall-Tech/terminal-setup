return {
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end,
  },
  
  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup()
    end,
  },
  
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {}
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
    end,
  },
  
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<leader>fb', builtin.buffers)
      vim.keymap.set('n', '<leader>fh', builtin.help_tags)
    end,
  },
  
  -- LSP configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
      })
      
      local lspconfig = require('lspconfig')
      
      -- Configure language servers
      lspconfig.lua_ls.setup{}      -- Lua language server
      lspconfig.ruby_ls.setup{}     -- Ruby language server
      lspconfig.pyright.setup{}     -- Python language server
      lspconfig.tsserver.setup{}    -- TypeScript/JavaScript language server
      
      -- Global LSP mappings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      
      -- Check for format function (handles version differences)
      if vim.lsp.buf.format then
        vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
      else
        vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting)
      end
    end,
  },
  
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "lua", "ruby", "python", "javascript", "typescript", "markdown" },
        highlight = {
          enable = true,
        },
      }
    end,
  },
  
  -- Git integration
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gs', ':Git<CR>')
      vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
      vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
    end,
  },
  
  -- Auto-completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup {
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
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' }
        }),
      }
    end,
  },
  
  -- Commenting
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },
  
  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    ft = 'markdown',
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  
  -- Autopairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },
  
  -- Indentation guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    config = function()
      require('ibl').setup()
    end,
  },
  
  -- Notes system support (optional plugins for notes)
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = vim.fn.executable('make') == 1,
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },
  
  -- Which-key for showing key mappings
  {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup()
    end,
  },
}
