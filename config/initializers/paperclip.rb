Paperclip::Attachment.interpolations[:workout] = proc do |attachment, style|
  attachment.instance.workout.id 
end