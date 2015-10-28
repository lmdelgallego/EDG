class AdminAbility
  include CanCan::Ability

  def initialize(admin)
    if admin.super?
      can :manage, :all
    else
      can :manage, Admin, id: admin.id
      cannot :index, Admin
      cannot :invite, Admin
      cannot :index, Plan
      can :manage, Grant
      can :manage, Contest, admin_id: admin.id
    end
  end
end
