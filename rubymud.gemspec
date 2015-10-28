Gem::Specification.new do |s|
  s.name        = 'ruby-mud'
  s.version     = '0.0.5'
  s.summary     = 'Framework for building text based adventure games in Ruby.'
  s.date        = '2015-10-30'
  s.description = 'A very simple framework for building text based games in Ruby.'
  s.authors     = ['Rick Carlino', 'Andrew Monks']
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/amonks/ruby_mud'
  s.files       = [
                    'lib/ruby_mud.rb',
                    'lib/mud_server.rb',
                    'lib/default_controller.rb',
                    'lib/abstract_controller.rb',
                    'lib/session.rb'
                  ]

  # s.add_runtime_dependency 'I have none!'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
end
