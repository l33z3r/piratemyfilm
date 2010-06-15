class TruncateProjectDescription < ActiveRecord::Migration
  def self.up
    @projects = Project.find(:all, :conditions => ['length(description) > 140'])

    @projects.each do |@p|
      @p.description = @p.description.truncate(140)
      @p.save!
    end

  end

  def self.down
  end
end
