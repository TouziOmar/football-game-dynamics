library(dplyr)

match_teams_tbl <- team_match_mental_features %>%
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
    loss
  ) %>%
  dplyr::distinct()

match_teams_tbl %>%
  count(fixture_id) %>%
  count(n)
goals_tbl <- events_tbl %>%
  dplyr::filter(event_detail %in% c("Normal Goal", "Penalty", "Own Goal"))
dim(goals_tbl)
table(goals_tbl$event_detail)
goals_tbl <- goals_tbl %>%
  mutate(
    event_time_extra = dplyr::coalesce(event_time_extra, 0),
    match_minute = event_time_elapsed + event_time_extra
  )

goal_events_team_view_tbl <- match_teams_tbl %>%
  inner_join(
    goals_tbl %>%
      dplyr::select(
        fixture_id,
        match_minute,
        event_detail,
        event_type,
        team_id,
        team_name,
        player_id,
        player_name
      ) %>%
      rename(
        event_team_id = team_id,
        event_team_name = team_name
      ),
    by = "fixture_id"
  )

goal_events_team_view_tbl <- goal_events_team_view_tbl %>%
  mutate(
    goal_for_event = if_else(event_team_id == team_id, 1L, 0L),
    goal_against_event = if_else(event_team_id != team_id, 1L, 0L)
  )

goal_events_team_view_tbl %>%
  mutate(check_sum = goal_for_event + goal_against_event) %>%
  count(check_sum)
goal_events_team_view_tbl <- goal_events_team_view_tbl %>%
  group_by(fixture_id, team_id) %>%
  arrange(match_minute, .by_group = TRUE) %>%
  mutate(event_order_in_team_match = row_number()) %>%
  ungroup()

goal_events_team_view_tbl <- goal_events_team_view_tbl %>%
  group_by(fixture_id, team_id) %>%
  arrange(event_order_in_team_match, .by_group = TRUE) %>%
  mutate(
    goals_for_live = cumsum(goal_for_event),
    goals_against_live = cumsum(goal_against_event)
  ) %>%
  ungroup()

goal_events_team_view_tbl %>%
  mutate(check_sum = goal_for_event + goal_against_event) %>%
  count(check_sum)

score_check_tbl <- goal_events_team_view_tbl %>%
  group_by(fixture_id, team_id) %>%
  filter(event_order_in_team_match == max(event_order_in_team_match)) %>%
  ungroup() %>%
  transmute(
    fixture_id,
    team_id,
    team_name,
    goals_for_live,
    goals_against_live,
    goals_for_official = goals_for,
    goals_against_official = goals_against,
    gf_ok = goals_for_live == goals_for_official,
    ga_ok = goals_against_live == goals_against_official
  )

score_check_tbl %>%
  summarise(
    all_gf_ok = all(gf_ok),
    all_ga_ok = all(ga_ok),
    n_bad_gf = sum(!gf_ok),
    n_bad_ga = sum(!ga_ok)
  )