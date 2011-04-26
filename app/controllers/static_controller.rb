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

    @projects_by_genre = []

    Genre.all.each do |genre|
      @count = Project.find_all_public(:conditions => "genre_id = #{genre.id}").size
      @projects_by_genre << [genre.title, @count]
    end

    @projects_by_genre.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    #funding stats
    @total_reservations = Project.find_all_public.size

    #TODO change this to pick up dynamic ipo
    @total_reservations_amount = ProjectSubscription.sum(:amount) * 5

    @total_funds_needed = @total_budget

    @num_funded_projects = Project.all_funded.size
    @total_funded_amount = Project.all_funded_amount

    @pmf_fund_user = User.find(PMF_FUND_ACCOUNT_ID)

    @total_pmf_projects_invested_in = @pmf_fund_user.subscribed_non_funded_projects.length
    @total_pmf_shares_reserved_all_projects = @pmf_fund_user.non_funded_project_subscriptions.sum("amount")

    #TODO pick up dynamically ipo
    @total_pmf_shares_reserved_amount = @total_pmf_shares_reserved_all_projects * 5

    #member stats
    @members_count = User.count(:all)

    @members_by_country = []

    Country.all.each do |country|
      @country_count = Profile.find_all_by_country_id(country).size
      if @country_count > 0
        @members_by_country << [country.name, @country_count]
      end
    end

    @members_by_country.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @members_by_membership_type = []

    MembershipType.all.each do |mt|
      @type_name = mt.name
      @count = User.find(:all, :include => "membership", :conditions => "memberships.membership_type_id = #{mt.id}").size
      @members_by_membership_type << [@type_name, @count]
    end

    @members_by_membership_type.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @num_users_reserving_shares = ProjectSubscription.all.collect(&:user).uniq.size
    @members_reserving_shares_percent = ((@num_users_reserving_shares * 100).to_f/@members_count).ceil
    @avg_number_projects_per_member = (@num_all_projects.to_f / @members_count).ceil
    @avg_number_reservations_per_member = (ProjectSubscription.sum(:amount).to_f/@members_count).ceil

    #top movers that used to be at the top of the site
    @top_sitewide_projects = ProjectChangeInfoOneDay.top_five_change_for_site
    @bottom_sitewide_projects = ProjectChangeInfoOneDay.bottom_five_change_for_site

    #stats moved over from admin section of site
    @signups_yesterday = User.find(:all, :conditions => ['created_at > :date1 and created_at < :date2',
        {:date1 => 2.days.ago.midnight, :date2 => 1.day.ago.midnight}]).size

    @projects_created_yesterday = Project.find(:all, :conditions => ['created_at > :date1 and created_at < :date2',
        {:date1 => 2.days.ago.midnight, :date2 => 1.day.ago.midnight}]).size

  end
  
  protected

  def setup
    
  end

  def allow_to
    super :all, :all => true
  end

end
