class TeamMembershipRowComponent < ViewComponent::Base
  def initialize(team_membership_row:, user: nil)
    @team_membership_row = team_membership_row
    @user = user
  end

  def bg_color_class
    return 'bg-blue-300' if team_membership_of_user?
  end

  private

  def team_membership_of_user?
    @team_membership_row.user == @user
  end
end
