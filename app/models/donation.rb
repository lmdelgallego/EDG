class Donation < ActiveRecord::Base
  validates :user_id, :amount, presence: true
  
  belongs_to :user
  
  attr_accessor :stripe_token

  scope :successful, -> { where(status: 'ok') }
  scope :total_amount, -> { successful.sum(:amount) }
  scope :this_month, -> { successful.where('created_at >= ? ', 1.month.ago) }
  scope :this_week, -> { successful.where('created_at >= ? ', 1.week.ago) }
  
  def save_with_payment
    if valid?
      save
      if !stripe_token.present?
        raise "We're doing something wrong -- this isn't supposed to happen"
      end
      
      cent_amount = amount.to_i * 100
      customer = Stripe::Customer.create(
        :card => stripe_token,
        :email => self.user.email,
        :description => "One time donation - #{amount} dollars."
      )
    
      # Charge the Customer instead of the card
      Stripe::Charge.create(
        :amount => cent_amount, # in cents
        :currency => "usd",
        :customer => customer.id
      )

      self.stripe_customer_id = customer.id
      self.stripe_token = nil
      save
    end
  rescue Stripe::StripeError => e
    self.status = "error"
    save
    logger.error "Stripe Error: " + e.message
    errors.add :base, "There was an error while charging your credit card. #{e.message}"
    false
  end
  
end
