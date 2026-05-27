local wezterm = require('wezterm')

local M = {}

--- Checks if the user is on windows
local is_windows = string.match(wezterm.target_triple, 'windows') ~= nil
local separator = is_windows and '\\' or '/'

-- Locate this plugin's directory by matching the URL-encoded basename
-- ("/tabline.wez" -> "sZstablinesDswez"). Works for any fork URL or local
-- clone without hardcoding org/user names.
local plugin_dir
for _, plugin in ipairs(wezterm.plugin.list()) do
  local c = plugin.component
  if c == 'tabline.wez'
      or c:match('sZstablinesDswez$')
      or c:match('sZstablinesDswezsZs$') then
    plugin_dir = plugin.plugin_dir
    break
  end
end

if plugin_dir then
  package.path = package.path
    .. ';'
    .. plugin_dir .. separator .. 'plugin' .. separator .. '?.lua'
end

function M.setup(opts)
  require('tabline.config').set(opts)

  wezterm.on('update-status', function(window)
    require('tabline.component').set_status(window)
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    return require('tabline.tabs').set_title(tab, hover)
  end)

  require('tabline.extension').load()
end

function M.apply_to_config(config)
  config.use_fancy_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false
  config.tab_max_width = 32
  config.window_decorations = 'RESIZE'
  config.window_padding = config.window_padding or {}
  config.window_padding.left = 0
  config.window_padding.right = 0
  config.window_padding.top = 0
  config.window_padding.bottom = 0
  config.colors = config.colors or {}
  config.colors.tab_bar = config.colors.tab_bar or {}
  config.colors.tab_bar.background = require('tabline.config').theme.normal_mode.c.bg
  config.status_update_interval = 500
end

function M.get_config()
  return require('tabline.config').opts
end

function M.get_theme()
  return require('tabline.config').theme
end

function M.set_theme(theme, overrides)
  return require('tabline.config').set_theme(theme, overrides)
end

function M.refresh(window, tab)
  if window then
    require('tabline.component').set_status(window)
  end
  if tab then
    require('tabline.tabs').set_title(tab)
  end
end

return M
