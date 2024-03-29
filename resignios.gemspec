require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name = "resignios"
  spec.version = Resignios::VERSION
  spec.authors = ["Cary"]
  spec.email = ["guojiashuang@live.com"]

  spec.summary = "iOS重签名工具，基于fastlane sigh命令做了些许修改"
  spec.description = "iOS重签名工具，基于fastlane sigh命令做了些许修改"
  spec.homepage = 'https://github.com/CaryGo/resignios'
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir["lib/**/*.{rb,sh}", "bin/*"] + %w{ README.md LICENSE.txt CHANGELOG.md }
  spec.bindir = "bin"
  spec.executables = %w{ resigntool resign resignios }
  spec.require_paths = %w{ lib }

  spec.add_runtime_dependency 'claide',         '>= 1.0.2', '< 2.0'
  spec.add_runtime_dependency 'colored2',       '~> 3.1'
  spec.add_runtime_dependency 'commander'
  spec.add_runtime_dependency 'shellwords'
end
