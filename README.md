# micropython.nvim

## What Is micropython.nvim?

`micropython.nvim` - is neovim plugin. Currently is in development

## Micropython Table of Contents

- [Getting Started](#getting-started)

## Getting Started

### Requirement dependencies

The plugin uses [`mpremote`](https://docs.micropython.org/en/latest/index.html) tool to communicated with the device. It's required to have the tool installed to use the plugin.

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- init.lua:
{
    'iharkatkavets/micropython.nvim', branch = 'main',
    cmd = { 'MPInit', 'MPConnect', 'MPRun', 'MPLog' },
    opts = {
        port = '/dev/cu.usbmodem101',
    },
}

-- plugins/micropython.lua:
return {
  {
    'iharkatkavets/micropython.nvim', branch = 'main',
    cmd = { 'MPConnect', 'MPRun', 'MPLog' },
    opts = {
      port = '/dev/cu.usbmodem101',
    },
  },
}
```

## Contributing

All contributions are welcome! Just open a pull request.
