class AddLinkSignedInAtToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :link_signed_in_at, :datetime
  end
end
