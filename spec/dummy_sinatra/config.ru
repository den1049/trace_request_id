# frozen_string_literal: true

require_relative 'config/environment'

use Rack::MethodOverride
run ApplicationController

# To flush output immediately
$stdout.sync = true
