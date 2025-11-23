---
id: US-06
feature: Estimation Session
epic: Collaborative Estimation
priority: High
status: In Progress
test_coverage: features/estimation_session.feature
related_features:
  - Project Management
  - Effort Tree Structure
  - Estimation Categories
  - Estimation Parameters
  - Estimation Options
---

# User Story: Estimation Session

## User Story

**As a** project member
**I want to** collaboratively estimate effort for leaf nodes in real-time
**So that** the team can reach consensus on effort estimates through structured voting

## Overview

An estimation session is a collaborative, real-time process where multiple users estimate effort for leaf nodes in a project's effort tree. The session follows a structured workflow with distinct phases, facilitated by one user who controls the progression and makes final decisions.

The session operates on leaf nodes only (parent nodes will have rolled-up values calculated later). The estimation process for each category within an effort node follows this sequence:
1. **Parameter Selection** (if category is scaled)
2. **Estimation** (voting by all participants)
3. **Reveal & Finalize** (by facilitator)

This cycle repeats for each category within the current effort, then moves to the next effort node.

## Acceptance Criteria

### US-06-AC-01: Starting an Estimation Session

**Prerequisites**: User must have `estimation_sessions:facilitate`, `estimation_sessions:participate`, `projects:view`, and `projects:list` permissions

- In the project details, users can start an estimation session
- Session creation requires selecting an estimation option (predefined value set)
- Creating a session makes the user the facilitator
- The session is created with status "active"
- The session displays the first leaf node with its first category ready for estimation
- A unique session identifier is generated
- Only leaf nodes in the effort tree are available for estimation
- All state changes are broadcast in real-time to all participants via Turbo Streams

### US-06-AC-02: Joining an Estimation Session

**Prerequisites**: User must be authenticated and have `estimation_sessions:participate`, `projects:view`, and `projects:list` permissions

- In the project details, authenticated users can join an active estimation session
- Users can see the current leaf node and category being estimated
- Users can see the list of all participants
- The facilitator is clearly marked in the participant list
- All state changes are broadcast in real-time to all participants via Turbo Streams

### US-06-AC-03: Viewing Session Participants

- In the estimation session, all participants can view the list of session participants
- Each participant displays their email/identifier
- The facilitator is marked with a "Facilitator" label
- New participants joining are visible in real-time via Turbo Streams
- The current user can see themselves in the participant list

### US-06-AC-04: Viewing Current Effort Node and Category

- In the estimation session, all participants can see which leaf node is currently being estimated
- The current effort displays its title and description
- The current category being estimated is clearly highlighted
- All participants can see which categories have been finalized for the current effort
- All state changes are broadcast in real-time to all participants via Turbo Streams

### US-06-AC-05: Estimating a Scaled Category

**Prerequisites**: User must be the facilitator for parameter selection

- In the estimation session for a scaled category, the facilitator sees parameter selection interface
- The category is marked as requiring parameter selection
- The facilitator can select one parameter from available project parameters
- The selected parameter is saved immediately and broadcast in real-time to all participants via Turbo Streams
- All participants see which parameter was selected (e.g., "Implementation: per Number of Features")
- After parameter selection, the voting phase begins automatically
- All participants can cast votes by selecting one value from the estimation option
- Each participant's vote is recorded immediately but specific choices remain hidden from others
- Participants can see that they have voted and can change their vote before reveal
- Voting progress (e.g., "3/5 voted") is visible to all and updates in real-time via Turbo Streams
- After voting, the facilitator can reveal all votes
- All participants can see all votes organized by participant (e.g., "alice@example.com: 5, bob@example.com: 8, charlie@example.com: 5")
- Only the facilitator can select any value from the estimation option as the final estimate (including values with 0 votes)
- The selected value is saved immediately with the associated parameter
- All participants see the finalized estimate in real-time via Turbo Streams

### US-06-AC-06: Estimating an Absolute Category

**Prerequisites**: User must be a participant; facilitator controls reveal and finalize

- In the estimation session for an absolute category, no parameter selection is required
- All participants can immediately cast votes by selecting one value from the estimation option
- Each participant's vote is recorded immediately but specific choices remain hidden from others
- Participants can see that they have voted and can change their vote before reveal
- Voting progress (e.g., "3/5 voted") is visible to all and updates in real-time via Turbo Streams
- After voting, the facilitator can reveal all votes
- All participants can see all votes organized by participant (e.g., "alice@example.com: 5, bob@example.com: 8, charlie@example.com: 5")
- Only the facilitator can select any value from the estimation option as the final estimate (including values with 0 votes)
- The selected value is saved immediately
- All participants see the finalized estimate in real-time via Turbo Streams

### US-06-AC-07: Navigating Between Effort Nodes

**Prerequisites**: User must be the facilitator; all categories for current effort must be finalized

- In the estimation session after all categories are finalized, the facilitator can move to the next unestimated leaf node
- The facilitator can skip the current effort node and return later
- The facilitator can navigate to previously estimated effort nodes
- When facilitator navigates, all participants automatically see the new effort node and its first category in real-time via Turbo Streams
- The effort tree shows which nodes have been estimated, which are in progress, and which remain unestimated

### US-06-AC-08: Re-estimating Effort Nodes

**Prerequisites**: User must be the facilitator

- In the estimation session, the facilitator can select a previously estimated effort node
- The facilitator can see the current estimates for all categories of that effort
- The facilitator can restart the estimation process for specific categories
- Previous parameters for scaled categories are pre-selected but can be changed
- The estimation process follows the same flow (parameter selection → voting → reveal → finalize)
- New estimates replace the old ones
- All changes are broadcast in real-time to all participants via Turbo Streams

### US-06-AC-09: Viewing Estimation Progress

**Prerequisites**: User must be the facilitator

- In the estimation session, the facilitator can see which leaf nodes have been estimated
- Estimated nodes are clearly marked (e.g., with checkmark or color)
- Partially estimated nodes (some categories finalized) are clearly marked
- Unestimated nodes are clearly marked
- The facilitator can see the count of estimated vs total leaves
- The facilitator can click on any leaf to navigate to it

### US-06-AC-10: Leaving Estimation Session

- In the estimation session, participants can leave the session at any time
- Other participants see the updated participant count in real-time via Turbo Streams
- Previous votes from the participant remain recorded
- The participant can rejoin the session later
- The facilitator cannot leave unless they complete the session or transfer facilitator role

### US-06-AC-11: Completing Estimation Session

**Prerequisites**: User must be the facilitator

- In the estimation session, the facilitator can mark the session as complete at any time
- The facilitator receives a warning if not all leaves have been estimated
- All participants are notified that the session has been completed via Turbo Streams
- The session status is updated to "completed"
- Participants can still view the final estimates
- The session can no longer accept new votes or changes
- The facilitator can still view the session and all estimates

## Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| Estimation Option | Yes | Must be a valid estimation option |
| Parameter Selection | Conditional | Required for scaled categories before voting |
| Vote Value | Yes | Must be from the selected estimation option |
| Final Estimate Value | Yes | Must be from the selected estimation option (can be any value, including those with 0 votes) |

## Permission Requirements

| AC ID | Acceptance Criteria | Required Permissions |
|-------|---------------------|---------------------|
| US-06-AC-01 | Starting an Estimation Session | `estimation_sessions:facilitate`, `estimation_sessions:participate`, `projects:view`, `projects:list` |
| US-06-AC-02 | Joining an Estimation Session | `estimation_sessions:participate`, `projects:view`, `projects:list` |
| US-06-AC-03 | Viewing Session Participants | `estimation_sessions:participate` |
| US-06-AC-04 | Viewing Current Effort Node and Category | `estimation_sessions:participate` |
| US-06-AC-05 | Estimating a Scaled Category | `estimation_sessions:facilitate` (for parameter/reveal/finalize), `estimation_sessions:participate` (for voting) |
| US-06-AC-06 | Estimating an Absolute Category | `estimation_sessions:facilitate` (for reveal/finalize), `estimation_sessions:participate` (for voting) |
| US-06-AC-07 | Navigating Between Effort Nodes | `estimation_sessions:facilitate` |
| US-06-AC-08 | Re-estimating Effort Nodes | `estimation_sessions:facilitate` |
| US-06-AC-09 | Viewing Estimation Progress | `estimation_sessions:facilitate` |
| US-06-AC-10 | Leaving Estimation Session | `estimation_sessions:participate` |
| US-06-AC-11 | Completing Estimation Session | `estimation_sessions:facilitate` |

## User Experience Flow

### Happy Path: Complete Estimation Session

1. Facilitator navigates to project details
2. Facilitator starts estimation session, selecting "Fibonacci" estimation option
3. System creates session and shows first leaf node with first category
4. Other team members join the session via project page
5. All participants see each other in the participants list in real-time
6. **First category is scaled (e.g., "Implementation")**:
   - Facilitator selects parameter "Number of Features"
   - All participants see parameter selection in real-time
7. All participants cast votes for the category
8. Progress indicator shows "5/5 voted" in real-time
9. Facilitator reveals votes, all participants see votes by participant (e.g., "alice@example.com: 3, bob@example.com: 5, charlie@example.com: 5, dave@example.com: 8, eve@example.com: 8")
10. Facilitator selects final estimate value "8" (only facilitator can select)
11. System saves estimate and automatically shows next category in real-time
12. **Second category is absolute (e.g., "Complexity")**:
    - No parameter selection needed
    - Participants immediately vote
13. Facilitator reveals and finalizes
14. System shows next category or moves to next effort if all categories done
15. Process repeats for each leaf node
16. Facilitator marks session as complete when all nodes are estimated
17. All participants notified of completion in real-time

### Alternative Path: Changing Vote

1. Participant casts vote for a category
2. Participant realizes they want to change their vote
3. Before facilitator reveals, participant selects a different value
4. System updates the vote immediately
5. Voting progress updates for all participants in real-time

### Alternative Path: Facilitator Selects Compromise Value

1. Facilitator reveals votes, all participants see votes by participant showing a split (e.g., "alice@example.com: 3, bob@example.com: 3, charlie@example.com: 3, dave@example.com: 8, eve@example.com: 8")
2. Team discusses verbally/in separate channel
3. Team agrees on compromise value not voted by anyone (e.g., "5")
4. Facilitator selects "5" as final estimate despite no votes for that value
5. System saves the estimate
6. All participants see the compromise value in real-time

### Alternative Path: Skipping an Effort Node

1. Facilitator begins estimating an effort node
2. Team decides the node is too complex to estimate now
3. Facilitator skips the node
4. System moves to next unestimated leaf
5. All participants follow navigation in real-time
6. Later, facilitator navigates back to skipped node
7. Estimation process continues normally

### Alternative Path: Re-estimating a Category

1. Facilitator reviews completed estimates
2. Team identifies an estimate that needs revision
3. Facilitator navigates to that effort node
4. System shows existing estimates for all categories
5. Facilitator restarts estimation for specific category
6. Previous parameter selection is pre-filled (for scaled categories)
7. Team votes again
8. New estimate replaces old one
9. All changes visible in real-time to participants

### Alternative Path: Participant Leaves and Rejoins

1. Participant leaves the session mid-estimation
2. Other participants see updated participant count in real-time
3. Session continues without the participant
4. Participant's previous votes remain recorded
5. Later, participant rejoins the session
6. Participant sees current effort and category being estimated
7. Participant can continue voting on new categories
