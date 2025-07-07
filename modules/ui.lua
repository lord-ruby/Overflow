--manage buttons for the consumables
function Card:create_overflow_ui()
    if not self.ability.immutable then self.ability.immutable = {} end
    if self.ability.immutable.overflow_amount and (to_big(self.ability.immutable.overflow_amount) == to_big(1) or to_big(self.ability.immutable.overflow_amount) == to_big(0)) then
        self.ability.immutable.overflow_amount = nil
    end
    if self.ability.immutable.overflow_amount and self.ability.immutable.overflow_amount_text ~= "" and (self.area == G.consumeables or self.bypass) then
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
    else
        if self.children.overflow_ui then
            self.children.overflow_ui:remove()
            self.children.overflow_ui = nil 
        end
        self.ability.immutable.overflow_amount = nil
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
        local y = Overflow.can_bulk_use(self) and 0.45 or 0
        if  Overflow.can_bulk_use(self) then
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
        end
        if Overflow.mass_use_sets[self.config.center.set] and self.area and Overflow.can_mass_use(self.config.center.set, self.area.cards) and G.FUNCS.can_mass_use({config = {ref_table = self}}) then
            self.children.mass_use = UIBox {
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
                        button = 'mass_use',
                        func = 'can_mass_use',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_mass_use"),
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
                        y = y+0.5
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
            y = y + 0.5
        end
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
            self.children.merge_all = UIBox {
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
                        button = 'merge_all',
                        func = 'can_merge_all',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge_all"),
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
                        y = y + 2
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
        end
    else  
        local y = 0.3
        if is_highlighted and Overflow.mass_use_sets[self.config.center.set] and self.area and Overflow.can_mass_use(self.config.center.set, self.area.cards) and G.FUNCS.can_mass_use({config = {ref_table = self}}) then
            self.children.mass_use = UIBox {
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
                        button = 'mass_use',
                        func = 'can_mass_use',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_mass_use"),
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
            y = y + 0.5
        else
            if self.children.mass_use then 
                self.children.mass_use:remove()
                self.children.mass_use = nil
            end 
        end
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
                        y = y
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
            self.children.merge_all = UIBox {
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
                        button = 'merge_all',
                        func = 'can_merge_all',
                        ref_table = self
                    },
                    nodes = {
                        {
                            n = G.UIT.T,
                            config = {
                                text = localize("k_merge_all"),
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
            if self.children.merge_all then 
                self.children.merge_all:remove()
                self.children.merge_all = nil
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
    card.ability.bypass_aleph = true
    if card.children.overflow_ui then
        card.children.overflow_ui:remove()
        card.children.overflow_ui = nil 
    end
    G.FUNCS.use_card(e, false, true)
end

G.FUNCS.can_split_one = function(e)
	local card = e.config.ref_table
	if to_big(card.ability.immutable.overflow_amount or 0) > to_big(1) then
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
    local mod = G.GAME.modifiers.entr_twisted 
    G.GAME.modifiers.entr_twisted = nil
	local card = e.config.ref_table
    local new_card = copy_card(card)
    Overflow.set_amount(new_card, nil)
    Overflow.set_amount(card, card.ability.immutable.overflow_amount - 1)
    new_card:add_to_deck()
    card:set_cost()
    new_card:set_cost()
    new_card.ability.immutable.overflow_used_amount = nil
    card.ability.immutable.overflow_used_amount = nil
    new_card.ability.split = true
    G.consumeables:emplace(new_card)
    G.GAME.modifiers.entr_twisted = mod
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
        card.ability.bypass_aleph = true
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
    local mod = G.GAME.modifiers.entr_twisted 
    G.GAME.modifiers.entr_twisted = nil
	local card = e.config.ref_table
    local new_card = copy_card(card)
    local top_half = math.floor(card.ability.immutable.overflow_amount/2)
    local bottom_half = card.ability.immutable.overflow_amount - top_half
    new_card.bypass = true
    card.bypass = true
    Overflow.set_amount(new_card, bottom_half)
    Overflow.set_amount(card, top_half)
    new_card:add_to_deck()
    new_card.ability.split = true
    card:set_cost()
    new_card:set_cost()
    new_card.ability.immutable.overflow_used_amount = nil
    card.ability.immutable.overflow_used_amount = nil
    G.consumeables:emplace(new_card)
    new_card:create_overflow_ui()
    card:create_overflow_ui()
    new_card.bypass = nil
    card.bypass = nil
    G.GAME.modifiers.entr_twisted = mod
end

G.FUNCS.can_merge_all = function(e)
	local card = e.config.ref_table
    local count = 0
    for i, v in ipairs(G.consumeables.cards) do
        if v ~= card and v.config.center.key == card.config.center.key then count = count + 1 end
    end
	if Overflow.can_merge(card) and count > 1 then
        e.config.colour = G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'merge_all'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.merge_all = function(e)
	local card = e.config.ref_table
    for i, v in ipairs(G.consumeables.cards) do
        if Overflow.can_merge(v, card) and card ~= v then
            v.ability.bypass_aleph = true
            v:start_dissolve()
            Overflow.set_amount(card, (v.ability.immutable.overflow_amount or 1) + (card.ability.immutable.overflow_amount or 1))
        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        func = function()
            card:create_overflow_ui()
            return true
        end
    }))
end


G.FUNCS.can_mass_use = function(e)
	local card = e.config.ref_table
    if card.area == G.hand or card.area == G.consumeables then
        e.config.colour = G.C.SECONDARY_SET[card.config.center.set]
        e.config.button = 'mass_use'
        if e.states then
            e.states.visible = true
        end
        return true
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
        if e.states then
            e.states.visible = false
        end
        return nil
    end
end

G.FUNCS.mass_use = function(e)
	local card = e.config.ref_table
    card.mass_use = true
    card.ability.immutable.overflow_amount = card.ability.immutable.overflow_amount or 1
    G.FUNCS.bulk_use(e)
end

local use_cardref = G.FUNCS.use_card
G.FUNCS.use_card = function(e)
    local card = e.config.ref_table
    local area = card.area
    use_cardref(e)
    if card.mass_use then
        local c
        for i, v in ipairs(area.cards) do
            if v.config.center.set == card.config.center.set then c = v end
        end
        if c then
            c.mass_use = true
            c.ability.immutable.overflow_amount = c.ability.immutable.overflow_amount or 1
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    G.E_MANAGER:add_event(Event({ --why must you forsake me like this
                        trigger = 'after',
                        func = function()
                            G.FUNCS.bulk_use{config = {ref_table = c}}
                            return true
                        end
                    }))
                    return true
                end
            }))
        end
    end
end


Overflow.overflowConfigTab = function()
	ovrf_nodes = {
	}
	left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
	right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
	config = { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = { left_settings, right_settings } }
	ovrf_nodes[#ovrf_nodes + 1] = config
	ovrf_nodes[#ovrf_nodes + 1] = create_toggle({
		label = MP and localize("k_only_stack_negatives_mp") or localize("k_only_stack_negatives"),
		active_colour = HEX("40c76d"),
		ref_table = Overflow.config,
		ref_value = "only_stack_negatives",
		callback = function()
            Overflow.save_config()
        end,
	})
    ovrf_nodes[#ovrf_nodes + 1] = create_toggle({
		label = MP and localize("k_fix_slots_mp") or localize("k_fix_slots"),
		active_colour = HEX("40c76d"),
		ref_table = Overflow.config,
		ref_value = "fix_slots",
		callback = function()
            Overflow.save_config()
        end,
	})

    ovrf_nodes[#ovrf_nodes + 1] = create_option_cycle({
		label = localize("sorting_mode"),
		scale = 0.8,
		w = 8,
		options = {localize("sorting_default"), localize("sorting_lh"), localize("sorting_ch"), localize("sorting_mh"), localize("sorting_sh"), localize("sorting_ph"), localize("sorting_ll"), localize("sorting_cl"), localize("sorting_ml"), localize("sorting_sl"), localize("sorting_pl")},
		opt_callback = "update_sorting_mode",
		current_option = Overflow.config.sorting_mode,
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

if not SMODS then
    function noSMODSoverflowConfigTab()
        local t = create_UIBox_generic_options({
            contents = {
                {
                    n = G.UIT.R,
                    nodes = {
                        create_toggle({
                            label = MP and localize("k_only_stack_negatives_mp") or localize("k_only_stack_negatives"),
                            active_colour = HEX("40c76d"),
                            ref_table = Overflow.config,
                            ref_value = "only_stack_negatives",
                            callback = function()
                                Overflow.save_config()
                            end,
                        }),
                        create_toggle({
                            label = MP and localize("k_fix_slots_mp") or localize("k_fix_slots"),
                            active_colour = HEX("40c76d"),
                            ref_table = Overflow.config,
                            ref_value = "fix_slots",
                            callback = function()
                                Overflow.save_config()
                            end,
                        }),
                        create_option_cycle({
                            label = localize("sorting_mode"),
                            scale = 0.8,
                            w = 8,
                            options = {localize("sorting_default"), localize("sorting_lh"), localize("sorting_ph"), localize("sorting_ll"), localize("sorting_pl")},
                            opt_callback = "update_sorting_mode",
                            current_option = Overflow.config.sorting_mode,
                        })
                    }
                }
            }
        })
        return t
    end
    local create_uibox_options_ref = create_UIBox_options
    function create_UIBox_options()
        local contents = create_uibox_options_ref()
        table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, 
        UIBox_button({ label = { "Overflow" }, button = "overflow_open_config", minw = 5, colour = HEX("FF0000") }))
        return contents
    end
    function G.FUNCS.overflow_open_config(e)
        G.SETTINGS.paused = true
        Overflow.config_opened = true
        G.FUNCS.overlay_menu({
            definition = noSMODSoverflowConfigTab(),
        })
    end
    function G.FUNCS.overflow_close_config(e)
        Overflow.config_opened = nil
        if e then
            return G.FUNCS.options(e)
        end
    end
end

G.FUNCS.update_sorting_mode = function(e)
	Overflow.config.sorting_mode = e.to_key
    Overflow.save_config()
end
