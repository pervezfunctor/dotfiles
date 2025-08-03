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
          ai = { };
          comment = { };
          files = { };
          icons = { };
          icons = { };
          indentscope = { };
          jump = { };
          move = { };
          notify = { };
          pairs = { };
          pick = { };
          starter = { };
          statusline = { };
          statusline = { };
          statusline = { };
          surround = { };
          surround = { };
          tabline = { };
          trailspace = { };
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
