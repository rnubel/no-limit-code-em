require 'net/http'
class OddsCalculator
  POKER_STATS_URI = URI.parse 'http://ec2-54-204-3-36.compute-1.amazonaws.com'
  attr_accessor :table, :round

  def initialize(table)
    @table = table
    @round = table.current_round
  end

  def odds
    req = Net::HTTP::Post.new('/stats', {'Content-Type' =>'application/json'})
    req.body = parameters.to_json
    response = Net::HTTP.new(POKER_STATS_URI.host, POKER_STATS_URI.port).start {|http| http.request(req) }
    JSON.parse(response.body)
  end

  private
  def parameters
    hash = { players: {}, community_cards: @round.community_cards }
    @table.players.each do |p|
      hash[:players][p.name] = { hand: p.hand, folded: p.folded? }
    end

    hash
  end
end
