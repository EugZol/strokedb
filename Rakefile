require 'rake'; require 'rubygems'

$:.unshift(File.dirname(__FILE__) + '/lib')
require 'strokedb'; require 'core_ext'

require 'task/echoe'
Echoe.taskify do
  Dir['task/**/*.task'].each {|t| load t}
  
  namespace :echoe do
    Echoe.new('StrokeDB', StrokeDB::VERSION) do |g|
      g.author         = ['Yurii Rashkovskii', 'Oleg Andreev']
      g.email          = ['strokedb@googlegroups.com']
      g.summary        = 'embeddable, distributed, document-based database'
      g.url            = 'http://strokedb.com'
      g.description    = <<-EOF
  StrokeDB is an embeddable, distributed, document-based database written in Ruby.
  It is schema-free (allowing you to define any attribute on any object at any
  time), it scales infinitely, it even allows free versioning and integrates
  perfectly with Ruby applications.
  EOF
    
      g.platform       = Gem::Platform::RUBY
      g.dependencies   = ['diff-lcs >= 1.1.2', 'uuidtools >= 1.0.3', 'json >= 1.1.2']
    
      g.manifest_name  = 'MANIFEST'
      g.ignore_pattern = /(^\.git|^.DS_Store$|^meta|^test\/storages|^examples\/(.*).strokedb|^bugs)/
      g.executable_pattern = 'bin/stroke'
    end
    
    desc 'tests packaged files to ensure they are all present'
    task :verify => :package do
      # An error message will be displayed if files are missing
      if system %(ruby -e "require 'rubygems'; require 'pkg/strokedb-#{StrokeDB::VERSION}/strokedb'")
        puts "\nThe library files are present"
      end
    end
    
    desc 'Clean tree, update manifest, and install gem'
    task :magic => [:clean, :manifest, :install]
  end
  
  # Developers: Run this before commiting!
  desc 'Check everything over before commiting!'
  task :aok => [:'rcov:verbose', :'rcov:verify_verbose', :'rcov:open',
                :'rdoc:html', :'rdoc:open',
                :'ditz:stage', :'ditz:html', :'ditz:todo', :'ditz:status', :'ditz:html:open']
end

# desc 'Run by CruiseControl.rb during continuous integration'
task :cruise => [:'rcov:run', :'rcov:verify', :'ditz:html', :'rdoc:html']

# By default, we just list the tasks.
task :default => :list
task :list do
  system 'rake -T'
end