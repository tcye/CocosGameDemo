

Hero = class("Hero", Role)

local j_pressed = false
local k_pressed = false

function Hero:onKeyPressed(keycode, event)
	Role.onKeyPressed(self, keycode, event)

	if keycode == cc.KeyCode.KEY_J then
		self:runAttackaAction()
		j_pressed = true
	elseif keycode == cc.KeyCode.KEY_K then
		self:runAttackbAction()
		k_pressed = true
	end

	if j_pressed and k_pressed then
		self.life = self.life - cfg.role.hero.runattack_consume
		self:runRunAttackAction()
	end
end

function Hero:onKeyReleased(keycode, event)
	Role.onKeyReleased(self, keycode, event)

	if keycode == cc.KeyCode.KEY_J then
		j_pressed = false
	elseif keycode == cc.KeyCode.KEY_K then
		k_pressed = false
	end
end

function Hero:runChargeAction()
	if self:changeState(STATE_CHARGE) then
		self.allowmove = false
		self:stopAllActions()
		self:runAction(self.charge)
	end
end

function Hero:ownRunAttackAction(hurtvalue)
	local act1 = tk.getAnimation("hero.runattack1")
	local act2 = tk.getAnimation("hero.runattack2")
	local act3 = tk.getAnimation("hero.runattack3")
	local act4 = tk.getAnimation("hero.runattack4")
	local act5 = tk.getAnimation("hero.runattack5")
	
	self.runattackaction = cc.Sequence:create(
		cc.Animate:create(act1),
		self:createJudgeFunc(hurtvalue),
		cc.Animate:create(act2),
		self:createJudgeFunc(hurtvalue),
		cc.Animate:create(act3 ),
		self:createJudgeFunc(hurtvalue),
		cc.Animate:create(act4),
		self:createJudgeFunc(hurtvalue),
		cc.Animate:create(act5),
		self:createJudgeFunc(hurtvalue),
		self:createIdleFunc())
	self.runattackaction:retain()

	self.runRunAttackAction = function (self)
		if self:changeState(STATE_RUNATTACK) then
			self.allowmove = false
			self:stopAllActions()
			self:runAction(self.runattackaction)
		end
	end
end

function Hero:ctor()
	-- 空闲动作
	self:ownNormalAction("hero.idle", "runIdleAction", STATE_IDLE)
	-- 跑动动作
	self:ownNormalAction("hero.run", "runRunAction", STATE_RUN)
	-- 受伤动作
	--self:ownNormalAction("hero.hurt", "runHurtAction", STATE_HURT)
	self:ownHurtAction("hero.hurt")
	-- 普通攻击A, B, C，分出招和收招，期间夹杂攻击判定
	self:ownAttackAction("hero.attacka1", "hero.attacka2", 
		"runAttackaAction", self:createJudgeFunc(cfg.role.hero.attacka_damage))
	self:ownAttackAction("hero.attackb1", "hero.attackb2", 
		"runAttackbAction", self:createJudgeFunc(cfg.role.hero.attackb_damage))
	self:ownAttackAction("hero.attackc1", "hero.attackc2", 
		"runAttackcAction", self:createJudgeFunc(cfg.role.hero.attackc_damage))
	
	-- 大招，跑动攻击，需要消耗自身一定血量
	self:ownRunAttackAction(cfg.role.hero.runattack_damage)
	-- 死亡动作
	self:ownDeadAction("hero.dead")

	-- 调用父类初始化函数，完成键盘事件注册等工作
	Role.ctor(self)

	self.bodybox = cc.rect(-30, 0, 60, 60)
	self.hitbox = cc.rect(35, 0, 80, 90)
	self.life = cfg.role.hero.life

end

-- 伤害判定函数
function Hero:createJudgeFunc(hurtvalue)
	local function callback(node, tab)
		local enemies = self:getScene().enemies
		local hitbox = self:getHitBox()
		local alive = {}
		for i, e in ipairs(enemies) do
			local bodybox = e:getBodyBox()
			if math.abs(self.position.y - e.position.y) < 10 and
			 cc.rectIntersectsRect(hitbox, bodybox) then
				e.life = e.life - hurtvalue
				if e.life <= 0 then
					e:runDeadAction()
				else
					e:runHurtAction()
				end
			end
		end
	end
	return cc.CallFunc:create(callback)
end

function Hero:updatePositionOnMap()

	if self.state == STATE_RUNATTACK then
		local vx = 0
		local vy = self.velocity.y

		if self:isFlippedX() then
			vx = -3
		else
			vx = 3
		end
		self.position.x = self.position.x + vx
		self.position.y = self.position.y + vy
		-- 放大招时也不能跑出地图外去啊
		local mapwidth = self:getScene().mapwidth
		local mapheight = self:getScene().mapheight
		if self.position.x < 0 then
			self.position.x = 0
		elseif self.position.x > mapwidth then
		 	self.position.x = mapwidth
		end
		if self.position.y < 0 then
			self.position.y = 0
		elseif self.position.y > mapheight/4 then
		 	self.position.y = mapheight/4
		end

	else
		Role.updatePositionOnMap(self)
	end
end
