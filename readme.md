
rework of https://github.com/Ramblurr/scriptbots in love engine

--------------------------------------------------------------------------------

[https://stackoverflow.com/a/17437077/2727632]
If you want to access the items in a specific order, retrieve the keys from `arr`
and sort it. Then access arr through the sorted keys:

```lua
local ordered_keys = {}

for k in pairs(arr) do
    table.insert(ordered_keys, k)
end

table.sort(ordered_keys)
for i = 1, #ordered_keys do
    local k, v = ordered_keys[i], arr[ ordered_keys[i] ]
    print(k, v[1], v[2], v[3])
end
```
