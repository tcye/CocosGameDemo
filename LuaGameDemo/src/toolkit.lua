
-- 工具包，封装了一些常用函数，方便调用
tk = tk or {}

-- 类似C++11的bind，用于把类函数绑定为回调函数
function tk.bind(func, this, ...)
	return function (...)
		return func(this, ...)
	end
end

-- 场景管理相关
function tk.getRunningScene()
	return cc.Director:getInstance():getRunningScene()
end

function tk.runWithScene(...)
	cc.Director:getInstance():runWithScene(...)
end

-- 加载Sprite sheet
function tk.addSpriteFrames(...)
	cc.SpriteFrameCache:getInstance():addSpriteFrames(...)
end

function tk.getSpriteFrame(...)
	return cc.SpriteFrameCache:getInstance():getSpriteFrame(...)
end

-- 方便以固定名称模式，从一系列图像中创建animation
function tk.newAnimation(formatStr, ibegin, iend, time)
	local frames = {}
	for i = ibegin, iend do
		local imgName = string.format(formatStr, i)
		local frame = tk.getSpriteFrame(imgName)
		frames[#frames+1] = frame
	end
	return cc.Animation:createWithSpriteFrames(frames, time)
end

-- 缓存animation，提高效率，比如创建enemy的时候，就不用每个enemy都创建一次
local _animation_cache = { }
function tk.addAnimationCache(name, animation)
	if _animation_cache[name] then
		tk.removeAnimationCache(name)
	end
	_animation_cache[name] = animation
	animation:retain()
end

function tk.removeAnimationCache(name)
	_animation_cache[name]:release()
	_animation_cache[name] = nil
end

function tk.getAnimation(name)
	return _animation_cache[name]
end

-- 定时器
function tk.schedule(func, interval, once)
	once = once or false
	local scheduler = cc.Director:getInstance():getScheduler()
	scheduler:scheduleScriptFunc(func, interval, once)
	--scheduler:unscheduleAllForTarget(func, interval, once)
end
