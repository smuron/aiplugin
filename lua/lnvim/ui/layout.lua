local M = {}
local constants = require("lnvim.constants")
local buffers = require("lnvim.ui.buffers")

function M.create_layout()
	local width = vim.o.columns
	local height = vim.o.lines

	-- Calculate dimensions
	local col1_width = math.floor(width * 0.4)
	local col2_width = math.floor(width * 0.25)
	local col3_width = math.floor(width * 0.25)

	local row1_height = math.floor(height * 0.3)
	local row2_height = 4
	local row3_height = height - row1_height - row2_height
	local layout = {}

	-- Function to find or create a window for a specific buffer
	layout.main = vim.api.nvim_get_current_win()

	-- Create column layout
	vim.cmd("vsplit")
	vim.cmd("wincmd L")
	layout.diff = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buffers.diff_buffer)
	vim.cmd("vsplit")
	layout.files = vim.api.nvim_get_current_win()

	-- Set buffers to windows
	vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buffers.files_buffer)

	-- Create todo window
	vim.cmd("split")
	layout.todo = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buffers.todo_buffer)

	-- Create work window
	vim.cmd("split")
	layout.work = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buffers.work_buffer)

	vim.cmd("wincmd h")
	vim.cmd("wincmd h")
	-- Set window sizes
	vim.cmd("vertical resize " .. col1_width)
	vim.cmd("wincmd l")
	vim.cmd("vertical resize " .. col2_width)
	vim.cmd("wincmd l")
	vim.cmd("vertical resize " .. col3_width)
	vim.cmd("resize " .. row1_height)
	vim.cmd("wincmd j")
	vim.cmd("resize " .. row2_height)
	-- Update layout table with new window IDs
	layout.main = vim.fn.win_findbuf(vim.api.nvim_get_current_buf())[1]
	layout.diff = vim.fn.win_findbuf(buffers.diff_buffer)[1]
	layout.files = vim.fn.win_findbuf(buffers.files_buffer)[1]
	layout.todo = vim.fn.win_findbuf(buffers.todo_buffer)[1]
	layout.work = vim.fn.win_findbuf(buffers.work_buffer)[1]
	M.layout = layout
	return layout
end

function M.get_layout()
	return M.layout
end

function M.close_layout()
	pcall(vim.api.nvim_win_close, M.layout.diff, true)
	pcall(vim.api.nvim_win_close, M.layout.files, true)
	pcall(vim.api.nvim_win_close, M.layout.work, true)
	pcall(vim.api.nvim_win_close, M.layout.todo, true)
	M.layout = nil
end
function M.focus_drawer()
	vim.api.nvim_set_current_win(M.layout.work)
end

local function init_buffer(buf)
	if buf ~= nil then
		return buf
	end
	return vim.api.nvim_create_buf(false, true)
end

function M.show_drawer()
	-- Set up buffers
	buffers.work_buffer = init_buffer(buffers.work_buffer)
	buffers.todo_buffer = init_buffer(buffers.todo_buffer)
	buffers.diff_buffer = init_buffer(buffers.diff_buffer)
	buffers.files_buffer = init_buffer(buffers.files_buffer)
	buffers.new_version_buffer = init_buffer(buffers.new_version_buffer)
	local layout = M.create_layout()
	-- Mount the layout

	-- Set up buffer options
	vim.api.nvim_buf_set_name(
		buffers.work_buffer,
		"~" .. os.date("!%Y-%m-%d_%H-%M-%S_prompt") .. "." .. constants.filetype_ext
	)

	vim.api.nvim_buf_set_name(
		buffers.diff_buffer,
		"~" .. os.date("!%Y-%m-%d_%H-%M-%S_out") .. "." .. constants.filetype_ext
	)
	-- diff buffer opts
	vim.api.nvim_win_set_option(layout.diff, "wrap", true)

	-- Focus on the prompt window
	vim.api.nvim_set_current_win(layout.work)
end

return M
