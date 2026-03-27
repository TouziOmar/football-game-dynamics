analysis_tbl <- analysis_tbl %>%
  mutate(
    open_game_no_T1 = rowMeans(
      select(., Win_0_T2, Win_0_T3, Win_0_T4),
      na.rm = TRUE
    )
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    resilience_no_T1 = rowMeans(
      select(
        .,
        avoid_loss_m1_T2, avoid_loss_m1_T3, avoid_loss_m1_T4,
        avoid_loss_m2_T2, avoid_loss_m2_T3, avoid_loss_m2_T4
      ),
      na.rm = TRUE
    )
  )
analysis_tbl <- analysis_tbl %>%
  mutate(
    game_management_no_T1 = rowMeans(
      select(
        .,
        Win_p1_T2, Win_p1_T3, Win_p1_T4,
        Win_p2_T2, Win_p2_T3, Win_p2_T4
      ),
      na.rm = TRUE
    )
  )
analysis_tbl %>%
  summarise(
    cor_open_no_T1 = cor(open_game_no_T1, total_points, method = "spearman"),
    cor_resilience_no_T1 = cor(resilience_no_T1, total_points, method = "spearman"),
    cor_management_no_T1 = cor(game_management_no_T1, total_points, method = "spearman")
  )