# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_lighthouse/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-lighthouse'
  spec.version       = Legion::Extensions::CognitiveLighthouse::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']
  spec.license       = 'MIT'

  spec.summary       = 'Cognitive lighthouse LEX — guiding beacons that cut through cognitive fog'
  spec.description   = 'Models guiding beacons that periodically sweep their beam to illuminate areas ' \
                       'of uncertainty, helping navigate complex decision spaces. Beacons can be steady ' \
                       'or rotating, can dim in fog, and can guide other agents through ambiguity.'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-lighthouse'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['documentation_uri'] = "#{spec.homepage}#readme"
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']   = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(test|spec|features)/}) }
  end

  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
