--manage buttons for the consumables
function Card:create_overflow_ui()
    if self.ability.overflow_amount and to_big(self.ability.overflow_amount) == to_big(1) then
        self.ability.overflow_amount = nil
    end
    if self.ability.overflow_amount then
        if self.children.overflow_ui then
            self.children.overflow_ui:remove()
            self.children.overflow_ui = nil 
        end
        self.children.overflow_ui = UIBox {
			definition = {n=G.UIT.C, config={align = "tm"}, nodes={
                {n=G.UIT.C, config={ref_table = self, align = "tm",maxw = 0.45, padding = 0.1, r=0.08, minw = 0.45, minh = 0.45, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE}, nodes={
                  {n=G.UIT.T, config={text = "x",colour = G.C.RED, scale = 0.35, shadow = true}},
                  {n=G.UIT.T, config={ref_table = self.ability, ref_value = 'overflow_amount',colour = G.C.WHITE, scale = 0.35, shadow = true}}
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
		if self.ability.overflow_amount then
			self:create_overflow_ui()
		end
	end
end

local highlight_ref = Card.highlight
function Card:highlight(is_highlighted)
    if is_highlighted and self.ability.overflow_amount and to_big(self.ability.overflow_amount) > to_big(1) then
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
                    y = 0.3
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
                    y = 0.8
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
                    y = 1.3
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
                        y = 1.8
                    },
                    bond = 'Strong',
                    parent = self
                }
            }
        end
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
    return highlight_ref(self,is_highlighted)
end

G.FUNCS.can_bulk_use = function(e)
	local card = e.config.ref_table
	if (card.config.center.bulk_use or Overflow.bulk_use_functions[card.config.center.key]) and (not card.config.center.can_bulk_use or Overflow.can_bulk_use(card)) and to_big(card.ability.overflow_amount) > to_big(1) then
        e.config.colour = G.C.PURPLE
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
    card.ability.overflow_used_amount = card.ability.overflow_amount
    card.ability.overflow_amount = nil
    G.FUNCS.use_card(e, false, true)
end

G.FUNCS.can_split_one = function(e)
	local card = e.config.ref_table
	if to_big(card.ability.overflow_amount) > to_big(1) then
        e.config.colour = G.C.PURPLE
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
    new_card.ability.overflow_amount = nil
    card.ability.overflow_amount = card.ability.overflow_amount - 1
    new_card:add_to_deck()
    new_card.ability.split = true
    G.consumeables:emplace(new_card)
end

G.FUNCS.can_merge = function(e)
	local card = e.config.ref_table
	if Overflow.can_merge(card) then
        e.config.colour = G.C.PURPLE
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
        v.ability.overflow_amount = (v.ability.overflow_amount or 1) + (card.ability.overflow_amount or 1)
        card:start_dissolve()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
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
	if to_big(card.ability.overflow_amount) > to_big(1) then
        e.config.colour = G.C.PURPLE
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
    local top_half = math.floor(card.ability.overflow_amount/2)
    local bottom_half = card.ability.overflow_amount - top_half
    new_card.ability.overflow_amount = bottom_half
    card.ability.overflow_amount = top_half
    new_card:add_to_deck()
    new_card.ability.split = true
    G.consumeables:emplace(new_card)
end