
HpBar = class("HpBar", function () return cc.Sprite:create("bloodBg.png") end)

function HpBar:ctor()
	local progress = cc.ProgressTimer:create(cc.Sprite:create("blood.png"))
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress:setMidpoint(cc.p(0, 0.5))
	progress:setBarChangeRate(cc.p(1.0, 0))
	progress:setAnchorPoint(cc.p(0,0))
	progress:setPosition(cc.p(0,0))
	progress:setPercentage(100)
	self:addChild(progress)
	self.progress = progress
end

function HpBar:setPercentage(p)
	self.progress:setPercentage(p)
end
