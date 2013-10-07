# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121023204958) do

  create_table "actions", :force => true do |t|
    t.string   "action"
    t.integer  "amount"
    t.string   "cards"
    t.integer  "player_id"
    t.integer  "round_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "actions", ["player_id"], :name => "index_actions_on_player_id"
  add_index "actions", ["round_id"], :name => "index_actions_on_round_id"

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "lock_version",  :default => 0
    t.integer  "tournament_id"
    t.integer  "initial_stack"
    t.datetime "lost_at"
  end

  add_index "players", ["key"], :name => "index_players_on_key"
  add_index "players", ["lost_at"], :name => "index_players_on_lost_at"
  add_index "players", ["tournament_id"], :name => "index_players_on_tournament_id"

  create_table "registrations", :force => true do |t|
    t.integer  "player_id"
    t.integer  "tournament_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "purse"
    t.integer  "current_stack"
  end

  create_table "request_logs", :force => true do |t|
    t.integer  "player_id"
    t.integer  "round_id"
    t.text     "body"
    t.datetime "created_at"
  end

  create_table "round_players", :force => true do |t|
    t.integer "player_id"
    t.integer "round_id"
    t.integer "initial_stack"
    t.integer "stack_change"
  end

  add_index "round_players", ["player_id"], :name => "index_round_players_on_player_id"
  add_index "round_players", ["round_id"], :name => "index_round_players_on_round_id"

  create_table "rounds", :force => true do |t|
    t.integer  "table_id"
    t.boolean  "playing"
    t.string   "player_order"
    t.string   "deck"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "ante"
    t.integer  "dealer_id"
    t.integer  "lock_version", :default => 0
  end

  add_index "rounds", ["playing"], :name => "index_rounds_on_playing"
  add_index "rounds", ["table_id"], :name => "index_rounds_on_table_id"

  create_table "seatings", :force => true do |t|
    t.integer "player_id"
    t.integer "table_id"
    t.boolean "active",    :default => true
  end

  add_index "seatings", ["active"], :name => "index_seatings_on_active"
  add_index "seatings", ["player_id"], :name => "index_seatings_on_player_id"
  add_index "seatings", ["table_id"], :name => "index_seatings_on_table_id"

  create_table "tables", :force => true do |t|
    t.integer  "tournament_id"
    t.boolean  "playing"
    t.string   "seat_order"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "lock_version",  :default => 0
  end

  add_index "tables", ["playing"], :name => "index_tables_on_playing"
  add_index "tables", ["tournament_id"], :name => "index_tables_on_tournament_id"

  create_table "timeout_logs", :force => true do |t|
    t.integer  "player_id"
    t.integer  "round_id"
    t.float    "idle_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tournaments", :force => true do |t|
    t.boolean  "open"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "lock_version", :default => 0
    t.boolean  "playing",      :default => false
  end

  add_index "tournaments", ["playing"], :name => "index_tournaments_on_playing"

end
