# TraceRequestId

A Ruby gem that stores X-Request-Id in thread context and passes it to Sidekiq jobs to trace user journeys. This gem helps maintain request context across different parts of your application, making it easier to track and debug user requests through your system.

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

### Rails Integration

The gem provides a Rails middleware that automatically handles request IDs. To use it:

1. Add the middleware to your Rails application configuration:

```ruby
# config/application.rb or config/environments/*.rb
config.middleware.insert_after ActionDispatch::RequestId, TraceRequestId::RailsMiddleware
```

The middleware:
- Extracts the request ID from the Rails request (set by ActionDispatch::RequestId)
- Stores it in the thread context for the duration of the request
- Automatically cleans up the thread context after the request completes

### Sidekiq Integration

The gem provides both client and server middleware for Sidekiq to maintain request context across background jobs.

#### Client Middleware

Add the client middleware to both client and server configurations:

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add TraceRequestId::SidekiqClientMiddleware
    # ... other client middlewares
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add TraceRequestId::SidekiqClientMiddleware
    # ... other client middlewares
  end
end
```

The client middleware:
- Captures the current trace ID from the thread context
- Stores it in the job payload before saving to Redis
- Generates a new UUID if no trace ID exists

#### Server Middleware

Add the server middleware to your Sidekiq server configuration:

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add TraceRequestId::SidekiqServerMiddleware
    # ... other server middlewares
  end
end
```

The server middleware:
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/trace_request_id.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 