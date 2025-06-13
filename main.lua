SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
}:register()

SMODS.Joker:take_ownership("j_perkeo", {
    demicoloncompat = true,
    name = "Perkeo (Overflow)",
    calculate = function(self, orig_card, context)
        return PerkeoOverride(self, orig_card, context)
    end
})
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
SMODS.Joker:take_ownership("j_constellation", {
    demicoloncompat = true,
    name = "Constellation (Overflow)",
    calculate = function(self, card, context)
        if (context.using_consumeable and context.consumeable.ability.set == 'Planet') or context.forcetrigger then
            card.ability.x_mult = card.ability.x_mult + (card.ability.extra * (context.consumeable.ability.overflow_used_amount or 1))
            G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}}}); return true
                end}))
            return
        end
    end,
    loc_vars = function(self,q,card)
        return {
            vars = {
                card.ability.extra,
                card.ability.x_mult
            }
        }
    end
})
SMODS.current_mod.config_tab = Overflow.overflowConfigTab

if not SMODS or not SMODS.Mods.Talisman or not SMODS.Mods.Talisman.can_load then
    to_big = function(num) return num or -1e300 end
    to_number = function(num) return num or -1e300 end
end

