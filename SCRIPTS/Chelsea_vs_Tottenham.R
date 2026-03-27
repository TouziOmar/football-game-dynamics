analysis_tbl %>%
  filter(team_name %in% c("Chelsea", "Tottenham")) %>%
  select(
    team_name,
    total_points,
    open_game_win,
    resilience,
    game_management,
    clutch_late
  )
chelsea_vs_tottenham <- analysis_tbl %>%
  filter(team_name %in% c("Chelsea", "Tottenham")) %>%
  select(team_name, open_game_win, resilience, game_management, clutch_late) %>%
  pivot_longer(-team_name, names_to = "metric", values_to = "value") %>%
  pivot_wider(names_from = team_name, values_from = value) %>%
  mutate(diff = Chelsea - Tottenham)

chelsea_vs_tottenham