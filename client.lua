local ESX = exports.es_extended:getSharedObject()
local PlayerData = {}
local opened = false

Citizen.CreateThread(function()
    while ESX.IsPlayerLoaded() == false do Wait(0) end 
    PlayerData = ESX.GetPlayerData()
end)

SonoSbirro = function()
    local job = PlayerData.job.name
    for k,v in pairs(Config.PoliceJob) do 
        if job == v then 
            return true 
        end
    end
    return false
end

RegisterCommand('mdt', function(source, args, rawCommand)
    OpenMDT()
end)

postNUI = function(data)
    SendNUIMessage(data)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  postNUI({
    type = "UPDATE_OFFICER_JOB",
    job = {
        name = job.name,
        label = job.label,
        grade = {
            name = job.grade_name,
            label = job.grade_label
        }
    }
  })
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function (xPlayer)
    PlayerData = xPlayer
end)

RegisterNUICallback('setGps', function(data, cb)
    SetNuiFocus(false, false)
    SetNewWaypoint(data.x, data.y)
    ESX.ShowNotification(Config.Translate[Config.Language]["set_gps"])
end)

OpenMDT = function()
    ESX.TriggerServerCallback('ricky-server:mdtGetStartInfo', function(officerInfo, cittadini, veicoli, allReports, numeroSbirri) 
        if not SonoSbirro() then return end
        if opened then return end

        if PlayerData.job.grade >= Config.HighGrade then 
            postNUI({
                type = "ACCESS_LIST_REPORT",
                reports = allReports
            })
        end
    postNUI({
        type = "UPDATE_OFFICER_NUMBER",
        officerNumber = numeroSbirri
    })
    postNUI({
        type = "UPDATE_CONFIG",
        config = Config
    })
    if cittadini == nil then return end
   -- if Config.HouseSystem == 'allhousing' then 
        for k,v in pairs(cittadini) do 
          for a,b in pairs(v.case) do 
            b.name = GetStreetNameAtCoord(b.x, b.y, b.z)
            b.name  = GetStreetNameFromHashKey(b.name)
          end
        end
   -- end 
    SetNuiFocus(true, true)
    postNUI({
        type = "OPEN_MDT",
        officerInfo = officerInfo,
        cittadini = cittadini,
        veicoli = veicoli
    })
    opened = true
    end)
end

RegisterNUICallback('addWanted', function(data, cb)
    local identifier = data.identifier
    TriggerServerEvent('ricky-server:mdtAddWanted', identifier)
end)

RegisterNUICallback('removeWanted', function(data, cb)
    local identifier = data.identifier
    TriggerServerEvent('ricky-server:mdtRemoveWanted', identifier)
end)

RegisterNUICallback('updateNote', function(data, cb)
    local identifier = data.identifier
    local note = data.note
    TriggerServerEvent('ricky-server:mdtUpdateNote', identifier, note)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    opened = false
end)

RegisterNetEvent('ricky-client:mdtUpdateCittadini')
AddEventHandler('ricky-client:mdtUpdateCittadini', function()
    ESX.TriggerServerCallback('ricky-server:mdtGetStartInfo', function(officerInfo, cittadini, veicoli)
      --  if Config.HouseSystem == 'allhousing' then 
            for k,v in pairs(cittadini) do 
              for a,b in pairs(v.case) do 
                b.name = GetStreetNameAtCoord(b.x, b.y, b.z)
                b.name  = GetStreetNameFromHashKey(b.name)
              end
            end
      --  end 
        postNUI({
            type = "UPDATE_CITTADINI",
            cittadini = cittadini
        })

        postNUI({
            type = "UPDATE_VEICOLI",
            veicoli = veicoli
        })

        postNUI({
            type = "UPDATE_OFFICER_INFO",
            officerInfo = officerInfo
        })
    end)
end)


RegisterNUICallback('addReato', function(data, cb)
    local identifier = data.identifier
    local reason = data.reason
    TriggerServerEvent('ricky-server:mdtAddReato', identifier, reason)
end)

RegisterNUICallback('deleteReato', function(data, cb)
    local identifier = data.identifier
    local idReato = data.idReato
    TriggerServerEvent('ricky-server:mdtDeleteReato', identifier, idReato)
end)

RegisterNUICallback('createReport', function(data, cb)
    local rapporto = data.rapporto
    TriggerServerEvent('ricky-server:mdtCreateReport', rapporto)
end)

RegisterCommand('mdt', function(source, args, rawCommand)
    OpenMDT()
end)