class AddProjectRatingIdToProjectRatingHistories < ActiveRecord::Migration
  def self.up
    add_column :project_rating_histories, :project_rating_id, :integer

    ProjectRating.find(:all).each do |pr|
      pr.destroy
    end

    ProjectRatingHistory.find(:all).each do |prh|
      prh.destroy
    end
  end

  def self.down
    add_column :project_rating_histories, :project_rating_id
  end
end
