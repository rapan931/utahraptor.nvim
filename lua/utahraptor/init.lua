local fn = vim.fn
local api = vim.api

-- Add 'Utahraptor' hightlight group
local augroup = api.nvim_create_augroup("Utahraptor", {})
api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = function() api.nvim_set_hl(0, 'Utahraptor', { bg = 'Purple', fg = 'White' }) end,
  desc = "Set Utahraptor highlight group",
})
api.nvim_set_hl(0, 'Utahraptor', { bg = 'Purple', fg = 'White' })

---@class utahraptorConfig
---@field flash_ms number flash time(ms)
---@field flash_hl_group string flash hightlignt group
local config = {
  flash_ms = 500,
  flash_hl_group = 'Utahraptor'
}

---@param flash_ms number
---@param flash_hl_group string
local function l_flash(flash_ms, flash_hl_group)
  local win_id = fn.win_getid()
  local pattern = fn.getreg('/')
  local last_backslash_chars = fn.matchstr(pattern, [[\\\+$]])

  local end_cars
  if #last_backslash_chars == 0 then
    end_cars = [[\)]]
  elseif #pattern == 1 then
    -- /\<CR>
    end_cars = [[\\)]]
  elseif #last_backslash_chars % 2 == 0 then
    -- /hoge\\<CR>
    -- /hoge\\\\<CR>
    end_cars = [[\)]]
  else
    -- /hoge\<CR>
    -- /hoge\\\<CR>
    end_cars = [[\\)]]
  end

  local l, c = unpack(vim.list_slice(fn.getpos('.'), 2, 3))
  local l_pattern = [[\%]] .. l .. [[l]]
  local c_pattern = [[\%]] .. c .. [[c]]
  local search_pattern = [[\c]] .. l_pattern .. c_pattern .. [[\(]] .. pattern .. end_cars

  local match_pattern_id = fn.matchadd(flash_hl_group, search_pattern, 100, -1, { window = win_id })

  local timer = vim.loop.new_timer()
  local i = 1
  local stopped = false
  local interval = 42
  timer:start(1, interval, vim.schedule_wrap(function()
    local ll, cc = unpack(vim.list_slice(fn.getpos('.'), 2, 3))
    if i * interval > flash_ms or (ll ~= l or cc ~= c) or fn.win_getid() ~= win_id then
      if not stopped then
        stopped = true
        timer:close()
        fn.matchdelete(match_pattern_id, win_id)
      end
    end
    i = i + 1
  end))
end

---@param command string command
local function do_command_and_flash(command)
  local ok, result = pcall(vim.cmd, command)

  if ok == false then
    api.nvim_echo({ { 'utahraptor.nvim: ', 'ErrorMsg' }, { result, 'ErrorMsg' } }, true, {})
    return
  end
  M.flash()
end

M = {}

---@param override utahraptorConfig
M.setup = function(override)
  config = vim.tbl_extend('force', config, override)
end

M.flash = function()
  local ok, result = pcall(l_flash, config.flash_ms, config.flash_hl_group)

  if ok == false then
    api.nvim_echo({ { 'utahraptor.nvim: ', 'ErrorMsg' }, { result, 'ErrorMsg' } }, true, {})
  end
end

M.n_flash = function()
  do_command_and_flash([[normal! n]])
end

M.N_flash = function()
  do_command_and_flash([[normal! N]])
end

return M
