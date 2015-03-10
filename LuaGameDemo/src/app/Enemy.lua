
Enemy = class("Enemy", Role)

function Enemy:onKeyPressed(keycode, event)
	-- 覆盖父类响应函数，敌人不能响应键盘操作
	--Role.onKeyPressed(self, keycode, event)
end

function Enemy:onKeyReleased(keycode, event)
	-- 覆盖父类响应函数，敌人不能响应键盘操作
	--Role.onKeyReleased(self, keycode, event)
end

function Enemy:ctor()
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
		"runAttackAction", self:createJudgeFunc(cfg.role.enemy.attack_damage))


	-- 调用父类构造函数，完成注册
	Role.ctor(self)
	-- 随机设置初始位置
	self.bodybox = cc.rect(-30, 0, 60, 70)
	self.hitbox = cc.rect(40, 0, 80, 70)
	self.life = cfg.role.enemy.life

	-- 增加血条在上面
	local hpbar= HpBar.new()
	self.hpbar = hpbar
	hpbar:setPosition(cc.p(100,170))
	hpbar:setScaleX(0.2)
	hpbar:setScaleY(0.4)
	self:addChild(hpbar)
	
end

function Enemy:updatePositionOnMap()
	-- 更新血条
	self.hpbar:setPercentage(self.life / cfg.role.enemy.life * 100)

	local hero = self:getScene().hero
	local dx = hero.position.x - self.position.x
	local dy = hero.position.y - self.position.y

	-- 如果英雄在攻击范围内，就直接发起攻击
	if math.abs(dx) < 70 and math.abs(dy) < 10 then
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
function Enemy:createJudgeFunc(hurtvalue)
	local function callback(node, tab)
		local hero = self:getScene().hero
		local bodybox = hero:getBodyBox()
		local hitbox = self:getHitBox()

		if math.abs(self.position.y - hero.position.y) < 10 and
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