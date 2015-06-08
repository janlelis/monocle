# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/rationalist"

Gem::Specification.new do |gem|
  gem.name          = "rationalist"
  gem.version       = Rationalist::VERSION
  gem.summary       = "parse argument options"
  gem.description   = "parse argument options. a ruby fork of minimist."
  gem.authors       = ["Jan Lelis"]
  gem.email         = ["mail@janlelis.de"]
  gem.homepage      = "https://github.com/janlelis/Rationalist"
  gem.license       = "MIT"

  gem.files         = Dir["{**/}{.*,*}"].select{ |path| File.file?(path) && path !~ /^pkg/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.0"
end
