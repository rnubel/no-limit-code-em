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

ActiveRecord::Schema.define(:version => 20121020032118) do

  create_table "actions", :force => true do |t|
    t.string   "action"
    t.integer  "amount"
    t.string   "cards"
    t.integer  "player_id"
    t.integer  "round_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",  :default => 0
    t.integer  "tournament_id"
    t.integer  "initial_stack"
    t.datetime "lost_at"
  end

  add_index "players", ["key"], :name => "index_players_on_key"

  create_table "registrations", :force => true do |t|
    t.integer  "player_id"
    t.integer  "tournament_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purse"
    t.integer  "current_stack"
  end

  create_table "round_players", :force => true do |t|
    t.integer "player_id"
    t.integer "round_id"
    t.integer "initial_stack"
    t.integer "stack_change"
  end

  create_table "rounds", :force => true do |t|
    t.integer  "table_id"
    t.boolean  "playing"
    t.string   "player_order"
    t.string   "deck"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ante"
    t.integer  "dealer_id"
    t.integer  "lock_version", :default => 0
  end

  create_table "seatings", :force => true do |t|
    t.integer  "player_id"
    t.integer  "table_id"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tables", :force => true do |t|
    t.integer  "tournament_id"
    t.boolean  "playing"
    t.string   "seat_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",  :default => 0
  end

  create_table "tournaments", :force => true do |t|
    t.boolean  "open"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
    t.boolean  "playing",      :default => false
  end

end
