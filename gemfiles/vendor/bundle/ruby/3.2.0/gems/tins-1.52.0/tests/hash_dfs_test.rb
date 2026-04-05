require 'test_helper'
require 'tins/xt/hash_dfs'

module Tins
  class HashDFSTest < Test::Unit::TestCase
    def setup
      @hash = { a: 'foo', b: [ { c: 'baz' }, { d: 'quux' }, [ 'blub' ] ] }
    end

    def test_without_nodes
      results = []
      @hash.dfs { |*a| results.push(a) }
      assert_equal [[0, 'blub'], [:d, 'quux'], [:c, 'baz'], [:a, 'foo']], results
    end

    def test_with_nodes
      results = []
      @hash.dfs(visit_internal: true) { |*a| results.push(a) }
      expected = [
        [nil, { a: 'foo', b: [{ c: 'baz' }, { d: 'quux' }, ['blub']] }],
        [:b, [{ c: 'baz' }, { d: 'quux' }, ['blub']]],
        [2, ['blub']],
        [0, 'blub'],
        [1, { d: 'quux' }],
        [:d, 'quux'],
        [0, { c: 'baz' }],
        [:c, 'baz'],
        [:a, 'foo']
      ]
      assert_equal expected, results
      assert_equal 9, results.size
    end

    def test_with_nodes_with_circle
      results = []
      @hash[:b].last << @hash
      @hash.dfs(visit_internal: true) { |*a| results.push(a) }
      assert_equal 9, results.size
    end
  end
end
