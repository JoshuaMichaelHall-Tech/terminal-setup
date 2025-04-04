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
  PLUGINS
  
  create_file(file, content)
end
