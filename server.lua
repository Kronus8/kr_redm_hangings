local CurrentHangings = {}

RegisterServerEvent("kr_hanging:addHangPlayer")
AddEventHandler("kr_hanging:addHangPlayer", function(rIndex, pSource, ropeId, knotId)
    if not (CurrentHangings[rIndex]) then CurrentHangings[rIndex] = {hPlayers = {}, tDoorOpen = false} end
    CurrentHangings[rIndex].hPlayers = {
        pId = pSource,
        rId = ropeId,
        kId = knotId
    }
    TriggerEvent("kr_hanging:refreshHanging")
end)

RegisterServerEvent("kr_hanging:addHangRope")
AddEventHandler("kr_hanging:addHangRope", function(rIndex)
    if not (CurrentHangings[rIndex]) then CurrentHangings[rIndex] = {hPlayers = {}, tDoorOpen = false} end
    TriggerEvent("kr_hanging:refreshHanging")
end)

RegisterServerEvent("kr_hanging:removeHangPlayer")
AddEventHandler("kr_hanging:removeHangPlayer", function(rIndex)
    if not (CurrentHangings[rIndex]) then CurrentHangings[rIndex] = {hPlayers = {}, tDoorOpen = false} end
    TriggerClientEvent("kr_hanging:releaseHangingPlayer", CurrentHangings[rIndex].hPlayers["pId"])
    CurrentHangings[rIndex].hPlayers = {}
    TriggerEvent("kr_hanging:refreshHanging")
end)

RegisterServerEvent("kr_hanging:setTrapdoorStatus")
AddEventHandler("kr_hanging:setTrapdoorStatus", function(rIndex, tDStatus)
    if not (CurrentHangings[rIndex]) then CurrentHangings[rIndex] = {hPlayers = {}, tDoorOpen = false} end
    CurrentHangings[rIndex].tDoorOpen = tDStatus
    TriggerEvent("kr_hanging:refreshHanging")
    TriggerClientEvent("kr_hanging:letTheHangingBegin", -1, rIndex)
end)

RegisterServerEvent("kr_hanging:refreshHanging")
AddEventHandler("kr_hanging:refreshHanging", function()
    TriggerClientEvent("kr_hanging:getHangInfo", -1, CurrentHangings)
end)