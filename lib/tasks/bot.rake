require 'bot'
require 'smart_bot'

namespace :bot do
  task :run do
    (ENV['num'] || 1).to_i.times.collect do |i|
      Thread.new do
        klass = Kernel.const_get(ENV['bot'] || "Bot")
        b = klass.new(
          :name => (name = (ENV['name'] || Faker::Name.name)),
          :delay => ENV['delay'] || 0.2,
          :logger => Logger.new("tmp/bot.#{i}.#{name}.log")
        ).run!
      end
    end.map(&:join)
  end
end
