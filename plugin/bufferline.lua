-- File: bufferline.vim
-- Author: romgrk
-- Description: Buffer line
-- Date: Fri 22 May 2020 02:22:36 AM EDT
-- !::exe [So]

local bufferline = require 'bufferline'

vim.opt.showtabline = 2

--------------------
-- Section: Commands
--------------------

vim.api.nvim_create_user_command('BarbarEnable', bufferline.enable, {desc = 'Enable barbar.nvim'})
vim.api.nvim_create_user_command('BarbarDisable', bufferline.disable, {desc = 'Disable barbar.nvim'})

vim.api.nvim_create_user_command(
  'BufferNext',
  function(tbl) require'bufferline.state'.goto_buffer_relative(math.max(tbl.count, 1)) end,
  {count = true, desc = 'Go to the next buffer'}
)

vim.api.nvim_create_user_command(
  'BufferPrevious',
  function(tbl) require'bufferline.state'.goto_buffer_relative(-math.max(tbl.count, 1)) end,
  {count = true, desc = 'Go to the previous buffer'}
)

vim.api.nvim_create_user_command(
  'BufferGoto',
  function(tbl) require'bufferline.state'.goto_buffer(tbl.args) end,
  {desc = 'Go to the buffer at the specified index', nargs = 1}
)

vim.api.nvim_create_user_command('BufferLast', '<Cmd>BufferGoto 1<CR>', {desc = 'Go to the first buffer'})
vim.api.nvim_create_user_command('BufferLast', '<Cmd>BufferGoto -1<CR>', {desc = 'Go to the last buffer'})

vim.api.nvim_create_user_command(
  'BufferMove',
  function(tbl) vim.api.nvim_command('<Cmd>BufferMovePrevious ' .. tbl.count .. '<CR>') end,
  {count = true, desc = 'Synonym for `:BufferMovePrevious`'}
)

vim.api.nvim_create_user_command(
  'BufferMoveNext',
  function(tbl) require'bufferline.state'.move_current_buffer(math.max(tbl.count, 1)) end,
  {count = true, desc = 'Move the current buffer to the right'}
)

vim.api.nvim_create_user_command(
  'BufferMovePrevious',
  function(tbl) require'bufferline.state'.move_current_buffer(-math.max(tbl.count, 1)) end,
  {count = true, desc = 'Move the current buffer to the left'}
)

vim.api.nvim_create_user_command('BufferPick', function() require'bufferline.jump_mode'.activate() end, {desc = 'Pick a buffer'})

vim.api.nvim_create_user_command('BufferPin', function() require'bufferline.state'.toggle_pin() end, {desc = 'Un/pin a buffer'})

vim.api.nvim_create_user_command(
  'BufferOrderByBufferNumber',
  function() require'bufferline.state'.order_by_buffer_number() end,
  {desc = 'Order the bufferline by buffer number'}
)

vim.api.nvim_create_user_command(
  'BufferOrderByDirectory',
  function() require'bufferline.state'.order_by_directory() end,
  {desc = 'Order the bufferline by directory'}
)

vim.api.nvim_create_user_command(
  'BufferOrderByLanguage',
  function() require'bufferline.state'.order_by_language() end,
  {desc = 'Order the bufferline by language'}
)

vim.api.nvim_create_user_command(
  'BufferOrderByWindowNumber',
  function() require'bufferline.state'.order_by_window_number() end,
  {desc = 'Order the bufferline by window number'}
)

vim.api.nvim_create_user_command(
  'BufferClose',
  function(tbl) require'bbye'.delete('bdelete', tbl.bang and '!' or '', tbl.args, tbl.mods) end,
  {bang = true, complete = 'buffer', desc = 'Close the current buffer.', nargs = '?'}
)

vim.api.nvim_create_user_command(
  'BufferDelete',
  function(tbl) require'bbye'.delete('bdelete', tbl.bang and '!' or '', tbl.args, tbl.mods) end,
  {bang = true, complete = 'buffer', desc = 'Synonym for `:BufferClose`', nargs = '?'}
)

vim.api.nvim_create_user_command(
  'BufferWipeout',
  function(tbl) require'bbye'.delete('bwipeout', tbl.bang and '!' or '', tbl.args, tbl.mods) end,
  {bang = true, complete = 'buffer', desc = 'Wipe out the buffer', nargs = '?'}
)

vim.api.nvim_create_user_command(
  'BufferCloseAllButCurrent',
  function() require'bufferline.state'.close_all_but_current() end,
  {desc = 'Close every buffer except the current one'}
)

vim.api.nvim_create_user_command(
  'BufferCloseAllButPinned',
  function() require'bufferline.state'.close_all_but_pinned() end,
  {desc = 'Close every buffer except pinned buffers'}
)

vim.api.nvim_create_user_command(
  'BufferCloseAllButCurrentOrPinned',
  function() require'bufferline.state'.close_all_but_current_or_pinned() end,
  {desc = 'Close every buffer except pinned buffers or the current buffer'}
)

vim.api.nvim_create_user_command(
  'BufferCloseBuffersLeft',
  function() require'bufferline.state'.close_buffers_left() end,
  {desc = 'Close all buffers to the left of the current buffer'}
)

vim.api.nvim_create_user_command(
  'BufferCloseBuffersRight',
  function() require'bufferline.state'.close_buffers_right() end,
  {desc = 'Close all buffers to the right of the current buffer'}
)

-------------------
-- Section: Options
-------------------

local DEFAULT_OPTIONS = {
  animation = true,
  auto_hide = false,
  clickable = true,
  closable = true,
  exclude_ft = nil,
  exclude_name = nil,
  icon_close_tab = '',
  icon_close_tab_modified = '●',
  icon_pinned = '',
  icon_separator_active =   '▎',
  icon_separator_inactive = '▎',
  icons = true,
  icon_custom_colors = false,
  insert_at_start = false,
  insert_at_end = false,
  letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
  maximum_padding = 4,
  maximum_length = 30,
  no_name_title = nil,
  semantic_letters = true,
  tabpages = true,
}

vim.g.bufferline = vim.tbl_extend('keep', vim.g.bufferline or {}, DEFAULT_OPTIONS)

vim.fn.dictwatcheradd(vim.g.bufferline, '*', 'v:lua.BufferlineOnOptionChanged')

--------------------------
-- Section: Event handlers
--------------------------

--- What to do when `vim.g.bufferline` is changed.
--- Needs to be global -_-
--- @param key string what option was changed.
function BufferlineOnOptionChanged(_, key, _)
  vim.g.bufferline = vim.tbl_extend('keep', vim.g.bufferline or {}, DEFAULT_OPTIONS)
  if key == 'letters' then
    require'bufferline.jump_mode'.initialize_indexes()
  end
end

--- What to do when clicking.
--- Needs to be global -_-
--- @param btn string
--- @param minwid number
function BufferlineMainClickHandler(minwid, _, btn, _)
  if minwid == 0 then
    return
  end

  -- NOTE: in Vimscript this was not `==`, it was a regex compare `=~`
  if btn == 'm' then
    require'bbye'.delete('bdelete', '', minwid)
  else
    require'bufferline.state'.open_buffer_in_listed_window(minwid)
  end
end

--- What to do when clicking the close button.
--- Needs to be global -_-
--- @param minwid number
function BufferlineCloseClickHandler(minwid, _, _, _)
  require'bbye'.delete('bdelete', '', minwid)
end


-- Final setup
bufferline.enable()
