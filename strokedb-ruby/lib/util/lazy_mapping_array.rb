module StrokeDB
  # Lazy loads items from array applying procs on each read and write.
  #
  # Example:
  #
  # @ary[i] = 10
  #
  # applies "unmap proc" to new item value.
  #
  # @ary.at(i)
  #
  # applies "map proc" to value just have been read.
  #
  # StrokeDB uses this class to "follow" links to other documents
  # found in slots in a lazy manner.
  #
  # player:
  #   model: [@#8b195509-f9c4-4fea-90c9-425b38bdda3e.ea5eda78-d410-44be-8b14-f4e33f6fa047]
  #   generation: 4
  #
  # when model collection item is fetched, reference followed and turned into document
  # instance with mapping proc of lazy mapping array.
  class LazyMappingArray < BlankSlate(Array)
    def initialize(*args)
      @map_proc = proc {|v| v}
      @unmap_proc = proc {|v| v}
      super(*args)
    end

    def map_with(&block)
      @map_proc = block
      self
    end

    def unmap_with(&block)
      @unmap_proc = block
      self
    end

    def class
      Array
    end

    def method_missing sym, *args, &blk
      super if sym.to_s =~ /^__/
      mname = "__#{::BlankSlate::MethodMapping[sym.to_s] || sym}"

      case sym
      when :push, :unshift, :<<, :[]=, :index, :-
        last = args.pop
        last = last.is_a?(Array) ? last.map{|v| @unmap_proc.call(v) } : @unmap_proc.call(last)
        args.push last

        __send__(mname, *args, &blk)

      when :[], :slice, :at, :map, :shift, :pop, :include?, :last, :first, :zip, :each, :inject, :each_with_index
        __map{|v| @map_proc.call(v) }.__send__(sym, *args, &blk)

      else
        __send__(mname, *args, &blk)
      end
    end
  end
end
