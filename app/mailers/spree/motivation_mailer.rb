module Spree
  class MotivationMailer < BaseMailer
    def motivation_email(order)
      @order = order

      mail(to: @order.email, from: from_address, subject: Spree.t('payment_reminder.motivation_email.subject')) do |format|
        format.html
      end
    end
  end
end
