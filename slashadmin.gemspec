$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "slash_admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "slashadmin"
  s.version     = SlashAdmin::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Slashadmin."
  s.description = "TODO: Description of Slashadmin."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 4.0.0.beta1'
  s.add_dependency 'batch_actions'
  s.add_dependency 'arbre'
  s.add_dependency 'bootstrap-sass', '~> 2.3.1.0'
  s.add_dependency 'haml'
  s.add_dependency 'kaminari'
  s.add_dependency 'ransack'
  s.add_dependency 'i18n'
end
