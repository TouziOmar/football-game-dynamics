fixed_time_points_tbl <- tibble(
  minute = c(0, 31, 61, 76),
  point_type = c("start", "bucket_change", "bucket_change", "bucket_change")
)

team_fixed_points_tbl <- match_teams_tbl %>%
  tidyr::crossing(fixed_time_points_tbl)
team_fixed_points_tbl %>%
  count(fixture_id, team_id)


team_goal_points_tbl <- goal_events_team_view_tbl %>%
  dplyr::select(
    fixture_id,
    team_id,
    team_name,
    opponent_id,
    opponent_name,
    goals_for,
    goals_against,
    points,
    win,
    draw,
    loss,
    minute = match_minute,
    event_team_id,
    event_team_name,
    event_detail,
    goal_for_event,
    goal_against_event
  ) %>%
  mutate(point_type = "goal_event")

team_fixed_points_tbl <- team_fixed_points_tbl %>%
  mutate(
    event_team_id = NA_integer_,
    event_team_name = NA_character_,
    event_detail = NA_character_,
    goal_for_event = 0L,
    goal_against_event = 0L
  )

state_points_tbl <- bind_rows(
  team_fixed_points_tbl,
  team_goal_points_tbl
)

state_points_tbl <- state_points_tbl %>%
  mutate(
    point_priority = case_when(
      point_type == "start" ~ 1L,
      point_type == "bucket_change" ~ 2L,
      point_type == "goal_event" ~ 3L,
      TRUE ~ 99L
    )
  ) %>%
  group_by(fixture_id, team_id) %>%
  arrange(minute, point_priority, .by_group = TRUE) %>%
  mutate(point_order = row_number()) %>%
  ungroup()

state_points_tbl <- state_points_tbl %>%
  group_by(fixture_id, team_id) %>%
  arrange(point_order, .by_group = TRUE) %>%
  mutate(
    goals_for_live = cumsum(goal_for_event),
    goals_against_live = cumsum(goal_against_event)
  ) %>%
  ungroup()

state_points_tbl <- state_points_tbl %>%
  mutate(
    bucket = case_when(
      minute >= 0  & minute <= 30 ~ "T1",
      minute >= 31 & minute <= 60 ~ "T2",
      minute >= 61 & minute <= 75 ~ "T3",
      minute >= 76 ~ "T4",
      TRUE ~ NA_character_
    )
  )

state_points_tbl <- state_points_tbl %>%
  mutate(
    gd_raw = goals_for_live - goals_against_live,
    gd_state = case_when(
      gd_raw <= -2 ~ "-2",
      gd_raw == -1 ~ "-1",
      gd_raw == 0  ~ "0",
      gd_raw == 1  ~ "+1",
      gd_raw >= 2  ~ "+2",
      TRUE ~ NA_character_
    )
  )

state_points_tbl <- state_points_tbl %>%
  mutate(
    state = paste0("(", gd_state, ",", bucket, ")")
  )


state_points_tbl %>%
  count(bucket)

state_points_tbl %>%
  count(gd_state)

state_points_tbl %>%
  count(state, sort = TRUE)


state_points_tbl %>%
  filter(fixture_id == 1378985) %>%
  select(
    fixture_id,
    team_id,
    team_name,
    point_order,
    minute,
    point_type,
    event_detail,
    goal_for_event,
    goal_against_event,
    goals_for_live,
    goals_against_live,
    gd_raw,
    gd_state,
    bucket,
    state
  ) %>%
  arrange(team_id, point_order)

state_points_tbl %>%
  filter(point_type == "start") %>%
  summarise(
    all_start_gf_zero = all(goals_for_live == 0),
    all_start_ga_zero = all(goals_against_live == 0)
  )