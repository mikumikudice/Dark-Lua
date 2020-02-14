-- My own library --
require("internals_lib")

-- All status --
local data = {}
local user = os.getenv('USERNAME')

data.exp = 0

-- All classes --
local clss = sys.split('knight,archer,wizard', ',')
local itmc = {knight = '(sword)', archer = '(bow)', wizard = '(staff)'}

local swd = sys.split('iron sword (02),dead titan (04),omega soul (07),golden leaf (11),sky lights (12)', ',')
local bow = sys.split('simple bow (01),the unkbow (03),x-crossbow (05),dead plants (09),that arrow (10)', ',')
local stf = sys.split('wood staff (03),evil blood (06),ghost tear (09),last memory (12),after life (16)', ',')

-- Create a new save --
function new_chr()

    -- Introduction and name --
    io.write('\nHello hero!')
    data.name = question('What are your name?\nI am')
    
    -- Class (weapons and bonus) --
    io.write('\nOk, what is your class?')
    data.cls = question('[' .. sys.tabletostr(clss) .. ']' .. '\nI am a', clss)

    fun = new_atb(1, data.cls)
    data.gold = math.random(0, 100)
    
    -- Store in data --
    for atb in pairs(fun) do
        
        data[atb] = fun[atb]
    end

    if data.cls == 'knight' then data.lft = 'iron sword (02)' end
    if data.cls == 'wizard' then data.lft = 'wood staff (03)' end
    if data.cls == 'archer' then data.lft = 'simple bow (01)' end

    -- Show it and save game --
    io.write('\nYour ')
    showAtb(data)

    save_game()
    hall()
end

-- Main place --
function hall()

    text = '\nWelcome back, ' .. data.name .. '!'
    io.write('\n' .. string.rep('=', #text * 3))
    io.write('\n' .. text .. '\n')

    chs = question('What you want to:\n\n see char  (0)\n travel to (1)\n save game (2)\n exit      (3)\n\nchoice', {'0', '1', '2', '3'})

    -- See character atributes --
    if chs == '0' then

        text = 'You are ' .. data.name .. ', the ' .. data.cls .. '!'

        io.write('\n' .. string.rep('=', #text * 3))
        io.write('\n' .. text .. '\n')

        io.write('\nYou are at lvl ' .. tostring(data.lvl) .. ' with ' .. tostring(data.exp) .. ' of EXP.')
        io.write('\nYou have ' .. tostring(data.gold) .. ' Pieces of Gold.')

        io.write('\n\nYour ')
        showAtb(data)
        
        if data.lft ~= nil then io.write('\nYour main weapon: ' .. itmc[data.cls] .. ' ' .. data.lft) end
        if data.itm ~= nil then io.write('\nYour efect item : ' .. data.itm) end

        io.write('\n\ntype any key to exit...')
        io.read()

        hall()
    end

    -- Travel to some place --
    if chs == '1' then
        
        to = question('Travel to:\n\n dungeons (0)\n shopping (1)\n quest    (2)\n cancel   (3)\n\nchoice', {'0', '1', '2', '3'})

        if to == '0' then dungeons() end
        if to == '1' then shopping() end
        if to == '2' then quest() end
        if to == '3' then hall() end
    end

    -- Save Game --
    if chs == '2' then

        save_game() 
        hall()
    end

    -- Exit --
    if chs == '3' then exit() end
end

--# Travel to ----------------------------------------------#--

function dungeons(room, cmstr, ftng)

    -- First call --
    if data.chp == nil then data.chp = data.thp end
    if room == nil then room = 1 end

    -- You died --
    if data.chp <= 0 then
        
        io.write('\nYou died!')
        exit()
    end

    -- Monster died --
    if cmstr ~= nil then
        
        if cmstr.chp <= 0 then
        
            io.write('\nYou killed the ' .. cmstr.name .. '!')
            io.write('\nYou got ' .. tostring(cmstr.hit + cmstr.thp) .. ' of EXP.\n')
            
            -- Gain EXP --
            data.exp = data.exp + cmstr.hit + cmstr.thp
            data.lvl = lvl_up(data.exp)

            -- Next level --
            room = room + 1
            ftng = false
            cmstr = nil
        
        else ftng = true end
    end

    -- 1# room : enemy --
    if room == 1 then

        -- Create a new monster --
        if cmstr == nil then

            io.write('\n' .. string.rep('===========', 3) .. '\n')
            io.write('\nFirst Room!\n')

            cmstr = new_atb(data.lvl)
            cmstr.name = new_mstr()
            cmstr.hit = math.random(0, 4 + data.lvl)
            cmstr.chp = cmstr.thp
        end
    
    -- 2# room : chest --
    elseif room == 2 then

        io.write('\n' .. string.rep('===========', 3) .. '\n')
        io.write('\nChest Room!\n')

        local itm = nil
        if data.cls == 'knight' then itm = swd[math.random(1, #swd)] end
        if data.cls == 'archer' then itm = bow[math.random(1, #bow)] end
        if data.cls == 'wizard' then itm = stf[math.random(1, #stf)] end

        io.write('\nYou found a chest. Inside have a ' .. itm:sub(1, -6))
        chs = question('Catch the item? (Y\\n)\n\nchoice', {'Y', 'y', 'N', 'n'})

        if chs:lower() == 'y' then data.lft = itm
        else io.write('\nAll right then... Next room!') end

        room = room + 1

    -- 3# room : boss --
    elseif room == 3 then
        
        -- Create a new monster --
        if cmstr == nil then

            io.write('\n' .. string.rep('==========', 3) .. '\n')
            io.write('\nBoss Room!\n')

            cmstr = new_atb(data.lvl + 1)
            cmstr.name = new_mstr()
            cmstr.hit = math.random(2, 6 + data.lvl)
            cmstr.chp = cmstr.thp
        end

    -- End --
    else
        
        data.chp = nil
        hall()
    end

    -- Fighting --
    if ftng then

        -- Chose an option --
        io.write('\nThe ' .. cmstr.name .. ' want to fight!')
        io.write('\n[current life: ' .. tostring(data.chp) .. ']')
        io.write('\n[monster life: ' .. tostring(cmstr.chp) .. ']')

        chs = question('\n Fight (0)\n Item  (1)\n Run   (2)\n About (3)\n\nchoice', {'0', '1', '2', '3'})

        -- Fight --
        if chs == '0' then data, cmstr = battle(data, cmstr) end

        -- Item --
        if chs == '1' then
            
            if data.itm ~= nil then data.bns = item(data.itm)
            else io.write('\nYou have no an item!') end
        end

        -- Scape --
        if chs == '2' then

            if data.int > cmstr.int then
                
                io.write('\nYou ran away!')
                ftng = false
                cmstr = nil

                room = room + 1

            else io.write('\nYou cannot scape!') end
        end

        -- See monster status --
        if chs == '3' then

            io.write('\nMonster ')
            showAtb(cmstr)
            io.write(' dmg: ' .. tostring(cmstr.hit) ..'\n')
        end
    end

    -- Next turn --
    if data.chp ~= nil then dungeons(room, cmstr, ftng) end
end

function shopping()

    io.write('\nHello, sir ' .. data.name .. '.')
    io.write('\nWhat would you like to buy today?')
    io.write('\n[ Your gold: ' .. tostring(data.gold) .. ']')

    buy = question('\n shield potion [20 PoG] (0)\n speed potion  [15 PoG] (1)\n life potion   [10 PoG] (2)\n bye!                   (3)\n\nchoice', {'0', '1', '2', '3'})

    if buy == '0' then
        
        if data.gold >= 20 then
            
            io.write('\nBought a shield potion for 20 Pieces of Gold!')
            data.itm = 'shield potion'
            data.gold = data.gold - 20
        
        else io.write('\nYou have no enogh gold.') end
    end

    if buy == '1' then
        
        if data.gold >= 15 then
            
            io.write('\nBought a speed potion for 20 Pieces of Gold!')
            data.itm = 'speed potion'
            data.gold = data.gold - 15
        
        else io.write('\nYou have no enogh gold.') end
    end

    if buy == '2' then
        
        if data.gold >= 10 then
            
            io.write('\nBought a life potion for 20 Pieces of Gold!')
            data.itm = 'life potion'
            data.gold = data.gold - 10
        
        else io.write('\nYou have no enogh gold.') end
    end

    if buy == '3' then io.write('\nPlease come back!\n') end

    hall()
end

function quest()

    pcnt = 0
    time = 0

    local qst = sys.split('buy a goat,kill a guy,invoke a ghost,create a music,plant a tree', ',')
    local qto = sys.split('for me,for my village,for my cat,for my wife,for my friend', ',')

    local qst_indx = math.random(1, #qst)
    local qto_indx = math.random(1, #qto)

    ido = question('Can you ' .. qst[qst_indx] .. ' ' .. qto[qto_indx] .. ' (Y\\n)?\n\nchoice', {'Y', 'y', 'N', 'n'})

    if ido:lower() == 'y' then

        while pcnt < 100 do
            
            if time + qst_indx <= os.time() then

                sys.relin('\nDoing (' .. tostring(math.floor(pcnt)) .. '% complete)...')
                pcnt = pcnt + (qto_indx / 10) + 0.5
                time = os.time()
            end
        end

        if pcnt >= 100 then
            
            loot = math.abs(math.floor((100 - data.gold) / 2))
            io.write('\n\nFinish! And you got ' .. loot .. ' PoG!\n')

            data.gold = data.gold + loot

            hall()
        end
    end
end

--# Combat -------------------------------------------------#--

function new_mstr()

    local adj = sys.split('disgusting,terrible,dangerous,legendary,fearsome,fallen,forgotten,evil,last,macabre,sadness', ',')
    local mtr = sys.split('dragon,knight,lizard,ghost,ogre,demon,spider,chicken,rabbit,goat,golem', ',')

    return adj[math.random(1,#adj)] .. ' ' .. mtr[math.random(1,#mtr)]
end

function battle(hero, mstr)

    -- Iniciative --
    local hinit = math.random(4, 12) + hero.dex
    local minit = math.random(4, 12) + mstr.dex

    -- Atack --
    local hhit = tonumber(hero.lft:sub(-3, -2))
    local hatk = math.random(4, 12) + hero.atk

    local matk = math.random(4, 12) + mstr.atk

    -- Bônus --
    if hero.bns ~= nil then
        
        if hero.bns.type == 'shield' then
            
            matk = matk - hero.bns.vall
            io.write('\nYou drunk the shield potion (efect: ' .. tostring(hero.bns.vall) .. ').\n')
        end

        if hero.bns.type == 'speed' then
            
            hinit = hinit + hero.bns.vall
            io.write('\nYou drunk the speed potion (efect: ' .. tostring(hero.bns.vall) .. ').\n')
        end

        if hero.bns.type == 'life' then
            
            hero.chp = hero.chp + hero.bns.vall

            -- Full life --
            if hero.chp > hero.thp then hero.chp = hero.thp end

            io.write('\nYou drunk the life potion (efect: ' .. tostring(hero.bns.vall) .. ').\n')
        end

        -- Clear bonus --
        hero.bns = nil
    end

    -- Hero atacks first --
    if hinit > minit then
        
        io.write('\nYou atacked first!')

        if hatk >= mstr.def then
            
            mstr.chp = mstr.chp - hhit
            io.write('\nYou hit him! And the ' .. mstr.name .. ' lost '.. tostring(hhit) ..' HP.\n')
        
        else io.write('\nOh.. you missed!\n') end
    
    -- Enemy atacks first --
    elseif hinit < minit then

        io.write('\nThe '.. mstr.name ..' atacked first!')

        if matk >= hero.def then
            
            hero.chp = hero.chp - mstr.hit
            io.write('\nHe hit you! And you lost '.. tostring(mstr.hit) ..' HP.\n')
        
        else io.write('\nHey! The '.. mstr.name ..' missed!\n') end

    -- Both atack --
    else

        io.write('\nBoth atack!\n')

        if hatk >= mstr.def then
            
            mstr.chp = mstr.chp - hhit
            io.write('\nYou hit him! And the ' .. mstr.name .. ' lost '.. tostring(hhit) ..' HP.\n')
        
        else io.write('\nOh.. you missed!\n') end

        if matk >= hero.def then
            
            hero.chp = hero.chp - mstr.hit
            io.write('\nHe hit you! And you lost '.. tostring(mstr.hit) ..' HP.\n')
        
        else io.write('\nHey! The '.. mstr.name ..' missed!\n') end
    end

    return hero, mstr
end

function item(name)

    local potion = {}
    potion.type = ''
    potion.vall = 0

    if name == 'shield potion' then

        potion.type = 'shield'
        potion.vall = 20
    end

    if name == 'speed potion' then

        potion.type = 'speed'
        potion.vall = 15
    end

    if name == 'life potion' then

        potion.type = 'life'
        potion.vall = 10
    end

    data.itm = nil
    return potion
end

function lvl_up(exp)

    -- Level 5 --
    if exp >= 800 and data.lvl == 4 then

        io.write('\nLevel up! You are now in lvl 5.\n')

        data.thp = data.thp + 5
        data.dex = data.dex + 2
        data.int = data.int + 2

        return 5

    -- Level 4 --
    elseif exp >= 400 and data.lvl == 3 then
        
        io.write('\nLevel up! You are now in lvl 4.\n')

        data.thp = data.thp + 4
        data.atk = data.atk + 2
        data.def = data.def + 2

        return 4

    -- Level 3 --
    elseif exp >= 200 and data.lvl == 2 then

        io.write('\nLevel up! You are now in lvl 3.\n')

        data.thp = data.thp + 3
        data.dex = data.dex + 1
        data.int = data.int + 1

        return 3
    
    -- Level 2 -- 
    elseif exp >= 100 and data.lvl == 1 then

        io.write('\nLevel up! you are now in lvl 2.\n')

        data.thp = data.thp + 2
        data.atk = data.atk + 1
        data.def = data.def + 1

        return 2

    -- Did not uped --
    else return data.lvl end
end

--# Creatures stuff ----------------------------------------#--

-- New atribute's set --
function new_atb(lvl, cls)
    
    local atb = {}

    atb.lvl = lvl

    atb.thp = math.random(4, 10) + lvl
    atb.def = math.random(-4, 4) + lvl

    atb.int = math.random(-4, 4)
    atb.dex = math.random(-4, 4)
    atb.atk = math.random(-4, 4)

    -- CLass bonus --
    if atb.int + 1 <= 4 and cls == 'wizard' then atb.int = atb.int + 1 end
    if atb.dex + 1 <= 4 and cls == 'archer' then atb.dex = atb.dex + 1 end
    if atb.atk + 1 <= 4 and cls == 'knight' then atb.atk = atb.atk + 1 end

    return atb
end

-- Print atributes --
function showAtb(atb)

    io.write('attributes:\n')
    io.write('\n total HP: ' .. tostring(atb.thp) .. '\n def: ' .. tostring(atb.def))
    io.write('\n\n int: ' .. tostring(atb.int) .. '\n dex: ' .. tostring(atb.dex)  .. '\n atk: ' .. tostring(atb.atk) ..'\n')
end

--# System stuff -------------------------------------------#--

-- Make a question and confirm --
function question(msg, van)

    -- This is local --
    local cnf, val = '', ''

    if msg ~= nil then

        io.write('\n' .. msg .. ': ')
        val = io.read()
    end

    -- If the answer needs be in a list --
    if van ~= nil and not sys.finds(van, val) then

        io.write('\nThis is not an option!\n')
        return question(msg, van)
    end

    -- Are you sure about that? --
    io.write('\nAre you sure? (Y\\n): ')
    cnf = io.read()

    if cnf:lower() == 'y' then return val
    else return question(msg, def) end
end

function save_game()

    -- Create file or read it --
    local file = io.open('C:\save.txt', 'w')
    local line = ''

    -- Write every value in pairs --
    for itm in pairs(data) do
        
        line = line .. tostring(itm) .. ':' .. tostring(data[itm]) .. '\n'
    end

    -- Remove the last enter (\n) --
    line = line:sub(1, -1)

    -- Write it on file --
    file:write(line)
    file:close()

    io.write('\nGame saved!\n')
end

function load_game()
    
    local splt = nil

    -- Open and read all lines --
    local file = io.open('C:\save.txt')
    local line = file:read('*all')

    file:close()

    -- Break text on enters --
    line = sys.split(line, '\n')

    -- Read every line --
    for itm in pairs(line) do
        
        -- Get value name and value --
        splt = sys.split(line[itm], ':')

        -- Convert to number if is --
        if tonumber(splt[2]) ~= nil then splt[2] = tonumber(splt[2]) end

        -- Store loaded data --
        data[splt[1]] = splt[2]
    end
end

function exit()
    
    io.write('\nBye!')
    io.read()
    os.exit()
end

--# Initialize system --------------------------------------#--

-- Set origin of randomness --
math.randomseed(os.time())

--Set terminal color --
os.execute('color 3')

io.write('Copyright(c) 2019-2020 Mateus Morais Dias (mateusmoraisdias3@gmail.com)\nby BinaryBrain_ all rights reserved.\n\nGame version : 1.7\n')
game = question('New game  (0)\nLoad game (1)\nchoice', {'0', '1'})

-- Load game --
if game == '1' then
    
    -- The save file exists --
    if io.open('C:\save.txt') ~= nil then
    
        load_game()
        hall()

    else

        io.write('\nYou have no a save file. Loading a new game...\n')
        new_chr()
    end

-- Create a new character --
else new_chr() end