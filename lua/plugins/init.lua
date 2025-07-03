-- Загружаем все плагины из отдельных файлов
local plugins = {}

-- Функция для объединения таблиц плагинов
local function merge_plugins(plugin_table)
  if type(plugin_table) == "table" then
    for _, plugin in ipairs(plugin_table) do
      table.insert(plugins, plugin)
    end
  end
end

-- Импортируем все файлы плагинов
merge_plugins(require("plugins.theme"))
merge_plugins(require("plugins.neotree"))
merge_plugins(require("plugins.telescope"))
merge_plugins(require("plugins.treesitter"))
merge_plugins(require("plugins.lsp"))
merge_plugins(require("plugins.lualine"))
merge_plugins(require("plugins.misc"))
merge_plugins(require("plugins.git"))

return plugins