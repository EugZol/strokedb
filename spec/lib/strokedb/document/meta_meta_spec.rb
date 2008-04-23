require File.dirname(__FILE__) + '/spec_helper'

describe "Meta meta" do
  before(:each) do
    setup_default_store
    # @mem_storage = StrokeDB::MemoryStorage.new
    # StrokeDB.stub!(:default_store).and_return(StrokeDB::Store.new(:storage => @mem_storage))
  end

  it "should have nsurl http://strokedb.com/" do
    Meta.document.nsurl.should == STROKEDB_NSURL
  end
  
  it "should have blank default nsurl by default" do
    Meta.default_nsurl.should be_blank
  end

  it "should be able to configure new default nsurl" do
    Meta.default_nsurl = "http://mycoolapp.com"
    Meta.default_nsurl.should == "http://mycoolapp.com"
    Meta.default_nsurl = ""
  end

end

describe "Meta meta instantiation" do

  before(:each) do
    # @store = mock("store")
    # StrokeDB.stub!(:default_store).and_return(@store)
    setup_default_store
    Object.send!(:remove_const,'SomeName') if defined?(SomeName)
    @meta = Meta.new(:name => "SomeName")
  end

  it "should create new meta module and bind it to name passed" do
    @meta.should be_a_kind_of(Meta)
    SomeName.should == @meta
  end

end

describe "Meta meta instantiation with block specified" do
  
  before(:each) do
    # @mem_storage = StrokeDB::MemoryStorage.new
    # StrokeDB.stub!(:default_store).and_return(StrokeDB::Store.new(:storage => @mem_storage))
    Object.send!(:remove_const,'SomeName') if defined?(SomeName)
    setup_default_store
    @meta = Meta.new(:name => "SomeName") { def result_of_evaluation ; end  } 
  end
  
  it "should evalutate block" do
    @meta.new.should respond_to(:result_of_evaluation)
  end
  
end