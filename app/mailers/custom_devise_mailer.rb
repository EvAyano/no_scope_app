class CustomDeviseMailer < Devise::Mailer
    default from: 'postmaster@sandboxf2bc592f34f240e38729439757b85352.mailgun.org',
            reply_to: 'noreply@no-scope.com'
  
    layout 'mailer'
  end
  