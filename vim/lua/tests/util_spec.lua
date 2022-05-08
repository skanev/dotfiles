local u = require('mine.util')

describe("Utils", function()
  it("provides means to filter an array", function()
    assert.are.same(
      { 'bar', 'baz' },
      u.filter({ 'foo', 'bar', 'baz' }, function(i) return i:find('a') end)
    )
  end)

  it("provides means to map an array", function()
    assert.are.same(
      { 'foo!', 'bar!', 'baz!' },
      u.map({ 'foo', 'bar', 'baz' }, function(i) return i .. '!' end)
    )
  end)
end)
