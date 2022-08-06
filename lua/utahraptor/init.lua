local fn = vim.fn
local api = vim.api

local call_count = 0

local function matchdelete(match_id)
  if match_id ~= nil then
    fn.matchdelete(match_id)
  end
end

M = {}

local function l_flash(wait_ms)
  call_count = call_count + 1
  local current_call_count = call_count

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

  local l, c = unpack(vim.list_slice(fn.getpos('.'), 2, 3))
  local l_pattern = [[\%]] .. l .. [[l]]
  local c_pattern = [[\%]] .. c .. [[c]]

  local match_pattern_id = fn.matchadd('CursorIM', l_pattern .. c_pattern .. [[\(]] .. pattern .. end_cars, 100)
  local match_cursor_id = fn.matchadd('Cursor', l_pattern .. c_pattern, 101)

  vim.cmd('redraw')

  local timer = vim.loop.new_timer()
  local i = 1
  timer:start(1, 25, vim.schedule_wrap(function()
    local ll, cc = unpack(vim.list_slice(fn.getpos('.'), 2, 3))
    if i * 20  > wait_ms or (ll ~= l or cc ~= c)then
      matchdelete(match_pattern_id)
      matchdelete(match_cursor_id)
      timer:close()  -- Always close handles to avoid leaks.
    end
    i = i + 1
  end))
end

M.flash = function()
  local ok, result = pcall(l_flash, 1000)

  if ok == false then
    api.nvim_echo({{'utahraptor.nvim: ', 'ErrorMsg'}, {result, 'ErrorMsg'}}, true, {})
  end
end

return M
