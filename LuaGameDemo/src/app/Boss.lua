

Boss = class("Boss", Role)

function Boss:onKeyPressed(keycode, event)
	-- 覆盖父类响应函数，敌人不能响应键盘操作
	--Role.onKeyPressed(self, keycode, event)
end

function Boss:onKeyReleased(keycode, event)
	-- 覆盖父类响应函数，敌人不能响应键盘操作
	--Role.onKeyReleased(self, keycode, event)
end

function Boss:ctor()
	-- 空闲动作
	self:ownNormalAction("enemy.idle", "runIdleAction", STATE_IDLE)
	-- 跑动动作
	self:ownNormalAction("enemy.run", "runRunAction", STATE_RUN)
	-- 受伤动作
	self:ownHurtAction("enemy.hurt")
	-- 死亡动作
	self:ownDeadAction("enemy.dead")
	-- 普通攻击
	self:ownAttackAction("enemy.attack1", "enemy.attack2", 
		"runAttackAction", self:createJudgeFunc(20))


	-- 调用父类构造函数，完成注册
	Role.ctor(self)
	-- 设置初始位置
	self.bodybox = cc.rect(-60, 0, 120, 140)
	self.hitbox = cc.rect(80, 0, 160, 140)

	-- 增加血条在上面
	local hpbar= HpBar.new()
	self.hpbar = hpbar
	hpbar:setPosition(cc.p(100,170))
	hpbar:setScaleX(0.2)
	hpbar:setScaleY(0.4)
	self:addChild(hpbar)

	-- 大Boss嘛，自然要大一点。。。血多一点
	self:setScale(2)
	self.life = 1000
end

function Boss:updatePositionOnMap()
	-- 更新血条
	self.hpbar:setPercentage(self.life / 500 * 100)

	local hero = self:getScene().hero
	local dx = hero.position.x - self.position.x
	local dy = hero.position.y - self.position.y

	-- 如果英雄在攻击范围内，就直接发起攻击
	if math.abs(dx) < 160 and math.abs(dy) < 15 then
		self:runAttackAction()
	--如果英雄在视野范围内，就朝他跑过去
	elseif math.abs(dx) < 200 and math.abs(dy) < 100 then
		self.velocity = cc.p(dx, dy)
		self.velocity = cc.pNormalize(self.velocity)
		self.velocity = cc.pMul(self.velocity, 0.5)
	-- 如果英雄在视野外，就站立巡逻。。。好吧，以后再改成正真的巡逻。。。
	else
		self.velocity = cc.p(0, 0)
	end

	Role.updatePositionOnMap(self)
end

-- 伤害判定函数
function Boss:createJudgeFunc(hurtvalue)
	local function callback(node, tab)
		local hero = self:getScene().hero
		local bodybox = hero:getBodyBox()
		local hitbox = self:getHitBox()

		if math.abs(self.position.y - hero.position.y) < 15 and
			cc.rectIntersectsRect(hitbox, bodybox) then
			hero.life = hero.life - hurtvalue
			if hero.life <= 0 then
				hero:runDeadAction()
			else
				hero:runHurtAction()
			end
		end
		
	end
	return cc.CallFunc:create(callback)
end