local colors = {
  bg = 'NONE',
  fg = '#c0caf5',
  yellow = '#e0af68',
  cyan = '#56b6c2',
  darkblue = '#081633',
  green = '#98be65',
  orange = '#FF8800',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ec5f67'
}

local transparent_theme = {
  normal = {
    a = { fg = colors.fg, bg = 'NONE' },
    b = { fg = colors.fg, bg = 'NONE' },
    c = { fg = colors.fg, bg = 'NONE' }
  },
  insert = { a = { fg = colors.fg, bg = 'NONE' } },
  visual = { a = { fg = colors.fg, bg = 'NONE' } },
  replace = { a = { fg = colors.fg, bg = 'NONE' } },
  inactive = {
    a = { fg = colors.fg, bg = 'NONE' },
    b = { fg = colors.fg, bg = 'NONE' },
    c = { fg = colors.fg, bg = 'NONE' }
  }
}

return transparent_theme