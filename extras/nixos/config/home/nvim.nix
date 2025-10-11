{ ... }:
{
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin.enable = true;

    plugins = {
      lualine.enable = true;

      mini = {
        enable = true;
        modules = {
          ai = {
            n_lines = 500;
          };
          comment = {
            options = {
              ignore_blank_line = false;
              start_at_beginning = false;
              pad_comment_parts = true;
            };
          };
          files = { };
          icons = { };
          indentscope = { };
          jump = {
            keys = {
              next = "]";
              prev = "[";
            };
          };
          move = {
            mappings = {
              left = "<M-h>";
              right = "<M-l>";
              down = "<M-j>";
              up = "<M-k>";
            };
            options = {
              limit_to_scope = false;
            };

          };
          notify = {
            timeout = 1000;
          };
          pairs = {
            modes = {
              insert = true;
              command = false;
              terminal = false;
            };
          };
          pick = {
            mappings = {
              caret_left = "<Left>";
              caret_right = "<Right>";
              choose = "<CR>";
              choose_in_split = "<C-s>";
              choose_in_tabpage = "<C-t>";
              choose_in_vsplit = "<C-v>";
              choose_marked = "<M-CR>";
              delete_char = "<BS>";
              delete_char_right = "<Del>";
              delete_left = "<C-u>";
              delete_word = "<C-w>";
              mark = "<C-x>";
              mark_all = "<C-a>";
              move_down = "<C-n>";
              move_start = "<C-g>";
              move_up = "<C-p>";
              paste = "<C-r>";
              refine = "<C-Space>";
              scroll_down = "<C-f>";
              scroll_left = "<C-h>";
              scroll_right = "<C-l>";
              scroll_up = "<C-b>";
              stop = "<Esc>";
              toggle_info = "<S-Tab>";
              toggle_preview = "<Tab>";
            };
          };
          starter = { };
          statusline = {
            use_icons = true;
          };
          surround = {
            mappings = {
              add = "sa"; # Add surrounding in Normal and Visual modes
              close = "q"; # Close window
              delete = "sd"; # Delete surrounding
              find = "sf"; # Find surrounding (to the right)
              find_left = "sF"; # Find surrounding (to the left)
              go_in = "l"; # Go into directory
              go_in_plus = "L"; # Go into directory and select first item
              go_out = "h"; # Go to parent directory
              go_out_plus = "H"; # Go to parent directory and select first item
              highlight = "sh"; # Highlight surrounding
              replace = "sr"; # Replace surrounding
              reset = "<BS>"; # Reset window to root directory
              reveal_cwd = "@"; # Reveal current working directory
              show_help = "g?"; # Show help
              synchronize = "="; # Synchronize window with current buffer directory
              trim_left = "<"; # Trim left
              trim_right = ">"; # Trim right
              update_n_lines = "sn"; # Update `n_lines`
            };
            windows = {
              preview = false;
              width_focus = 25;
              width_nofocus = 15;
              width_preview = 25;
            };
          };
          tabline = {
          };
          trailspace = {
            trailing_space = {
              hl = "MiniTrailspace";
              pattern = "[[\s+$]]";
            };
            trailing_tab = {
              hl = "MiniTrailspace";
              pattern = "[[\t+$]]";
            };
            trailing_newline = {
              hl = "MiniTrailspace";
              pattern = "[[\n\+$]]";
            };
          };
        };
      };

      treesitter = {
        enable = true;
        settings = {
          ensureInstalled = "all";
        };
      };

      lspconfig = {
        enable = true;
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
      };

      none-ls = {
        enable = true;
        settings = {
          ensureInstalled = "all";
        };

      };
    };

    opts = {
      number = true;
      relativenumber = true;

      tabstop = 2;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      smartindent = true;

      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;

      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      wrap = false;
      scrolloff = 8;
      sidescrolloff = 8;

      splitbelow = true;
      splitright = true;

      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];

      backup = false;
      writebackup = false;
      undofile = true;
      swapfile = false;

      updatetime = 250;
      timeoutlen = 300;
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
        options.desc = "Clear search highlights";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>q<CR>";
        options.desc = "Quit";
      }
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<CR>";
        options.desc = "Save";
      }

      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Go to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Go to lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Go to upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Go to right window";
      }

      {
        mode = "n";
        key = "<C-Up>";
        action = "<cmd>resize +2<CR>";
        options.desc = "Increase window height";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = "<cmd>resize -2<CR>";
        options.desc = "Decrease window height";
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = "<cmd>vertical resize -2<CR>";
        options.desc = "Decrease window width";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = "<cmd>vertical resize +2<CR>";
        options.desc = "Increase window width";
      }

      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>bprevious<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>bnext<CR>";
        options.desc = "Next buffer";
      }

      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>lua MiniPick.builtin.files()<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>lua MiniPick.builtin.grep_live()<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>lua MiniPick.builtin.buffers()<CR>";
        options.desc = "Find buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>lua MiniPick.builtin.help()<CR>";
        options.desc = "Find help";
      }

      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua MiniFiles.open()<CR>";
        options.desc = "Open file explorer";
      }
      {
        mode = "n";
        key = "<leader>E";
        action = "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>";
        options.desc = "Open file explorer at current file";
      }

      {
        mode = "v";
        key = "<";
        action = "<gv";
        options.desc = "Indent left and reselect";
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
        options.desc = "Indent right and reselect";
      }

      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selection up";
      }
    ];
  };
}
