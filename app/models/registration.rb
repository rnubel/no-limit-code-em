class Registration < ActiveRecord::Base
  belongs_to :player
  belongs_to :tournament, inverse_of: :registrations
end
