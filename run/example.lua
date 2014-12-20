local lib = require('example_require')

local function format_data()
  return 
  {
    selected_entity = tostring(SELECTED or '(NONE)'),
    library_result = lib or '(LIBRARY NOT FOUND)'
  }
end

return format_data()