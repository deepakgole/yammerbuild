require 'rubygems'
require 'rake'
require 'echoe'
require 'lib/yammer_build'

Echoe.new('yammerbuild', '0.0.1') do |p|
  p.description    = "A gem which yammers builds on a network"
  p.url            = "http://github.com/tombombadil/hello_world"
  p.author         = "Deepak Gole"
  p.email          = "gole.deepak@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

namespace :yammer do

desc 'This task send a email to yammer'
  task :send_email do
    YammerBuild::Notifier.send_email
  end

end
