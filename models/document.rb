require 'friendly_id'

class Document < ActiveRecord::Base  
  belongs_to :university
  belongs_to :professor
  
  extend FriendlyId
  friendly_id :title, :use => :slugged
  
  scope :complete, :conditions => ['professor_id IS NOT NULL']
  scope :staff,    :conditions => ['professor_id IS NULL']
end