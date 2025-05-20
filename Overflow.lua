Overflow.config = SMODS.current_mod.config

local files = {
    "ui",
    "hooks",
    "utils",
    "vanilla_bulk_use"
}
for i, v in ipairs(files) do    
    local f, err = SMODS.load_file(v..".lua")
    if f then f()
    else error(err) end
end

SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
}:register()


SMODS.Joker:take_ownership("j_perkeo", {
    calculate = function(self, orig_card, context)
        if context.ending_shop then
            if G.consumeables.cards[1] then
                local cards = {}
                for i, v in ipairs(G.consumeables.cards) do
                    cards[#cards+1] = {(v.ability.immutable.overflow_amount or 1), v}
                end
                local card = Overflow.weighted_random(cards, "perkeo")
                if card.ability.immutable.overflow_amount and Overflow.can_merge(card, card, true) then
                    Overflow.set_amount(card, card.ability.immutable.overflow_amount + 1)
                else
                    local check
                    for i, v in ipairs(G.consumeables.cards) do
                        if v.edition and v.edition.key == "e_negative" and v.config.center.key == card.config.center.key and v ~= card then
                            Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + 1)
                            check = true
                        end
                    end
                    if not check then
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
                    end
                end
                card_eval_status_text(context.blueprint_card or orig_card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                return {calculated = true}
            end
        end
    end
})