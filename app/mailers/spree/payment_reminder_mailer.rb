class Spree::PaymentReminderMailer < ActionMailer::Base
  def payment_reminder_email(order)
    @order = order
    
    mail(to: @order.email, subject: t('payment_reminder.payment_reminder_email.subject')) do |format|
      format.html
    end
  end
end 