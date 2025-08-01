--automatically stack consumables
local emplace_ref = CardArea.emplace
function CardArea:emplace(card, ...)
    if self ~= G.consumeables or card.config.center.set == "Joker" or card.ability.split or Overflow.is_blacklisted(card) or not G.consumeables then
        emplace_ref(self, card, ...)
        if card.children.overflow_ui then
            card.children.overflow_ui:remove()
            card.children.overflow_ui = nil 
        end
    else
        if not card.ability.immutable then card.ability.immutable = {} end
        if Overflow.config.only_stack_negatives or (MP and MP.LOBBY and MP.LOBBY.code) then
            if not card.edition or not card.edition.negative then
                emplace_ref(self, card, ...)
            else
                local v, i = Overflow.TableMatches(self.cards, function(v, i)
                    return v.config.center.key == card.config.center.key and v.edition and v.edition.negative and v ~= self
                end)
                if v then
                    Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (card.ability.immutable.overflow_amount or 1))
                    card.states.visible = false
                    card.ability.bypass_aleph = true
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
                card.ability.bypass_aleph = true
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
        if Overflow.config.only_stack_negatives or (MP and MP.LOBBY and MP.LOBBY.code) then
            if (type(edition) == "string" and edition ~= "e_negative") or (type(edition) == "table" and not edition.negative) then
                set_editionref(self, edition, ...)
            else    
                local v, i = Overflow.TableMatches(G.consumeables.cards, function(v, i)
                    return v.config.center.key == self.config.center.key and v.edition and v.edition.negative and v ~= self
                end)
                if v then
                    Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (self.ability.immutable.overflow_amount or 1))
                    self.states.visible = false
                    self.ability.bypass_aleph = true
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
                self.ability.bypass_aleph = true
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
    local mod = G.GAME.modifiers.entr_twisted
    G.GAME.modifiers.entr_twisted = nil
    if card.children.overflow_ui then
        card.children.overflow_ui:remove()
        card.children.overflow_ui = nil 
    end
    if (not card.ability.cry_multiuse or to_big(card.ability.cry_multiuse) <= to_big(1)) then
        if card.ability and card.ability.immutable and card.ability.immutable.overflow_amount and to_big(card.ability.immutable.overflow_amount) > to_big(1) and card.area == G.consumeables then
            local new_card = copy_card(card)
            G.GAME.modifiers.entr_twisted = mod
            card.ability.bypass_aleph = true
            local amount = card.ability.immutable.overflow_amount
            use_cardref(e, mute, nosave)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    new_card:add_to_deck()
                    G.consumeables:emplace(new_card)
                    new_card.ability.immutable = new_card.ability.immutable or {}
                    new_card.ability.immutable.overflow_amount = amount - 1
                    new_card.ability.immutable.overflow_amount_text = number_format(new_card.ability.immutable.overflow_amount)
                    new_card.bypass = true
                    if to_big(new_card.ability.immutable.overflow_amount or 0) > to_big(0) then
                        new_card:create_overflow_ui()
                    end
                    new_card.bypass = nil
                    return true
                end
            }))
        else
            G.GAME.modifiers.entr_twisted = mod
            card.ability.bypass_aleph = true
            if not card.ability.immutable then card.ability.immutable = {} end
            local amount = card.ability.immutable.overflow_amount
            use_cardref(e, mute, nosave)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    Overflow.set_amount(card, (amount or 1) - 1)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            if to_big(card.ability.immutable.overflow_amount or 0) > to_big(0) then
                                card:create_overflow_ui()
                            end
                            return true
                        end
                    }))
                    return true
                end
            }))
        end
    else
        G.GAME.modifiers.entr_twisted = mod
        card.ability.bypass_aleph = true
        local amount = card.ability.immutable.overflow_amount
        use_cardref(e, mute, nosave)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                Overflow.set_amount(card, (amount or 1) - 1)
                if to_big(card.ability.immutable.overflow_amount or 0) > to_big(0) then
                    card:create_overflow_ui()
                end
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        func = function()
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    e.config.ref_table.ability.overflow_used_amount = nil
                    return true
                end
            }))
            return true
        end
    }))
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
            new_card2.ability.bypass_aleph = true
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
function Card:set_cost(...)
	local cost = set_cost_ref(self, ...)
    if not self.ability.immutable then self.ability.immutable = {} end
    if self.ability.immutable.overflow_amount and to_big(self.ability.immutable.overflow_amount) > to_big(0) and self.ability.consumeable then
	    local cost = self.sell_cost * (self.ability.immutable.overflow_amount or 1)
        if to_big(math.abs(cost)) > to_big(0) then
            self.sell_cost = cost
        end
        self.sell_cost_label = self.facing == 'back' and '?' or number_format(self.sell_cost)
    end
    return cost
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
	card_load_ref(self, cardTable, other_card)
	if self.ability then
		self.ability.immutable = self.ability.immutable or {}
        self.ability.immutable.overflow_amount = cardTable.overflow_amount
        if self.ability.immutable.overflow_amount then
            self.bypass = true
            self:create_overflow_ui()
            self.bypass = nil
        end
	end
end
local card_save_ref = Card.save
function Card:save()
    local tbl = card_save_ref(self)
    tbl.overflow_amount = self and self.ability and self.ability.immutable and self.ability.immutable.overflow_amount
    return tbl
end

if not SMODS then
    local init_localization_ref = init_localization
    function init_localization(...)
        if not G.localization.__overflow_injected then
            local en_loc = require("overflow/localization/en-us")
            Overflow.table_merge(G.localization, en_loc)
            if G.SETTINGS.language ~= "en-us" then
                local success, current_loc = pcall(function()
                    return require("overflow/localization/" .. G.SETTINGS.language)
                end)
                if success and current_loc then
                    Overflow.table_merge(G.localization, current_loc)
                end
            end
            G.localization.__overflow_injected = true
        end
        return init_localization_ref(...)
    end
end

if not SMODS then
    function create_UIBox_current_hands(simple)

    local hands = {

    }
    for i, v in pairs(G.handlist) do
        hands[#hands+1] = v
    end
    if Overflow.config.sorting_mode ~= 1 then
        hands = Overflow.sort(hands, true)
    end
    for i, v in pairs(hands) do
        hands[i] = create_UIBox_current_hand_row(v, simple)
    end
    local t = {n=G.UIT.ROOT, config={align = "cm", minw = 3, padding = 0.1, r = 0.1, colour = G.C.CLEAR}, nodes={
      {n=G.UIT.R, config={align = "cm", padding = 0.04}, nodes=
        hands
      },
    }}
  
    return t
  end

end

function AllowStacking() end
function AllowDividing() end
function AllowMassUsing(set) Overflow.mass_use_sets[set] = true end
function AllowBulkUse() end
function Card:getQty()
    if not self.ability.immutable then self.ability.immutable = {} end
    return self.ability.immutable.overflow_amount or 1
end
function Card:setQty(q)
    Overflow.set_amount(self, q)
end
function Card:set_stack_display()
    self:create_overflow_ui()
end