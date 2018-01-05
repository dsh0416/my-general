require './lib/my_general/version'

task :default => :spec
task :install => :build

task :build do
  puts `gem build my_general.gemspec`
end

task :install do
  puts `gem install ./my_general-#{MyGeneral::VERSION}.gem`
end
