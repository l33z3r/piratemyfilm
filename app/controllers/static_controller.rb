class StaticController < ApplicationController

  skip_before_filter :login_required
  
  protected
  
  def allow_to
    super :all, :all => true
  end  

end
