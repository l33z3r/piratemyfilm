class AddMembershipTypesData < ActiveRecord::Migration
  #edit this file if you want to change the name of membership types or add new membership types

  def self.up
    MembershipType.delete_all

    @membership_type = MembershipType.create(:max_projects_listed => 5,
      :pc_limit_per_project => 5, :pc_project_limit => 5, :funding_limit_per_project => 50000)
    @membership_type.name = 'Basic'
    @membership_type.save!
    # this is necessary because the name attribute is inaccessible

    @membership_type = MembershipType.create(:max_projects_listed => 10,
      :pc_limit_per_project => 10, :pc_project_limit => 10, :funding_limit_per_project => 1000000)
    @membership_type.name = 'Gold'
    @membership_type.save!

    @membership_type = MembershipType.create(:max_projects_listed => 25,
      :pc_limit_per_project => 25, :pc_project_limit => 25, :funding_limit_per_project => 2500000)
    @membership_type.name = 'Platinum'
    @membership_type.save!

    @membership_type = MembershipType.create()
    @membership_type.name = 'Black Pearl'
    @membership_type.save!
    #eg: "if membership_type.max_projects_listed == nil", no limits apply
    
  end

  def self.down
    MembershipType.delete_all
  end
end
