require "tests.setup"
local tests = {name="lib/List"}
local ignore = {}
---------------------------------------------------------------------------------------------------

function tests.set_get()
	local list = List:new()
	list[1]=1
	assert(Assert.IsEqual(list[1], 1))
	assert(Assert.IsEqual(list.length, 1))
	assert(Assert.IsEqual(#list, 1))
end

function tests.__pairs()
	local data={1,2,3}
	local list = List:new(data)
	local c=0
	for k,v in list do
		c=c+1
		assert(Assert.IsEqual(v,data[k]))
	end
	assert(Assert.IsEqual(c,3))

end

function tests.ipairs()
	local data={1,2,3}
	local list = List:new(data)

	local c = 0
	for k,v in ipairs(list) do
		c=c+1
		assert(Assert.IsEqual(v,data[k]))
	end
	assert(Assert.IsEqual(c,3))

	data = {1,nil,3}; c = 0
	list = List:new(); list[1]=1; list[3]=3
	for k,v in ipairs(list) do
		c=c+1
		assert(Assert.IsEqual(v,data[k]))
	end
	assert(Assert.IsEqual(c,3))
end

function tests.set_nil()
	local data={1,2,3}
	local list = List:new(data)
	list[3]=nil
	assert(Assert.IsEqual(#list, 3))

	list = List:new(data)
	list[1]=nil
	list[3]=nil
	assert(Assert.IsEqual(#list, 3))
end

function tests.indexOf()
	local data={1,2,3}
	local list = List:new(data)

	assert(Assert.IsEqual(list:indexOf(2), 2))
end

function tests.add()
	local data={}
	local list = List:new(data)
	list:add(1)
	assert(Assert.IsEqual(list[1],1))
	assert(Assert.IsEqual(#list,1))

	list[10]=10
	list:add(11)
	assert(Assert.IsEqual(list[11],11))
	assert(Assert.IsEqual(#list,11))
end

function tests.removeAt()
	local data={1,2,3}
	local list = List:new(data)
	list:removeAt(2)
	assert(Assert.IsEqual(list[2],3))
	assert(Assert.IsEqual(#list,2))

	data={nil,2,3}
	list = List:new(data)
	list:removeAt(2)
	assert(Assert.IsEqual(list[2],3))
	assert(Assert.IsEqual(#list,2))

	data={1,nil,3}
	list = List:new(data)
	list:removeAt(2)
	assert(Assert.IsEqual(list[2],3))
	assert(Assert.IsEqual(#list,2))
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)