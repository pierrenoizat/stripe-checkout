class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin, :corporate, :startup]
  after_initialize :set_default_role, :if => :new_record?
  
  before_save :pay_with_bitcoin, unless: Proc.new { |user| user.admin? }  # executed before before_create callback
  
  before_create :pay_with_card, unless: Proc.new { |user| user.admin? or user.bitcoin }
  
  # after_create :sign_up_for_mailing_list

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
          
          
  def purchased_product?(id)
    
    @product = Product.find_by_id(id)

    @orders = Order.all.select { |m| ((m.email == self.email and m.content == @product.title) and m.status == "paid") }
    purchased = !@orders.blank?
    
  end

  def set_default_role
    self.role ||= :user
    self.bitcoin ||= false
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def pay_with_bitcoin
    
    @orders = Order.order("created_at ASC").all.select { |m| m.email == self.email }

    @order = @orders.last
    @products = Product.all.select { |m| m.title == @order.content }
    @product = @products.last
    self.product_id = @product.id
    
  end

  def pay_with_card
    
    @orders = Order.order("created_at ASC").all.select { |m| m.email == self.email }

    @order = @orders.last

    if @order.pay_type == "card"
    
    if self.stripeToken.nil?
      self.errors[:base] << 'Could not verify card.'
      raise ActiveRecord::RecordInvalid.new(self)
    end
    customer = Stripe::Customer.create(
      :email => self.email,
      :card  => self.stripeToken
    )
    
    price = ((@order.amount*100).to_i > $MIN_STRIPE_AMOUNT ? (@order.amount*100).to_i : $MIN_STRIPE_AMOUNT) # warning: Stripe requires amount to be at least 50 cents
   
    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => "#{price}",  
      :description => "#{@order.content}",
      :currency    => 'eur'
    )
     
    if charge[:paid] == true
      @order.update_attributes(
      :pay_type => 'card',
      :status => 'paid'
      )
      @order.save
    end
    
    # Rails.logger.info("Stripe transaction for #{self.email}") if charge[:paid] == true
  # rescue Stripe::InvalidRequestError => e
    # self.errors[:base] << e.message
    # raise ActiveRecord::RecordInvalid.new(self)
  # rescue Stripe::CardError => e
    # self.errors[:base] << e.message
    # raise ActiveRecord::RecordInvalid.new(self)
    
  end # if
    
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
