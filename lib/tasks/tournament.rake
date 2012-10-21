class TournamentPrinter
  include Hirb::Console

  def print_tables(tables)
    puts "-----------------------------------------------"
    tables.playing.each_slice(4) do |tables_for_row|
      logs = tables_for_row.collect { |t| t.rounds.last.state.log }
      max_s = logs.map(&:size).max
      logs.collect! { |l| l.insert(-1, *([""] * (max_s - l.size))) }

      table([
        tables_for_row.collect { |t|
          t.active_players
           .map { |p| "#{p.id} (#{p.stack})" }
           .join(" ")
        } ] + logs.transpose
    )
    end
  end
end

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

    Rake::Task['tournament:run'].invoke
  end

  task :run => :environment do
    t = Tournament.playing.last
    raise "No tournament playing!" unless t

    TournamentPrinter.new.print_tables(t.tables.includes(:seatings))
    until t.players.playing.count == 1
      t.balance_tables!

      TournamentPrinter.new.print_tables(t.tables.includes(:seatings))
      sleep 5
    end

    puts "Tournament over! Winners:"

    t.players.order("lost_at DESC").each_with_index do |p, i|
      puts "#{i+1}\t#{p.stack}\t#{p.name}"
    end
  end

  task :end => :environment do
    t = Tournament.playing.last
    raise "No tournament found to end!" unless t

    t.end!

    puts "Tournament #{t.inspect} has been ended!"
  end

  task :restart => [:end, :create]
end
