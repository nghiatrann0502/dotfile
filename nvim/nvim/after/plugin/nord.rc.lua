local status, nord = pcall(require, "nord")
if (not status) then
  print("Nord is not installed")
  return
end

-- vim.g.nord_cotrast = true

-- nord.set()
