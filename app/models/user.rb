class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6, maximum: 128 }
  validates :password_confirmation, presence: true
  validates :admin, inclusion: { in: [true, false] }

  has_many :roles, as: :resource
  has_many :businesses, foreign_key: 'user_id', dependent: :destroy
  has_many :business_users
  has_many :businesses, through: :business_users


  scope :admin, -> {where(admin: true)}
  scope :new_user, -> {with_role(:new_user)}
  scope :guest, -> {with_role(:guest)}

  after_create :assign_default_role

  def admin?
    admin
  end

  def assign_default_role
    self.add_role(:new_user) if self.roles.blank?
  end

end
