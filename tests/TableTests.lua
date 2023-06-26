require "tests.setup"
local tests = {name="lib.Table"}
local ignore = {}
---------------------------------------------------------------------------------------------------

function ignore.gaparray_insert()
	local t={}
	t[3]=3;print("..3  ",#t,serpent.line(t,{comment=false}))
	t:insert(4);print("..34 ",#t,serpent.line(t,{comment=false}))
	t[1]=3;print("1.34 ",#t,serpent.line(t,{comment=false}))
	t:insert(5);print("1.345",#t,serpent.line(t,{comment=false}))
end

function ignore.lengthOperator1()
	local t ={}

	t = {1,2,3,4,5};	
	print(4, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[1]=nil
	print(4, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[2]=nil
	print(4, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[5]=nil
	print(4, #t, serpent.line(t))


	t = {1,2,3,4,5};	t[1]=nil; t[5]=nil;
	print(3, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[1]=nil; t[4]=nil; t[5]=nil;
	print(3, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[1]=nil; t[5]=nil; t[4]=nil;
	print(3, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[2]=nil; t[4]=nil; t[5]=nil;
	print(3, #t, serpent.line(t))

	t = {1,2,3,4,5};	t[2]=nil; t[5]=nil; t[4]=nil;
	print(3, #t, serpent.line(t))
end

function tests.removeGaps()
	local t = {1,2,3,4,5}
	local length = #t

	local r = Table.removeGaps(t, 5)
	assert(Assert.IsReferenceEqual(r, t))
	assert(Assert.IsEqual(#r, length))

	t = {1,2,3,4,5}; length = #t
	t[4]=nil; length=length -1
	r = Table.removeGaps(t, 5)
	assert(Assert.IsReferenceEqual(r, t))
	assert(Assert.IsEqual(#r, length))

	t = {1,2,3,4,5}; length = #t
	t[1]=nil; length=length -1
	t[5]=nil; length=length -1
	r = Table.removeGaps(t, 5)
	assert(Assert.IsReferenceEqual(r, t))
	assert(Assert.IsEqual(#r, length))

	t = {1,2,3,4,5}; length = #t
	t[1]=nil; length=length -1
	t[4]=nil; length=length -1
	t[5]=nil; length=length -1
	r = Table.removeGaps(t, 5)
	assert(Assert.IsReferenceEqual(r, t))
	assert(Assert.IsEqual(#r, length))
end

function tests.table_nil_test1()
	local t = {"A","B",nil,"D"}
	assert(Assert.IsEqual(#t, 4))
	t[3]=nil	-- {"A","B",nil,"D"}
	assert(Assert.IsEqual(#t, 4))
	t[2]=nil	-- {"A",nil,nil,"D"}
	assert(Assert.IsEqual(#t, 4))
	t[4]=nil	-- {"A"}
	assert(Assert.IsEqual(#t, 1))

	t = {"A","B",nil,"D"}
	table.remove(t,3)	-- {"A","B","D"}
	assert(Assert.IsEqual(#t,3))
	assert(Assert.IsEqual(t[3],"D"))

	table.insert(t,3,nil) -- {"A","B",nil,"D"}
	assert(Assert.IsEqual(#t, 4))
	assert(Assert.IsEqual(t[4],"D"))

	table.insert(t,5,nil) -- {"A","B",nil,"D",nil} >> {"A","B",nil,"D"} no out of range error
	assert(Assert.IsEqual(#t, 4))

	table.insert(t,nil)
	assert(Assert.IsEqual(#t, 4))
end

function tests.table_bug_1_gap_array_set_value_of_last_index_to_nil()
	local t={1,2,3,4,5}
	t[2] = nil
	t[4] = nil
	assert(Assert.IsEqual(#t, 5))
	t[5] = nil -- set last index to nil
	assert(Assert.IsEqual(#t, 1)) -- but should be 5 or 3

	assert(Assert.IsEqual(pcall(function ()t:remove(4)	end), false))
end

function tests.table_create_gap()
	local t = {"A",nil,"C"}
	assert(Assert.IsEqual(#t, 3))	-- as expected {"A",nil,"C"}
	assert(Assert.IsEqual(t[3], "C"))
end
function tests.table_create_gapend()
	local t = {"A",nil,nil}
	assert(Assert.IsEqual(#t, 1))	-- but is {"A"}
end

function tests.table_set_gap()
	local t = {"A"}
	t[3]="C"						-- expect {"A",nil,"C"} 
	assert(Assert.IsEqual(#t, 1))	-- but is {"A"}
end

--[[
function tests.table_insert_gap()
	local t = {"A"}
	table.insert(t, 3, "C")			-- expect {"A",nil,"C"} 
	--                                 but is error: argument #2 to 'insert' (position out of bounds)
	-- assert(Assert.IsEqual(#t, 3))
end
--]]
--[[
function tests.table_insert_gap_len()
	local t = {"A",__len=3}			-- expect {"A",nil,nil} __len seems not to work as expected
	table.insert(t, 3, "C")			-- expect {"A",nil,"C"} 
	--                                 but is error: argument #2 to 'insert' (position out of bounds)
	-- assert(Assert.IsEqual(#t, 3))
end
--]]

function tests.size_gaparray()
	assert(Assert.IsEqual(#{"A",nil,"C"}, 3)) -- nil is counted
	assert(Assert.IsEqual(#{"A","B",nil}, 2)) -- nil is counted exept at end
	assert(Assert.IsEqual(Table.count({"A",nil,"C"}), 2))
	assert(Assert.IsEqual(Table.count({"A","B",nil}), 2))
end

function tests.size_array()
	local sample={"A","B","C"}
	assert(Assert.IsEqual(Table.count(sample), 3))
end

function tests.size_arraygaps()
	local sample={"A","B","C","D"}
	sample[2]=nil
	assert(Assert.IsNil(sample[2]))
	assert(Assert.IsEqual(Table.count(sample), 3))
end

function tests.size_dictionary()
	local sample={k1="A",k2=nil,k3="C"}
	assert(Assert.IsEqual(Table.count(sample), 2))
end

function tests.size_mix()
	local sample={}
	sample[1]="A"
    sample["key"]="B";
    table.insert(sample,"C")
	assert(Assert.IsEqual(Table.count(sample), 3))
end

function tests.contains_basic_test()
    local sample = {}
    sample[1]="A"
    sample["key"]="B";
    table.insert(sample,"C")

	-- print("pairs")
	-- for k, v in pairs(sample) do
    --     print(k..","..v)
    -- end
	-- print("ipairs")
	-- for i, v in ipairs(sample) do
    --     print(i..","..v)
    -- end

	assert(Table.count(sample)==3)
    assert(Table.contains(sample,"A"))
    assert(Table.contains(sample,"B"))
    assert(Table.contains(sample,"C"))
end

function tests.getValues_basic_test()
    local sample = {}
    sample[1]="A"
    sample["key"]="B";
    table.insert(sample,"C")
    local result = Table.getValues(sample)

    assert(Table.count(sample)==3)

    assert(Table.contains(sample,"A"))
    assert(Table.contains(sample,"B"))
    assert(Table.contains(sample,"C"))
end

--#region migrate tests -------------------------------------------------------

tests.migrateTable_DataVersion_ShouldBe_Updated = function ()
	local p = {dataVersion = 2,	newField1 = "a"	}
	local t = {dataVersion = 1, oldField1 = "old"}
	Table.migrate(t,p)
	if t["dataVersion"] ~= 2 then error("dataVersion is not 2") end
end

tests.migrateTable_ExistingFields_ShouldBe_Unchanged = function ()
	local p = {dataVersion = 2,	value = "b"	}
	local t = {dataVersion = 1, value = "a"}
	Table.migrate(t,p)
	if t["value"] ~= "a" then error("value is not 'a'") end
end

tests.migrateTable_NewFields_ShouldBe_Added = function ()
	local p = {dataVersion = 2,	newField1 = "a"	}
	local t = {dataVersion = 1, oldField1 = "old"}
	Table.migrate(t,p)
	if t["newField1"] ~= "a" then error("newField1 is not 'a'") end
end

tests.migrateTable_ForceUpdate_ShouldBe_Work = function ()
	local p = {dataVersion = 2,	value = "b", value_migrationUpdate=true}
	local t = {dataVersion = 1, value = "a"}
	Table.migrate(t,p)
	if t["value"] ~= "b" then error("value is not 'b'") end
end

tests.migrateTable_OrphanedFields_ShouldBe_Removed = function ()
	local p = {dataVersion = 2,	newField1 = "a"	}
	local t = {dataVersion = 1,	oldField1 = "old"}
	Table.migrate(t,p)
	if t["oldField1"] ~= nil then error("oldField1 is not nil") end
end
--#endregion

function tests.createPatch()
	local t1={a=1,b=2,c=3,s={a=1,b=2,c=3},sa={a=1}}
	local t2={a=1,b=3,    s={a=1,b=2,c=3},sb={a=1}}
	local r = Table.createPatch(t1,t2)
	assert(Assert.IsEqual(r.a, nil)) -- value not changed
	assert(Assert.IsEqual(r.b, 3))
	assert(Assert.IsEqual(r.c, "§DELETED"))
	assert(Assert.IsEqual(r.s, nil)) -- table not changed
	assert(Assert.IsEqual(r.sa,"§DELETED"))
	assert(Assert.IsEqual(r.sb, t2.sb))
	--print(serpent.block(r))
end

function tests.isEmpty()
	local t = {}; assert(Assert.IsTrue(Table.isEmpty(t)))
	t = {"a","b"}; 	assert(Assert.IsFalse(Table.isEmpty(t)))
	t[1]=nil; assert(Assert.IsFalse(Table.isEmpty(t)))
	t[2]=nil; assert(Assert.IsTrue(Table.isEmpty(t)))
	t={a="a"}; assert(Assert.IsFalse(Table.isEmpty(t)))
	t.a=nil; assert(Assert.IsTrue(Table.isEmpty(t)))
end

function tests.isEqual()
	local t1={};local t2={}
	assert(Assert.IsTrue(Table.isEqual(t1,t2)))
	t1={1,2,3};t2={1,2,3}; assert(Assert.IsTrue(Table.isEqual(t1,t2)))			-- array
	t1={1,2,{3,4}};t2={1,2,{3,4}}; assert(Assert.IsTrue(Table.isEqual(t1,t2)))	-- array, recursive

	t1={a=1,b=2};t2={a=1,b=2}; assert(Assert.IsTrue(Table.isEqual(t1,t2)))			-- dictionary
	t1={a=1,b={c=3}};t2={a=1,b={c=3}}; assert(Assert.IsTrue(Table.isEqual(t1,t2)))	-- dictionary, recursive
	t1={a=1,b=2};t2={b=2,a=1}; assert(Assert.IsTrue(Table.isEqual(t1,t2)))	-- dictionary, recursive, swpapped

	t1={1,2,3};t2={1,2}; assert(Assert.IsFalse(Table.isEqual(t1,t2)))
	t1={1,2,3};t2={1,2,4}; assert(Assert.IsFalse(Table.isEqual(t1,t2)))
	t1={1,2,3};t2={3,2,1}; assert(Assert.IsFalse(Table.isEqual(t1,t2)))

	-- TODO mixed {1,2,a=3}
end

function tests.diff()
	local a = {a=1,b={c=2}}
	local b = {a=1,b={c=2}}
	Table.diff(a,b)
	assert(Assert.IsTrue(Table.isEmpty(a)))
end

function tests.hasIndices()
	assert(Assert.IsTrue(Table.hasIndices({1,2,3})))
	assert(Assert.IsTrue(Table.hasIndices({k="x", 1,2,3})))

	local t={}; t[1]=1; assert(Assert.IsTrue(Table.hasIndices(t)))

	--TODO works only for continuous arrays
	--[[
	local t={1,2,3}; t[1]=nil; assert(Assert.IsTrue(Table.hasIndices(t))) --FAIL
	local t={}; t[2]=1; assert(Assert.IsTrue(Table.hasIndices(t))) -- FAIL
	local t={}; t[200]=1; assert(Assert.IsTrue(Table.hasIndices(t)))
	local t={}; t[65535]=1; assert(Assert.IsTrue(Table.hasIndices(t))) -- FAIL
	]]

	assert(Assert.IsFalse(Table.hasIndices({})))
	assert(Assert.IsFalse(Table.hasIndices({k="x"})))
end

function tests.hasKeys()
	local t={}
	t={a=1,2,3}; assert(Assert.IsTrue(Table.hasKeys(t)))
	t={1,2,a=3}; assert(Assert.IsTrue(Table.hasKeys(t)))

	t={1,2}; assert(Assert.IsFalse(Table.hasKeys(t)))
	t={}; assert(Assert.IsFalse(Table.hasKeys(t)))
end

function tests.isContinuous()
	local t={}
	t={1,2,3}; assert(Assert.IsTrue(Table.isContinuous(t)))
	t={1,2,nil}; assert(Assert.IsTrue(Table.isContinuous(t)))
	t={1,2,a=3}; assert(Assert.IsTrue(Table.isContinuous(t)))
	t={a=1,2,3}; assert(Assert.IsTrue(Table.isContinuous(t)))

	t={nil,2,3}; assert(Assert.IsFalse(Table.isContinuous(t)))
	t={1,nil,3}; assert(Assert.IsFalse(Table.isContinuous(t)))
	t={1,2,3}; t[1]=nil; assert(Assert.IsFalse(Table.isContinuous(t)))
	t={1,2,3}; t[2]=nil; assert(Assert.IsFalse(Table.isContinuous(t)))

	t={1,2,3}; t[3]=nil; assert(Assert.IsTrue(Table.isContinuous(t))) --!!
end

function tests.getMaxIndex()
	local t={}
	t[1]=1; assert(Assert.IsEqual(Table.getMaxIndex(t),1))
	t[200]=2; assert(Assert.IsEqual(Table.getMaxIndex(t),200))
	t[65535]=3; assert(Assert.IsEqual(Table.getMaxIndex(t),65535))
	t[65535]=nil;assert(Assert.IsEqual(Table.getMaxIndex(t),200))
	t[500]=3; assert(Assert.IsEqual(Table.getMaxIndex(t),500))
end

function tests.lengthOperator()
	local t ={}
	t={1,2,3}; assert(Assert.IsEqual(#t,3))
	t={1,2,nil}; assert(Assert.IsEqual(#t,2)) -- !!
	t={1,nil,3}; assert(Assert.IsEqual(#t,3))
	t={nil,2,3}; assert(Assert.IsEqual(#t,3))

	t={1,2,3};t[3]=nil; assert(Assert.IsEqual(#t,2)) --!!
	t={1,2,3};t[2]=nil; assert(Assert.IsEqual(#t,3))
	t={1,2,3};t[1]=nil; assert(Assert.IsEqual(#t,3))

	t={}; t[1]=1; assert(Assert.IsEqual(#t,1))
	t={}; t[2]=1; assert(Assert.IsEqual(#t,0)) -- !!
	t={}; t[200]=1; assert(Assert.IsEqual(#t,0))-- !!
	t={}; t[65535]=1; assert(Assert.IsEqual(#t,0))-- !!

	t={nil,2,3}; t[4]=4; assert(Assert.IsEqual(#t,4))
	t={nil,2,3}; t[5]=5; assert(Assert.IsEqual(#t,0)) --!!
end

function tests.manipulatingArray1()
	local a = {1,2,3,4,5,6}
	for i, v in ipairs(a) do
		if(i==2 or i==4) then table.remove(a,i) end
	end
	assert(Assert.IsEqual(a,{1,3,4,6}))--!!
end

function tests.manipulatingArray()
	local a = {1,2,3};local s=""

	a[1]=nil
	table.remove(a,1)
	s=""; for _, v in ipairs(a) do s=s..v end
	assert(Assert.IsEqual(s,"23"))

	table.insert(a,4)
	s=""; for _, v in ipairs(a) do s=s..tostring(v) end
	assert(Assert.IsEqual(s,"234"))
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)