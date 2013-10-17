class TournamentPresenter
  include ActiveSupport::Inflector
  include CardHelper

  attr_reader :tournament
  def initialize(tournament)
    @tournament = tournament
  end

  def scoreboard
    @scoreboard = tournament.players.each_with_index.collect { |p, i|
      {
        :name => p.name,
        :stack => stack_display(p.stack, true),
        :lost_at => p.lost_at,
        :real_stack => p.stack
      }
    }.sort_by { |p| [p[:real_stack], p[:lost_at]] }.reverse
  end

  def tables
    @tables = tournament.tables.playing.collect do |table|
      {
        :table_id => table.id,
        :community_cards => build_hand(table.current_round.community_cards),
        :players => table.active_players.collect { |p| {:player_id => p.id,
                                                        :name => p.name.first(14) + (p.name.length > 14 ? "..." : ""),
                                                        :their_turn => p.my_turn?,
                                                        :folded => p.folded?,
                                                        :initial_stack => p.current_player_state(:initial_stack),
                                                        :stack => stack_display(p.current_player_state(:stack),false),
                                                        :hand => build_hand(p.current_player_state(:hand)),
                                                        :current_bet => p.current_player_state(:current_bet) || 0 }},
        :latest_winners => table.rounds
                                .ordered
                                .where(:playing => false)
                                .last(3)
                                .collect(&:winners) # At this point, list of hashes of winners
                                .map { |winners_hash|
                                  winners_hash.collect { |(player, w) |
                                    { :name => player.name.first(14) + (player.name.length > 14 ? "..." : ""), :winnings => w }
                                  }
                                }
                                .flatten
                                .last(3)
                                .reverse
      }
    end.sort_by { |t| t[:table_id] }

    @tables.each do |t|
      t[:pot] = stack_display(t[:players].sum {|h| h[:current_bet] || 0}).html_safe
    end

  end

  def stack_display(chips, border=true)
    chips ||= 0
    colors = {:white=>1, :red=>5, :green=>25, :black=>100, :purple=>500, :yellow=>1000, :gray=>5000}
    initial = chips
    chip_types = colors.to_a.sort_by{|c|c.last}.reverse.reduce([]) do |list, (color, value)|
      list += [color.to_s] * (chips / value)
      chips = chips % value
      list
    end.uniq
    html = chip_types.map { |color|
      "<i class='chip chip-#{color} #{"chip-bordered" if border}'></i>".html_safe
    }.join
    html += "$" + initial.to_s
  end

  def build_hand(cards)
    cards.collect { |c| build_card(c[0..0], c[1..1].upcase) }.join(" ")
  end

end
