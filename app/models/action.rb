class Action < ActiveRecord::Base
  belongs_to :round, inverse_of: :actions
  belongs_to :player

  validates_presence_of :action
end
