require 'httpclient'
require 'httpclient/include_client'
require 'Faker'
require 'json'

class Bot
  extend HTTPClient::IncludeClient

  include_http_client(ENV['host'] || 'http://nolimitcodeem.com')

  def base_uri
    ENV['host'] || 'http://nolimitcodeem.com'
  end

  attr_accessor :key

  def initialize(opts)
    @name = opts[:name]
    @delay = opts[:delay].to_f || 1
  end

  def register(params)
    response = http_client.post("#{base_uri}/api/players", :body => params)
    json = JSON.parse(response.body)

    raise "Registration failed" unless json["key"]

    self.key = json["key"]
    puts "[#{@name}] (#{Time.now}) Registered with key #{key}"
  end

  def status
    # puts "[#{@name}] (#{Time.now}) Polling status..."
    start = Time.now
    response = http_client.get("#{base_uri}/api/players/#{key}")
    # puts "[#{@name}] (#{Time.now}) Polling status took #{Time.now - start}s"
    json = JSON.parse(response.body)
  end

  def action(params)
    start = Time.now
    puts "[#{@name}] (#{Time.now}) Decided on action: #{params.inspect}"
    http_client.post("#{base_uri}/api/players/#{key}/action", :body => params)
    puts "[#{@name}] (#{Time.now}) Posting action took #{Time.now - start}s"
  end

  def decide_action!(s)
    # puts "[#{@name}] (#{Time.now}) #{s.inspect}"
    if s["betting_phase"] == 'deal' || s["betting_phase"] == 'post_draw'
      n = rand(100)
      if n < 30
        action(:action_name => "fold")
      else
        if n < 80 # Call
          action(:action_name => "bet", :amount => s["minimum_bet"])
        elsif n < 95 # Raise small
          action(:action_name => "bet", :amount => [s["minimum_bet"] + rand(1..20), s["maximum_bet"]].min)
        else # All-in baby
          action(:action_name => "bet", :amount => s["maximum_bet"])
        end
      end
    else
      action(:action_name => "replace", :cards => s["hand"].shuffle.first(rand(4)).join(" "))
    end
  end

  def run!
    register(:name => @name)

    while true
      begin
        s = status
        # puts "[#{@name}] Getting status... #{s['your_turn']}, #{s['betting_phase']}"
        break if s["lost_at"]

        if s["your_turn"]
          decide_action!(s)
        end
      rescue Exception => e
        puts "#{e.inspect} #{e.backtrace}"
      end

      sleep @delay
    end
  end
end

30.times.collect do |i|
  Thread.new do
    b = Bot.new(
      :name => Faker::Name.name,
      :delay => 0.2,
    ).run!
  end
end.map(&:join)

