--automatically stack consumables
local emplace_ref = CardArea.emplace
function CardArea:emplace(card, ...)
    if self ~= G.consumeables or card.config.center.set == "Joker" or card.ability.split or Overflow.is_blacklisted(card) or not G.consumeables then
        emplace_ref(self, card, ...)
    else
        if not card.ability.immutable then card.ability.immutable = {} end
        if Overflow.config.only_stack_negatives then
            if not card.edition or card.edition.key ~= "e_negative" then
                emplace_ref(self, card, ...)
            else
                local v, i = Overflow.TableMatches(self.cards, function(v, i)
                    return v.config.center.key == card.config.center.key and v.edition and v.edition.key == "e_negative" and v ~= self
                end)
                if v then
                    Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (card.ability.immutable.overflow_amount or 1))
                    card.states.visible = false
                    card:start_dissolve()
                else
                    emplace_ref(self, card, ...)
                end
            end
        else    
            local v, i = Overflow.TableMatches(self.cards, function(v, i)
                if (not v.edition and not card.edition) or (v.edition and card.edition and v.edition.key == card.edition.key) then
                    return v.config.center.key == card.config.center.key and v ~= self
                end
            end)
            if v then
                Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (card.ability.immutable.overflow_amount or 1))
                card.states.visible = false
                card:start_dissolve()
            else
                emplace_ref(self, card, ...)
            end
        end
        G.consumeables.config.card_count = G.consumeables.config.card_count + (card.ability.immutable.overflow_amount or 1)
    end
end

local set_editionref = Card.set_edition
function Card:set_edition(edition, ...)
    if self.area ~= G.consumeables or self.config.center.set == "Joker" or self.ability.split or Overflow.is_blacklisted(self) or not G.consumeables then
        set_editionref(self, edition, ...)
    else
        if not self.ability.immutable then self.ability.immutable = {} end
        if Overflow.config.only_stack_negatives then
            if edition ~= "e_negative" then
                set_editionref(self, edition, ...)
            else    
                local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                    return v.config.center.key == self.config.center.key and v.edition and v.edition.key == "e_negative" and v ~= self
                end)
                if v then
                    Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (self.ability.immutable.overflow_amount or 1))
                    self.states.visible = false
                    self:start_dissolve()
                else
                    set_editionref(self, edition, ...)
                end
            end
        else
            local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                if (not v.edition and not self.edition) or (v.edition and self.edition and v.edition.key == self.edition.key) then
                    return v.config.center.key == self.config.center.key and v ~= self
                end
            end)
            if v then
                Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (self.ability.immutable.overflow_amount or 1))
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
    
    if card.ability and card.ability.immutable and card.ability.immutable.overflow_amount and to_big(card.ability.immutable.overflow_amount) > to_big(1) and card.area == G.consumeables then
        local new_card = copy_card(card)
        use_cardref(e, mute, nosave)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                Overflow.set_amount(new_card, card.ability.immutable.overflow_amount - 1)
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
    if other.area == G.consumeables and other.config.center.set ~= "Joker" and Overflow.can_merge(other, new_card2, nil, dont_reset_qty) and not Overflow.is_blacklisted(other) then
        if not dont_reset_qty then 
            new_card2.ability.split = nil
            if not new_card2.ability.immutable then new_card2.ability.immutable = {} end
            new_card2.ability.immutable.overflow_amount = 1
            new_card2.ability.immutable.overflow_amount_text = ""
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
            Overflow.set_amount(other, to_big((other.ability.immutable.overflow_amount or 1)) * 2) 
            if not new_card2.ability.immutable then new_card2.ability.immutable = {} end
            new_card2.ability.immutable.overflow_amount = 0
            new_card2:start_dissolve()
            return new_card2
        end
    else    
        if not new_card2.ability.immutable then new_card2.ability.immutable = {} end
        new_card2.ability.immutable.overflow_amount = 1
        new_card2.ability.immutable.overflow_amount_text = ""
        return new_card2
    end
end

local set_cost_ref = Card.set_cost
function Card:set_cost()
	set_cost_ref(self)
    if not self.ability.immutable then self.ability.immutable = {} end
	self.sell_cost = self.sell_cost * (self.ability.immutable.overflow_amount or 1)
    self.sell_cost_label = self.facing == 'back' and '?' or number_format(self.sell_cost)
end

SMODS.Voucher:take_ownership('observatory', {
    calculate = function(self, card, context)
        if
            context.other_consumeable and
            context.other_consumeable.ability.set == 'Planet' and
            context.other_consumeable.ability.consumeable.hand_type == context.scoring_name
        then
            if not context.other_consumeable.ability.immutable then context.other_consumeable.ability.immutable = {} end
            return {
                x_mult = to_big(card.ability.extra) ^ (context.other_consumeable.ability.immutable.overflow_amount or 1),
                message_card = context.other_consumeable,
            }
        end
    end,
})

if not to_big then
    to_big = function(num) return num end
end
