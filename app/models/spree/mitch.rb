module Spree
  class Mitch
    def orders_that_need_motivation
      orders = Spree::Order
        .where("state != 'complete'")
        .where("state != 'canceled'")
        .where("email is not null")
        .where('updated_at < ?', 5.hours.ago)
        .where('updated_at > ?', 24.hours.ago)

      orders.keep_if { |order| !order.future_orders? && order.item_total > 0 }
    end

    def send_motivation_emails
      orders_that_need_motivation.map { |order| order.send_motivation_email }
    end

    def payment_reminder_candidates
      orders = Spree::Order
        .complete
        .where("state != 'canceled'")
        .where("(payment_state is null OR payment_state != 'paid')")
        .where("payment_reminder_sent_at is null")

        orders.keep_if do |order|
        payment_methods_reminder_threshold = order.payments.last.try(:payment_method).try(:reminder_threshold) || 1
        reminder_threshold = payment_methods_reminder_threshold.hours.ago

        min = reminder_threshold - 1.days
        max = reminder_threshold

        !order.future_orders? && order.completed_at.between?(min, max)
      end
    end

    def send_payment_reminder_emails_to_unpaid_orders
      payment_reminder_candidates.map { |order| order.send_payment_reminder_email }
    end

    def cancellation_candidates
      cancellation_canditates = Spree::Order
        .complete
        .where("payment_state != 'paid'")
        .where("state != 'canceled'")

      cancellation_canditates.keep_if do |order|
        reminder_threshold = ((order.payments.last.try(:payment_method).try(:reminder_threshold) || 1) * 3).hours.ago

        order.completed_at < reminder_threshold
      end
    end

    def cancel_cancellation_candidates
      cancellation_candidates.each do |cancellation_candidate|
        cancellation_candidate.cancel!
      end
    end
  end
end
