class Genre < ActiveRecord::Base
  
  has_many :projects
  
end
