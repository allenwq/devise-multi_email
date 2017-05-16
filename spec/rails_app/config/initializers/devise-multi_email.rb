
Devise::MultiEmail.configure do |config|
  # specify this for backwards-compatibility
  config.primary_email_method_name = :primary_email_record
end
