class Action < ActiveRecord::Base
  belongs_to :round, inverse_of: :actions
  belongs_to :player

  validates_presence_of :action

  def to_hash
    {
      :player_id => player.id,
      :action => action,
      :amount => amount,
      :cards => cards
    }
  end
end
