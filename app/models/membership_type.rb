class MembershipType < ActiveRecord::Base
  #we're working on the premise that if an integer attribute value is "unlimited"
  #it will be set to 'nil' in the database. Since we're adding all data to the database
  #via migration, this will not present a problem

  belongs_to :user

  #options for select as they will appear in the view:
  @@SELECT_OPTIONS = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, "unlimited"]
  @@FUNDING_OPTIONS = [50000, 1000000, 2500000, 500000, 10000000, "unlimited"]

  #here we are validating presence of membership_type name, we are also ensuring
  #that this attribute is inaccessible. This improves security by ensuring that
  #new membership types cannot be created
  
  validates_presence_of :name
  attr_accessible :max_projects_listed, :funding_limit_per_project, 
    :pc_limit_per_project, :pc_project_limit

  def self.select_options
    @@SELECT_OPTIONS
  end

  def self.funding_options
    @@FUNDING_OPTIONS
  end

  def update_unlimited_param(attribute)
    self[attribute] = nil
    self.save!
  end
  
end
