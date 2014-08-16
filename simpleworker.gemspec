# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simpleworker/version"

Gem::Specification.new do |s|
  s.name        = "simpleworker"
  s.version     = SimpleWorker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Gowan"]
  s.email       = ["gowanjason@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Distribute ruby scripts on multiple machines}
  s.description = %q{Distribute ruby scripts on multiple machines for automated testing.}

  s.rubyforge_project = "simpleworker"

  s.add_dependency 'childprocess', '~> 0.5.3'

  s.add_development_dependency "rspec", "~> 2.5"
  s.add_development_dependency "rake", "~> 0.9.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
