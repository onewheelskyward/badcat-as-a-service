require 'sinatra/base'
require 'sinatra/config_file'
require 'json'

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
    # unless settings.tokens.include? params[:token] and settings.team_domains.include? params[:team_domain]
    #   puts "Token #{params[:token]} not found in #{settings.tokens} or #{params[:team_domain]} doesn't match #{settings.team_domains}"
    #   false
    # end
    true
  end

  def get_random_badcat
    badcats = []
    in_tweet = false
    tweet = ''
    zoom = File.read('badcat.txt')
    zoom.split(/\n/).each do |line|
      if line.match /Bad Joke Cat ‏@BadJokeCat/
        in_tweet = true
        next
      end

      if line.match /\d+ retweets \d+ likes/
        in_tweet = false
        badcats.push tweet
        tweet = ''
      end

      if in_tweet == true
        tweet += line
      end
    end
    badcats.sample
  end

  get '/badcat*' do
    halt 400, '{"message": "Auth failed."}' unless check_auth(params)

    puts params[:response_url]

    result = get_random_badcat # params[:text]

    {response_type: 'in_channel',
     text: result
    }.to_json
  end
end
