module ApplicationHelper
  include CardHelper

  def nlce_active?
    !!(ENV['NLCE_ACTIVE'] && ENV['NLCE_ACTIVE'] == "1")
  end

  def irc_link
    ENV['IRC_LINK']
  end

  def html_card(card)
    build_card(card[0], card[1])
  end

  def navbar_link(link_text, link_path)
    class_name  = current_page?(link_path)  ? 'active'            : nil

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end 

end
