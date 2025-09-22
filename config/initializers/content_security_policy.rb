if Rails.env.development?
  Rails.application.config.content_security_policy do |policy|
    policy.default_src :self
    policy.connect_src :self, :http, :https
  end
end
