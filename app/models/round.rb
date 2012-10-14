require 'poker_table'

class Round < ActiveRecord::Base
  belongs_to :table

  has_and_belongs_to_many :players, join_table: 'round_players'
  belongs_to :dealer, :class_name => "Player"

  has_many :actions

  DECK =  ["AC", "AD", "AH", "AS", "2C", "2D", "2H", "2S", "3C", "3D", "3H", "3S", "4C", "4D", "4H", "4S", "5C", "5D", "5H", "5S", "6C", "6D", "6H", "6S", "7C", "7D", "7H", "7S", "8C", "8D", "8H", "8S", "9C", "9D", "9H", "9S", "TC", "TD", "TH", "TS", "JC", "JD", "JH", "JS", "QC", "QD", "QH", "QS", "KC", "KD", "KH", "KS"]

  after_initialize :shuffle_deck!
  before_save :set_ante!

  def shuffle_deck!
    self.deck ||= DECK.shuffle.join(" ") # Allow override for testing
  end

  def set_ante!
    self.ante ||= self.table.tournament.current_ante # TODO: timing issue?
  end

  def ordered_players
    self.players.partition { |p| p.id >= self.dealer_id }.flatten
  end

  def record_action!(params)
    action = self.actions.build params

    if valid_action?(action)
      action.save!
    end
  end

  def valid_action?(action)
    true
  end

  def state
    initial_state.simulate! action_list
  end

  def initial_state
    PokerTable.new players: player_list,
                   ante:    ante,
                   deck:    deck
  end

  def player_list
    ordered_players.collect do |p|
      { id: p.id, stack: 0 }
    end
  end

  def action_list
    actions.order("id ASC").collect do |a|
      { player_id: a.player_id,
        action: a.action, 
        amount: a.amount,
        cards: a.cards }
    end
  end
end
