# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fluent-plugin-mongo"
  s.version = "0.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Masahiro Nakagawa"]
  s.date = "2012-03-30"
  s.description = "MongoDB plugin for Fluent event collector"
  s.email = "repeatedly@gmail.com"
  s.executables = ["mongo-tail"]
  s.files = ["bin/mongo-tail"]
  s.homepage = "https://github.com/fluent/fluent-plugin-mongo"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "MongoDB plugin for Fluent event collector"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fluentd>, [">= 0.10.7"])
      s.add_runtime_dependency(%q<mongo>, [">= 1.6.0"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<simplecov>, [">= 0.5.4"])
      s.add_development_dependency(%q<rr>, [">= 1.0.0"])
    else
      s.add_dependency(%q<fluentd>, [">= 0.10.7"])
      s.add_dependency(%q<mongo>, [">= 1.6.0"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<simplecov>, [">= 0.5.4"])
      s.add_dependency(%q<rr>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<fluentd>, [">= 0.10.7"])
    s.add_dependency(%q<mongo>, [">= 1.6.0"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<simplecov>, [">= 0.5.4"])
    s.add_dependency(%q<rr>, [">= 1.0.0"])
  end
end
