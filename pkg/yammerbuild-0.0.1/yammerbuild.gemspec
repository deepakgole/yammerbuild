# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yammerbuild}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Deepak Gole"]
  s.date = %q{2010-07-09}
  s.description = %q{A gem which yammers builds on a network}
  s.email = %q{gole.deepak@gmail.com}
  s.extra_rdoc_files = ["lib/yammer_build.rb"]
  s.files = ["Rakefile", "lib/yammer_build.rb", "Manifest", "yammerbuild.gemspec"]
  s.homepage = %q{http://github.com/tombombadil/hello_world}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Yammerbuild"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{yammerbuild}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A gem which yammers builds on a network}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
