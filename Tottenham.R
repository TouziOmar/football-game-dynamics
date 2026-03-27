tottenham_open <- markov_team_wide_shrunk_corrected_with_n_tbl %>%
  filter(team_name == "Tottenham") %>%
  select(starts_with("Win_0_"))
tottenham_lead <- markov_team_wide_shrunk_corrected_with_n_tbl %>%
  filter(team_name == "Tottenham") %>%
  select(starts_with("Win_p1_"))
tottenham_trail <- markov_team_wide_shrunk_corrected_with_n_tbl %>%
  filter(team_name == "Tottenham") %>%
  select(starts_with("Win_m1_"))
teams_compare <- markov_team_wide_shrunk_corrected_with_n_tbl %>%
  filter(team_name %in% c("Tottenham", "Chelsea"))