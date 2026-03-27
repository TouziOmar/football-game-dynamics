transitions_tbl <- state_points_tbl %>%
  group_by(fixture_id, team_id) %>%
  arrange(point_order, .by_group = TRUE) %>%
  mutate(
    minute_from = minute,
    minute_to = lead(minute),
    state_from = state,
    state_to = lead(state),
    point_type_from = point_type,
    point_type_to = lead(point_type)
  ) %>%
  ungroup()

transitions_tbl <- transitions_tbl %>%
  group_by(fixture_id, team_id) %>%
  mutate(
    next_goal_for_event = lead(goal_for_event),
    next_goal_against_event = lead(goal_against_event),
    transition_type = case_when(
      point_type_to == "bucket_change" ~ "time_change",
      point_type_to == "goal_event" & next_goal_for_event == 1L ~ "goal_for",
      point_type_to == "goal_event" & next_goal_against_event == 1L ~ "goal_against",
      TRUE ~ NA_character_
    )
  ) %>%
  ungroup()

transitions_tbl <- transitions_tbl %>%
  mutate(
    duration = minute_to - minute_from
  )

transitions_intermediate_tbl <- transitions_tbl %>%
  filter(!is.na(state_to))

absorbing_transitions_tbl <- state_points_tbl %>%
  group_by(fixture_id, team_id) %>%
  arrange(point_order, .by_group = TRUE) %>%
  slice_tail(n = 1) %>%
  ungroup() %>%
  mutate(
    state_from = state,
    state_to = case_when(
      win == 1 ~ "Win",
      draw == 1 ~ "Draw",
      loss == 1 ~ "Loss",
      TRUE ~ NA_character_
    ),
    minute_from = minute,
    minute_to = pmax(90, minute),
    duration = minute_to - minute_from,
    transition_type = "absorbing"
  ) %>%
  select(
    fixture_id,
    team_id,
    team_name,
    minute_from,
    minute_to,
    duration,
    state_from,
    state_to,
    transition_type
  )

transitions_intermediate_tbl <- transitions_intermediate_tbl %>%
  select(
    fixture_id,
    team_id,
    team_name,
    minute_from,
    minute_to,
    duration,
    state_from,
    state_to,
    transition_type
  )
transitions_final_tbl <- bind_rows(
  transitions_intermediate_tbl,
  absorbing_transitions_tbl
) %>%
  arrange(fixture_id, team_id, minute_from, minute_to)

transitions_final_tbl %>%
  count(transition_type)

transitions_final_tbl %>%
  filter(transition_type == "absorbing") %>%
  count(state_to)
transitions_final_tbl %>%
  filter(fixture_id == 1378985) %>%
  arrange(team_id, minute_from, minute_to)