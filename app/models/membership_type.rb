# == Schema Information
# Schema version: 20100528091908
#
# Table name: membership_types
#
#  id                            :integer(4)    not null, primary key
#  name                          :string(255)   
#  max_projects_listed           :integer(4)    
#  pc_limit                      :integer(4)    
#  pc_project_limit              :integer(4)    
#  funding_limit_per_project     :integer(4)    
#  created_at                    :datetime      
#  updated_at                    :datetime      
#  min_funding_limit_per_project :integer(4)    default(0)
#

class MembershipType < ActiveRecord::Base
  #we're working on the premise that if an integer attribute value is "unlimited"
  #it will be set to 'nil' in the database. Since we're adding all data to the database
  #via migration, this will not present a problem

  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  #options for select as they will appear in the view:
  @@SELECT_OPTIONS = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, "unlimited"]
  @@MIN_FUNDING_OPTIONS = [0, 1000, 2000, 3000, 5000]
  @@FUNDING_OPTIONS = [50000, 10000, 20000, 25000, 30000, 35000, 40000, 1000000, 2500000, 500000, 10000000, "unlimited"]

  #here we are validating presence of membership_type name, we are also ensuring
  #that this attribute is inaccessible. This improves security by ensuring that
  #new membership types cannot be created
  
  validates_presence_of :name
  attr_accessible :max_projects_listed, :min_funding_limit_per_project,
    :funding_limit_per_project, :pc_limit, :pc_project_limit

  def self.select_options
    @@SELECT_OPTIONS
  end

  def self.min_funding_options
    @@MIN_FUNDING_OPTIONS
  end

  def self.funding_options
    @@FUNDING_OPTIONS
  end

  def update_unlimited_param(attribute)
    self[attribute] = -1
    self.save!
  end
  
end
