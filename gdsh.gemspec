# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gdsh/version'

Gem::Specification.new do |spec|
  spec.name          = 'gdsh'
  spec.version       = Gdsh::VERSION
  spec.authors       = ['Emin Tham']
  spec.email         = ['emintham@gmail.com']
  spec.summary       = 'A Google Drive shell in Ruby.'
  spec.description   = ''
  spec.homepage      = 'https://github.com/emintham/gdsh'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'google-api-client'
  spec.add_dependency 'launchy'
  spec.add_dependency 'diff-lcs'
end
