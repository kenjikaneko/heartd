# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fluentd"
  s.version = "0.10.25"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sadayuki Furuhashi"]
  s.date = "2012-07-23"
  s.email = "frsyuki@gmail.com"
  s.executables = ["fluentd", "fluent-cat", "fluent-gem"]
  s.extra_rdoc_files = ["ChangeLog", "README", "README.rdoc"]
  s.files = ["bin/fluentd", "bin/fluent-cat", "bin/fluent-gem", "ChangeLog", "README", "README.rdoc"]
  s.homepage = "http://fluentd.org/"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("~> 1.9.2")
  s.rubygems_version = "1.8.24"
  s.summary = "Fluent event collector"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<msgpack>, ["~> 0.4.4"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.3"])
      s.add_runtime_dependency(%q<yajl-ruby>, ["~> 1.0"])
      s.add_runtime_dependency(%q<cool.io>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<http_parser.rb>, ["~> 0.5.1"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<rr>, [">= 1.0.0"])
      s.add_development_dependency(%q<timecop>, [">= 0.3.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.0.0"])
    else
      s.add_dependency(%q<msgpack>, ["~> 0.4.4"])
      s.add_dependency(%q<json>, [">= 1.4.3"])
      s.add_dependency(%q<yajl-ruby>, ["~> 1.0"])
      s.add_dependency(%q<cool.io>, ["~> 1.1.0"])
      s.add_dependency(%q<http_parser.rb>, ["~> 0.5.1"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<rr>, [">= 1.0.0"])
      s.add_dependency(%q<timecop>, [">= 0.3.0"])
      s.add_dependency(%q<jeweler>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<msgpack>, ["~> 0.4.4"])
    s.add_dependency(%q<json>, [">= 1.4.3"])
    s.add_dependency(%q<yajl-ruby>, ["~> 1.0"])
    s.add_dependency(%q<cool.io>, ["~> 1.1.0"])
    s.add_dependency(%q<http_parser.rb>, ["~> 0.5.1"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<rr>, [">= 1.0.0"])
    s.add_dependency(%q<timecop>, [">= 0.3.0"])
    s.add_dependency(%q<jeweler>, [">= 1.0.0"])
  end
end
