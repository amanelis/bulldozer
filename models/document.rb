class Document < ActiveRecord::Base  
  belongs_to :university
  belongs_to :professor
end