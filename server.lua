local ESX = exports.es_extended:getSharedObject()

getLabelJob = function(name)

    local result =  MySQL.Sync.fetchAll("SELECT * FROM jobs WHERE name = @name", {
          ['@name'] = name,
    })
    if result[1] ~= nil then
        return result[1].label
    else
        return false
    end
end

getNameGrade = function(job, grade)

    local result =  MySQL.Sync.fetchAll("SELECT * FROM job_grades WHERE job_name = @job AND grade = @grade", {
          ['@job'] = job,
          ['@grade'] = grade
    })
    if result[1] ~= nil then
        return result[1].name
    else
        return false
    end
end

getLabelGrade = function(job, grade)

    local result =  MySQL.Sync.fetchAll("SELECT * FROM job_grades WHERE job_name = @job AND grade = @grade", {
          ['@job'] = job,
          ['@grade'] = grade
    })
    if result[1] ~= nil then
        return result[1].label
    else
        return false
    end
end

GetWanted = function(identifier)
    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    if result[1] ~= nil then
        if result[1].wanted == 'true' then 
            return true 
        else
            return false 
        end
    else
        return false
    end
end

GetNote = function(identifier)
    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    if result[1] ~= nil then
        return result[1].note
    else
        return ''
    end
end

GetNameFromIdentifier = function(identifier)
    local result =  MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    if result[1] ~= nil then
        return result[1].firstname .. ' ' .. result[1].lastname
    else
        return false
    end
end

getBills = function(identifier)
    local multe = {}
    if Config.BillSystem == 'esx_billing' then 
    -- local result =  MySQL.Sync.fetchAll("SELECT * FROM billing WHERE identifier = @identifier", {
    --       ['@identifier'] = identifier,
    -- })
    -- for i=1, #result, 1 do 
    --     local coso = result[i]
    --   table.insert(multe, {
    --     from = coso.sender,
    --     amount = coso.amount,
    --     date = 'Unkown'
    --   })
    -- end
elseif Config.BillSystem == 'okokBilling' then 
    local result =  MySQL.Sync.fetchAll("SELECT * FROM okokbilling WHERE receiver_identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    for i = 1, #result, 1 do 
      local coso = result[i]
        table.insert(multe, {
            from = coso.society_name,
            amount = coso.invoice_value,
            date = coso.sent_date,
            id = coso.id,
            payed = coso.status
        })
    end
  end
    return multe 
end

getReati = function(identifier) 
    local reati = {}
    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    if result[1] ~= nil then
        local coso = json.decode(result[1].crimes)
        if coso ~= nil then 
            for i=1, #coso, 1 do 
                table.insert(reati, {
                    reason = coso[i].reason,
                    officer = coso[i].officer,
                    date = coso[i].date
                })
            end
        end
    end
    return reati
end

getReport = function(identifier)
    local report = {}

    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt_rapporti WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })

    for i=1, #result, 1 do 
        local coso = result[i]
        table.insert(report, {
            rapporto = coso.rapporto,
            data = coso.data,
            name = GetNameFromIdentifier(coso.identifier)
        })
    end

    return report
end

getAllReports = function()
    local report = {}

    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt_rapporti")

    for i=1, #result, 1 do 
        local coso = result[i]
        table.insert(report, {
            rapporto = coso.rapporto,
            data = coso.data,
            name = GetNameFromIdentifier(coso.identifier)
        })
    end

    return report
end

getStartInfo = function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer == nil then return end

    local utenti =  MySQL.Sync.fetchAll("SELECT * FROM users")
    local veicoli =  MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles")

    local cittadini = {}
    local automobili =  {}

    local allReports = {}

    allReports = getAllReports()

    local officerInfo = {
        name = xPlayer.getName(),
        grade = {
            name = xPlayer.getJob().grade_name,
            label = xPlayer.getJob().grade_label
        },
        id = xPlayer.source,
        rapporti = getReport(xPlayer.identifier),
    }

    local numeroSbirri = 0
    for i=1, #veicoli, 1 do 
      local coso = veicoli[i]
      table.insert(automobili, {
        plate = coso.plate,
        type = coso.type,
        model = json.decode(coso.vehicle).model,
        identifier = coso.owner,
        owner = GetNameFromIdentifier(coso.owner)
      })
    end

    for i = 1, #utenti, 1 do 
      local coso = utenti[i]
      local sesso = 'Maschio'
      if coso.sex == 'f' then 
        sesso = 'Femmina'
      end

      for k,v in pairs(Config.PoliceJob) do 
        if v == coso.job then 
            numeroSbirri = numeroSbirri + 1
        end
      end


      table.insert(cittadini, {
        firstName = coso.firstname,
        lastName = coso.lastname,
        fullName = coso.firstname .. ' ' .. coso.lastname,
        dateOfBirth = coso.dateofbirth,
        identifier = coso.identifier,
        sesso = sesso,
        photo = GetPhoto(coso.identifier),
        wanted = GetWanted(coso.identifier),
        contoBancario = json.decode(coso.accounts).bank,
        note = GetNote(coso.identifier),
        veicoli = getVehicleOwner(coso.identifier),
        case = getProperty(coso.identifier),
        multe = getBills(coso.identifier),
        reati = getReati(coso.identifier),
        job = {
            name = coso.job,
            label = getLabelJob(coso.job),
            grade = {
                name = getNameGrade(coso.job, coso.job_grade),
                label = getLabelGrade(coso.job, coso.job_grade)
            }
        }
      })
    end

    return officerInfo, cittadini, automobili, allReports, numeroSbirri 
end

ESX.RegisterServerCallback('ricky-server:mdtGetStartInfo', function(source, cb)
    cb(getStartInfo(source))
end)

CheckSQL = function(identifier)
    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt WHERE identifier = @identifier", {
          ['@identifier'] = identifier,
    })
    if result[1] == nil then 
        MySQL.Async.execute('INSERT INTO rickymdt (identifier) VALUES (@identifier)', {
            ['@identifier'] = identifier,
        })
    end
end

RegisterServerEvent('ricky-server:mdtAddWanted')
AddEventHandler('ricky-server:mdtAddWanted', function(identifier)
  CheckSQL(identifier)

    MySQL.Sync.execute("UPDATE rickymdt SET wanted = @wanted WHERE identifier = @identifier", {
        ['@identifier'] = identifier,
        ['@wanted'] = 'true'
    })
    TriggerClientEvent('ricky-client:mdtUpdateCittadini', -1)
end)

RegisterServerEvent('ricky-server:mdtRemoveWanted')
AddEventHandler('ricky-server:mdtRemoveWanted', function(identifier)
    CheckSQL(identifier)
    
        MySQL.Sync.execute("UPDATE rickymdt SET wanted = @wanted WHERE identifier = @identifier", {
            ['@identifier'] = identifier,
            ['@wanted'] = 'false'
        })
        TriggerClientEvent('ricky-client:mdtUpdateCittadini', -1)
end)

RegisterServerEvent('ricky-server:mdtUpdateNote')
AddEventHandler('ricky-server:mdtUpdateNote', function(identifier, note)
    CheckSQL(identifier)
    
        MySQL.Sync.execute("UPDATE rickymdt SET note = @note WHERE identifier = @identifier", {
            ['@identifier'] = identifier,
            ['@note'] = note
        })
        TriggerClientEvent('ricky-client:mdtUpdateCittadini', -1)
end)

RegisterServerEvent('ricky-server:mdtAddReato')
AddEventHandler('ricky-server:mdtAddReato', function(identifier, reason)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  CheckSQL(identifier)

  local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt WHERE identifier = @identifier", {
    ['@identifier'] = identifier,
  })

  local reati = json.decode(result[1].crimes)

  if reati == nil then 
    reati = {}
  end

    table.insert(reati, {
        reason = reason,
        officer = {
            identifier = xPlayer.identifier,
            name = xPlayer.getName(),
        },
        date = os.date('%d/%m/%Y %H:%M:%S', os.time())
    })

    MySQL.Sync.execute("UPDATE rickymdt SET crimes = @crimes WHERE identifier = @identifier", {
        ['@identifier'] = identifier,
        ['@crimes'] = json.encode(reati)
    })
    TriggerClientEvent('ricky-client:mdtUpdateCittadini', -1)
end)

RegisterServerEvent('ricky-server:mdtDeleteReato')
AddEventHandler('ricky-server:mdtDeleteReato', function(identifier, idReato)
    local result =  MySQL.Sync.fetchAll("SELECT * FROM rickymdt WHERE identifier = @identifier", {
        ['@identifier'] = identifier,
      })
    
      local reati = json.decode(result[1].crimes)

        table.remove(reati, idReato + 1)
    
        MySQL.Sync.execute("UPDATE rickymdt SET crimes = @crimes WHERE identifier = @identifier", {
            ['@identifier'] = identifier,
            ['@crimes'] = json.encode(reati)
        })
        TriggerClientEvent('ricky-client:mdtUpdateCittadini', -1)
end)


RegisterServerEvent('ricky-server:mdtCreateReport')
AddEventHandler('ricky-server:mdtCreateReport', function(rapporto)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Sync.execute("INSERT INTO rickymdt_rapporti (identifier, rapporto, data) VALUES(@identifier, @rapporto, @data)", {
        ['@identifier'] = xPlayer.identifier,
        ["@rapporto"] = rapporto,
        ['@data'] = os.date('%d/%m/%Y %H:%M:%S', os.time())
    })
    TriggerClientEvent('ricky-client:mdtUpdateCittadini', -1)
end)