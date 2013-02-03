module ApplicationHelper
  include ActiveSupport::Inflector
  def stack_display(chips, border=true)
    colors = {:white=>1, :red=>5, :green=>25, :black=>100, :purple=>500, :yellow=>1000, :gray=>5000}

    chip_types = colors.to_a.sort_by{|c|c.last}.reverse.reduce([]) do |list, (color, value)|
      list += [color.to_s] * (chips / value)
      chips = chips % value
      list
    end.uniq

    chip_types.map { |color|
      "<i class='chip chip-#{color} #{"chip-bordered" if border}'></i>".html_safe
    }.join
  end

  def nlce_active?
    !!ENV['NLCE_ACTIVE']
  end

  def irc_link
    ENV['IRC_LINK']
  end
end
