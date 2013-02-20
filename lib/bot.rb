require 'httpclient'
require 'httpclient/include_client'


class Bot
  extend HTTPClient::IncludeClient

  include_http_client(ENV['host'] || 'localhost:3000')

  def base_uri
    ENV['host'] || 'localhost:3000'
  end

  attr_accessor :key, :logger

  def initialize(opts)
    @name = opts[:name]
    @delay = opts[:delay].to_f || 1
    @logger = opts[:logger] || Logger.new(STDOUT)
  end

  def register(params)
    response = http_client.post("#{base_uri}/api/players", :body => params)
    json = JSON.parse(response.body)

    raise "Registration failed" unless json["key"]

    self.key = json["key"]
    logger.info "[#{@name}] (#{Time.now}) Registered with key #{key}"
  end

  def status
    if ENV['log'] then logger.info "[#{@name}] (#{Time.now}) Polling status..." end
    start = Time.now
    response = http_client.get("#{base_uri}/api/players/#{key}")
    if ENV['log'] then logger.info "[#{@name}] (#{Time.now}) [#{response.status}] Polling status took #{Time.now - start}s" end
    json = JSON.parse(response.body)
  end

  def action(params)
    start = Time.now
    if ENV['log'] then logger.info "[#{@name}] (#{Time.now}) Decided on action: #{params.inspect}" end
    http_client.post("#{base_uri}/api/players/#{key}/action", :body => params)
    if ENV['log'] then logger.info "[#{@name}] (#{Time.now}) Posting action took #{Time.now - start}s" end
  end

  def decide_action!(s)
    logger.info "[#{@name}] (#{Time.now}) #{s.inspect}"
    if s["betting_phase"] == 'deal' || s["betting_phase"] == 'post_draw'
      n = rand(100)
      if n < 50
        action(:action_name => "fold")
      else
        if n < 80 || s["stack"] <= s["call_amount"] # Call
          action(:action_name => "call")
        elsif n < 95 # Raise small
          action(:action_name => "raise", :amount => rand(1..20) )
        else # All-in baby
          action(:action_name => "raise", :amount => s["stack"] - s["call_amount"])
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
        logger.info "[#{@name}] Getting status... #{s['your_turn']}, #{s['betting_phase']}"
        break if s["lost_at"]

        if s["your_turn"]
          decide_action!(s)
        end
      rescue Exception => e
        logger.error "#{e.inspect} #{e.backtrace}"
      end

      logger.info "Sleeping #{@delay}s..." if ENV['log']
      t0 = Time.now
      sleep @delay
      logger.info "Slept #{Time.now - t0}s." if ENV['log']
    end
  end
end

