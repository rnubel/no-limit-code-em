module ApplicationHelper
  def nlce_active?
    !!(ENV['NLCE_ACTIVE'] && ENV['NLCE_ACTIVE'] == "1")
  end

  def irc_link
    ENV['IRC_LINK']
  end
end
