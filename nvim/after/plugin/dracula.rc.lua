local status, dracula = pcall(require, "dracula")
if (not status) then
  print("Dracula is not installed")
  return
end

--dracula.load()
