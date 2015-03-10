
Role = class("Role", function () return cc.Sprite:create() end)

STATE_IDLE = 0
STATE_RUN = 1
STATE_ATTACK = 2
STATE_CHARGE =3
STATE_DEAD = 4
STATE_HURT = 5
STATE_RUNATTACK = 6

function Role:onKeyPressed(keycode, event)
	if keycode == cc.KeyCode.KEY_A then
		self.velocity.x = self.velocity.x - 2
	elseif keycode == cc.KeyCode.KEY_D then
		self.velocity.x = self.velocity.x + 2
	elseif keycode == cc.KeyCode.KEY_W then
		self.velocity.y = self.velocity.y + 1
	elseif keycode == cc.KeyCode.KEY_S then
		self.velocity.y = self.velocity.y - 1
	end
end

function Role:onKeyReleased(keycode, event)
	if keycode == cc.KeyCode.KEY_A then
		self.velocity.x = self.velocity.x + 2
	elseif keycode == cc.KeyCode.KEY_D then
		self.velocity.x = self.velocity.x - 2
	elseif keycode == cc.KeyCode.KEY_W then
		self.velocity.y = self.velocity.y - 1
	elseif keycode == cc.KeyCode.KEY_S then
		self.velocity.y = self.velocity.y + 1
	end
end

function Role:changeState(s)
	-- 正在受伤时不能攻击（可能被连招连死）
	if self.beinghurt and s == STATE_ATTACK then return false end
	-- 当角色死亡或者要切换的状态与当前状态相同，则不能切换到状态s
	if self.state == STATE_DEAD or self.state == s then 
		return false
	end
	self.state = s
	return true
end

function Role:createIdleFunc()
	local function callback(node, tab)
		self.allowmove = true
		self.beinghurt = false
		self:runIdleAction()
	end
	return cc.CallFunc:create(callback)
end

-- 模板，为角色添加普通action，并添加普通action的触发函数
function Role:ownNormalAction(actName, runFntName, state)
	local act = tk.getAnimation(actName)
	self[actName] = cc.RepeatForever:create(cc.Animate:create(act))
	self[actName]:retain()

	self[runFntName] = function (self)
		if self:changeState(state) then
			self:stopAllActions()
			self:runAction(self[actName])
		end
	end
end

-- 模板，为角色添加攻击action，并添加攻击action的触发函数
function Role:ownAttackAction(actName1, actName2, runFntName, judgeFunc,state)
	state = state or STATE_ATTACK
	local act1 = tk.getAnimation(actName1)
	local act2 = tk.getAnimation(actName2)
	local actName = actName1 .. actName2
	self[actName] = cc.Sequence:create(
		cc.Animate:create(act1),
		judgeFunc,
		cc.Animate:create(act2),
		self:createIdleFunc())
	self[actName]:retain()

	self[runFntName] = function (self)
		if self:changeState(state) then
			self.allowmove = false
			self:stopAllActions()
			self:runAction(self[actName])
		end
	end
end

function Role:createDeadRemoveFunc()
	local function ret(node, tab)
		--self:removeFromParent()
		self:setVisible(false)
	end
	return cc.CallFunc:create(ret)
end

-- 模板，为角色添加死亡动作，并添加死亡的触发函数
function Role:ownDeadAction(actName)
	local act = tk.getAnimation(actName)
	self.dead = cc.Sequence:create(
		cc.Animate:create(act),
		cc.Blink:create(3, 9),
		self:createDeadRemoveFunc())
	self.dead:retain()
	
	self.runDeadAction = function (self)
		if self:changeState(STATE_DEAD) then
			self.allowmove = false
			self:stopAllActions()
			self:runAction(self.dead)
		end
	end
end

function Role:ownHurtAction(actName)
	local act = tk.getAnimation(actName)
	self.hurt = cc.Sequence:create(
		cc.Animate:create(act),
		self:createIdleFunc())
	self.hurt:retain()
	
	self.runHurtAction = function (self)
		if self:changeState(STATE_HURT) then
			self.allowmove =false
			self.beinghurt = true
			self:stopAllActions()
			self:runAction(self.hurt)
		end
	end
end

function Role:ctor()

	-- 设置任务初始速度和初始位置
	self.velocity = cc.p(0, 0)
	self.position = cc.p(0, 0)
	self.allowmove = true
	self:runIdleAction()

	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	local listener = cc.EventListenerKeyboard:create()

	-- 注册listener响应键盘控制
	listener:registerScriptHandler(tk.bind(self.onKeyPressed, self), cc.Handler.EVENT_KEYBOARD_PRESSED)
	listener:registerScriptHandler(tk.bind(self.onKeyReleased, self), cc.Handler.EVENT_KEYBOARD_RELEASED)
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	-- 每帧更新Role在地图上的位置
	self:scheduleUpdateWithPriorityLua(function() self:updatePositionOnMap() end, 10)
end

-- update函数每帧调用，通过Role的状态更新Role在地图上的位置
function Role:updatePositionOnMap()
	-- 如果处于不可打断的效果中，不更新位置，等待效果播放完毕
	if not self.allowmove then return end

	local mapwidth = tk.getRunningScene().mapwidth
	local mapheight = tk.getRunningScene().mapheight

	local orig = self.position
	self.position = cc.pAdd(self.position, self.velocity)

	-- 不能跑出地图外
	if self.position.x < 0 or self.position.x > mapwidth then
		self.position.x = orig.x
	end 
	if self.position.y < 0 or self.position.y > mapheight/4 then
		self.position.y = orig.y
	end

	-- 改变人物朝向
	if self.velocity.x < 0 then
		self:setFlippedX(true)
	elseif self.velocity.x > 0 then
		self:setFlippedX(false)
	end

	-- 根据人物速度切换动画（跑动还是静止）
	if self.velocity.x == 0 and self.velocity.y == 0 then
		self:runIdleAction()
	else
		self:runRunAction()
	end

	-- 设置zorder，形成正确的遮挡关系
	self:setLocalZOrder(mapheight-self.position.y)
end

-- 获得bodybox在地图上的位置
function Role:getBodyBox()
	local re = clone(self.bodybox)
	re.x = re.x + self.position.x
	re.y = re.y + self.position.y
	return re
end

function Role:getHitBox()
	local re = clone(self.hitbox)
	if self:isFlippedX() then
		re.x = self.position.x - re.x
	else
		re.x = self.position.x + re.x
	end
	
	re.y = re.y + self.position.y
	return re
end

