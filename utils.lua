function Overflow.TableMatches(table, func)
    for i, v in ipairs(table) do
        if func(v, i) then return v, i end
    end
end

function Overflow.bulk_use(card, area, amount)
    if card.config.center.bulk_use then
        card.config.center:bulk_use(card, area, nil, amount)
    end
end

function Overflow.can_bulk_use(card)
    if type(card.config.center.can_bulk_use) == "boolean" then return card.config.center.can_bulk_use end
    if type(card.config.center.can_bulk_use) == "function" then return card.config.center:can_bulk_use(card) end
    return card.config.center.can_bulk_use
end