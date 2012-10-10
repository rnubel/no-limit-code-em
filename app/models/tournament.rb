class Tournament < ActiveRecord::Base
  DEFAULT_TABLE_SIZE = 6

  has_and_belongs_to_many :players, :join_table => 'registrations'
  
  has_many :tables

  def start!(options={})
    self.open = false

    create_initial_seatings!(options)

    self.save!
  end

  # Create new tables for any players not seated.
  def creat_initial_seatings!(options={})
    players_to_seat = players.standing.all
    table_size = options[:table_size] || DEFAULT_TABLE_SIZE

    num_tables = (players_to_seat.size.to_f / table_size).ceil
    num_big_tables = players_to_seat.size % num_tables
    big_table = (players_to_seat.size.to_f / num_tables).ceil
    small_table = (players_to_seat.size.to_f / num_tables).floor
    
    new_tables = num_tables.times.collect do
      self.tables.create 
    end
 
    new_tables.each_with_index do |table, i|
      (i < num_big_tables ? big_table : small_table).times do 
        table.players.push(players_to_seat.pop)
      end
    end
  end
end
