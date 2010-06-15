class StaticController < ApplicationController

  skip_before_filter :login_required
  before_filter :setup

  protected

  def setup
    @hide_filter_params = true
  end

  def allow_to
    super :all, :all => true
  end  

end
