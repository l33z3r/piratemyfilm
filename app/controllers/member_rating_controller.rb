class MemberRatingController < ApplicationController

  skip_before_filter :login_required, :only=> [:pmf_rating]

  def rate
    begin
      @member_id = params[:member_id]
      @member = User.find(@member_id)
          
      #cannot rate yourself
      if @member.id == @u.id
        flash[:error] = "You cannot rate yourself!"
        redirect_to profile_path @member.profile and return
      end

      @my_member_rating = MemberRatingHistory.find_by_member_id_and_rater_id(@member_id, @u.id, :order => "created_at DESC", :limit => "1")

      @beginning_of_day = Time.now.beginning_of_day

      if @my_member_rating && @my_member_rating.created_at > @beginning_of_day
        flash[:error] = "You have already rated this member today!"
        redirect_to profile_path @member.profile and return
      end

      @current_member_rating = MemberRating.find_by_member_id @member_id

      if !@current_member_rating
        @current_member_rating = MemberRating.create(:member => @member, :average_rating => 0)
      end

      #Get all memeber rating historys
      @member_rating_histories = MemberRatingHistory.find_all_by_member_id @member_id
        
      @rating = params[:rating].to_f

      #update the running average
      @alpha = 1.0/(@member_rating_histories.size + 1)
      @current_sample = @rating
      @current_avg = @current_member_rating.average_rating

      #formula for updating running avg
      @new_avg = ((1 - @alpha) * @current_avg) + (@alpha * @current_sample)
        
      @current_member_rating.average_rating = @new_avg
      @current_member_rating.save!

      @member.member_rating = @new_avg
      @member.save!

      #add the new sample
      MemberRatingHistory.create(:member => @member, :rater => @u,
        :member_rating => @current_member_rating, :rating => @rating)
        
      flash[:positive] = "Producer Rated!"

      redirect_to profile_path @member.profile
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error rating producer!"
      redirect_to profile_path @member.profile
    end
  end

  protected

  def allow_to
    super :user, :all => true
  end

end
