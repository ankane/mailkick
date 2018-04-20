class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome
    mail to: "test@example.org", subject: "Hello"
  end
end
