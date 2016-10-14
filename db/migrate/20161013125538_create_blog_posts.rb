class CreateBlogPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :path

      t.belongs_to :company, foreign_key: true

      t.timestamps
    end
  end
end
