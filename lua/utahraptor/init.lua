local fn = vim.fn
local api = vim.api

local function l_flash(wait_ms)
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
    -- /hogehoge\\<CR>
    -- /hogehoge\\\\<CR>
    end_cars = [[\)]]
  else
    -- /hogehoge\<CR>
    -- /hogehoge\\\<CR>
    end_cars = [[\\)]]
  end

  local l, c = unpack(vim.list_slice(fn.getpos('.'), 2, 3))
  local l_pattern = [[\%]] .. l .. [[l]]
  local c_pattern = [[\%]] .. c .. [[c]]
  local search_pattern = l_pattern .. c_pattern .. [[\(]] .. pattern .. end_cars

  local match_pattern_id = fn.matchadd('ErrorMsg', search_pattern, 100, -1, { window = win_id })

  local timer = vim.loop.new_timer()
  local i = 1
  local stopped = false
  local interval = 42
  timer:start(1, interval, vim.schedule_wrap(function()
    local ll, cc = unpack(vim.list_slice(fn.getpos('.'), 2, 3))
    if i * interval  > wait_ms or (ll ~= l or cc ~= c) or fn.win_getid() ~= win_id then
      if not stopped then
        stopped = true
        timer:close()
        fn.matchdelete(match_pattern_id, win_id)
      end
    end
    i = i + 1
  end))
end

M = {}
M.flash = function()
  local ok, result = pcall(l_flash, 1000)

  if ok == false then
    api.nvim_echo({{'utahraptor.nvim: ', 'ErrorMsg'}, {result, 'ErrorMsg'}}, true, {})
  end
end

return M
