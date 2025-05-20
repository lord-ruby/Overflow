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
                    Overflow.set_amount(v, (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1))
                    card.states.visible = false
                    card:start_dissolve()
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
                Overflow.set_amount(v, (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1))
                card.states.visible = false
                card:start_dissolve()
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
                    Overflow.set_amount(v, (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1))
                    self.states.visible = false
                    self:start_dissolve()
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
                Overflow.set_amount(v, (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1))
                self.states.visible = false
                self:start_dissolve()
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
                Overflow.set_amount(new_card, card.ability.overflow_amount - 1)
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
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
    if other.area == G.consumeables and other.config.center.set ~= "Joker" and Overflow.can_merge(other, new_card) then
        if not dont_reset_qty then 
            Overflow.set_amount(new_card, nil) 
            new_card2.ability.split = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    new_card2:create_overflow_ui()
                    other:create_overflow_ui()
                    return true
                end
            }))
            return new_card2
        else
            Overflow.set_amount(other, to_big((other.ability.overflow_amount or 1)) * 2) 
            new_card2.ability.overflow_amount = 0
            new_card2:start_dissolve()
            return new_card2
        end
    else    
        return new_card2
    end
end

local set_cost_ref = Card.set_cost
function Card:set_cost()
	set_cost_ref(self)
	self.sell_cost = self.sell_cost * (self.ability.overflow_amount or 1)
    self.sell_cost_label = self.facing == 'back' and '?' or number_format(self.sell_cost)
end