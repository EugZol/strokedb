require File.dirname(__FILE__) + '/spec_helper'

describe View, "without a name" do

  before(:each) do
    setup_default_store
  end
  
  it "could not be initialized" do
    lambda do 
      @post_comments = View.define!
    end.should raise_error(ArgumentError)
  end
  
end

describe View, "without #map method defined" do
  before(:each) do
    setup_default_store
  end
  
  it "should raise exception when view is created" do
    lambda { 
       View.define!(:name => "post_comments_invalid")
    }.should raise_error(InvalidViewError)
  end
  
  it "should raise exception when #map is used" do
    pending "TODO: option :only for a viewdoc"
    Comment = Meta.new
    @post_comments = View.define!(:name => "post_comments_invalid", :only => ["comment"])
    c = Comment.new :text => "hello"
    lambda { @post_comments.map(c.uuid, c) }.should raise_error(InvalidViewError)
  end
  
end

describe "'Has many comments' view" do
  
  before(:all) do
    setup_default_store
    @view = View.define!("post_comments") do |view|
      def view.map(uuid, doc)
        doc['type'] =~ /comment/ ? [[[doc.parent, doc.created_at], doc]] : nil
      end
    end
    
    @article1 = Document.create! :type => "post"
    @article2 = Document.create! :type => "post"
    @article3 = Document.create! :type => "post"
    
    @comment11 = Document.create! :type => "comment11", :parent => @article1, :created_at => Time.now
    @comment12 = Document.create! :type => "comment12", :parent => @article1, :created_at => Time.now
    @comment13 = Document.create! :type => "comment13", :parent => @article1, :created_at => Time.now
    
    @comment21 = Document.create! :type => "comment21", :parent => @article2, :created_at => Time.now
    @comment22 = Document.create! :type => "comment22", :parent => @article2, :created_at => Time.now
  end
  
  it "should find all the comments sorted by date" do
    results = @view.find
    # since article UUID can be anything 
   (results == [@comment11, @comment12, @comment13,    @comment21, @comment22] || 
    results == [@comment21, @comment22,    @comment11, @comment12, @comment13]).should == true
  end
  
  it "should find all the article's comments" do
    @view.find(:key => @article1).should == [@comment11, @comment12, @comment13]
    @view.find(:key => @article2).should == [@comment21, @comment22]
    @view.find(:key => @article3).should == [ ]
  end

  it "should find all the article's comments in a reverse order" do
    @view.find(:key => @article1, :reverse => true).should == [@comment13, @comment12, @comment11]
    @view.find(:key => @article2, :reverse => true).should == [@comment22, @comment21]
    @view.find(:key => @article3, :reverse => true).should == [ ]
  end
  
  it "should find all the article's comments with limit" do
    @view.find(:key => @article1, :limit => 2).should == [@comment11, @comment12]
    @view.find(:key => @article2, :limit => 2).should == [@comment21, @comment22]
    @view.find(:key => @article3, :limit => 2).should == [ ]
  end

  it "should find all the article's comments with offset and limit" do
    @view.find(:key => @article1, :offset => 1, :limit => 2).should == [@comment12, @comment13]
    @view.find(:key => @article2, :offset => 1, :limit => 2).should == [@comment22]
    @view.find(:key => @article3, :offset => 1, :limit => 2).should == [ ]
  end
  
end

describe View, "with block defined and saved" do
  
  before(:each) do
    setup_default_store
    @view = View.define!("SomeView") do |view|
      def view.map(uuid, doc)
        [[doc,doc]]
      end
    end
  end
  
  it "should re-establish block when reloaded" do
    @view = @view.reload
    lambda { @view.map(1,2).should == [[1,2]]}.should_not raise_error(InvalidViewError)
  end
  
  it "should have the same storage when reloaded" do
    storage_id = @view.send(:storage).object_id
    @view = @view.reload
    @view.send(:storage).object_id.should == storage_id
  end
  
  it "should be findable with #[] syntax" do
    View["SomeView"].should == @view
  end
  
end


describe View, "with nsurl and block defined and saved" do
  
  before(:each) do
    setup_default_store
    @view = View.define!("SomeView", :nsurl => "http://strokedb.com/") do |view|
      def view.map(uuid, doc)
        [[doc,doc]]
      end
    end
  end
  it "should be findable with #[] syntax" do
    View["SomeView", "http://strokedb.com/"].should == @view
  end
  
end

