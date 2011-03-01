class StaticController < ApplicationController

  skip_before_filter :login_required
  before_filter :setup

  def stats
    @num_all_projects = Project.find_all_public.size
    
    #project stats
    @projects_listed_count = @num_all_projects
    @total_budget = Project.find_all_public.sum(&:capital_required)
    @avg_budget = (Project.find_all_public.sum(&:capital_required).to_f/@num_all_projects).ceil

    #TODO change this to pick up dynamic ipo
    @total_reservations_dollar_amount = ProjectSubscription.sum(:amount) * 5

    @avg_funding_percent = (Project.find_all_public.sum(&:percent_funded).to_f/@num_all_projects).ceil
    @avg_shares_reserved_per_project = (ProjectSubscription.sum(:amount).to_f/@num_all_projects).ceil

    @total_ups = ProjectChangeInfoOneDay.total_today_ups
    @total_downs = ProjectChangeInfoOneDay.total_today_downs
    @total_volume = ProjectChangeInfoOneDay.total_today_volume
    
    #member stats
    @members_count = User.count(:all)
    @num_users_reserving_shares = ProjectSubscription.all.collect(&:user).uniq.size
    @members_reserving_shares_percent = ((@num_users_reserving_shares * 100).to_f/@members_count).ceil
    @avg_number_projects_per_member = (@num_all_projects.to_f / @members_count).ceil
    @avg_number_reservations_per_member = (ProjectSubscription.sum(:amount).to_f/@members_count).ceil
  end
  
  protected

  def setup
    
  end

  def allow_to
    super :all, :all => true
  end  

end
