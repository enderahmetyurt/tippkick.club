require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test '51 games' do
    assert_equal 1, Game.final_phase.count
    assert_equal 2, Game.semi_finals_phase.count
    assert_equal 4, Game.quarter_finals_phase.count
    assert_equal 8, Game.round_of_16_phase.count
    assert_equal 36, Game.group_phase.count
    assert_equal 51, Game.count
  end

  test 'validate final_whistle_is_after_kickoff' do
    game = games(:game_25)

    travel_to game.kickoff_at do
      assert_not game.final_whistle

      assert_includes game.errors[:final_whistle_at], 'cannot be before kickoff'
    end

    travel_to game.kickoff_at + 1.second do
      assert_changes -> { game.reload.final_whistle_at }, from: nil do
        assert game.final_whistle
      end
    end
  end

  test 'validate scores_cannot_change_before_kickoff' do
    game = games(:game_25)

    travel_to game.kickoff_at do
      assert_not game.update(home_team_score: 9, guest_team_score: 9)

      assert_includes game.errors[:home_team_score], 'cannot be changed before kickoff'
      assert_includes game.errors[:guest_team_score], 'cannot be changed before kickoff'
    end

    travel_to game.kickoff_at + 1.second do
      assert game.update(home_team_score: 9, guest_team_score: 9)
    end
  end

  test '#final_whistle' do
    game = games(:game_25)
    travel_to '2021-06-20 17:45:00 UTC' do
      assert_changes -> { game.reload.final_whistle_at }, from: nil do
        game.final_whistle
      end

      assert_changes -> { game.reload.final_whistle_at }, to: nil do
        game.final_whistle(reset: true)
      end
    end
  end

  test '#live?' do
    game = games(:game_25)
    travel_to '2021-06-20 16:00:00 UTC' do
      assert_not game.live?
    end

    travel_to '2021-06-20 16:00:01 UTC' do
      assert game.live?
      game.final_whistle
      assert_not game.live?
    end
  end

  test '#kickoff_past?' do
    game = games(:game_25)
    travel_to '2021-06-20 16:00:00 UTC' do
      assert_not game.kickoff_past?
    end

    travel_to '2021-06-20 16:00:01 UTC' do
      assert game.kickoff_past?
    end
  end

  test '#kickoff_future?' do
    game = games(:game_25)
    travel_to '2021-06-20 15:59:59 UTC' do
      assert game.kickoff_future?
    end

    travel_to '2021-06-20 16:00:00 UTC' do
      assert_not game.kickoff_future?
    end
  end
end
