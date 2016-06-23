ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'
require 'rack/test'
require 'simplecov'
require 'coveralls'

SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]

SimpleCov.start { add_filter '/spec/' }

RSpec.configure do |config|
  config.include Sinatra::Helpers
  config.include Rack::Test::Methods
end

def app
  App
end

describe 'The badcat-cse-as-a-service App' do
  it 'gets a badcat' do
    get '/badcat?token=x&team_domain=woo&text=boop'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('{"response_type":"in_channel","text":"')
  end
end
