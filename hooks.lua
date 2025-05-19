--automatically stack consumables
local emplace_ref = CardArea.emplace
function CardArea:emplace(card, ...)
    if self ~= G.consumeables or card.config.center.set == "Joker" or card.ability.split then 
        emplace_ref(self, card, ...)
    else
        if Overflow.config.only_stack_negatives then
            if not card.edition or card.edition.key ~= "e_negative" then
                emplace_ref(self, card, ...)
            else
                local v, i = Overflow.TableMatches(self.cards, function(v, i)
                    return v.config.center.key == card.config.center.key and v.edition and v.edition.key == "e_negative"
                end)
                if v then
                    v.ability.overflow_amount = (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1)
                    card:start_dissolve()
                    v:create_overflow_ui()
                else
                    emplace_ref(self, card, ...)
                end
            end
        else    
            local v, i = Overflow.TableMatches(self.cards, function(v, i)
                if (not v.edition and not card.edition) or (v.edition and card.edition and v.edition.key == card.edition.key) then
                    return v.config.center.key == card.config.center.key
                end
            end)
            if v then
                v.ability.overflow_amount = (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1)
                card:start_dissolve()
                v:create_overflow_ui()
            else
                emplace_ref(self, card, ...)
            end
        end
    end
end

local set_editionref = Card.set_edition
function Card:set_edition(edition, ...)
    if self.area ~= G.consumeables or self.config.center.set == "Joker" or self.ability.split then
        set_editionref(self, edition, ...)
    else
        if Overflow.config.only_stack_negatives then
            if edition ~= "e_negative" then
                set_editionref(self, edition, ...)
            else    
                local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                    return v.config.center.key == self.config.center.key and v.edition and v.edition.key == "e_negative"
                end)
                if v then
                    v.ability.overflow_amount = (v.ability.overflow_amount or 1) + (self.ability.overflow_amount or 1)
                    self:start_dissolve()
                    v:create_overflow_ui()
                else
                    set_editionref(self, edition, ...)
                end
            end
        else
            local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                if (not v.edition and not self.edition) or (v.edition and self.edition and v.edition.key == self.edition.key) then
                    return v.config.center.key == self.config.center.key
                end
            end)
            if v then
                v.ability.overflow_amount = (v.ability.overflow_amount or 1) + (self.ability.overflow_amount or 1)
                self:start_dissolve()
                v:create_overflow_ui()
            else
                set_editionref(self, edition, ...)
            end
        end
    end
end

local use_cardref = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
    local card = e.config.ref_table
    if card.ability and card.ability.overflow_amount and to_big(card.ability.overflow_amount) > to_big(1) and card.area == G.consumeables then
        local new_card = copy_card(card)
        use_cardref(e, mute, nosave)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                new_card.ability.overflow_amount = card.ability.overflow_amount - 1
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
                new_card:create_overflow_ui()
                return true
            end
        }))
    else
        use_cardref(e, mute, nosave)
    end
end

local copy_cardref = copy_card
function copy_card(other, new_card, card_scale, playing_card, strip_edition, dont_reset_qty)
    local new_card2 = copy_cardref(other, new_card, card_scale, playing_card, strip_edition)
    if not dont_reset_qty then new_card2.ability.overflow_amount = nil end
    new_card2.ability.split = nil
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
            new_card2:create_overflow_ui()
            other:create_overflow_ui()
            return true
        end
    }))
    return new_card2
end