class VmvMailer < ApplicationMailer
    #add_template_helper(ApplicationHelper)
  #helpers :application
  helper ApplicationHelper

  default from: "mehmet.alsadi@gmail.com"

  def sample_email(receiver)
    puts "the mail will be sent to "
    puts receiver
    mail(to: receiver, subject: 'Verify My Vote Login Credential')
  end

  def blockchain_email(receiver)
    puts "the mail will be sent to "
    puts receiver
    mail(to: receiver, subject: 'Vote Record')
  end

  def verification_email(receiver)
    puts "the mail will be sent to "
    puts receiver
    mail(to: receiver, subject: 'Vote Verification')
  end
end
