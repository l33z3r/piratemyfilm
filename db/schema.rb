# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110306104211) do

  create_table "admin_project_ratings", :force => true do |t|
    t.integer  "project_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "blog_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin_blog",    :default => false
    t.integer  "project_id"
    t.integer  "num_wp_comments",  :default => 0
    t.string   "wp_comments_link"
    t.string   "guid"
  end

  add_index "blogs", ["profile_id"], :name => "index_blogs_on_profile_id"

  create_table "comments", :force => true do |t|
    t.text     "comment"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "profile_id"
    t.string   "commentable_type", :default => "",    :null => false
    t.integer  "commentable_id",                      :null => false
    t.integer  "is_denied",        :default => 0,     :null => false
    t.boolean  "is_reviewed",      :default => false
  end

  add_index "comments", ["profile_id"], :name => "index_comments_on_profile_id"
  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"

  create_table "countries", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_items", :force => true do |t|
    t.boolean  "include_comments", :default => false, :null => false
    t.boolean  "is_public",        :default => false, :null => false
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feed_items", ["item_id", "item_type"], :name => "index_feed_items_on_item_id_and_item_type"

  create_table "feeds", :force => true do |t|
    t.integer "profile_id"
    t.integer "feed_item_id"
  end

  add_index "feeds", ["profile_id", "feed_item_id"], :name => "index_feeds_on_profile_id_and_feed_item_id"

  create_table "forum_posts", :force => true do |t|
    t.text     "body"
    t.integer  "owner_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_posts", ["topic_id"], :name => "index_forum_posts_on_topic_id"

  create_table "forum_topics", :force => true do |t|
    t.string   "title"
    t.integer  "forum_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_topics", ["forum_id"], :name => "index_forum_topics_on_forum_id"

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", :force => true do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends", ["inviter_id", "invited_id"], :name => "index_friends_on_inviter_id_and_invited_id", :unique => true
  add_index "friends", ["invited_id", "inviter_id"], :name => "index_friends_on_invited_id_and_inviter_id", :unique => true

  create_table "genres", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_rating_histories", :force => true do |t|
    t.integer  "member_id"
    t.integer  "rater_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_ratings", :force => true do |t|
    t.integer  "member_id"
    t.integer  "average_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "membership_types", :force => true do |t|
    t.string   "name"
    t.integer  "max_projects_listed"
    t.integer  "pc_limit"
    t.integer  "pc_project_limit"
    t.integer  "funding_limit_per_project"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "min_funding_limit_per_project", :default => 0
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "membership_type_id", :default => 1
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.boolean  "read",        :default => false, :null => false
  end

  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notification_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_windows", :force => true do |t|
    t.integer  "project_id"
    t.string   "paypal_email"
    t.date     "close_date"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "caption",    :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
    t.string   "image"
  end

  add_index "photos", ["profile_id"], :name => "index_photos_on_profile_id"

  create_table "pmf_fund_subscription_histories", :force => true do |t|
    t.integer  "project_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pmf_share_buyouts", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "share_amount"
    t.float    "share_price"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "website"
    t.string   "blog"
    t.string   "flickr"
    t.text     "about_me"
    t.string   "aim_name"
    t.string   "gtalk_name"
    t.string   "ichat_name"
    t.string   "icon"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.boolean  "is_active",        :default => false
    t.string   "youtube_username"
    t.string   "flickr_username"
    t.datetime "last_activity_at"
    t.string   "time_zone",        :default => "UTC"
    t.integer  "country_id",       :default => 1
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "project_change_info_one_days", :force => true do |t|
    t.integer  "share_amount", :default => 0
    t.integer  "share_change", :default => 0
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_comments", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_flaggings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_followings", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_rating_histories", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_rating_id"
  end

  create_table "project_ratings", :force => true do |t|
    t.integer  "project_id"
    t.integer  "average_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_subscriptions", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",                  :limit => 10, :precision => 10, :scale => 0, :default => 1
    t.boolean  "outstanding",                                                          :default => false
    t.integer  "subscription_payment_id"
  end

  create_table "projects", :force => true do |t|
    t.integer  "owner_id"
    t.string   "title"
    t.string   "producer_name"
    t.text     "synopsis"
    t.integer  "genre_id"
    t.text     "description"
    t.text     "cast"
    t.string   "web_address"
    t.decimal  "ipo_price",                                      :precision => 10, :scale => 2
    t.integer  "percent_funded",                   :limit => 3,  :precision => 3,  :scale => 0
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "youtube_vid_id"
    t.string   "status",                                                                        :default => "Funding"
    t.integer  "project_length",                                                                :default => 0
    t.integer  "share_percent_downloads",          :limit => 3,  :precision => 3,  :scale => 0
    t.integer  "share_percent_ads",                :limit => 3,  :precision => 3,  :scale => 0
    t.integer  "downloads_reserved",               :limit => 10, :precision => 10, :scale => 0, :default => 0
    t.integer  "downloads_available",              :limit => 10, :precision => 10, :scale => 0, :default => 0
    t.integer  "capital_required",                 :limit => 12, :precision => 12, :scale => 0
    t.datetime "rated_at"
    t.boolean  "is_deleted",                                                                    :default => false
    t.datetime "deleted_at"
    t.integer  "member_rating",                                                                 :default => 0
    t.integer  "admin_rating",                                                                  :default => 0
    t.string   "director"
    t.string   "writer"
    t.string   "exec_producer"
    t.integer  "producer_fee_percent"
    t.integer  "capital_recycled_percent"
    t.integer  "share_percent_ads_producer",                                                    :default => 0
    t.float    "producer_dividend",                                                             :default => 0.0
    t.float    "shareholder_dividend",                                                          :default => 0.0
    t.string   "symbol"
    t.float    "fund_dividend",                                                                 :default => 0.0
    t.integer  "pmf_fund_investment_percentage"
    t.datetime "green_light"
    t.string   "director_photography"
    t.string   "editor"
    t.integer  "pmf_fund_investment_share_amount",                                              :default => 0
    t.string   "project_payment_status"
    t.integer  "producer_talent_id"
    t.integer  "director_talent_id"
    t.integer  "writer_talent_id"
    t.integer  "exec_producer_talent_id"
    t.integer  "director_photography_talent_id"
    t.integer  "editor_talent_id"
    t.datetime "fully_funded_time"
    t.datetime "completion_date"
    t.string   "watch_url"
    t.date     "premier_date"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscription_payments", :force => true do |t|
    t.integer  "payment_window_id"
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "share_amount"
    t.float    "share_price"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talent_rating_histories", :force => true do |t|
    t.integer  "talent_rating_id"
    t.integer  "user_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talent_ratings", :force => true do |t|
    t.integer  "user_talent_id"
    t.integer  "average_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_talents", :force => true do |t|
    t.integer  "user_id"
    t.string   "talent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "is_admin"
    t.boolean  "can_send_messages",                       :default => true
    t.string   "email_verification"
    t.boolean  "email_verified"
    t.integer  "member_rating",                           :default => 0
  end

  add_index "users", ["login"], :name => "index_users_on_login"

end
