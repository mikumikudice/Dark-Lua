sys = {}

local lstr = ''

function sys.split(str, div)

    -- Table to store substrings --
    local subs = {}

    -- For every word --
    while true do

        -- Get index of substring (div) --
        local findx, lindx = str:find(div)

        -- Store last substring --
        if not findx then

            subs[#subs + 1] = str
            break
        end

        -- Store the substring before (div) --
        subs[#subs + 1], str = str:sub(1, findx - 1), str:sub(lindx + 1)
    end

    return subs
end

function sys.finds(lst, val)

    for it in pairs(lst) do
        
        if val == lst[it] then return it end
    end
end

function sys.tabletostr(tab)
    
    local cnv = ''

    for it in pairs(tab) do
        
        cnv = cnv .. tostring(tab[it]) .. ', '
    end

    cnv = cnv:sub(1, -3)

    return cnv
end

function sys.relin(str)

    io.write(('\b \b'):rep(#lstr))
    io.write(str)
    io.flush()
	io.flush()
    
    lstr = str
end

function sys.debug(message)
    
    io.write('\ndebug: [' .. tostring(message) .. ']\n')
end