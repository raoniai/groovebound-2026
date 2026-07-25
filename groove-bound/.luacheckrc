std = "luajit"
codes = true
max_line_length = 120

-- LÖVE's global namespace is the only sanctioned writable global.
globals = { "love" } -- main.lua and conf.lua define LÖVE callbacks.

-- Test files may use the shared arg convention.
files["tests/"] = {
  read_globals = { "arg" },
}

-- No unused-argument noise for self in methods.
self = false
