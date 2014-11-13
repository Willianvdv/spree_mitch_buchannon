Spree::Order.class_eval do

  # Motivational emails

  def self.orders_that_need_motivation
    # + No future orders
    # + Must have line items
    # + Must not be cancelled

    Spree::Order.where("state != 'complete'")
                .where("email is not null")
                .where('updated_at < ?', 5.hours.ago)
                .where('updated_at > ?', 24.hours.ago)

  end

  def self.send_motivation_emails
    orders_that_need_motivation.each do |order_that_needs_motivation|
      order_that_needs_motivation.send_motivation_email
    end
  end

  def send_motivation_email
    touch :motivation_sent_at
    message = Spree::MotivationMailer.motivation_email(self)
    message.deliver!
  end

  # Payment reminder emails

  def self.payment_reminder_candidates
    orders = Spree::Order.complete
              .where("state != 'canceled'")
              .where("(payment_state is null OR payment_state != 'paid')")
              .where("payment_reminder_sent_at is null")

    orders.keep_if do |order|
      future_orders = Spree::Order.where('completed_at > ?', order.completed_at)
                                  .where(email: order.email)

      reminder_threshold = (order.payments.last.try(:payment_method).try(:reminder_threshold) || 1).hours.ago

      min = reminder_threshold - 1.days
      max = reminder_threshold

      future_orders.empty? && order.completed_at.between?(min, max)
    end
  end

  def send_payment_reminder_email
    touch :payment_reminder_sent_at
    message = Spree::PaymentReminderMailer.payment_reminder_email(self)
    message.deliver!
  end


  def self.send_payment_reminder_emails_to_unpaid_orders
    payment_reminder_candidates.each do |payment_reminder_candidate|
      payment_reminder_candidate.send_payment_reminder_email
    end
  end

  def self.send_motivation_email_to_uncompleted_orders

  end

  # Cancellation of old orders

  def self.cancellation_candidates
    cancellation_canditates = complete
                                .where("payment_state != 'paid'")
                                .where("state != 'canceled'")

    cancellation_canditates.keep_if do |order|
      reminder_threshold = ((order.payments.last.try(:payment_method).try(:reminder_threshold) || 1) * 3).hours.ago

      order.completed_at < reminder_threshold
    end
  end

  def self.cancel_cancellation_candidates
    cancellation_candidates.each do |cancellation_candidate|
      cancellation_candidate.cancel!
    end
  end

  # Override!
  def send_cancel_email
    if completed_at > 30.days.ago
      Spree::OrderMailer.cancel_email(self.id).deliver
    else
      Rails.logger.info "Won't send cancel email because order is older than 30 days"
    end
  end
end
