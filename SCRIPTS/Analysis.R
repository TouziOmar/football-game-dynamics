library(dplyr)

analysis_tbl <- markov_team_wide_shrunk_corrected_with_n_tbl %>%
  left_join(
    team_mental_summary %>%
      select(team_id, team_name, total_points),
    by = c("team_id", "team_name")
  )

analysis_tbl <- analysis_tbl %>%
  mutate(
    open_game_win = rowMeans(
      select(., Win_0_T1, Win_0_T2, Win_0_T3, Win_0_T4),
      na.rm = TRUE
    )
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    avoid_loss_m1_T1 = Win_m1_T1 + Draw_m1_T1,
    avoid_loss_m1_T2 = Win_m1_T2 + Draw_m1_T2,
    avoid_loss_m1_T3 = Win_m1_T3 + Draw_m1_T3,
    avoid_loss_m1_T4 = Win_m1_T4 + Draw_m1_T4,
    
    avoid_loss_m2_T1 = Win_m2_T1 + Draw_m2_T1,
    avoid_loss_m2_T2 = Win_m2_T2 + Draw_m2_T2,
    avoid_loss_m2_T3 = Win_m2_T3 + Draw_m2_T3,
    avoid_loss_m2_T4 = Win_m2_T4 + Draw_m2_T4
  ) %>%
  mutate(
    resilience = rowMeans(
      select(
        .,
        avoid_loss_m1_T1, avoid_loss_m1_T2, avoid_loss_m1_T3, avoid_loss_m1_T4,
        avoid_loss_m2_T1, avoid_loss_m2_T2, avoid_loss_m2_T3, avoid_loss_m2_T4
      ),
      na.rm = TRUE
    )
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    game_management = rowMeans(
      select(
        .,
        Win_p1_T1, Win_p1_T2, Win_p1_T3, Win_p1_T4,
        Win_p2_T1, Win_p2_T2, Win_p2_T3, Win_p2_T4
      ),
      na.rm = TRUE
    )
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    clutch_late = rowMeans(
      select(
        .,
        Win_0_T4,
        avoid_loss_m1_T4, avoid_loss_m2_T4,
        Win_p1_T4, Win_p2_T4
      ),
      na.rm = TRUE
    )
  )
analysis_tbl %>%
  summarise(
    cor_open_game = cor(open_game_win, total_points, method = "spearman"),
    cor_resilience = cor(resilience, total_points, method = "spearman"),
    cor_game_management = cor(game_management, total_points, method = "spearman"),
    cor_clutch_late = cor(clutch_late, total_points, method = "spearman")
  )
analysis_tbl <- analysis_tbl %>%
  arrange(desc(total_points)) %>%
  mutate(
    rank_points = row_number(),
    group = case_when(
      rank_points <= 5 ~ "Top 5",
      rank_points > n() - 5 ~ "Bottom 5",
      TRUE ~ "Middle"
    )
  )
analysis_tbl %>%
  filter(group %in% c("Top 5", "Bottom 5")) %>%
  group_by(group) %>%
  summarise(
    open_game_win = mean(open_game_win, na.rm = TRUE),
    resilience = mean(resilience, na.rm = TRUE),
    game_management = mean(game_management, na.rm = TRUE),
    clutch_late = mean(clutch_late, na.rm = TRUE)
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    delta_open = Win_0_T4 - Win_0_T1
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    delta_resilience_m1 = avoid_loss_m1_T4 - avoid_loss_m1_T1,
    delta_resilience_m2 = avoid_loss_m2_T4 - avoid_loss_m2_T1,
    delta_resilience = (delta_resilience_m1 + delta_resilience_m2) / 2
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    delta_lead_p1 = Win_p1_T4 - Win_p1_T1,
    delta_lead_p2 = Win_p2_T4 - Win_p2_T1,
    delta_lead = (delta_lead_p1 + delta_lead_p2) / 2
  )
analysis_tbl %>%
  summarise(
    cor_delta_open = cor(delta_open, total_points, method = "spearman"),
    cor_delta_resilience = cor(delta_resilience, total_points, method = "spearman"),
    cor_delta_lead = cor(delta_lead, total_points, method = "spearman")
  )
final_summary_tbl <- analysis_tbl %>%
  select(
    team_id, team_name, total_points,
    open_game_win,
    resilience,
    game_management,
    clutch_late,
    delta_open,
    delta_resilience,
    delta_lead
  ) %>%
  arrange(desc(total_points))
final_summary_tbl

cor(Win_0_T1, total_points)
cor(Win_0_T4, total_points)