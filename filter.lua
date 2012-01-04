module(..., package.seeall)

-- local Err = require 'lib.error'
local Form = require 'bamboo.form'



-- 检查是否登录
function checkLogined(extra, params)
	DEBUG('check if user have logined')
	if not extra then extra = {} end
	local method, location = unpack(extra)

	method = method or 'json'
	location = location or '/'
	
	if not req.user then
		if method then
			if method == 'page' then
				web:redirect(location)
			end
			if method == 'json' then
				-- Err.error(107)
			end
		end
		return false
	end
	
	return true, params
end

--检查参数(或关系)
function checkParamsOr(extra, p)
	DEBUG('checking params')
	local params = Form:parse(req)
	local query = Form:parseQuery(req)

	p = p or {}

	for k, v in pairs(params) do
		p[k] = v
	end

	for k, v in pairs(query) do
		p[k] = v
	end

	if not isFalse(extra) then
		for _, v in ipairs(extra) do
			if params[v] and params[v]~=''then
				return true, p
			end
			if query[v] and query[v] ~= '' then
				return true, p
			end
		end
	end

	return Err.error(101)
end

-- 检查参数(与关系)
function checkParams(extra, p)
	DEBUG('checking params')
	local params = Form:parse(req)
	local query = Form:parseQuery(req)

	ptable(params)
	ptable(query)

	p = p or {}
	if not isFalse(extra) then
		for _, v in ipairs(extra) do
			if not params[v] or params[v] == '' then 
				if not query[v] or query[v] == '' then
					return Err.error(101)
				end
			end
		end
	end

	for k, v in pairs(params) do
		p[k] = v
	end

	for k, v in pairs(query) do
		p[k] = v
	end
	
	ptable(p)

	return true, p
end

-- 获取模型实例
-- 使用方法 getinstance: Quanuser user_id 使用user_id获取Quanuser实例，一般情况下可以在外面套一个函数来针对特定模型做相应处理
function getInstance(extra, params)
	-- 如果没有参数
	if isFalse(extra) or #extra < 2 then return false end
	if isFalse(params) then return false end
	
	local model_name, field = unpack(extra)

	if isFalse(params[field]) or type(tonumber(params[field])) ~= 'number' then return false end
	
	-- 获取模型
	local instance_model = bamboo.getModelByName(model_name)

	-- 获取实例
	local obj
	if instance_model then
		obj = instance_model:getById(params[field])
	end

	if not obj then
		return false
	end

	params[field] = nil
	params[model_name] = obj

	return true, params
end

-- -- 获取生活实例
-- function checkLifeAvailable(extra, params)
-- 	print('checking if life is available')
-- 	local ret, p =  getInstance({'Quanlife', 'life_id'}, params)
-- 	if not ret then return Err.error(120) end
-- 	return true, p
-- end

-- -- 获取用户实例
-- function checkUserAvailable(extra, params)
-- 	print('checking if user is available')
-- 	local ret, p =  getInstance({'Quanuser', 'user_id'}, params)
-- 	if not ret then return Err.error(102) end
-- 	p.user = p.Quanuser
-- 	p.Quanuser = nil
-- 	return true, p
-- end

-- -- 获取群组实例
-- function checkGroupAvailable(extra, params)
-- 	print('checking if group is available')
-- 	local ret, p =  getInstance({'Quangroup', 'group_id'}, params)
-- 	if not ret then return Err.error(110) end
-- 	p.Quangroup:update('timestamp', tostring(os.time()))
-- 	p.group = p.Quangroup
-- 	p.Quangroup = nil
-- 	return true, p
-- end

-- post filters

bamboo.registerFilters
{
	{'login', checkLogined}
}
