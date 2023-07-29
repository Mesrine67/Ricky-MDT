Config = {}

Config.AnimazioneIniziale = false

Config.PoliceJob = {
    'polizia',
}

Config.HighGrade = 5 -- Rank number onwards that will be able to access the list of reports

Config.HouseSystem = '' -- 'esx_property_old' or 'allhousing or 'esx_property_new'

Config.BillSystem = '' -- 'okokBilling' :(

Config.Language = "it"

Config.Translate =  {
    ["it"] = {
        ["home"] = "Home",
        ["title"] = "Dipartimento di Polizia",
        ["id"] = "ID :",
        ["access_officer"] = "Accesso Operatore",
        ["login"] = "Login",
        ["vehicle_db"] = "Database Veicoli",
        ["citizen_db"] = "Database Cittadini",
        ["total_citizen_reg"] = "TOTALE CIVILI REGISTRATI",
        ["total_veh_reg"] = "TOTALE VEICOLI REGISTRATI",
        ["total_citizen_wanted"] = "TOTALE CIVILI RICERCATI",
        ["total_police"] = "TOTALE FORZE DELL'ORDINE",
        ["search_by_name"] = "Cerca Per Nome",
        ["search_by_plate"] = "Cerca Per Targa",
        ["wanted"] = "Ricercato",
        ["not_wanted"] = "Non Ricercato",
        ["bank"] = "Conto Corrente:",
        ["veh_number"] = "Numero Veicoli:",
        ["property_number"] = "Numero Proprietà:",
        ["veh_list"] = "Lista Veicoli",
        ["property_list"] = "Lista Proprietà",
        ["bill_list"] = "Lista Multe",
        ["no_note"] = "Nessuna Nota",
        ["add_wanted"] = "Aggiungi Ricercato",
        ["remove_wanted"] = "Rimuovi Ricercato",
        ["set_gps"] = "GPS Impostato",
        ["currency"] = "€",
        ["reports"] = "Rapporti",
        ["my_reports"] = "I MIEI RAPPORTI",
        ["report_date"] = "Rapporto del",
        ["click_view"] = "CLICCA PER GUARDARE",
        ["add_report"] = "Aggiungi Rapporto",
        ["close"] = "CHIUDI",
        ["confirm"] = "CONFERMA",
        ["cancel"] = "INDIETRO",
        ["you_sure"] = "Sei sicuro?",
        ["attention"] = "ATTENZIONE",
        ["alert_msg"] = "Una volta creato non potrà più essere modificato/eliminato",
        ["create_report"] = "Crea Rapporto",
        ["from"] = "Da",
        ["reason"] = "Motivo",
        ["date"] = "Data",
        ["actions"] = "Azioni",
        ["add"] = "AGGIUNGI",
        ["criminal_record"] = "Fedina Penale",
        ["type_desc"] = "Digitare una descrizione",
        ["type_reason"] = "Inserisci il motivo",
        ['all_reports'] = "Lista Rapporti"
    },
    ["en"] = {
        ["home"] = "Home",
        ["title"] = "Police Department",
        ["id"] = "ID :",
        ["access_officer"] = "Operator Access",
        ["login"] = "Login",
        ["vehicle_db"] = "Vehicle Database",
        ["citizen_db"] = "Citizen Database",
        ["total_citizen_reg"] = "TOTAL REGISTERED CIVILIANS",
        ["total_veh_reg"] = "TOTAL REGISTERED VEHICLES",
        ["total_citizen_wanted"] = "TOTAL CIVILIANS WANTED",
        ["total_police"] = "TOTAL LAW ENFORCEMENT",
        ["search_by_name"] = "Search By Name",
        ["search_by_plate"] = "Search By Plate",
        ["wanted"] = "Wanted",
        ["not_wanted"] = "Not Wanted",
        ["bank"] = "Bank Account:",
        ["veh_number"] = "Vehicles Number:",
        ["property_number"] = "Property Number:",
        ["veh_list"] = "Vehicle List",
        ["property_list"] = "Property List",
        ["bill_list"] = "Bills List",
        ["no_note"] = "No Notes",
        ["add_wanted"] = "Add Wanted",
        ["remove_wanted"] = "Remove Wanted",
        ["set_gps"] = "GPS Set",
        ["currency"] = "$",
        ["reports"] = "Reports",
        ["my_reports"] = "MY REPORTS",
        ["report_date"] = "Report of",
        ["click_view"] = "CLICK TO VIEW",
        ["add_report"] = "Add Report",
        ["close"] = "CLOSE",
        ["confirm"] = "CONFIRM",
        ["cancel"] = "CANCEL",
        ["you_sure"] = "Are you sure?",
        ["attention"] = "ATTENTION",
        ["alert_msg"] = "Once created it can no longer be modified/deleted",
        ["create_report"] = "Create Report",
        ["from"] = "From",
        ["reason"] = "Reason",
        ["date"] = "Date",
        ["actions"] = "Actions",
        ["add"] = "ADD",
        ["criminal_record"] = "Criminal Record",
        ["type_desc"] = "Type a description",
        ["type_reason"] = "Enter the reason",
        ['all_reports'] = "Reports List"

    }
}

-- Functions --


GetPhoto = function(identifier)
    local result =  MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    return result[1].idCardPhoto
end

getProperty = function(identifier) 

    -- ATTENZIONE: SE VOLETE ADATTARE IL VOSTRO SISTEMA DI CASE, DOVETE FARE IN MODO CHE LA FUNZIONE
    -- RITORNI UNA TABELLA CON LE COORDINATE DELLE CASE, COME NELLA TABELLA "case" QUI SOTTO (X,Y,Z)


    local case = {}
    if Config.HouseSystem == 'esx_property_old' then
        local result =  MySQL.Sync.fetchAll("SELECT * FROM owned_properties WHERE owner = @identifier", {
            ['@identifier'] = identifier,
      })
      for i=1, #result, 1 do 
        local coso = result[i]
        local properties =  MySQL.Sync.fetchAll("SELECT * FROM properties WHERE name = @id", {
              ['@id'] = coso.name,
        })
        local coso2 = json.decode(properties[i].entering)
        table.insert(case, {
            name = properties[1].label,
            x = coso2.x,
            y = coso2.y,
            z = coso2.z,
        })
      end
    elseif Config.HouseSystem == 'allhousing' then 
        local result =  MySQL.Sync.fetchAll("SELECT * FROM allhousing WHERE owner = @identifier", {
              ['@identifier'] = identifier,
        })
        for i=1, #result, 1 do 
          local coso = json.decode(result[i].entry)
          table.insert(case, {
                x = coso.x,
                y = coso.y,
                z = coso.z,
            })
        end
    elseif Config.HouseSystem == 'esx_property_new' then 
        local house = exports['esx_property']:GetPlayerProperties(identifier)
        for k,v in pairs(house) do 
            table.insert(case, {
                x = v['Entrance'].x,
                y = v['Entrance'].y,
                z = v['Entrance'].z,
            })
        end
    end
    return case
end

getVehicleOwner = function(identifier)
    local veicoli = {}
    local result =  MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
          ['@identifier'] = identifier,
    })
    for i=1, #result, 1 do 
        coso = result[i]
      table.insert(veicoli, {
        plate = coso.plate,
        type = coso.type,
        model = json.decode(coso.vehicle).model
      })
    end
    return veicoli
end
