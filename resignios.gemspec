require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name = "resignios"
  spec.version = Resignios::VERSION
  spec.authors = ["guojiashuang"]
  spec.email = ["guojiashuang@live.com"]

  spec.summary = "iOS重签名"
  spec.description = "iOS重签名"
  spec.homepage = 'https://github.com/CaryGo/resignios'
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir["lib/**/*.rb"] + %w{ bin/resign bin/resignios README.md LICENSE.txt CHANGELOG.md }
  spec.bindir = "bin"
  spec.executables = %w{ resign resignios }
  spec.require_paths = %w{ lib }

  spec.add_runtime_dependency 'claide',         '>= 1.0.2', '< 2.0'
  spec.add_runtime_dependency 'colored2',       '~> 3.1'
  spec.add_runtime_dependency 'commander'
end
