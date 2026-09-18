-- Compatibility pathfinder module for scripts which were written for the
-- external MoveToApp package.  The client already exposes the safe movement
-- primitives to Lua, so keep this adapter small and deterministic instead of
-- making script loading depend on a missing third-party module.
--
-- The adapter intentionally does not call the deprecated moveToMap() API.  It
-- walks to the nearest map link using moveToCell(); the normal game protocol
-- then updates the current map and the next script tick can continue routing.

local MoveToApp = {}

local function normalizeMapName(name)
    if name == nil then
        return ""
    end

    local value = tostring(name)
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    value = value:gsub("%.pm$", "")
    return string.lower(value)
end

local function mapNamesEqual(left, right)
    return normalizeMapName(left) == normalizeMapName(right)
end

-- Resolve a map/coordinate pair to the map node expected by the old module.
-- This client receives the destination map from the server after crossing a
-- link, so the map name itself is the most reliable node identifier here.
function MoveToApp.getMapNode(mapName, x, y)
    return mapName
end

function MoveToApp.isDestination(currentMap, destinationMap)
    return mapNamesEqual(currentMap, destinationMap)
end

-- Move to the closest traversable map link.  Link destinations are not encoded
-- in the .pm payload exposed to Lua; selecting the closest link is therefore a
-- safe fallback for old route scripts and lets the server provide the next map
-- name before the following route decision.
function MoveToApp.moveTo(currentMap, destinationMap)
    if MoveToApp.isDestination(currentMap, destinationMap) then
        return false
    end

    local links = getMapLinks()
    if links == nil or type(links) ~= "table" or #links == 0 then
        return false
    end

    local playerX = tonumber(getPlayerX()) or 0
    local playerY = tonumber(getPlayerY()) or 0
    local best = nil
    local bestDistance = nil

    for _, link in ipairs(links) do
        local x = tonumber(link.x)
        local y = tonumber(link.y)
        if x ~= nil and y ~= nil then
            local distance = math.abs(playerX - x) + math.abs(playerY - y)
            if bestDistance == nil or distance < bestDistance then
                best = { x = x, y = y }
                bestDistance = distance
            end
        end
    end

    if best == nil then
        return false
    end
    return moveToCell(best.x, best.y)
end

-- Open the nearest PokéMart when its NPC is present.  Buying is a separate
-- action and is only attempted after the server reports an open shop.
function MoveToApp.useNearestPokemart(currentMap, itemName, quantity)
    if isShopOpen() then
        return buyItem(itemName, quantity)
    end

    local npcs = getNpcData()
    if npcs == nil or type(npcs) ~= "table" then
        return false
    end

    for _, npc in ipairs(npcs) do
        local name = npc.name
        if name ~= nil then
            local lowerName = string.lower(tostring(name))
            if string.find(lowerName, "mart", 1, true)
                or string.find(lowerName, "shop", 1, true)
                or string.find(lowerName, "market", 1, true) then
                return talkToNpc(tostring(name))
            end
        end
    end

    return false
end

return MoveToApp
