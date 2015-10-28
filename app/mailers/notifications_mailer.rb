class NotificationsMailer < ActionMailer::Base
  default from: "admin@contagiousideas.com"
  
  # def new_contest_entry_admin(contest, entry)
  #   @admin = contest.admin
  #   @contest = contest
  #   @entry = entry
  #   mail to: @admin.email, subject: "There is a new entry for your contest #{@contest.name}"
  # end
  
  # def new_contest_entry_participant(contest, entry)
  #   @user = entry.user
  #   @contest = contest
  #   @entry = entry
  #   mail to: @user.email, subject: "Thank you for participating in #{@contest.name}"
  # end

  def new_donation_user(user)
    @user = user
    mail to: @user.email, subject: "Thank you :)"
  end

  def new_donation_superadmin
    @admin = Admin.where(super: true).first
    mail to: @admin.email, subject: "New donation on the site"
  end

  def winner_entry_user(grant)
    puts "mailer"
    @grant = grant
    @user = grant.user
    @contest = grant.contest
    @entry = grant.entry
    mail to: @user.email, subject: "Your entry is the winner on the contest #{@contest.name}"
  end

  def contest_will_close_soon(contest)
    @admin = contest.admin
    @contest = contest
    mail to: @admin.email, subject: "Your contest #{@contest.name} will end soon" 
  end

  def contest_closed(contest) 
    @admin = contest.admin
    @contest = contest
    mail to: @admin.email, subject: "Your contest #{@contest.name} will end soon" 
  end

  def new_contact_message(to_email, from_email, name, message)
    @from_email = from_email
    @name = name
    @message = message
    mail to: to_email, subject: "New contact message"
  end

  def premium_account(user)
    @user = user
    @name = user.full_name
    mail to: @user.email, subject: "Now you are premium user."
  end

  def share_private_contest(message, username, email, contest)
    @message = message
    @contest = contest 
    @username = username
    mail to: email, subject: "Contagious Ideas share a contest with you"
  end

  def user_new_entries(entries, days_ago, user)
    @entries = entries
    @days_ago = days_ago 
    @user = user
    @contests = @user.contests
    mail to: user.email, subject: "Thank you for participating in Contagious Ideas."
  end

  def new_entries_to_admin(contests, admin, days_ago)
    @admin = admin
    @contests = contests
    @days_ago = days_ago
    mail to: @admin.email, subject: "There are new entries for your contests"
  end

end
