class DeleteIndexOnLogin < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :login
  end
end
