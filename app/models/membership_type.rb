class MembershipType < ActiveRecord::Base
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  #options for select as they will appear in the view:
  @@SELECT_OPTIONS = 
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30, 
    35, 40, 45, 50, 100, 200, 500, 1000, 10000, 
    2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 100000]
  
  @@MIN_FUNDING_OPTIONS = 
    [0, 100, 200, 300, 400, 500, 1000, 2000, 3000, 5000]
  
  @@FUNDING_OPTIONS = 
    [5000, 10000, 15000, 20000, 25000, 30000, 40000, 50000,
    75000, 100000, 250000, 500000, 1000000]

  #here we are validating presence of membership_type name, we are also ensuring
  #that this attribute is inaccessible. This improves security by ensuring that
  #new membership types cannot be created
  
  validates_presence_of :name
  attr_accessible :max_projects_listed, :min_funding_limit_per_project,
    :funding_limit_per_project, :pc_limit, :pc_project_limit

  def sort_val
    return 1 if self.name == "Basic"
    return 2 if self.name == "Gold"
    return 3 if self.name == "Platinum"
    return 4 if self.name == "Black Pearl"
  end
  
  def self.select_options
    @@SELECT_OPTIONS
  end

  def self.min_funding_options
    @@MIN_FUNDING_OPTIONS
  end

  def self.funding_options
    @@FUNDING_OPTIONS
  end

  def self.membership_select_opts include_all=true
    @membership_select_opts = []

    @membership_types = find(:all)

    @membership_types.each do |@mt|
      @membership_select_opts << [@mt.name, @mt.id.to_s]
    end

    if include_all
      @membership_select_opts.unshift(["All", "0"])
    end
    
    @membership_select_opts
  end
  
end








# == Schema Information
#
# Table name: membership_types
#
#  id                            :integer(4)      not null, primary key
#  name                          :string(255)
#  max_projects_listed           :integer(4)
#  pc_limit                      :integer(4)
#  pc_project_limit              :integer(4)
#  funding_limit_per_project     :integer(4)
#  created_at                    :datetime
#  updated_at                    :datetime
#  min_funding_limit_per_project :integer(4)      default(0)
#

