# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fluent-logger"
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sadayuki Furuhashi"]
  s.date = "2012-04-24"
  s.description = "fluent logger for ruby"
  s.email = "frsyuki@gmail.com"
  s.executables = ["fluent-post"]
  s.files = ["bin/fluent-post"]
  s.homepage = "https://github.com/fluent/fluent-logger-ruby"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "fluent logger for ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yajl-ruby>, ["~> 1.0"])
      s.add_runtime_dependency(%q<msgpack>, ["~> 0.4.4"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.7.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0.5.4"])
      s.add_development_dependency(%q<timecop>, [">= 0.3.0"])
    else
      s.add_dependency(%q<yajl-ruby>, ["~> 1.0"])
      s.add_dependency(%q<msgpack>, ["~> 0.4.4"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<rspec>, [">= 2.7.0"])
      s.add_dependency(%q<simplecov>, [">= 0.5.4"])
      s.add_dependency(%q<timecop>, [">= 0.3.0"])
    end
  else
    s.add_dependency(%q<yajl-ruby>, ["~> 1.0"])
    s.add_dependency(%q<msgpack>, ["~> 0.4.4"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<rspec>, [">= 2.7.0"])
    s.add_dependency(%q<simplecov>, [">= 0.5.4"])
    s.add_dependency(%q<timecop>, [">= 0.3.0"])
  end
end
