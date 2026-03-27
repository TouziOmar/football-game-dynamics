X <- analysis_tbl %>%
  select(open_game_win, resilience, game_management, clutch_late) %>%
  scale()

pca_res <- prcomp(X)
summary(pca_res)
pca_df <- as.data.frame(pca_res$x)

pca_df <- pca_df %>%
  bind_cols(analysis_tbl %>% select(team_name, total_points))
set.seed(123)

kmeans_res <- kmeans(X, centers = 3)

analysis_tbl$cluster <- kmeans_res$cluster
analysis_tbl %>%
  group_by(cluster) %>%
  summarise(
    open_game = mean(open_game_win),
    resilience = mean(resilience),
    management = mean(game_management),
    clutch = mean(clutch_late),
    avg_points = mean(total_points)
  )

pca_res$rotation

kmeans_res <- kmeans(X, centers = 3)
analysis_tbl$cluster <- kmeans_res$cluster
analysis_tbl %>%
  group_by(cluster) %>%
  summarise(
    open_game = mean(open_game_win),
    resilience = mean(resilience),
    management = mean(game_management),
    clutch = mean(clutch_late),
    points = mean(total_points)
  )



analysis_tbl %>%
  arrange(cluster, desc(total_points)) %>%
  select(cluster, team_name, total_points)

analysis_tbl %>%
  arrange(desc(total_points)) %>%
  slice(1:5) %>%
  select(team_name, total_points, cluster)