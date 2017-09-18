Gem::Specification.new do |spec|
  spec.name          = "mc2p-ruby"
  spec.version       = "0.1.1"
  spec.authors       = ["MyChoice2Pay"]
  spec.email         = ["hola@mychoice2pay.com"]
  spec.summary       = "MyChoice2Pay Ruby Gem"
  spec.description   = %q{Gem for the MyChoice2Pay API.}
  spec.homepage      = "https://www.mychoice2pay.com"
  spec.license       = "MIT"

  spec.files         = Dir["{lib, bin}/**/*", "LICENCE.txt", "README.md"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = ['mc2p']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'unirest', '~> 1.0'
end