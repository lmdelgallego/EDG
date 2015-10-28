class Membership < ActiveRecord::Base
  belongs_to :user
 attr_accessor :stripe_token, :referer_path, :mode
	before_update :stripe_membership
  belongs_to :plan

 def stripe_membership
  puts stripe_token
    if stripe_token.present?
      @plan = Plan.find_by_name('Premium')
      if mode == "m" 
        cent_amount = @plan.price.to_i * 100 
        date = Time.zone.now + 1.month
      elsif mode == "a"
        cent_amount = @plan.anual_price.to_i * 100
        date = Time.zone.now + 1.year
      end

      customer = Stripe::Customer.create(
        :card => stripe_token,
        :email => self.user.email,
        :description => "Subscription payment  - #{cent_amount} dollars."
      )
      Stripe::Charge.create(
        :amount => cent_amount, # in cents
        :currency => "usd",
        :customer => customer.id
      )
      self.stripe_customer_id = customer.id
      self.status = true
      self.stripe_token = nil
      self.expiration_date = date
      self.plan_id = @plan.id
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "There was an error while charging your credit card. #{e.message}"
    false
  end

  class << self

    def finish_memberships
      puts "Change memberships"
      today = Time.zone.now.beginning_of_day
      Membership.where(plan_id: 2).rewhere(status: true).each do |member|
        if member.expiration_date
          member.update(expiration_date: nil, plan_id: 1) if member.expiration_date <= today
        end
      end
    end
    handle_asynchronously :finish_memberships
  end

end
