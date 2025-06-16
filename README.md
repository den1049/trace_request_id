# TraceRequestId

A Ruby gem that stores X-Request-Id in thread context and passes it to Sidekiq jobs to trace user journeys.
This gem helps maintain request context across different parts of your application, making it easier to track
and debug user requests through your system.

## Features

- Thread-safe storage of request IDs
- Automatic UUID generation for new requests
- Sidekiq integration for passing request IDs to background jobs
- Rails middleware support for automatic request ID handling
- Simple API for managing request IDs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trace_request_id'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install trace_request_id

## Usage

### Basic Usage

```ruby
# Get the current request ID (returns nil if not set)
TraceRequestId.id

# Set a request ID
TraceRequestId.id = "custom-request-id"

# Get or initialize a request ID (generates UUID if not set)
TraceRequestId.id(init: true)

# Clear the current request ID
TraceRequestId.clear
```

### Sinatra Integration

```ruby
class MyApplication < Sinatra::Base
  use Rack::TraceId
end
```

### Rails Integration

The gem provides a Rails middleware that automatically handles request IDs.

It registers Rails middleware using Railtie, inserting it after ActionDispatch::RequestId

The middleware:
- Extracts the request ID from the Rails request (set by ActionDispatch::RequestId)
- Stores it in the thread context for the duration of the request
- Cleans up the thread context after the request completes

### Sidekiq Integration

The gem registers Sidekiq middleware automatically using Railtie.
The gem provides both client and server middleware to maintain request context across background jobs.

#### Client Middleware

- Captures the current trace ID from the thread context
- Stores it in the job payload before saving to Redis
- Generates a new UUID if no trace ID exists

#### Server Middleware

- Restores the trace ID from the job payload to the worker thread context
- Automatically cleans up the thread context after the job completes

## Thread Safety

The gem is designed to be thread-safe. Each thread maintains its own request ID context, making it safe to use in multi-threaded environments.

Example of thread isolation:

```ruby
# Main thread
TraceRequestId.id = "main-thread-id"

# Different threads maintain separate contexts
thread1 = Thread.new do
  TraceRequestId.id = "thread1-id"
  # TraceRequestId.id returns "thread1-id"
end

thread2 = Thread.new do
  TraceRequestId.id = "thread2-id"
  # TraceRequestId.id returns "thread2-id"
end

# Main thread still has its original ID
# TraceRequestId.id returns "main-thread-id"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, to run the tests:
- rspec --pattern spec/*.rb
- cd spec/dummy_app
- rspec
- cd ../spec/dummy_app_no_sidekiq
- rspec
- cd ../spec/dummy_sinatra
- rspec

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/den1049/trace_request_id.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 
