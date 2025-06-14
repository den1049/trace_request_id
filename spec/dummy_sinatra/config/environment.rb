require 'bundler'
require 'bundler/setup'
require 'rack'

Bundler.require

require 'trace_request_id'
require_all 'app'

configure :development, :test do
  disable :protection
end
