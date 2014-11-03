$:.push File.expand_path("../lib", __FILE__)
require "simpleworker/version"

Gem::Specification.new do |s|
  s.name        = "simpleworker"
  s.version     = SimpleWorker::VERSION
  s.licenses    = ['MIT']
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Gowan"]
  s.email       = ["gowanjason@gmail.com"]
  s.homepage    = "https://github.com/jesg/simpleworker"
  s.summary     = %q{Distribute ruby scripts on multiple machines}
  s.description = %q{Distribute ruby scripts on multiple machines for automated testing.}

  s.rubyforge_project = "simpleworker"

  s.add_dependency 'childprocess', '>= 0.5.3'
  s.add_dependency 'redis', '>= 0.0.1'

  s.add_development_dependency "rspec", "~> 2.5"
  s.add_development_dependency "rake", "~> 0.9.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
