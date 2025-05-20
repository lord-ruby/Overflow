Overflow = SMODS.current_mod

local files = {
    "ui",
    "hooks",
    "utils",
    "vanilla_bulk_use"
}
for i, v in ipairs(files) do    
    local f, err = SMODS.load_file(v..".lua")
    if f then f()
    else error(err) end
end

SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
}:register()