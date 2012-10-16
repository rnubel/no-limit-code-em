namespace :tournament do
  task :create => :environment do
    raise "A tournament is already open!" unless Tournament.open.empty?

    t = Tournament.create :open => true

    puts "Tournament #{t.inspect} has opened for registration."
  end

  task :stats => :environment do
    t = Tournament.last

    puts t.players.inspect
  end

  task :start => :environment do
    raise "No tournament found to start!" unless Tournament.open.first

    t = Tournament.last
    t.start!

    puts "Tournament #{t.inspect} has closed registration and begun!"
  end

  task :end => :environment do
    t = Tournament.playing.last
    raise "No tournament found to end!" unless t

    t.end!

    puts "Tournament #{t.inspect} has been ended!"
  end
end
