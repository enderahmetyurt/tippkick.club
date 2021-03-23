require 'test_helper'

class UserRankingServiceTest < ActiveSupport::TestCase
  test '.call!, focus on global ranking' do
    user_1, user_2 = users(:diego, :pele)

    assert_changes -> { user_2.reload.global_ranking_position }, to: 2 do
      assert_changes -> { user_1.reload.global_ranking_position }, to: 1 do
        UserRankingService.new.call!
      end
    end
  end

  test '.call!, focus on accepted memberships' do
    membership_1, membership_2 = memberships(:diego_campeones, :pele_campeones_invited)
    membership_2.accept
    membership_1.update_column(:ranking_position, nil)
    membership_2.update_column(:ranking_position, nil)

    assert_changes -> { membership_2.reload.ranking_position }, to: 2 do
      assert_changes -> { membership_1.reload.ranking_position }, to: 1 do
        UserRankingService.new.call!
      end
    end
  end

  test '.call!, focus on invited memberships' do
    membership = memberships(:pele_campeones_invited)

    assert_no_changes -> { membership.reload.ranking_position } do
      UserRankingService.new.call!
    end
  end
end