require "lib.TestRunner"
require "lib.Assert"

local tests = {name = "lib.Assert"}

function tests.AssertEquals()
    assert(Assert.IsEqual(3,3)==true)
    assert(Assert.IsEqual(3,4)==false)
end

function tests.AssertNotEquals()
    assert(Assert.IsNotEqual(3,3)==false)
    assert(Assert.IsNotEqual(3,4)==true)
end

function tests.AssertIsTrue()
    assert(Assert.IsTrue(true)==true)
    assert(Assert.IsTrue(false)==false)
    assert(Assert.IsTrue(nil)==false)
    assert(Assert.IsTrue(1)==false)
    assert(Assert.IsTrue("a")==false)
    assert(Assert.IsTrue("true")==false)
end

function tests.AssertIsFalse()
    assert(Assert.IsFalse(false)==true)
    assert(Assert.IsFalse(true)==false)
    assert(Assert.IsFalse(nil)==false)
    assert(Assert.IsFalse(1)==false)
    assert(Assert.IsFalse("a")==false)
    assert(Assert.IsFalse("false")==false)
end

function tests.AssertIsNil()
    assert(Assert.IsNil(nil)==true)
    assert(Assert.IsNil(false)==false)
    assert(Assert.IsNil(0)==false)
    assert(Assert.IsNil("")==false)
    assert(Assert.IsNil("nil")==false)
end

function tests.AssertIsNotNil()
    assert(Assert.IsNotNil(nil)==false)
    assert(Assert.IsNotNil(true)==true)
    assert(Assert.IsNotNil(false)==true)
    assert(Assert.IsNotNil(0)==true)
    assert(Assert.IsNotNil("")==true)
    assert(Assert.IsNotNil("nil")==true)
    assert(Assert.IsNotNil("true")==true)
end

function tests.AssertIsTypeOf()
    assert(Assert.IsTypeOf(nil,"nil")==true)
    assert(Assert.IsTypeOf(3,"number")==true)
    assert(Assert.IsTypeOf("3","string")==true)
    assert(Assert.IsTypeOf(true,"boolean")==true)
    assert(Assert.IsTypeOf({},"table")==true)

    local r,s = Assert.IsTypeOf(3,"nil")
    assert(Assert.IsFalse(r))
    assert(Assert.IsTypeOf(s,"string"))
end

TestRunner.run(tests)