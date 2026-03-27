📌 Project Overview

This project aims to understand what drives team performance in football by modeling matches as dynamic processes rather than static statistics.

Instead of relying on traditional metrics (goals, possession, xG), we analyze how teams convert match situations (game states) into final outcomes (win, draw, loss).

A football match is modeled as a sequence of states defined by score difference and match timing, and performance is measured by how efficiently teams transform these states into points.

🧠 Research Question

What game situations and behaviors best explain team performance in terms of league points?

Sub-questions addressed:
Is winning “open games” (when the score is level) the key factor?
Does timing (early vs late performance) matter?
How important is resilience (ability to recover when trailing)?
Are top teams homogeneous or do multiple performance profiles exist?
How do teams actually lose points?
⚙️ Methodology
1. Game State Construction

Each match is broken down into discrete states defined by:

Goal difference: -2, -1, 0, +1, +2
Match period: T1, T2, T3, T4

→ Total of 20 possible states

2. Markov Model

Matches are modeled as absorbing Markov chains:

Transient states → game situations
Absorbing states → Win / Draw / Loss

We compute:

The probability of finishing in each outcome given any game state.

3. Team-Level Models

Each team has its own transition and absorption matrix.

However, due to limited observations in some states, raw probabilities can be unstable.

4. Shrinkage (Regularization)

To improve robustness, we apply shrinkage toward the global model:

Combines team-specific and league-wide probabilities
Eliminates extreme values (0 or 1)
Improves stability

Result:

Correlation raw vs shrunk ≈ 0.88
5. Final Dataset

Each team is represented by:

Win / Draw / Loss probabilities for each state
Number of observations per state
Aggregated performance indicators
📈 Key Findings
🔑 1. The Main Driver of Performance

The strongest predictors of points are:

Win_0_T2 → 0.986
Win_0_T1 → 0.977

👉 This leads to the main conclusion:

The ability to win “open games” (when the score is level) is the primary determinant of success.
📌 Project Overview

This project aims to understand what drives team performance in football by modeling matches as dynamic processes rather than static statistics.

Instead of relying on traditional metrics (goals, possession, xG), we analyze how teams convert match situations (game states) into final outcomes (win, draw, loss).

A football match is modeled as a sequence of states defined by score difference and match timing, and performance is measured by how efficiently teams transform these states into points.

🧠 Research Question

What game situations and behaviors best explain team performance in terms of league points?

Sub-questions addressed:
Is winning “open games” (when the score is level) the key factor?
Does timing (early vs late performance) matter?
How important is resilience (ability to recover when trailing)?
Are top teams homogeneous or do multiple performance profiles exist?
How do teams actually lose points?
⚙️ Methodology
1. Game State Construction

Each match is broken down into discrete states defined by:

Goal difference: -2, -1, 0, +1, +2
Match period: T1, T2, T3, T4

→ Total of 20 possible states

2. Markov Model

Matches are modeled as absorbing Markov chains:

Transient states → game situations
Absorbing states → Win / Draw / Loss

We compute:

The probability of finishing in each outcome given any game state.

3. Team-Level Models

Each team has its own transition and absorption matrix.

However, due to limited observations in some states, raw probabilities can be unstable.

4. Shrinkage (Regularization)

To improve robustness, we apply shrinkage toward the global model:

Combines team-specific and league-wide probabilities
Eliminates extreme values (0 or 1)
Improves stability

Result:

Correlation raw vs shrunk ≈ 0.88
5. Final Dataset

Each team is represented by:

Win / Draw / Loss probabilities for each state
Number of observations per state
Aggregated performance indicators
📈 Key Findings
🔑 1. The Main Driver of Performance

The strongest predictors of points are:

Win_0_T2 → 0.986
Win_0_T1 → 0.977

👉 This leads to the main conclusion:

The ability to win “open games” (when the score is level) is the primary determinant of success.
Timing Effects

We analyzed performance differences between early and late match periods:

Delta Open Game → -0.480
Delta Resilience → -0.502

👉 Interpretation:

Strong teams perform better early in the match rather than relying on late-game performance.

🧪 Robustness Check

Removing early match data (T1):

Open game correlation → 0.886

👉 The model remains stable → results are not driven by early-game bias.

📉 Principal Component Analysis (PCA)

Four main components were identified:

PC1 → Overall team strength
PC2 → Resilience vs game management
PC3 → Open game performance
PC4 → Clutch performance

👉 Performance is multi-dimensional, not driven by a single factor.

🧩 Clustering (Team Profiles)

Teams were grouped into 3 clusters:

Cluster	Avg Points	Profile
1	51.4	Dominant teams
2	48.2	Balanced teams
3	28.6	Weak teams
Top Teams Distribution
Arsenal → Cluster 1
Aston Villa → Cluster 1
Manchester City → Cluster 2
Manchester United → Cluster 2
Liverpool → Cluster 2

👉 Conclusion:

Multiple performance profiles can lead to success.

⚔️ Case Studies
Chelsea vs Tottenham
Open game difference → +0.123
Points difference → +18

👉 Model perfectly explains the gap.

Manchester City vs Newcastle
Open game → +0.061
Game management → +0.059

👉 Consistent with ranking.

Manchester City vs Aston Villa (Paradox Case)

Aston Villa outperforms City in all metrics, yet has fewer points.

👉 Insight:

The model captures average performance but not full efficiency or contextual factors.
