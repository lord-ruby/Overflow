--manage buttons for the consumables
function Card:create_overflow_ui()
    if not self.ability.immutable then self.ability.immutable = {} end
    if self.ability.immutable.overflow_amount and to_big(self.ability.immutable.overflow_amount) == to_big(1) then
        self.ability.immutable.overflow_amount = nil
    end
    if self.ability.immutable.overflow_amount then
        if self.children.overflow_ui then
            self.children.overflow_ui:remove()
            self.children.overflow_ui = nil 
        end
        self.ability.immutable.overflow_amount_text = self.ability.immutable.overflow_amount_text or number_format(self.ability.immutable.overflow_amount)
        self.children.overflow_ui = UIBox {
			definition = {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.C, config={ref_table = self, align = "tm",maxw = 1.5, padding = 0.1, r=0.08, minw = 0.45, minh = 0.45, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE}, nodes={
                  {n=G.UIT.T, config={text = "x",colour = G.C.RED, scale = 0.35, shadow = true}},
                  {n=G.UIT.T, config={ref_table = self.ability.immutable, ref_value = 'overflow_amount_text',colour = G.C.WHITE, scale = 0.35, shadow = true}}
                }}
              }
			},
			config = {
				align = "tm",
				bond = 'Strong',
				parent = self
			},
			states = {
				collide = { can = false },
				drag = { can = true }
			}
		}
    end
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
	card_load_ref(self, cardTable, other_card)
	if self.ability then
        if not self.ability.immutable then self.ability.immutable = {} end
		if self.ability.immutable.overflow_amount then
			self:create_overflow_ui()
		end
	end
end

local highlight_ref = Card.highlight
function Card:highlight(is_highlighted)
    if self.area == G.consumeables and self.config.center.set ~= "Joker" and is_highlighted and self.ability.immutable.overflow_amount and to_big(self.ability.immutable.overflow_amount) > to_big(1) then
        local y = Overflow.can_bulk_use(self) and 0.3 or 0
        self.children.bulk_use = UIBox {
            definition = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.3,
                    maxh = 0.5,
                    minw = 0.4,
                    maxw = 4,
                    r = 0.08,
                    padding = 0.1,
                    align = 'cm',
                    colour = G.C.DARK_EDITION,
                    shadow = true,
                    button = 'bulk_use',
                    func = 'can_bulk_use',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_bulk_use"),
                            scale = 0.3,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = 'bmi',
                offset = {
                    x = 0,
                    y = y
                },
                bond = 'Strong',
                parent = self
            }
        }
        self.children.split_one = UIBox {
            definition = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.3,
                    maxh = 0.5,
                    minw = 0.4,
                    maxw = 4,
                    r = 0.08,
                    padding = 0.1,
                    align = 'cm',
                    colour = G.C.DARK_EDITION,
                    shadow = true,
                    button = 'split_one',
                    func = 'can_split_one',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_split_one"),
                            scale = 0.3,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = 'bmi',
                offset = {
                    x = 0,
                    y = y + 0.5
                },
                bond = 'Strong',
                parent = self
            }
        }
        self.children.split_half = UIBox {
            definition = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.3,
                    maxh = 0.5,
                    minw = 0.4,
                    maxw = 4,
                    r = 0.08,
                    padding = 0.1,
                    align = 'cm',
                    colour = G.C.DARK_EDITION,
                    shadow = true,
                    button = 'split_half',
                    func = 'can_split_half',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize("k_split_half"),
                            scale = 0.3,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = 'bmi',
                offset = {
                    x = 0,
                    y = y + 1
                },
                bond = 'Strong',
                parent = self
            }
        }
        if Overflow.can_merge(self) then
            self.children.merge = UIBox {
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        minh = 0.3,
                        maxh = 0.5,
                        minw = 0.4,
                        maxw = 4,
                        r = 0.08,
                        padding = 0.1,
                        align = 'cm',
                        colour = G.C.DARK_EDITION,
                        shadow = true,
                        button = 'merge',
                        func = 'can_merge',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge"),
                                scale = 0.3,
                                colour = G.C.UI.TEXT_LIGHT
                            }
                        }
                    }
                },
                config = {
                    align = 'bmi',
                    offset = {
                        x = 0,
                        y = y + 1.5
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
        end
    else    
        if is_highlighted and Overflow.can_merge(self) then
            self.children.merge = UIBox {
                definition = {
                    n = G.UIT.ROOT,
                    config = {
                        minh = 0.3,
                        maxh = 0.5,
                        minw = 0.4,
                        maxw = 4,
                        r = 0.08,
                        padding = 0.1,
                        align = 'cm',
                        colour = G.C.DARK_EDITION,
                        shadow = true,
                        button = 'merge',
                        func = 'can_merge',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge"),
                                scale = 0.3,
                                colour = G.C.UI.TEXT_LIGHT
                            }
                        }
                    }
                },
                config = {
                    align = 'bmi',
                    offset = {
                        x = 0,
                        y = 0.3
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
        else
            if self.children.bulk_use then 
                self.children.bulk_use:remove()
                self.children.bulk_use = nil
            end
            if self.children.split_one then 
                self.children.split_one:remove()
                self.children.split_one = nil
            end
            if self.children.split_half then 
                self.children.split_half:remove()
                self.children.split_half = nil
            end
            if self.children.merge then 
                self.children.merge:remove()
                self.children.merge = nil
            end
        end
    end
    return highlight_ref(self,is_highlighted)
end

G.FUNCS.can_bulk_use = function(e)
	local card = e.config.ref_table
	if (card.config.center.bulk_use or Overflow.bulk_use_functions[card.config.center.key]) and (not card.config.center.can_bulk_use or Overflow.can_bulk_use(card)) and to_big(card.ability.immutable.overflow_amount) > to_big(1) then
        e.config.colour = G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'bulk_use'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.bulk_use = function(e)
	local card = e.config.ref_table
    card.ability.overflow_used_amount = card.ability.immutable.overflow_amount
    Overflow.set_amount(card, nil)
    G.FUNCS.use_card(e, false, true)
end

G.FUNCS.can_split_one = function(e)
	local card = e.config.ref_table
	if to_big(card.ability.immutable.overflow_amount) > to_big(1) then
        e.config.colour = G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'split_one'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.split_one = function(e)
	local card = e.config.ref_table
    local new_card = copy_card(card)
    Overflow.set_amount(new_card, nil)
    Overflow.set_amount(card, card.ability.immutable.overflow_amount - 1)
    new_card:add_to_deck()
    new_card.ability.split = true
    G.consumeables:emplace(new_card)
end

G.FUNCS.can_merge = function(e)
	local card = e.config.ref_table
	if Overflow.can_merge(card) then
        e.config.colour = G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'merge'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.merge = function(e)
	local card = e.config.ref_table
    local v = Overflow.can_merge(card)
    if v then
        Overflow.set_amount(v, (v.ability.immutable.overflow_amount or 1) + (card.ability.immutable.overflow_amount or 1))
        card:start_dissolve()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            func = function()
                v:create_overflow_ui()
                card:create_overflow_ui()
                return true
            end
        }))
    end
end

G.FUNCS.can_split_half = function(e)
	local card = e.config.ref_table
	if to_big(card.ability.immutable.overflow_amount) > to_big(1) then
        e.config.colour = G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'split_half'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.split_half = function(e)
	local card = e.config.ref_table
    local new_card = copy_card(card)
    local top_half = math.floor(card.ability.immutable.overflow_amount/2)
    local bottom_half = card.ability.immutable.overflow_amount - top_half
    Overflow.set_amount(new_card, bottom_half)
    Overflow.set_amount(card, top_half)
    new_card:add_to_deck()
    new_card.ability.split = true
    G.consumeables:emplace(new_card)
end

local overflowConfigTab = function()
	ovrf_nodes = {
	}
	left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
	right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
	config = { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = { left_settings, right_settings } }
	ovrf_nodes[#ovrf_nodes + 1] = config
	ovrf_nodes[#ovrf_nodes + 1] = create_toggle({
		label = localize("k_only_stack_negatives"),
		active_colour = HEX("40c76d"),
		ref_table = Overflow.config,
		ref_value = "only_stack_negatives",
		callback = function()
        end,
	})
    ovrf_nodes[#ovrf_nodes + 1] = create_toggle({
		label = localize("k_fix_slots"),
		active_colour = HEX("40c76d"),
		ref_table = Overflow.config,
		ref_value = "fix_slots",
		callback = function()
        end,
	})
	return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = ovrf_nodes,
	}
end

SMODS.current_mod.config_tab = overflowConfigTab