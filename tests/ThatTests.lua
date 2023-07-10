require "tests.setup"
local tests = {name = "lib.That"}
-----------------------------------

function tests.ThatEquals()
    assert(That.IsEqual(3,3)==true)
    assert(That.IsEqual(3,4)==false)
end

function tests.ThatNotEquals()
    assert(That.IsNotEqual(3,3)==false)
    assert(That.IsNotEqual(3,4)==true)
end

function tests.ThatIsTrue()
    assert(That.IsTrue(true)==true)
    assert(That.IsTrue(false)==false)
    assert(That.IsTrue(nil)==false)
    assert(That.IsTrue(1)==false)
    assert(That.IsTrue("a")==false)
    assert(That.IsTrue("true")==false)
end

function tests.ThatIsFalse()
    assert(That.IsFalse(false)==true)
    assert(That.IsFalse(true)==false)
    assert(That.IsFalse(nil)==false)
    assert(That.IsFalse(1)==false)
    assert(That.IsFalse("a")==false)
    assert(That.IsFalse("false")==false)
end

function tests.ThatIsNil()
    assert(That.IsNil(nil)==true)
    assert(That.IsNil(false)==false)
    assert(That.IsNil(0)==false)
    assert(That.IsNil("")==false)
    assert(That.IsNil("nil")==false)
end

function tests.ThatIsNotNil()
    assert(That.IsNotNil(nil)==false)
    assert(That.IsNotNil(true)==true)
    assert(That.IsNotNil(false)==true)
    assert(That.IsNotNil(0)==true)
    assert(That.IsNotNil("")==true)
    assert(That.IsNotNil("nil")==true)
    assert(That.IsNotNil("true")==true)
end

function tests.ThatIsTypeOf()
    assert(That.IsTypeOf(nil,"nil")==true)
    assert(That.IsTypeOf(3,"number")==true)
    assert(That.IsTypeOf("3","string")==true)
    assert(That.IsTypeOf(true,"boolean")==true)
    assert(That.IsTypeOf({},"table")==true)

    local r,s = That.IsTypeOf(3,"nil")
    assert(That.IsFalse(r))
    assert(That.IsTypeOf(s,"string"))
end


-- https://docs.nunit.org/articles/nunit/writing-tests/constraints/Constraints.html
local Is = That.Is

function tests.Constraint_True()
	assert(That(true,Is.True))
	-- assert(That(false,Is.Not.True))
end
function tests.Constraint_False()
	assert(That(false,Is.False))
	-- assert(That(true,Is.Not.False))
end
function tests.Constraint_Nil()
	assert(That(nil,Is.Nil))
	assert(That("foo",Is.Not.Nil))
end
function tests.Constraint_And()
	assert(That(true, Is.True.And.True))
	assert(That(false,Is.False.And.True))
	assert(That(false,Is.True.And.False))
	assert(That(false,Is.False.And.False))
end
function tests.Constraint_Or()
	assert(That(true,Is.True.Or.True))
	assert(That(true,Is.False.Or.True))
	assert(That(true,Is.True.Or.False))
	assert(That(false,Is.False.Or.False))
end

function tests.Constraint_Equal()
	assert(That("foo",Is.Equal("foo")))
	assert(That("foo",Is.EqualTo("foo")))
end

function tests.Constraint_String_StartsWith()
	assert(That("foo",Is.String.StartsWith("f"))) -- Is.StartsWith ??
	-- assert(That("foo",StartsWith("f"))) -- StartsWith top level constraint
end

function tests.Constraint_String_EndsWith()
	assert(That("bar",Is.String.EndsWith("r"))) -- Is.EndsWith ??
	-- assert(That("bar",EndsWith("r"))) -- EndsWith top level constraint
end

function tests.Constraint_Empty()
	assert(That("",Is.Empty))
	assert(That("foo",Is.Not.Empty))
	assert(That({},Is.Empty))
	assert(That({"1"},Is.Not.Empty))
	assert(That({a="a"},Is.Not.Empty))
	-- tests that an object is an empty string, directory or collection.
end

function tests.Constraint_Contains()
	--tests for a substring.
	-- assert(That("foo",String.Contains("o")))
	-- assert(That("foo",Does.Contain("o")))
	-- assert(That("bar",Does.Not.Contain("o")))
end

function tests.Constraint_LessThan()
	assert(That(0,Is.LessThan(1)))
	assert(That(-1,Is.Negative))
end

function tests.Constraint_GreaterThan()
	assert(That(1,Is.GreaterThan(0)))
	assert(That(1,Is.Positive))
end

--[[
AllItems
	And
AnyOf
AssignableFrom
AssignableTo
Attribute
AttributeExists
- BinarySerializable
CollectionContains
CollectionEquivalent
CollectionOrdered
CollectionSubset
CollectionSuperset
Delayed
DictionaryContainsKey
DictionaryContainsKeyValuePair
DictionaryContainsValue
EmptyCollection
	Empty
EmptyDirectory
EmptyString
	EndsWith
Equal
ExactCount
ExactType
	False
FileOrDirectoryExists
GreaterThan
GreaterThanOrEqual
InstanceOfType
LessThan
LessThanOrEqual
NaN
NoItem
	Not
	Null
	Or
Property
PropertyExists
Range
Regex
Reusable
SameAs
SamePath
SamePathOrUnder
SomeItems
StartsWith
SubPath
Substring
Throws
ThrowsNothing
	True
UniqueItems
XmlSerializable	
]]

TestRunner.run(tests)