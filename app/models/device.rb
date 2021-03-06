class Device < ActiveRecord::Base
	belongs_to :workout
	
	has_attached_file :source,
		:storage => ENV['S3_BUCKET'] ? :s3 : :filesystem,
		:s3_credentials => {
			:access_key_id => ENV['S3_KEY'],
			:secret_access_key => ENV['S3_SECRET']
		},
		:bucket => ENV['S3_BUCKET'],
		:path => ":class/:id_partition/:basename.:extension",
		:s3_permissions => "private"

  	validates_attachment_presence :source, :unless => :manual?
		
		
		def manual?
      mfg == "MANUAL"
	  end
	  
	  def zip?
	    source_content_type == "application/zip"
    end
end
