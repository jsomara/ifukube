# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ifukube"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jordan O'Mara"]
  s.email       = ["jomara@redhat.com"]
  s.homepage    = "https://github.com/jsomara/ifukube"
  s.summary     = %q{Yet another gem for searching bugzilla.}
  s.description = %q{Yet another gem for searching bugzilla.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end