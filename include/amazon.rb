class AmazonS3Asset
  
  include AWS::S3
  S3ID = "AKIAIZHFNNVBSE4BYUTQ"
  S3KEY = "ibnk9H9U5+wva9wn1A/2OtcEJ7h+hmMRfRmX5WuN"
  
  def initialize
    puts "Connecting to Amazon..."
    if AWS::S3::Base.connected? == false
      AWS::S3::Base.establish_connection!(
        :access_key_id     => S3ID,
        :secret_access_key => S3KEY
      )
    end
  end

  def delete_key(bucket, key)
    if exists?(bucket, key) 
      S3Object.delete key, bucket
    end
  end
  
  def empty_bucket(bucket)
    bucket_keys(bucket).each do |k|
      puts "deleting #{k}"
      delete_key(bucket,k)
    end
  end
  
  def bucket_keys(bucket)
    b = Bucket.find(bucket)
    b.objects.collect {|o| o.key}
  end

  def copy_over_bucket(from_bucket, to_bucket)
    puts "Replacing #{to_bucket} with contents of #{from_bucket}"
    #delete to_bucket
    empty_bucket(to_bucket)
    bucket_keys(from_bucket).each do |k|
      copy_between_buckets(from_bucket, to_bucket, k)
    end
  end
  
  def copy_between_buckets(from_bucket, to_bucket, from_key, to_key = nil)
    if exists?(from_bucket, from_key)
      to_key = from_key if to_key.nil?
      puts "Copying #{from_bucket}.#{from_key} to #{to_bucket}.#{to_key}"
      url = "http://s3.amazonaws.com/#{from_bucket}/#{from_key}"
      filename = download(url)
      store_file(to_bucket,to_key,filename)
      File.delete(filename)
      return "http://s3.amazonaws.com/#{to_bucket}/#{to_key}"
    else
      puts "#{from_bucket}.#{from_key} didn't exist"
      return nil
    end
  end

  def store_file(filename, url, bucket, content)
    # S3Object.store(
    #   key,
    #   File.open(filename),
    #   bucket,
    #   :access => :public_read
    # )
    # puts "  ----> AmazonS3Asset.store_file"
    # puts "  ----> filename: #{filename}"
    # puts "  ----> url: #{url}"
    # puts "  ----> bucket: #{bucket}"
    # puts "  ----> content: #{content}"    
    
    o = S3Object.store(
         filename,
         open(url),
         bucket,
         :content_type => content,
         :access => :public_read
       )
    u = S3Object.url_for(File.basename(filename), bucket)[/[^?]+/]
    
    result = {:s3_response => o, :s3_url => u}
    result
  end

  def download(url, save_as = nil)
    if save_as.nil?
      Dir.mkdir("amazon_s3_temp") if !File.exists?("amazon_s3_temp")
      save_as = File.join("amazon_s3_temp",File.basename(url))
    end
    begin
      puts "Saving #{url} to #{save_as}"
      agent = WWW::Mechanize.new {|a| a.log = Logger.new(STDERR) }
      img = agent.get(url)
      img.save_as(save_as)
      return save_as
    rescue
      raise "Failed on " + url + "  " + save_as
    end
  end

  def exists?(bucket,key)
    begin
      res = S3Object.find key, bucket
    rescue 
      res = nil
    end
    return !res.nil?
  end
      
end