require 'strokedb'
include StrokeDB

require 'benchmark'
include Benchmark 

$storage = FileChunkStorage.new "test/storages/rw_bench_storage"
store = SkiplistStore.new($storage, 4)

def test_storage(bm, n, title, &block)
  $storage.clear!
  bm.report(title) do
    n.times &block
  end
end

N = 128
bm(28) do |x| 
  test_storage x, N, "Write                       " do |i|
    d = store.new_doc :index => i
    d.save!
  end
  
  # init and enable the cache
  $storage.chunks_cache = {}
  
  test_storage x, N, "Write (FileChunkStore cache)" do |i|
    d = store.new_doc :index => i
    d.save!
  end
end
