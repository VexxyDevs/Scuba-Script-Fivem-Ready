local scubaHelmetModel = "p_s_scuba_tank_s"
local scubaHelmetDrawable = 1
local scubaHelmetTexture = 0
local scubaTankProp = "prop_scuba_tank_01"

local function equipScubaHelmet()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local isInWater = IsEntityInWater(ped)
    if not isInWater then
        return
    end

    RequestModel(scubaHelmetModel)
    while not HasModelLoaded(scubaHelmetModel) do
        Citizen.Wait(0)
    end

    SetPedComponentVariation(ped, 9, scubaHelmetDrawable, scubaHelmetTexture, 2) -- helmet
    SetModelAsNoLongerNeeded(scubaHelmetModel)

    -- Attach the scuba tank prop to the player's back
    local boneIndex = GetPedBoneIndex(ped, 24818)
    local propIndex = GetHashKey(scubaTankProp)
    local x, y, z = table.unpack(coords)
    local heading = GetEntityHeading(ped)
    local object = CreateObject(propIndex, x, y, z, true, false, true)
    AttachEntityToEntity(object, ped, boneIndex, 0.1, 0.05, -0.05, 0.0, 270.0, 0.0, true, true, false, true, 1, true)

    -- Set the oxygen level to maximum
    SetPedMaxTimeUnderwater(ped, 999999.0)

    -- Display a chat message
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 255},
        args = {"^*^6Scuba kit equipped!^r^0^*^7"}
    })
end

local function removeScubaHelmet()
    local ped = PlayerPedId()

    SetPedComponentVariation(ped, 9, 0, 0, 2) -- remove helmet
    ClearPedProp(ped, 1) -- remove tank

    -- Restore the default oxygen level
    ResetPedMaxTimeUnderwater(ped)

    -- Delete the scuba tank prop
    local boneIndex = GetPedBoneIndex(ped, 24818)
    local object = GetPedPropIndex(ped, 1)
    DeleteEntity(object)
end

RegisterCommand("waterkit", function()
    equipScubaHelmet()
end)

AddEventHandler("playerSpawned", function()
    -- Restore the default oxygen level when the player spawns
    ResetPedMaxTimeUnderwater(PlayerPedId())
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()
        local isInWater = IsEntityInWater(ped)
        if isInWater and not IsPedSwimming(ped) then
            -- If the player is in water but not swimming, equip the scuba kit
            equipScubaHelmet()
        elseif not isInWater and GetPedPropIndex(ped, 1) == scubaHelmetDrawable then
            -- If the player is not in water but still has the scuba kit equipped, remove it
            removeScubaHelmet()
        end
    end
end)
