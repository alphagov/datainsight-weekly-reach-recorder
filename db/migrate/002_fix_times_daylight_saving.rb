require "datainsight_recorder/migrations"

migration 2, :fix_times_daylight_saving do
  up do
    execute "UPDATE weekly_reach_models SET start_at=ADDTIME(start_at, '-01:00:00') WHERE start_at > '2013-03-31 00:00:00' AND start_at <= '2013-10-27 00:00:00' AND HOUR(start_at) = 0"
    execute "UPDATE weekly_reach_models SET end_at=ADDTIME(end_at, '-01:00:00') WHERE end_at > '2013-03-31 00:00:00' AND end_at <= '2013-10-27 00:00:00' AND HOUR(end_at) = 0"
  end

  down do
    execute "UPDATE weekly_reach_models SET start_at=ADDTIME(start_at, '+01:00:00') WHERE start_at > '2013-03-30 23:00:00' AND start_at <= '2013-10-26 23:00:00' AND HOUR(start_at) = 23"
    execute "UPDATE weekly_reach_models SET end_at=ADDTIME(end_at, '+01:00:00') WHERE end_at >'2013-03-30 23:00:00' AND end_at <= '2013-20-26 23:00:00' AND HOUR(end_at) = 23"
  end
end
