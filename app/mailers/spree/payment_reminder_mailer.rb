module Spree
  class PaymentReminderMailer < BaseMailer
    def payment_reminder_email(order)
      @order = order
      
      mail(to: @order.email, from: from_address, subject: t('payment_reminder.payment_reminder_email.subject')) do |format|
        format.html
      end
    end
  end
end
