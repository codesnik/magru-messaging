class AddDeleterToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :deleter_id, :integer
  end

  def self.down
    remove_column :messages, :deleter_id
  end
end
