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
    return card.config.center.can_bulk_use or Overflow.bulk_use_functions[card.config.center.key]
end

function Overflow.can_merge(self)
    if Overflow.config.only_stack_negatives then
        if not self.edition or self.edition.key ~= "e_negative" then
            return 
        else    
            local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                return v.config.center.key == self.config.center.key and v.edition and v.edition.key == "e_negative" and v ~= self
            end)
            return v
        end
    else
        local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
            if (not v.edition and not self.edition) or (v.edition and self.edition and v.edition.key == self.edition.key) then
                return v.config.center.key == self.config.center.key and v ~= self
            end
        end)
        return v
    end
end

function Overflow.set_amount(card, amount)
    if card then
        if to_big(amount) < to_big(1e100) then
            amount = to_number(amount)
        end
        card.ability.overflow_amount = amount
        if to_big(card.ability.overflow_amount) < to_big(1e100) then
            card.ability.overflow_amount = to_number(card.ability.overflow_amount)
        end
        card.ability.overflow_amount_text = amount and number_format(amount) or "s"
        card:set_cost()
        card:create_overflow_ui()
    end
end