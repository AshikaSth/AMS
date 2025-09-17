class Album < ApplicationRecord
  belongs_to :artist
  def music_count
    music.count
end
