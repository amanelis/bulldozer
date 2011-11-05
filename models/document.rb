class Document < ActiveRecord::Base  
  belongs_to :university
  belongs_to :professor
  
  scope :complete, :conditions => ['professor_id IS NOT NULL']
  scope :staff,    :conditions => ['professor_id IS NULL']
end