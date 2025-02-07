local M = {}

local function setup_commands()
  local utils = require("flutter-tools.utils")
  -- Commands
  utils.command("FlutterRun", [[lua require('flutter-tools.commands').run()]])
  utils.command("FlutterReload", [[lua require('flutter-tools.commands').reload()]])
  utils.command("FlutterRestart", [[lua require('flutter-tools.commands').restart()]])
  utils.command("FlutterQuit", [[lua require('flutter-tools.commands').quit()]])
  utils.command("FlutterVisualDebug", [[lua require('flutter-tools.commands').visual_debug()]])
  -- Lists
  utils.command("FlutterDevices", [[lua require('flutter-tools.devices').list_devices()]])
  utils.command("FlutterEmulators", [[lua require('flutter-tools.devices').list_emulators()]])
  --- Outline
  utils.command("FlutterOutline", [[lua require('flutter-tools.outline').open()]])
  --- Dev tools
  utils.command("FlutterDevTools", [[lua require('flutter-tools.dev_tools').start()]])
  utils.command(
    "FlutterCopyProfilerUrl",
    [[lua require('flutter-tools.commands').copy_profiler_url()]]
  )
  utils.command("FlutterPubGet", [[lua require('flutter-tools.commands').pub_get()]])
  --- Log
  utils.command("FlutterLogClear", [[lua require('flutter-tools.log').clear()]])
end

---Create autocommands for the plugin
local function setup_autocommands()
  local utils = require("flutter-tools.utils")
  utils.augroup("FlutterToolsStart", {
    {
      events = { "BufEnter" },
      targets = { "*.dart" },
      modifiers = { "++once" },
      command = "lua require('flutter-tools').__start()",
    },
  })
  utils.augroup("FlutterToolsHotReload", {
    {
      events = { "BufWritePost" },
      targets = { "*.dart" },
      command = "lua require('flutter-tools.commands').reload(true)",
    },
    {
      events = { "BufWritePost" },
      targets = { "*/pubspec.yaml" },
      command = "lua require('flutter-tools.commands').pub_get()",
    },
    {
      events = { "BufEnter" },
      targets = { require("flutter-tools.log").filename },
      command = "lua require('flutter-tools.log').__resurrect()",
    },
  })

  utils.augroup("FlutterToolsOnClose", {
    {
      events = { "VimLeavePre" },
      targets = { "*" },
      command = "lua require('flutter-tools.dev_tools').stop()",
    },
  })
end

local started = false

function M.__start()
  if started then
    return
  else
    started = true
  end

  setup_commands()
  local conf = require("flutter-tools.config").get()

  if conf.debugger.enabled then
    require("flutter-tools.dap").setup(conf)
  end

  if conf.widget_guides.enabled then
    require("flutter-tools.guides").setup()
  end
end

---Entry point for this plugin
---@param user_config table
function M.setup(user_config)
  if not pcall(require, "plenary") then
    return require("flutter-tools.utils").echomsg(
      "plenary.nvim is a required dependency of this plugin, please ensure it is installed"
    )
  end

  require("flutter-tools.config").set(user_config)
  -- Setup LSP autocommands to attach to dart files
  require("flutter-tools.lsp").setup()
  setup_autocommands()
end

return M
