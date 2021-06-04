# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "cryptomarket-sdk"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["T. Ismael Verdugo"]
  s.email       = ["ismael@dysopsis.com"]
  s.homepage    = "http://github.com/cryptomarket/ruby-sdk"
  s.summary     = %q{Cryptomarket sdk for ruby}
  s.description = %q{Cryptomarket sdk for rest connection and websocket connection for the ruby language}


  s.files = %w[LICENSE.md README.md] + Dir.glob('lib/**/*.rb')

  s.add_dependency 'rest-client', '~> 2.1'
  s.add_dependency 'faye-websocket', '~> 0.11.0'

  s.extra_rdoc_files = %w[README.md]
  s.rdoc_options     = %w[--main README.md --markup markdown]
  s.require_paths    = %w[lib]
end
