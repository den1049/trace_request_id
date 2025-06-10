# frozen_string_literal: true

require_relative 'lib/trace_request_id/version'

Gem::Specification.new do |spec|
  spec.name = 'trace_request_id'
  spec.version = TraceRequestId::VERSION
  spec.authors = ['Your Name']
  spec.email = ['your.email@example.com']

  spec.summary = 'A gem to store X-Request-Id in thread context and pass it to Sidekiq jobs'
  spec.description = 'This gem helps track user journey storing X-Request-Id in the thread context
                      and passing it to Sidekiq jobs'
  spec.homepage = 'https://github.com/yourusername/trace_request_id'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob('lib/**/*') + %w[README.md]
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
