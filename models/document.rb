class Document < ActiveRecord::Base  
  belongs_to :university
  belongs_to :professor
  
  scope :complete, :conditions => ['professor_id IS NOT NULL']
  scope :staff,    :conditions => ['professor_id IS NULL']
  
  # has_attached_file :upload,
  #   :storage => :s3,
  #   :access_key_id => 'AKIAIZHFNNVBSE4BYUTQ',
  #   :secret_access_key => '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',
  #   :bucket => "frtbcdn",
  #   :path => ":attachment/:id/:style.:extension"
  def self.upload_document_to_s3
    
  end
end