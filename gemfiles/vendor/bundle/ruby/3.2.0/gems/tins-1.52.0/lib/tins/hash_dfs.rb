module Tins
  # HashDFS for a depth‑first traversal for Ruby hash and array structures.
  #
  # Provides methods to traverse hash structures in a depth-first manner,
  # visiting all keys and values.
  module HashDFS
    extend Tins::ThreadLocal

    # Thread‑local flag used to remember which objects have already been
    # visited during the current DFS run.  It is cleared in the `ensure`
    # block to avoid leaking state between traversals.
    thread_local :dfs_seen

    # Performs a depth‑first search on the receiver’s structure.
    #
    # @param visit_internal [Boolean] whether to yield internal hashes/arrays.
    #   When `false` (default) the block is called only for leaf values.
    #   When `true`, the block is called for every node, including the
    #   intermediate hashes/arrays that contain other objects.
    # @yield [index, object] yields the index/key (or array index) and the
    #   object being visited.
    # @yieldparam index [Object, Integer, nil] the key or array index, or
    #   `nil` for the root object.
    # @yieldparam object [Object] the current object (Hash, Array, or leaf).
    # @raise [ArgumentError] if no block is given.
    # @return [self] returns the receiver for chaining.
    #
    # @example Basic usage
    #   { a: 1, b: [2, 3] }.dfs do |idx, val|
    #     puts "#{idx.inspect} => #{val.inspect}"
    #   end
    def dfs(visit_internal: false, &block)
      block or raise ArgumentError, 'require &block argument'
      self.dfs_seen = {}
      stack = []
      stack.push([nil, self])

      while (index, object = stack.pop)
        case
        when dfs_seen[object.__id__]
          next
        when Hash === object
          dfs_seen[object.__id__] = true
          object.each do |k, v|
            stack.push([k, dfs_convert_to_hash_or_ary(v)])
          end
          visit_internal or next
        when Array === object
          dfs_seen[object.__id__] = true
          object.each_with_index do |v, i|
            stack.push([i, dfs_convert_to_hash_or_ary(v)])
          end
          visit_internal or next
        end
        block.(index, object)
      end
      self
    ensure
      self.dfs_seen = nil
    end

    # Converts the given object into a hash or array if possible.
    #
    # @param object [Object] the object to convert.
    # @return [Hash, Array, Object] the converted object or the original
    #   object if no conversion method is available.
    #
    # @example
    #   dfs_convert_to_hash_or_ary(Struct.new(:a).new(1)) # => { a: 1 }
    def dfs_convert_to_hash_or_ary(object)
      case
      when object.respond_to?(:to_hash)
        object.to_hash
      when object.respond_to?(:to_ary)
        object.to_ary
      else
        object
      end
    end
  end
end
