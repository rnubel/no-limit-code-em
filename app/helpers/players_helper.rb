module PlayersHelper
  def player_name(id)
    @players[id] && @players[id].name
  end
end
