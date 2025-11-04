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
        if (context.using_consumeable and context.consumeable.ability.set == 'Planet' and not context.blueprint) or context.forcetrigger then
            for _=1,(context.consumeable and context.consumeable.ability.overflow_used_amount or 1)-1 do
                SMODS.scale_card(card, {
                    ref_table = card.ability,
                    ref_value = "x_mult",
                    scalar_value = "extra",
                    scaling_message = {}
                })
            end
            SMODS.scale_card(card, {
                ref_table = card.ability,
                ref_value = "x_mult",
                scalar_value = "extra",
                message_key = 'a_xmult'
            })
            return nil, true
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

if not to_big then
    to_big = function(num) return num or -1e300 end
    is_number = function(num) return type(num) == "number" end
    to_number = function(num) return num or -1e300 end
end

