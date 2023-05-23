local status, onedark = pcall(require, "onedark")
if (not status) then
  print("Onedark is not installed")
  return
end

require('onedark').setup {
  style = 'darker',
  -- transparent = true,
}

onedark.load()
