# utahraptor.nvim
Flash search word.

## Install

[packer.nvim](https://github.com/wbthomason/packer.nvim)  
[vim-jetpack](https://github.com/tani/vim-jetpack)

```lua
use 'rapan931/utahraptor.nvim'
```

## Usage

```lua
local utahraptor = require('utahraptor')

vim.keymap.set({'n', 'x', 'o'}, 'n', function() require('utahraptor').n_flash() end)
vim.keymap.set({'n', 'x', 'o'}, 'N', function() require('utahraptor').N_flash() end)
```

use [bistahieversor.nvim](https://github.com/rapan931/bistahieversor.nvim) & [lasterisk.nvim](https://github.com/rapan931/lasterisk.nvim)

```lua
vim.keymap.set({'n', 'x', 'o'}, 'n', function()
  require('bistahieversor').n_and_echo()
  require('utahraptor').flash()
end)
vim.keymap.set({'n', 'x', 'o'}, 'N', function()
  require('bistahieversor').N_and_echo()
  require('utahraptor').flash()
end)

vim.keymap.set('n', '*',  function()
  require('lasterisk').search()
  require('bistahieversor').echo()
  require('utahraptor').flash()
end)
```

![Animation4](https://user-images.githubusercontent.com/24415677/184920909-2127e825-f480-4adb-a53c-9b42448396ef.gif)

## Options

```lua
require('utahraptor').setup({
  flash_ms = 500,
  flash_hl_group = 'Utahraptor'
})
```
