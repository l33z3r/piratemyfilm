class RemoveGreenLightNotificationType < ActiveRecord::Migration
  def self.up
    execute("delete from notifications where notification_type_id in (1, 2);")
  end

  def self.down
  end
end
