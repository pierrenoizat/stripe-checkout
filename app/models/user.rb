class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?
  before_create :pay_with_card, unless: Proc.new { |user| user.admin? }
  after_create :sign_up_for_mailing_list

  has_many :orders
  attr_accessor :stripeToken
  
  COUNTRIES = ["Afghanistan","Albania", "Algeria","Andorra", "Angola",
          "Argentina", "Armenia", "Australia", "Austria",
          "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Belarus", "Belgium", "Belize", "Benin",
          "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Brazil",
          "Bulgaria", "Burkina Faso", "Burundi", "Cambodia",
          "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Chad", "Chile", "China",
          "Colombia", "Congo", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba",
          "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominican Republic", "Ecuador", "Egypt",
          "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia",
          "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia",
          "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", 
          "Grenada", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti",
          "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq",
          "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya",
          "Korea, Democratic People's Republic of", "Korea", "Kuwait", "Kyrgyzstan",
          "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia",
          "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", 
          "Mali", "Malta","Mauritania", "Mauritius", "Mexico", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", 
          "Mozambique", "Myanmar",  "Namibia", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", 
          "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Panama", "Paraguay", "Peru", "Philippines",
          "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "San Marino",
          "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
          "Slovakia", "Slovenia", "Somalia", "South Africa", "Spain", "Sri Lanka", "Sudan", 
          "Swaziland", "Sweden", "Switzerland", "Taiwan", "Tajikistan", "Tanzania", "Thailand",
          "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
          "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom",
          "United States", "Uruguay", "Uzbekistan", "Venezuela", "Viet Nam", "Zambia", "Zimbabwe"]

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def pay_with_card
    
    @orders = Order.order("created_at ASC").all.select { |m| m.email == self.email }
    @order = @orders.last
    
    if self.stripeToken.nil?
      self.errors[:base] << 'Could not verify card.'
      raise ActiveRecord::RecordInvalid.new(self)
    end
    customer = Stripe::Customer.create(
      :email => self.email,
      :card  => self.stripeToken
    )
    price = Rails.application.secrets.product_price
    title = Rails.application.secrets.product_title
    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => "#{price}",
      :description => "#{title}",
      :currency    => 'usd'
    )
     
    if charge[:paid] == true
      @order.update_attributes(
      :user_id => charge[:customer],
      :balance      => 0,
      :content => "#{title}",
      :currency    => 'usd',
      :pay_type => 'card'
      )

    end
    
    Rails.logger.info("Stripe transaction for #{self.email}") if charge[:paid] == true
  rescue Stripe::InvalidRequestError => e
    self.errors[:base] << e.message
    raise ActiveRecord::RecordInvalid.new(self)
  rescue Stripe::CardError => e
    self.errors[:base] << e.message
    raise ActiveRecord::RecordInvalid.new(self)
  end

  def sign_up_for_mailing_list
    MailingListSignupJob.perform_later(self)
  end

  def subscribe
    mailchimp = Gibbon::API.new(Rails.application.secrets.mailchimp_api_key)
    result = mailchimp.lists.subscribe({
      :id => Rails.application.secrets.mailchimp_list_id,
      :email => {:email => self.email},
      :double_optin => false,
      :update_existing => true,
      :send_welcome => true
    })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  end

end
