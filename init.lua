-- debug browser
-- local url = "http://localhost:8080"
-- local url = "http://localhost:8081/vr/Rx1kDxqkJ38"
local url = "http://localhost:8081/vr/L75OgaYLkB2"
-- constant
local home = os.getenv("HOME")

-- Use Space as leader
vim.keymap.set("n", " ", "<Nop>", { silent = true })
vim.g.mapleader = " "

-- package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local packages = {
	-- ========== Move & Edit ================================================================
	-- easymotion
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
	},
	-- jump between parens
	"andymass/vim-matchup",
	-- comment
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				toggler = {
					line = "<C-/>",
					block = "<leader><C-/>",
				},
				opleader = {
					line = "<C-/>",
					block = "<leader><C-/>",
				},
			})
		end,
	},
}

if vim.g.vscode then
	vim.cmd("nmap j gj")
	vim.cmd("nmap k gk")
else
	for _, package in ipairs({
		-- smooth scroll
		{
			'declancm/cinnamon.nvim',
			config = function()
				require('cinnamon').setup({
					extra_keymaps = true,
					override_keymaps = true,
					max_length = 50,
				})
			end
		},
		-- multi edit
		"mg979/vim-visual-multi",
		-- go back & forth
		"ckarnell/history-traverse",
		-- autoclose parens
		{
			"m4xshen/autoclose.nvim",
			config = function()
				require("autoclose").setup()
			end,
		},
		-- fold
		{
			"kevinhwang91/nvim-ufo",
			dependencies = "kevinhwang91/promise-async",
			config = function()
				vim.o.foldcolumn = "1" -- '0' is not bad
				vim.o.foldlevel = 99
				vim.o.foldlevelstart = 99
				vim.o.foldenable = true
				require("ufo").setup()
			end,
		},
		-- manager todo list
		{
			"folke/todo-comments.nvim",
			requires = "nvim-lua/plenary.nvim",
			config = function()
				require("todo-comments").setup({})
			end,
		},
		-- ========== Feature Add-on ==================================
		-- key mapping visualizer
		{
			"folke/which-key.nvim",
			config = function()
				vim.o.timeout = true
				vim.o.timeoutlen = 100
				require("which-key").setup()
			end,
		},
		-- search
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.1",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		-- replace by regex
		{
			"nvim-pack/nvim-spectre",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		-- zenmode (:Goyo)
		"junegunn/goyo.vim",
		-- live server
		{
			"barrett-ruth/live-server.nvim",
			build = "npm i -g live-server",
			config = true,
		},
		-- interactive scratchpad
		"metakirby5/codi.vim",
		-- =========== Language Support ================================
		-- Langu LSP
		{
			"neovim/nvim-lspconfig",
			-- install lsp
			build = function()
				-- python
				os.execute("pip install jedi")
				-- ts, js
				os.execute("npm install -g typescript typescript-language-server")
				-- lua
				os.execute("brew install lua-language-server")
				-- html
				os.execute("npm i -g vscode-langservers-extracted")
			end,
			dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "hrsh7th/nvim-cmp" },
			config = function()
				local lspconfig = require("lspconfig")
				-- autocompletion capabilities
				local capabilities = require("cmp_nvim_lsp").default_capabilities()
				-- lsp settings
				-- js, ts
				lspconfig.tsserver.setup({ capabilities = capabilities })
				-- python
				lspconfig.pylsp.setup({
					capabilities = capabilities,
					settings = {
						pylsp = {
							plugins = {
								rope_autoimport = { enabled = false },
								rope_completion = { enabled = false },
								pyflakes = { enabled = false },
								pycodestyle = { enabled = false },
								mccabe = { enabled = false },
								pydocstyle = { enabled = false },

								autopep8 = { enabled = false },
								yapf = { enabled = false },
								flake8 = { enabled = false },
								pylint = { enabled = false },
							},
						},
					},
				})
				-- lua
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
							telemetry = { enable = false },
						},
					},
				})
				-- html
				lspconfig.html.setup({
					capabilities = capabilities
				})
				-- activate snippet and autocompletion
				local cmp = require("cmp")
				cmp.setup({
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-Space>"] = cmp.mapping.complete(),
						["<CR>"] = cmp.mapping.confirm({
							behavior = cmp.ConfirmBehavior.Replace,
							select = true,
						}),
					}),
					sources = {
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
					},
				})
			end,
		},
		-- DAP
		{
			"mfussenegger/nvim-dap",
			config = function()
				local dap = require("dap")
				-- lua
				dap.configurations.lua = {
					{
						type = "nlua",
						request = "attach",
						name = "Attach to running Neovim instance",
					},
				}
				dap.adapters.nlua = function(callback, config)
					callback({
						type = "server",
						host = config.host or "127.0.0.1",
						port = config.port or 8086
					})
				end
			end,
		},
		{
			-- activate dap javascript, typescript
			"mxsdev/nvim-dap-vscode-js",
			dependencies = "mfussenegger/nvim-dap",
			config = function()
				require("dap-vscode-js").setup({
					debugger_path = home .. "/programms/vscode-js-debug",
					adapters = { "pwa-node", "pwa-chrome" },
				})
				for _, language in ipairs({ "typescript", "javascript" }) do
					require("dap").configurations[language] = {
						{
							type = "pwa-node",
							request = "launch",
							name = "Launch file",
							program = "${file}",
							cwd = "${workspaceFolder}",
						},
						{
							type = "pwa-node",
							request = "attach",
							name = "Attach",
							processId = require("dap.utils").pick_process,
							cwd = "${workspaceFolder}",
						},
						-- run google-chrome-stable --remote-debugging-port=9222
						{
							type = "pwa-chrome",
							request = "launch",
							name = "Launch Browser",
							program = "${file}",
							cwd = "${workspaceFolder}",
							sourceMaps = true,
							protocol = "inspector",
							url = url,
							port = 9222,
							webRoot = "${workspaceFolder}",
						},
						{
							type = "pwa-chrome",
							request = "attach",
							name = "Attach Browser",
							outFiles = {
								"${workspaceFolder}/**/*.js",
								"!**/node_modules/**"
							},
							pathMapping = {
								-- A mapping of URLs/paths to local folders, to resolve scripts in the Browser to scripts on disk
							},
							-- Port to use to remote debugging the browser, given as --remote-debugging-port when launching the browser.
							port = 9222,
							-- A set of mappings for rewriting the locations of source files from what the sourcemap says, to their locations on disk.
							sourceMapPathOverrides = {
								["webpack:///./~/*"] = "${webRoot}/node_modules/*",
								["webpack:////*"] = "/*",
								["webpack://@?:*/?:*/*"] = "${webRoot}/*",
								["webpack://?:*/*"] = "${webRoot}/*",
								["webpack:///([a-z]):/(.+)"] = "$1:/$2",
								["meteor://💻app/*"] = "${webRoot}/*"
							},
							sourceMaps = true,
							-- Will search for a tab with this exact url and attach to it, if found
							url = url,
							-- A list of file glob patterns to find *.vue components. By default, searches the entire workspace. This needs to be specified due to extra lookups that Vue's sourcemaps require in Vue CLI 4. You can disable this special handling by setting this to an empty array.
							vueComponentPaths = {
								"${workspaceFolder}/**/*.vue",
								"!**/node_modules/**"
							},
							-- This specifies the workspace absolute path to the webserver root. Used to resolve paths like /app.js to files on disk. Shorthand for a pathMapping for "/"

							webRoot = "${workspaceFolder}"
						},
					}
				end
			end,
		},
		{
			"mfussenegger/nvim-dap-python",
			dependencies = "mfussenegger/nvim-dap",
			build = function()
				os.execute([[
 				mkdir ~/.virtualenvs
 				cd ~/.virtualenvs
 				python3 -m venv debugpy
 				debugpy/bin/python -m pip install debugpy
 			]])
				vim.cmd("TSInstall python")
			end,
			config = function()
				require("dap-python").setup(home .. "/.virtualenvs/debugpy/bin/python")
			end,
		},
		{
			-- debug UI
			"rcarriga/nvim-dap-ui",
			dependencies = { "mfussenegger/nvim-dap" },
			config = function()
				require("dapui").setup()
				local dap, dapui = require("dap"), require("dapui")
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close()
				end
			end,
		},
		-- problems & warnings diagnosis
		{
			"folke/trouble.nvim",
			dependencies = "nvim-tree/nvim-web-devicons",
			config = function()
				require("trouble").setup({})
			end,
		},
		-- formatter & linter
		{
			"jose-elias-alvarez/null-ls.nvim",
			build = function()
				os.execute('cargo install stylua')
			end,
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				local null_ls = require("null-ls")
				local formatting = null_ls.builtins.formatting
				local code_actions = null_ls.builtins.code_actions
				local diagnostics = null_ls.builtins.diagnostics
				local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
				null_ls.setup({
					sources = {
						--python
						diagnostics.mypy.with({
							method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
						}),
						-- diagnostics.ruff,
						formatting.black,
						-- web
						code_actions.eslint_d,
						formatting.prettierd,
						-- c++
						diagnostics.clazy,
						-- diagnostics.cpp_check,
						diagnostics.gccdiag,
						formatting.clang_format,
						-- lua
						formatting.stylua,
					},
					diagnostics_format = [[#{c}:#{m} #{s}]],
					-- format on save
					on_attach = function(client, bufnr)
						local async_formatting = function(bufnr)
							bufnr = bufnr or vim.api.nvim_get_current_buf()

							vim.lsp.buf_request(
								bufnr,
								"textDocument/formatting",
								vim.lsp.util.make_formatting_params({}),
								function(err, res, ctx)
									if err then
										local err_msg = type(err) == "string" and
										    err or
										    err.message
										-- you can modify the log message / level (or ignore it completely)
										vim.notify("formatting: " .. err_msg,
											vim.log.levels.WARN)
										return
									end

									-- don't apply results if buffer is unloaded or has been modified
									if
									    not vim.api.nvim_buf_is_loaded(bufnr)
									    or vim.api.nvim_buf_get_option(bufnr, "modified")
									then
										return
									end

									if res then
										local client = vim.lsp.get_client_by_id(
											ctx
											.client_id)
										vim.lsp.util.apply_text_edits(
											res,
											bufnr,
											client and client
											.offset_encoding or
											"utf-16"
										)
										vim.api.nvim_buf_call(bufnr, function()
											vim.cmd(
												"silent noautocmd update")
										end)
									end
								end
							)
						end
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = augroup,
								buffer = bufnr,
								callback = function()
									async_formatting(bufnr)
									-- vim.lsp.buf.format() -- sync_formatting
								end,
							})
						end
					end,
				})
			end,
		},
		-- floating window for text input & output
		{
			"folke/noice.nvim",
			config = function()
				require("noice").setup()
			end,
			dependencies = {
				"MunifTanjim/nui.nvim",
				"rcarriga/nvim-notify",
			},
		},
		-- ============= style & UI =================================================
		-- startup screen
		"goolord/alpha-nvim",
		-- file explorer
		{
			"nvim-tree/nvim-tree.lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("nvim-tree").setup({
					git = {
						ignore = false,
					},
				})
			end,
		},
		-- color schemes
		{
			"folke/tokyonight.nvim",
			config = function()
				vim.cmd([[colorscheme tokyonight-moon]])
			end,
		},
		-- dim inactive window
		{
			'sunjon/shade.nvim',
			config = function()
				require 'shade'.setup({
					overlay_opacity = 60,
					opacity_step = 1,
				})
			end
		},
		-- status bar
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("lualine").setup()
			end,
		},
		-- tab
		{
			"romgrk/barbar.nvim",
			-- "akinsho/bufferline.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons", "lewis6991/gitsigns.nvim" },
			init = function()
				vim.g.barbar_auto_setup = true
			end,
			opts = {
				focus_on_close = "left",
				separator = { left = "▎", right = "" },
				sidebar_filetypes = {
					NvimTree = true,
				},
			},
		},
		-- indent guide
		{
			"lukas-reineke/indent-blankline.nvim",
			dependencies = "nvim-treesitter/nvim-treesitter",
			config = function()
				require("indent_blankline").setup({
					show_current_context = true,
					show_current_context_start = true,
				})
			end,
		},
		-- symbol tree
		{
			'simrat39/symbols-outline.nvim',
			config = function() require("symbols-outline").setup() end
		},
		-- highlight hovered symbol
		{
			'RRethy/vim-illuminate',
		},
		-- ============= tool chains ===========================================
		-- git
		{
			'sindrets/diffview.nvim',
			dependencies = 'nvim-lua/plenary.nvim',
			config = function()
				require 'diffview'.setup {
					file_panel = {
						listing_style = "list",
					},
				}
			end
		},
		-- github
		{
			'pwntester/octo.nvim',
			dependencies = {
				'nvim-lua/plenary.nvim',
				'nvim-telescope/telescope.nvim',
				'nvim-tree/nvim-web-devicons',
			},
			config = function()
				require "octo".setup()
			end
		},
	}) do
		table.insert(packages, package)
	end
end

require("lazy").setup(packages)

if vim.g.vscode then
else
	-- ========= actual setup of the above packages go here =============
	require('style')

	-- key mappings
	require("which-key").register({
		-- window navigation
		["<C-s>"] = { "<cmd>w<cr>", "save" },
		["<C-q>"] = { "<cmd>q<cr>", "close" },
		["<C-,>"] = "split window down",
		["<C-.>"] = "split window right",
		["<C-j>"] = "move N windows down",
		["<C-k>"] = "move N windows up",
		["<C-h>"] = "move N windows left",
		["<C-l>"] = "move N windows right",
		["<M-j>"] = "decrease window height",
		["<M-k>"] = "increase window height",
		["<M-h>"] = "decrease window width",
		["<M-l>"] = "increase window width",
		["<M-m>"] = "maximize window",
		["<M-,>"] = "minimize window",
		["<M-.>"] = "equalize window",
		["<C-n>"] = "multiple line edit",
		-- tab
		['<A-o>'] = { "<cmd>BufferPick<cr>", "tab" },
		['<A-u'] = "tab pre",
		['<A-i>'] = "tab next",
		['<A-q>'] = { "<cmd>BufferClose!<cr>", "tab close" },
		["<F2>"] = { "<cmd>lua vim.lsp.buf.rename()<cr>", "rename" },
		["<F5>"] = { "<cmd>lua require'osv'.run_this({port = 8086})<cr>", "run & debug this file" },
		["<C-'>"] = { "<cmd>lua require'dap'.step_over()<cr>", "step over" },
		["<C-;>"] = { "<cmd>lua require'dap'.step_into()<cr>", "step into" },
		["<C-:>"] = { "<cmd>lua require'dap'.step_out()<cr>", "step out" },
		["<C-\\>"] = { "<cmd>lua require'dap'.continue()<cr>", "continue" },
		["<C-t>"] = { "terminal" },
		g = {
			h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "info" },
			d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "go to definition" },
			t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "go to type" },
			i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "go to implementations" },
		},
		["<leader>"] = {
			d = { "<cmd>lua require'dapui'.toggle()<cr>", "breakpoint" },
			b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "breakpoint" },
			B = { "<cmd>lua require'dap'.set_exception_breakpoints()<cr>", "conditional breakpoint" },
			r = { "<cmd>Telescope lsp_references<cr>", "go to references" },
			c = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "code action" },
			C = { "<cmd>CodiNew<cr>", "interactive scratchpad" },
			K = { "<cmd>WhichKey ''<cr>", "key mappings" },
			e = { "<cmd>NvimTreeToggle ''<cr>", "file explorer" },
			f = {
				name = "+find",
				w = { "<cmd>Telescope live_grep<cr>", "word" },
				b = { "<cmd>Telescope buffers<cr>", "buffers" },
				h = { "<cmd>Telescope help_tags<cr>", "helps" },
				m = { "<cmd>Telescope marks<cr>", "bookmarks" },
				k = { "<cmd>Telescope keymaps<cr>", "keymaps" },
				t = { "<cmd>TodoLocList<cr>", "todos" },
				s = { "<cmd>SymbolsOutline<cr>", "symbols" },
				["<leader>"] = { ":Telescope<cr>", "Telescope" },
			},
			p = { "<cmd>Telescope find_files<cr>", "files" },
			m = { '<cmd>Telescope lsp_document_symbols symbols={"method"}<cr>', "methods" },
			F = { "<cmd>Format<cr>", "format" },
			R = { "<cmd>Spectre<cr>", "search & replace all files" },
			P = { "<cmd>Trouble<cr>", "problems & warnings" },
			[","] = { "<cmd>HisTravBack<cr>", "go back" },
			["."] = { "<cmd>HisTravForward<cr>", "go forward" },
			["<leader>"] = {
				b = { "<cmd>lua require'dap'.clear_breakpoints()<cr>", "clear breakpoints" },
				c = { "<cmd>Telescope colorscheme<cr>", "colorscheme" },
				g = {
					":terminal /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --remote-debugging-port=9222 " ..
					url .. "<cr>",
					"browser" },
			},
			z = { "<cmd>Goyo<cr>", "zenmode" },
			i = { "<cmd>e ~/.config/nvim/init.lua<cr>", "init.lua" },
			-- git
			g = {
				name = "+git",
				b = { ":Telescope git_branches<cr>", "branch" },
				d = { ":DiffviewOpen<cr>", "diff" },
				p = {
					name = "PR",
					l = { ":Octo pr list<cr>", "list" },
					c = { ":Octo pr create<cr>", "create" },
					b = { ":Octo pr browser<cr>", "browser" },
				},
			},
			t = { ':lua print(os.date("%y/%m/%d %H:%M:%S"))<cr>', "time" }

		},
		s = "jump forward to",
		S = "jump back to",
	})
	-- window
	vim.cmd("nnoremap <C-j> <C-w>j")
	vim.cmd("nnoremap <C-k> <C-w>k")
	vim.cmd("nnoremap <C-h> <C-w>h")
	vim.cmd("nnoremap <C-l> <C-w>l")
	vim.cmd("nnoremap <M-j> 6<C-w>-")
	vim.cmd("nnoremap <M-k> 6<C-w>+")
	vim.cmd("nnoremap <M-h> 10<C-w><")
	vim.cmd("nnoremap <M-l> 10<C-w>>")
	vim.cmd("nnoremap <M-m> 500<C-w>+500<C-w>>")
	vim.cmd("nnoremap <M-,> 500<C-w>-500<C-w><")
	vim.cmd("nnoremap <M-.> <C-w>=")
	vim.cmd("nnoremap <C-.> <C-w>v<C-w>l")
	vim.cmd("nnoremap <C-,> <C-w>s<C-w>j")
	-- terminal
	vim.keymap.set('n', '<C-t>', '<cmd>terminal<cr>i')
	vim.cmd("tnoremap <C-t> <C-\\><C-n><cmd>terminal<cr>i")
	vim.cmd("tnoremap <Esc> <C-\\><C-n>")
	vim.cmd("tnoremap <C-q> <C-\\><C-n>:q<cr>")
	vim.cmd("tnoremap <C-j> <C-\\><C-n><C-w>j")
	vim.cmd("tnoremap <C-k> <C-\\><C-n><C-w>k")
	vim.cmd("tnoremap <C-h> <C-\\><C-n><C-w>h")
	vim.cmd("tnoremap <C-l> <C-\\><C-n><C-w>l")
	vim.cmd("tnoremap <A-u> <C-\\><C-n><cmd>BufferPrevious<cr>")
	vim.cmd("tnoremap <A-i> <C-\\><C-n><cmd>BufferNext<cr>")
	vim.cmd("tnoremap <A-o> <C-\\><C-n><cmd>BufferPick<cr>")
	vim.cmd("tnoremap <A-q> <C-\\><C-n><cmd>BufferClose!<cr>")
	vim.cmd("tnoremap <C-.> <C-\\><C-n><C-w>v<C-w>l<cmd>terminal<cr>i")
	vim.cmd("tnoremap <C-,> <C-\\><C-n><C-w>s<C-w>j<cmd>terminal<cr>i")
	vim.cmd("tnoremap <A-j> <C-\\><C-n>6<C-w>-i")
	vim.cmd("tnoremap <A-k> <C-\\><C-n>6<C-w>+i")
	vim.cmd("tnoremap <A-h> <C-\\><C-n>10<C-w><i")
	vim.cmd("tnoremap <A-l> <C-\\><C-n>10<C-w>>i")
	vim.cmd("tnoremap <A-m> <C-\\><C-n>500<C-w>+500<C-w>>i")
	vim.cmd("tnoremap <A-,> <C-\\><C-n>500<C-w>-500<C-w><i")
	vim.cmd("tnoremap <A-.> <C-\\><C-n><C-w>=i")
	-- tab
	vim.keymap.set('n', '<A-u>', '<cmd>BufferPrevious<cr>')
	vim.keymap.set('n', '<A-i>', '<cmd>BufferNext<cr>')

	-- autocmd
	-- open help window in a vertical split to the right.
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = vim.api.nvim_create_augroup("help_window_right", {}),
		pattern = { "*.txt" },
		callback = function()
			if vim.o.filetype == "help" then
				vim.cmd.wincmd("L")
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "zsh" },
		command = "startinsert",
	})

	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("startup_screen", {}),
		pattern = { "NvimTree_1" },
		callback = function()
			vim.cmd("Alpha")
		end,
	})

	-- ============= style ================================================
	vim.cmd("set nowrap")
	-- vim.cmd("set number")
end

-- copy to clipboad
vim.cmd("set clipboard=unnamed")
