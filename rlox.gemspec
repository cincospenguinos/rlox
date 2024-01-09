# frozen_string_literal: true

require_relative "lib/rlox/version"

Gem::Specification.new do |spec|
  spec.name = "rlox"
  spec.version = Rlox::VERSION
  spec.authors = ["Andre LaFleur"]
  spec.email = ["cincospenguinos@gmail.com"]

  spec.summary = "A Ruby implementation of the Lox programming language"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = ""

  spec.metadata["source_code_uri"] = "https://github.com/cincospenguinos/rlox"
  spec.homepage = spec.metadata["source_code_uri"]
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
