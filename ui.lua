--manage buttons for the consumables
function Card:create_overflow_ui()
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
                    minh = 0.4,
                    maxh = 0.6,
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
                            scale = 0.4,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            },
            config = {
                align = 'bmi',
                offset = {
                    x = 0,
                    y = 0.4
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
    end
    return highlight_ref(self,is_highlighted)
end

G.FUNCS.can_bulk_use = function(e)
	local card = e.config.ref_table
	if card.config.center.bulk_use and (not card.config.center.can_bulk_use or Overflow.can_bulk_use(card)) and to_big(card.ability.overflow_amount) > to_big(1) then
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
    card.bulkuse = true
    card.ability.overflow_used_amount = card.ability.overflow_amount
    card.ability.overflow_amount = nil
    G.FUNCS.use_card(e, false, true)
end
