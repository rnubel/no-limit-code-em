require 'draw_poker_table'

class Round < ActiveRecord::Base
  belongs_to :table

  has_and_belongs_to_many :players, join_table: 'round_players'
  has_many :round_players

  belongs_to :dealer, :class_name => "Player"
  has_many :actions

  has_one :tournament, through: :table

  DECK =  ["AC", "AD", "AH", "AS", "2C", "2D", "2H", "2S", "3C", "3D", "3H", "3S", "4C", "4D", "4H", "4S", "5C", "5D", "5H", "5S", "6C", "6D", "6H", "6S", "7C", "7D", "7H", "7S", "8C", "8D", "8H", "8S", "9C", "9D", "9H", "9S", "TC", "TD", "TH", "TS", "JC", "JD", "JH", "JS", "QC", "QD", "QH", "QS", "KC", "KD", "KH", "KS"]

  after_initialize :shuffle_deck!
  before_save :set_ante!

  scope :over, where(:playing => false)
  scope :ordered, order("id ASC")

  def shuffle_deck!
    self.deck ||= DECK.shuffle.join(" ") # Allow override for testing
  end

  def set_ante!
    self.ante ||= self.table.tournament.current_ante # TODO: timing issue?
  end

  def close!
    self.playing = false
    self.save!

    self.round_players.each do |rp|
      rp.stack_change = self.state.stack_changes[rp.player_id]
      rp.save!
    end
  end

  def losers
    raise "Round not over!" if self.playing

    state.losers.map { |loser_hash| self.players.find(loser_hash[:player_id]) }
  end

  def winners
    raise "Round not over!" if self.playing

    state.winners.reduce({}) { |h, winner_hash| h[self.players.find(winner_hash[:player_id])] = winner_hash[:winnings] ; h} 
  end

  def ordered_players
    self.players
      .partition { |p| p.id >= self.dealer_id }
      .map { |list| list.sort_by(&:id) }
      .flatten
  end

  def take_action!(params)
    raise "Round already closed!" unless playing?
    if valid_action?(params)
      action = self.actions.build action_params(params)
      action.save!
    else
      raise "Action #{params} not valid on current state!"
    end
  end

  def valid_action?(action_params)
    action_hash = action_params
                    .except(:player)
                    .merge(:player_id => action_params[:player].id)
    state.valid_action? action_hash
  end

  def over?
    state.round == 'showdown'
  end

  def state
    Rails.cache.fetch("round/#{id}/state/#{actions.count}") do
      s = initial_state
      s.simulate! action_list
    end
  end

  def current_player
    players.find(state.current_player[:id])
  end

  def betting_round
    state.round
  end

  def action_params(params)
    params[:cards] = params[:cards].join(" ") if params[:cards]
    params
  end

  def initial_state
    DrawPokerTable.new players: player_list,
                       ante:    ante,
                       deck:    deck
  end

  def player_list
    ordered_players.collect do |p|
      { id: p.id, stack: p.stack(self) }
    end
  end

  def action_list
    actions.order("id ASC").collect do |a|
      { player_id: a.player_id,
        action: a.action, 
        amount: a.amount,
        cards: a.cards && a.cards.split(" ") }
    end
  end

  def community_cards
    state.community_cards
  end
end
