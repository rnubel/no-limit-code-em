module CardHelper
  def build_card(number, suit_code)
    card = "<div class='card'>"
    case suit_code
      when "C"
        card << "<div class='suit black'>&clubs;</div>"
      when "S"
        card << "<div class='suit black'>&spades;</div>"
      when "D"
        card << "<div class='suit red'>&diams;</div>"
      when "H"
        card << "<div class='suit red'>&hearts;</div>"
    end
    card << (number == "T" ? "10" : number)
    card << "</div>"
    card
  end
end
