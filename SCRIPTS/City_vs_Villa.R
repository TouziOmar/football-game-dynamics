analysis_tbl %>%
  filter(team_name %in% c("Manchester City", "Aston Villa")) %>%
  select(
    team_name,
    total_points,
    open_game_win,
    resilience,
    game_management,
    clutch_late
  )
city_vs_villa <- analysis_tbl %>%
  filter(team_name %in% c("Manchester City", "Aston Villa")) %>%
  select(team_name, open_game_win, resilience, game_management, clutch_late) %>%
  pivot_longer(-team_name, names_to = "metric", values_to = "value") %>%
  pivot_wider(names_from = team_name, values_from = value) %>%
  mutate(diff = `Manchester City` - `Aston Villa`)

city_vs_villa
lm(total_points ~ cluster, data = analysis_tbl)
lm(total_points ~ open_game_win + resilience + game_management + clutch_late, data = analysis_tbl)
lm(total_points ~ open_game_win + resilience + game_management + clutch_late + cluster, data = analysis_tbl)