# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_mitch_buchannon'
  s.version     = '2.1.2'
  s.summary     = 'Saves orders by sending a reminder mail to the customer'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Willian van der Velde'
  s.email     = 'willian@reinaris.nl'
  s.homepage  = 'https://github.com/Willianvdv'

  s.require_path = 'lib'
  s.requirements << 'none'

  # spree_version = '~> 2.2.0'
  # s.add_dependency 'spree_api', spree_version
  # s.add_dependency 'spree_backend', spree_version
  # s.add_dependency 'spree_core', spree_version

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
end
