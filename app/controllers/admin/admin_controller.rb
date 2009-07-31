class Admin::AdminController < ApplicationController

  private

  def allow_to
    super :admin, :all => true
  end
  
end
