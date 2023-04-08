# This runner is based on the last part of this rake task: `rake mastodon:setup`
return if User.any?

User.new(
  email: ENV['ADMIN_EMAIL'], password: ENV['ADMIN_PASSWORD'],
  confirmed_at: Time.now.utc, bypass_invite_request_check: true,
  role: UserRole.find_by(name: 'Owner'),
  account_attributes: { username: ENV['ADMIN_USERNAME'] }
).save(validate: false)
Setting.site_contact_username = ENV['ADMIN_USERNAME'] # what does this even do and does it persist?
