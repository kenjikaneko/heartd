# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cool.io"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tony Arcieri"]
  s.date = "2011-08-10"
  s.description = "Cool.io provides a high performance event framework for Ruby which uses the libev C library"
  s.email = ["tony.arcieri@gmail.com"]
  s.extensions = ["ext/cool.io/extconf.rb", "ext/http11_client/extconf.rb"]
  s.files = ["ext/cool.io/extconf.rb", "ext/http11_client/extconf.rb"]
  s.homepage = "http://coolio.github.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A cool framework for doing high performance I/O in Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<iobuffer>, [">= 1.0.0"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 0.7.9"])
      s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_development_dependency(%q<rdoc>, [">= 3.6.0"])
    else
      s.add_dependency(%q<iobuffer>, [">= 1.0.0"])
      s.add_dependency(%q<rake-compiler>, ["~> 0.7.9"])
      s.add_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_dependency(%q<rdoc>, [">= 3.6.0"])
    end
  else
    s.add_dependency(%q<iobuffer>, [">= 1.0.0"])
    s.add_dependency(%q<rake-compiler>, ["~> 0.7.9"])
    s.add_dependency(%q<rspec>, [">= 2.6.0"])
    s.add_dependency(%q<rdoc>, [">= 3.6.0"])
  end
end
