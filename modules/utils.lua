function Overflow.TableMatches(table, func)
    for i, v in ipairs(table) do
        if func(v, i) then return v, i end
    end
end

function Overflow.bulk_use(card, area, amount)
    if card.config.center.bulk_use then
        card.config.center:bulk_use(card, area, nil, amount)
    end
    if Overflow.bulk_use_functions[card.config.center.key] then
        Overflow.bulk_use_functions[card.config.center.key](card, area, nil, amount)
    end
end

function Overflow.can_bulk_use(card)
    if type(card.config.center.can_bulk_use) == "boolean" then return card.config.center.can_bulk_use end
    if type(card.config.center.can_bulk_use) == "function" then return card.config.center:can_bulk_use(card) end
    return card.config.center.can_bulk_use or Overflow.bulk_use_functions[card.config.center.key] or card.config.center.bulk_use
end

function Overflow.can_merge(self, card, bypass, ignore_area)
    if self.dissolve or (card and card.dissolve) then return false end
    if card and self.sell_cost ~= card.sell_cost then return false end
    if Overflow.is_blacklisted(self) or Overflow.is_blacklisted(card) or (self.area ~= G.consumeables and not ignore_area) or self.config.center.set == "Joker" then return end
    if not card then
        if Overflow.config.only_stack_negatives or (MP and MP.LOBBY and MP.LOBBY.code) then
            if not self.edition or not self.edition.negative then
                return 
            else    
                local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                    return v.config.center.key == self.config.center.key and v.edition and v.edition.negative and (v ~= self or bypass)
                end)
                return v
            end
        else
            local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                if (not v.edition and not self.edition) or (v.edition and self.edition and v.edition.key == self.edition.key) then
                    return v.config.center.key == self.config.center.key and (v ~= self or bypass)
                end
            end)
            return v
        end
    else
        if (card.area ~= G.consumeables and not ignore_area) or card.config.center.set == "Joker" then return end
        if Overflow.config.only_stack_negatives or (MP and MP.LOBBY and MP.LOBBY.code) then
            if not self.edition or not self.edition.negative then
                return 
            else 
                return card.config.center.key == self.config.center.key and card.edition and card.edition.negative and (v ~= self or bypass)
            end
        else
            if (not card.edition and not self.edition) or (card.edition and self.edition and card.edition.key == self.edition.key) then
                return card.config.center.key == self.config.center.key and (card ~= self or bypass)
            end
        end
    end
end

function Overflow.set_amount(card, amount)
    if card then
        if to_big(amount or 0) < to_big(1e100) then
            amount = to_number(amount)
        end
        if not card.ability.immutable then card.ability.immutable = {} end
        card.ability.immutable.overflow_amount = amount
        if to_big(card.ability.immutable.overflow_amount or 0) < to_big(1e100) then
            card.ability.immutable.overflow_amount = to_number(card.ability.immutable.overflow_amount)
        end
        card.ability.immutable.overflow_amount_text = amount and number_format(amount) or "s"
        card:set_cost()
        card:create_overflow_ui()
        card.ability.immutable.overflow_used_amount = nil
    end
end

function Overflow.weighted_random(pool, pseudoseed)
    local poolsize = 0
    for k,v in pairs(pool) do
       poolsize = poolsize + to_number(v[1])*1000
    end
    local selection = pseudorandom(pseudoseed) * (poolsize-1) + 1
    for k,v in pairs(pool) do
       selection = selection - v[1] 
       if (to_big(selection) <= to_big(0)) then
          return v[2]
       end
    end
end

function Overflow.is_blacklisted(card)
    if not card then return false end
    return Overflow.blacklist[card.config.center.key] or Overflow.blacklist[card.config.center.set] or (card.base and card.base.suit)
end

function CardArea:get_total_count()
    local total = 0
    for i, v in ipairs(self.cards) do
        total = total + (v and v.ability and v.ability.immutable and v.ability.immutable.overflow_amount or 1)
    end
    return total
end

function Overflow.can_mass_use(set, area) 
    local total = 0
    if area == G.pack_cards or area == G.shop_jokers or area == G.shop_booster or area == G.shop_vouchers then return nil end
    for i, v in pairs(area) do
        if v.config.center.set == set then total = total + 1 end
    end
    return total > 1 and total or nil
end


function Overflow.table_merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(v) == "table" then
				target[k] = target[k] or {}
				target[k] = Overflow.table_merge(target[k], v)
			else
				target[k] = v
			end
		end
	end

	return target
end

function Overflow.save_config() 
    local serialized = "return { only_stack_negatives = "..tostring(Overflow.config.only_stack_negatives or false)..", fix_slots = "..tostring(Overflow.config.fix_slots or false)..", sorting_mode = "..tostring(Overflow.config.sorting_mode or 0).."}"
    love.filesystem.write("config/Overflow.lua", serialized)
end

function Overflow.load_config() 
    if love.filesystem.exists("config/Overflow.lua") then
    local str = ""
    for line in love.filesystem.lines("config/Overflow.lua") do
        str = str..line
    end
        return loadstring(str)()
    else    
        return {
            only_stack_negatives = true,
            fix_slots = true
        }
    end
end
if not Overflow.config then Overflow.config = Overflow.load_config() end

function Overflow.sort(hands, vanilla)
    if Overflow.config.sorting_mode == 2 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].level ) > to_big(1) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].level) > to_big(G.GAME.hands[b].level)
        end)
        tbl = {}
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].level) <= to_big(1) then
                tbl[#tbl+1] = other[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 3 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].chips ) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].chips) > to_big(G.GAME.hands[b].chips)
        end)
        tbl = {}
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].chips) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 4 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].mult ) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].mult) > to_big(G.GAME.hands[b].mult)
        end)
        tbl = {}
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].mult) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        return tbl
    end
    
    if Overflow.config.sorting_mode == 5 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if (to_big(G.GAME.hands[v].chips )*to_big(G.GAME.hands[v].mult )) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return (to_big(G.GAME.hands[a].chips )*to_big(G.GAME.hands[a].mult )) > (to_big(G.GAME.hands[b].chips )*to_big(G.GAME.hands[b].mult ))
        end)
        tbl = {}
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        for i, v in pairs(other) do
            if (to_big(G.GAME.hands[v].chips )*to_big(G.GAME.hands[v].mult )) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 6 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].played ) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].played) > to_big(G.GAME.hands[b].played)
        end)
        tbl = {}
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].played) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 7 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].level ) > to_big(1) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].level) < to_big(G.GAME.hands[b].level)
        end)
        tbl = {}
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].level) <= to_big(1) then
                tbl[#tbl+1] = other[i]
            end
        end
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 8 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].chips ) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].chips) < to_big(G.GAME.hands[b].chips)
        end)
        tbl = {}
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].chips) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 9 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].mult ) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].mult) < to_big(G.GAME.hands[b].mult)
        end)
        tbl = {}
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].mult) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 10 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if (to_big(G.GAME.hands[v].chips )*to_big(G.GAME.hands[v].mult )) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return (to_big(G.GAME.hands[a].chips )*to_big(G.GAME.hands[a].mult )) < (to_big(G.GAME.hands[b].chips )*to_big(G.GAME.hands[b].mult ))
        end)
        tbl = {}
        for i, v in pairs(other) do
            if (to_big(G.GAME.hands[v].chips )*to_big(G.GAME.hands[v].mult )) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        return tbl
    end

    if Overflow.config.sorting_mode == 11 then
        tbl = copy_table(hands)
        levelled = {}
        other = {}
        for i, v in pairs(tbl) do if to_big(G.GAME.hands[v].played ) > to_big(0) then levelled[#levelled+1]=v else other[#other+1] = v end end
        table.sort(levelled, function(a,b)
            return to_big(G.GAME.hands[a].played) < to_big(G.GAME.hands[b].played)
        end)
        tbl = {}
        for i, v in pairs(other) do
            if to_big(G.GAME.hands[v].played) <= to_big(0) then
                tbl[#tbl+1] = other[i]
            end
        end
        if #levelled > 0 then
            for i, v in pairs(levelled) do
                tbl[#tbl+1] = levelled[i]
            end
        end
        return tbl
    end

    return hands
end
