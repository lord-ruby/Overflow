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

SMODS.current_mod.config_tab = Overflow.overflowConfigTab

if not SMODS.Mods.Talisman or not SMODS.Mods.Talisman.can_load then
    to_big = function(num) return num or -1e300 end
    to_number = function(num) return num or -1e300 end
end
