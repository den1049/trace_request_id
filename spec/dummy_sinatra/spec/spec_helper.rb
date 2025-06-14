# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'rubygems'
require 'rspec'
require 'rspec/uuid'
require 'rack/test'
require 'sinatra'
require 'sinatra/base'
require 'trace_request_id'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
