require './lib/my_general/version'

Gem::Specification.new do |s|
  s.name                     = 'my_general'
  s.version                  = MyGeneral::VERSION
  s.required_ruby_version    = '>=2.2.6'
  s.date                     = Time.now.strftime('%Y-%m-%d')
  s.summary                  = 'Recover MySQL data from General Purpose Query Log'
  s.description              = 'Recover MySQL data from General Purpose Query Log.'
  s.authors                  = ['HeckPsi Lab']
  s.email                    = ['business@heckpsi.com']
  s.require_paths            = ['lib']
  s.bindir                   = ['bin']
  s.executables              = ['my_general']
  s.files                    = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|.resources)/}) } \
    - %w(README.md CODE_OF_CONDUCT.md CONTRIBUTING.md Gemfile Rakefile my_general.gemspec .gitignore .rspec .codeclimate.yml .rubocop.yml .travis.yml logo.png Rakefile Gemfile)
  s.homepage                 = 'https://github.com/dsh0416/my_general'
  s.metadata                 = { 'issue_tracker' => 'https://github.com/dsh0416/my_general/issues' }
  s.license                  = 'MIT'
  s.add_runtime_dependency     'ruby-progressbar', '~> 1.9'
end
