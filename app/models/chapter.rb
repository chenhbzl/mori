class Chapter < ActiveRecord::Base
  belongs_to :book
  belongs_to :volume
  has_one    :content
  
  def next
    Chapter.find next_id unless next_id.blank?
  end  
  
  def pre
    Chapter.find parent_id unless parent_id.blank?
  end
end