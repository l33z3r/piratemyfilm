class StaticController < ApplicationController
  
  protected
  
  def allow_to
    super :all, :all => true
  end  

end
