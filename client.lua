local createdPrompts = {}
local Hangings = {}

local HangPrompt
function SetupHangPrompt()
    Citizen.CreateThread(function()
        local str = 'Interact'
        HangPrompt = PromptRegisterBegin()
        PromptSetControlAction(HangPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(HangPrompt, str)
        PromptSetEnabled(HangPrompt, false)
        PromptSetVisible(HangPrompt, false)
        PromptSetHoldMode(HangPrompt, true)
        PromptRegisterEnd(HangPrompt)
        PromptSetGroup(HangPrompt,16,0)
        table.insert(createdPrompts, HangPrompt)
    end)
end

Citizen.CreateThread(function()
    SetupHangPrompt()
    local prompt, interacting = false, false 
    local lastPrompt = false
    while true do
        local ped = PlayerPedId()
        local waitingTime = 800
        
        local sId = PlayerPedId()--GetServerId(ped)
        for k,v in ipairs(Config.Hanging.Locations) do
            if (not Hangings[k]) then
                TriggerServerEvent("kr_hanging:addHangRope", k)
            else
                local coords = GetEntityCoords(ped)
                local dist = #(coords - v.Location)
                if (dist < 8.0) then
                    waitingTime = 5
                    local isHanging = (Hangings[k].hPlayers["pId"] ~= nil and Hangings[k].hPlayers["pId"] == sId)
                    local floorBoard = GetClosestObjectOfType(v.Location, 3.0, -1923741333, false, 0, 0)
                    local lever = GetClosestObjectOfType(v.Location, 3.0, -1539465244, false, 0, 0)
                    local leverCoords = GetEntityCoords(lever)
                    local floorboardCoords = GetEntityCoords(floorBoard)
                    local isTrapdoorOpen = IsEntityPlayingAnim(floorBoard, "script_re@public_hanging@lever", "pull_lever_deputy_trapdoor_val", 1)
                    local canClose = HasEntityAnimFinished(floorBoard, "script_re@public_hanging@lever", "pull_lever_deputy_trapdoor_val", 1)
                    local leverDist = #(coords - leverCoords)
                    local hangDist = #(coords - floorboardCoords)
                    if hangDist < 1.5 or leverDist < 1.5 then
                        local intType = hangDist < leverDist and 'hang' or 'lever'
                        local text
                        if intType == 'hang' then
                            if isHanging then
                                text = CreateVarString(10, 'LITERAL_STRING', 'Detach body')
                            else
                                text = CreateVarString(10, 'LITERAL_STRING', 'Put head in noose')
                            end
                        else
                            if isTrapdoorOpen then
                                text = CreateVarString(10, 'LITERAL_STRING', 'Close Trapdoor')
                            else
                                text = CreateVarString(10, 'LITERAL_STRING', 'Open Trapdoor')
                            end
                        end
                        PromptSetActiveGroupThisFrame(16,text)
                        if not prompt then
                            PromptSetEnabled(HangPrompt, true)
                            PromptSetVisible(HangPrompt, true)
                            prompt = true
                        end
                        if PromptHasHoldModeCompleted(HangPrompt) and not interacting then
                            interacting = true
                            PromptSetEnabled(HangPrompt, false)
                            PromptSetVisible(HangPrompt, false)
                            if intType == 'hang' then
                                if isHanging then
                                    TriggerServerEvent("kr_hanging:removeHangPlayer", k)
                                else
                                    Config.Hanging.Animation.RequestDict()
                                    SetEntityCoords(ped, (v.Location - vector3(0.0,0.0,0.97)))
                                    SetEntityHeading(ped, v.Heading)
                                    TaskPlayAnim(ped, Config.Hanging.Animation.Dict,Config.Hanging.Animation.Name, 1090519040, -1056964608, -1, 1, 0, 0, 0, 0, 0, 0)
                                    reqModelHash(GetHashKey('p_jug01x'))
                                    reqModelHash(357863945)
                                    local object = CreateObject(GetHashKey('p_jug01x'), (v.Location + v.RopeHang), 0, 1, 0, 0, 0)
                                    local knot = CreateObject(357863945, GetEntityCoords(ped), 0, 1, 0, 0, 0)
                                    SetEntityVisible(object, false)
                                    local objCo = GetEntityCoords(object)
                                    local rope = Citizen.InvokeNative(0xE9C59F6809373A99,objCo, 0, 0, 0, 1.35, 6, 1, 31, -1082130432)
                                    Citizen.InvokeNative(0xF092B6030D6FD49C, rope, "ROPE_SETTINGS_DEFAULT")
                                    ActivatePhysics(rope)
                                    Citizen.InvokeNative(0x462FF2A432733A44, rope, ped, object, 0.020, -0.18, 0.0, 0, 0, 0, "skel_head", 0)
                                    Citizen.InvokeNative(0x3C6490D940FF5D0B, rope, 0, 0, 3.0, 0)
                                    Citizen.InvokeNative(0x814D453FCFDF119F, rope, 1, -999)
                                    FreezeEntityPosition(object, true)
                                    AttachEntityToEntity(knot, ped, GetPedBoneIndex(ped, 21030), 0.0, -0.12, 0.015, 183, 88.5, -50.0, -1, 0, 1, 0, 0, 1, 1, 1065353216, 1065353216)
                                    TriggerServerEvent("kr_hanging:addHangPlayer", k, sId, rope ,ObjToNet(knot))
                                end
                            else
                                if isTrapdoorOpen then
                                    if (canClose) then
                                        StopEntityAnim(lever, "push_lever_deputy_lever", "script_re@public_hanging@lever", 1)
                                        StopEntityAnim(floorBoard, "pull_lever_deputy_trapdoor_val", "script_re@public_hanging@lever", 1)
                                        TriggerServerEvent("kr_hanging:setTrapdoorStatus", k, false)
                                    end
                                else
                                    reqAnimDict("script_re@public_hanging@lever")-- TRAP DOOR
                                    PlayEntityAnim(lever, "push_lever_deputy_lever", "script_re@public_hanging@lever", 1, 0, 1, 0, 0, 0); -- LEVER PUSHING OPENING
                                    PlayEntityAnim(floorBoard, "pull_lever_deputy_trapdoor_val", "script_re@public_hanging@lever", 1, 0, 1, 0, 0, 0); -- TRAPDOOR OPENING
                                    TriggerServerEvent("kr_hanging:setTrapdoorStatus", k, true)
                                end
                            end
                            Wait(3000)
                            prompt, interacting = false, false
                        end
                    else
                        if dist > 10 then sleep = 1000; end
                        PromptSetEnabled(HangPrompt, false)
                        PromptSetVisible(HangPrompt, false)
                        prompt, interacting = false, false     
                    end
                end
            end
        end
        Citizen.Wait(waitingTime)
    end
end)

RegisterNetEvent("kr_hanging:getHangInfo")
AddEventHandler("kr_hanging:getHangInfo", function(i)
    Hangings = i
end)
RegisterNetEvent("kr_hanging:releaseHangingPlayer")
AddEventHandler("kr_hanging:releaseHangingPlayer", function()
    local sId = PlayerPedId()--GetServerId(ped)
    for k,v in pairs(Hangings) do
        if (v.hPlayers["pId"] ~= nil and v.hPlayers["pId"] == sId) then
            local ped = PlayerPedId()
            local rope = v.hPlayers["rId"]
            local knot = NetToObj(v.hPlayers["kId"])
            DetachEntity(knot)
            DeleteEntity(knot)
            ClearPedTasksImmediately(ped, 1,1)
            DetachRopeFromEntity(rope, ped)
            DeleteRope(rope)
        end
    end
end)
RegisterNetEvent("kr_hanging:letTheHangingBegin")
AddEventHandler("kr_hanging:letTheHangingBegin", function(i)
    local sId = PlayerPedId()--GetServerId(ped)
    local ped = PlayerPedId()
    if (Hangings[i].hPlayers ~= nil and Hangings[i].hPlayers["pId"] ~= nil) then
        if (Hangings[i].hPlayers["pId"] == sId and Hangings[i].tDoorOpen) then
            Citizen.Wait(3300)
            SetPedToRagdoll(ped, 1000, 1000, 0, 0,0,0)
            KnockOffPedProp(ped, 0,1,0,0)
            Citizen.CreateThread(function()
                while Hangings[i] and Hangings[i].hPlayers["pId"] == sId and Hangings[i].tDoorOpen and not IsEntityDead(ped) do
                    Wait(500)
                    SetPedToRagdoll(ped, 1000, 1000, 0, 0,0,0)
                end
            end)
            Citizen.Wait(math.random(4000, 20000))
            SetEntityHealth(ped, 0.0)
        end
    end
end)

function reqModelHash(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
    end
end
function reqAnimDict(model)
    RequestAnimDict(model)
    while not HasAnimDictLoaded(model) do
        Citizen.Wait(5)
    end
end
--[[
function GetServerId(ped)
    for i=0, 255 do
        if (GetPlayerPed(i) == ped and NetworkIsPlayerActive(i)) then
            return GetPlayerServerId(i)
        end
    end
end]]

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then  
      for _,v in pairs(createdPrompts) do
        PromptSetEnabled(v, false)
        PromptSetVisible(v, false)
      end
    end
end)
