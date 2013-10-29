class Spree::PaymentReminderMailer < ActionMailer::Base
  layout 'spree/layouts/email'

  def payment_reminder_mail(order, mail)
    @order = order
    
    mail(to: mail, subject: 'payment reminder') do |format|
      format.html
    end
  end
end