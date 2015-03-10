
GameScene = class("GameScene", function () return cc.Scene:create() end)

-- 初始化场景，包括加载资源、添加地图已经英雄、敌人等精灵元素
function GameScene:ctor()
	-- 加载sprite sheet 和 animation
	self:loadRes()

	-- 加入地图
	self.map = Map.new("mymap.tmx")
	self:addChild(self.map)


	-- 以点为单位计算地图大小，方便更新精灵位置时候计算
	local mapsize = self.map:getMapSize()
	local tilesize = self.map:getTileSize()
	self.mapwidth = mapsize.width*tilesize.width
	self.mapheight = mapsize.height*tilesize.height


	-- 加入英雄
	self.hero = Hero.new()
	self:addChild(self.hero)
	self.hero.position = cc.p(100, 40)

	-- 加入10个小怪
	self.enemies = {}
	for i = 1, 10 do
		local e = Enemy.new()
		e.position.x = math.random(100, self.mapwidth)
		e.position.y = math.random(0, self.mapheight / 5)
		self.enemies[i] = e
		self:addChild(e)
	end

	-- 在地图最后添加一个大Boss
	local boss = Boss.new()
	boss.position = cc.p(self.mapwidth - 100, 40)
	self:addChild(boss)
	self.enemies[#self.enemies+1] = boss


	-- 英雄血条
	local hpbar = HpBar.new()
	hpbar:setAnchorPoint(cc.p(0,1))
	hpbar:setPosition(0, self.mapheight)
	self.hpbar = hpbar
	self:addChild(hpbar)
		
	-- 每帧根据精灵在地图上的位置，更新他们在屏幕上的位置
	self:scheduleUpdateWithPriorityLua(function() self:updatePositionOnScreen() end, 100)
end

-- 根据英雄在地图上位置更新所有精灵的位置，实现地图的智能滚动
-- 同时根据英雄的血量，更新血条
function GameScene:updatePositionOnScreen()

	herox = cfg.game.width/2.0
	mapx = herox - self.hero.position.x

	-- 为地图确定合适的坐标
	if mapx > 0 then
		mapx = 0
	elseif mapx < cfg.game.width-self.mapwidth then
		mapx = cfg.game.width-self.mapwidth
	end

	-- 重新确定英雄在屏幕上的位置
	herox = mapx + self.hero.position.x

	-- 更行地图和英雄的坐标
	self.hero:setPosition(cc.p(herox, self.hero.position.y))
	self.map:setPosition(cc.p(mapx, 0))

	-- 更新所有敌人的坐标
	for i, e in ipairs(self.enemies) do
		local ex = mapx + e.position.x
		e:setPosition(cc.p(ex, e.position.y))
	end

	-- 更新血条
	self.hpbar:setPercentage(self.hero.life / cfg.role.hero.life * 100)
end


-- 从Config中读取设置，加载资源和动作
function GameScene:loadRes()

	for role, rv in pairs(cfg.role) do
		tk.addSpriteFrames(rv.plist, rv.img)
		for actionname, av in pairs(rv.animation) do
			local animation = tk.newAnimation(unpack(av))
			tk.addAnimationCache(role .. "." .. actionname, animation)
		end
	end

end
