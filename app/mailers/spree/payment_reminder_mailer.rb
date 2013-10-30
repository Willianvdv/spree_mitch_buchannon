class Spree::PaymentReminderMailer < ActionMailer::Base
    def payment_reminder_email(order)
    @order = order
    
    mail(to: @order.email, subject: 'payment reminder') do |format|
      format.html
    end
  end
end 