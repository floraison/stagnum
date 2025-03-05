
Gem::Specification.new do |s|

  s.name = 'stagnum'

  s.version = File.read(
    File.expand_path('../lib/stagnum.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux+flor@gmail.com' ]
  s.homepage = 'https://github.com/floraison/stagnum'
  s.license = 'MIT'
  s.summary = 'a work thread pool'

  s.description = %{
A stupid work thread pool
  }.strip

  s.metadata = {
    'changelog_uri' => s.homepage + '/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => s.homepage + '/issues',
    'homepage_uri' =>  s.homepage,
    'documentation_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    #'mailing_list_uri' => 'https://groups.google.com/forum/#!forum/floraison',
    #'wiki_uri' => s.homepage + '/wiki',
    'rubygems_mfa_required' => 'true',
  }

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    '{README,CHANGELOG,CREDITS,LICENSE}.{md,txt}',
    #'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  #s.add_runtime_dependency 'raabro', '~> 1.4'

  s.add_development_dependency 'probatio', '~> 1.0'

  s.require_path = 'lib'
end

