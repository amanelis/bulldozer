class Document < ActiveRecord::Base  
  belongs_to :university, :professor
end