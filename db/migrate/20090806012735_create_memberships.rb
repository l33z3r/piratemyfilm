class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :membership_type_id, :default => 1
      t.datetime :expires_at
      t.timestamps
    end

    #give existing user some memberships
    User.find(:all).each { |u|
      Membership.create(:user => u, :membership_type => MembershipType.find_by_name("Gold"))
    }

  end

  def self.down
    drop_table :memberships
  end
end
