if not SMODS then
    local calculate_jokerref = Card.calculate_joker
    function Card:calculate_joker(context)
        if self.debuff then return nil end
        if self.ability.set == "Planet" and not self.debuff then
            if context.joker_main then
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = {G.P_CENTERS.v_observatory.config.extra}},
                    Xmult_mod = to_big(G.P_CENTERS.v_observatory.config.extra) ^ to_big(self.ability.immutable.overflow_amount or 1)
                }
            end
        elseif self.ability.set == "Joker" and self.ability.name == "Perkeo" then
            return PerkeoOverride(G.P_CENTERS.j_perkeo, self, context)
        elseif self.ability.name == 'Constellation' and not context.blueprint and context.consumeable.ability.set == 'Planet' then
            self.ability.x_mult = self.ability.x_mult + (self.ability.extra * (context.consumeable.ability.overflow_used_amount or 1))
            G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={self.ability.x_mult}}}); return true
                end}))
            return
        end
        return calculate_jokerref(self, context)
    end
end


function PerkeoOverride(self, orig_card, context)
    if context.ending_shop or context.forcetrigger then
        if G.consumeables.cards[1] then
            local card
            if to_big(G.consumeables:get_total_count()) < to_big(200) then
                local cards = {}
                for i, v in ipairs(G.consumeables.cards) do
                    for k = 1, (v.ability.immutable.overflow_amount or 1) do
                        cards[#cards+1] = v
                    end
                end
                card = pseudorandom_element(G.consumeables.cards, pseudoseed('perkeo'))
            else
                local cards = {}
                for i, v in ipairs(G.consumeables.cards) do
                    cards[#cards+1] = {to_big(v.ability.immutable.overflow_amount or 1) / to_big(v.area:get_total_count()), v}
                end
                card = Overflow.weighted_random(cards, "perkeo")
            end
            
            if card and card.config.center.set == "Joker" then
                if not Talisman or not Talisman.config_file.disable_anims then
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local new_card = copy_card(card, nil)
                            new_card.ability.immutable.overflow_amount = 1
                            new_card:set_edition("e_negative", true)
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card) 
                            return true
                        end
                    }))
                else    
                    local new_card = copy_card(card, nil)
                    new_card.ability.immutable.overflow_amount = 1
                    new_card:set_edition("e_negative", true)
                    new_card:add_to_deck()
                    G.consumeables:emplace(new_card)
                end
            elseif card and Overflow.can_merge(card, card, true) and not Overflow.is_blacklisted(card) then
                if card.ability.immutable.overflow_amount then
                    if not Talisman or not Talisman.config_file.disable_anims then
                        G.E_MANAGER:add_event(Event({
                            func = function() 
                                play_sound('negative', 1.5, 0.4)
                                    Overflow.set_amount(card, card.ability.immutable.overflow_amount + 1)
                                    card:juice_up()
                                return true
                            end
                        }))
                    else
                        Overflow.set_amount(card, card.ability.immutable.overflow_amount + 1)
                    end
                else
                    local check
                    for i, v in ipairs(G.consumeables.cards) do
                        if v.edition and v.edition.negative and v.config.center.key == card.config.center.key and v ~= card and not v.dissolve then
                            if not Talisman or not Talisman.config_file.disable_anims then
                                G.E_MANAGER:add_event(Event({
                                    func = function() 
                                        play_sound('negative', 1.5, 0.4)
                                        v:juice_up()
                                        Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + 1)
                                        return true
                                    end
                                }))
                            else
                                Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + 1)
                            end
                            check = true
                        end
                    end
                    if not check then
                        if not Talisman or not Talisman.config_file.disable_anims then
                            G.E_MANAGER:add_event(Event({
                                func = function() 
                                    local new_card = copy_card(card, nil)
                                    new_card.ability.immutable.overflow_amount = 1
                                    new_card:set_edition("e_negative", true)
                                    new_card:add_to_deck()
                                    new_card.ability.split = true
                                    G.consumeables:emplace(new_card) 
                                    new_card.split = nil
                                    return true
                                end
                            }))
                        else    
                            local new_card = copy_card(card, nil)
                            new_card.ability.immutable.overflow_amount = 1
                            new_card:set_edition("e_negative", true)
                            new_card:add_to_deck()
                            new_card.ability.split = true
                            G.consumeables:emplace(new_card)
                            new_card.split = nil
                        end
                    end
                end
            elseif card then
                local new_card = copy_card(card, nil)
                new_card.ability.immutable.overflow_amount = 1
                new_card.ability.split = true
                new_card:set_edition("e_negative", true)
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
                new_card.split = nil
            end
            if not Talisman or not Talisman.config_file.disable_anims then
                card_eval_status_text(context.blueprint_card or orig_card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
            end
            return {calculated = true}
        end
    end
end
require("overflow/ui")
require("overflow/hooks")
require("overflow/utils")
require("overflow/bulk_use")

if not to_big then
    to_big = function(num) return num or -1e300 end
    is_number = function(num) return type(num) == "number" end
    to_number = function(num) return num or -1e300 end
end
