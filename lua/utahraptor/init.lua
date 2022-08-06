local fn = vim.fn
local api = vim.api

local match_pattern_id = nil
local match_cursor_id = nil

local function sleep(ms)
  vim.wait(ms, function() return fn.getchar(1) ~= 0 end)
  -- local t = fn.reltime()
  -- while (fn.getchar(1) == 0) and ((ms - fn.reltimestr(fn.reltime(t)) * 1000.0) > 0) do
  -- end
end

local function l_flash()
  local pattern = fn.getreg('/')
  local last_en_chars = fn.matchstr(pattern, [[\\\+$]])

  local end_cars
  if #last_en_chars == 0 then
    end_cars = [[\)]]
  elseif #pattern == 1 then
    -- /\<CR>
    end_cars = [[\\)]]
  elseif #last_en_chars % 2 == 0 then
    -- /hogehoge\\<CR>
    -- /huga\\\\<CR>
    end_cars = [[\)]]
  else
    -- /hogehoge\<CR>
    -- /huga\\\<CR>
    end_cars = [[\\)]]
  end

  api.nvim_echo({{[[\%#\(]] .. pattern .. end_cars}}, true, {})
  match_pattern_id = fn.matchadd('CursorIM', [[\%#\(]] .. pattern .. end_cars, 100)
  match_cursor_id = fn.matchadd('Cursor', [[\\%#]], 101)

  vim.cmd('redraw')
  sleep(1000)
end

M = {}

M.flash = function()
  if match_cursor_id ~= nil or match_cursor_id ~= nil then
    api.nvim_echo({'utahraptor.nvim: Double called', 'ErrorMsg'}, true, {})
    return
  end

  local ok, result = pcall(l_flash)

  if match_pattern_id ~= nil then
    fn.matchdelete(match_pattern_id)
    match_pattern_id = nil
  end

  if match_cursor_id ~= nil then
    fn.matchdelete(match_cursor_id)
    match_cursor_id = nil
  end

  if ok == false then
    api.nvim_echo({{result, 'ErrorMsg'}}, true, {})
  end
end

return M
