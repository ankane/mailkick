class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome
    headers["List-Unsubscribe"] = "custom" if params[:header]
    mail to: "test@example.org", subject: "Hello"
  end
end
