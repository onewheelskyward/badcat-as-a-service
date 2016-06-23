require 'sinatra/base'
require 'sinatra/config_file'

class App < Sinatra::Base

  # Copy the config file from dist if it does not exist
  config_file = File.dirname(__FILE__) + '/config.yml'
  unless File.exist? config_file
    puts 'Auto-copying config distribution file to active config'
    system "cp #{File.dirname(__FILE__)}/config.yml.dist #{config_file}"
  end

  register Sinatra::ConfigFile
  config_file 'config.yml'

  before do
    content_type 'application/json'
  end

  def check_auth(params)
    unless settings.tokens.include? params[:token] and settings.team_domains.include? params[:team_domain]
      puts "Token #{params[:token]} not found in #{settings.tokens} or #{params[:team_domain]} doesn't match #{settings.team_domains}"
      false
    end
    true
  end

  def run_search(query, image = false)
    result = OnewheelGoogle::search(query, settings.cse_id, settings.api_key, 'high', image)

    unless result
      halt 500, '{"message": "search failed to return results."}'
    end

    result
  end

  get '/badcat*' do
    halt 400, '{"message": "Auth failed."}' unless check_auth(params)

    puts params[:response_url]

    result = get_random_badcat params[:text]

    { response_type: 'in_channel',
      text: result
    }.to_json
  end
end
