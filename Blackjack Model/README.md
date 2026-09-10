# Blackjack Model

## Overview

This project models Blackjack using dynamically updated transition matrices to investigate how knowledge of the remaining deck can influence player performance. The simulation compares different player strategies and tracks outcomes such as win rate, bust rate, and other game-level statistics.

The central model represents the probability of future card draws based on the current composition of the deck. As cards become visible during a game, these probabilities and the corresponding transition matrices are updated to reflect the new information.

## Modeling the Dealer's Hidden Card

One of the main challenges is the dealer's hole card. Although the player cannot observe this card, it has already been removed from the deck and therefore affects the true distribution of future draws.

Rather than assuming a particular hole card, the model accounts for every possible value. For each possible hole card, it constructs a transition matrix from the 48-card deck that would remain if that card were removed. Each matrix is weighted by the probability of its corresponding hole card based on the observable 49-card deck snapshot. 

The final transition matrix is therefore a probability-weighted combination of the possible hidden-card scenarios. This allows the simulated player to make decisions using the information actually available to a player without assuming knowledge of the dealer's hidden card.

## Simulation

As each new card is revealed, the model updates the remaining deck composition and recalculates the relevant probabilities. This produces a player that responds dynamically to changes in the deck rather than relying exclusively on fixed probabilities.

Multiple player strategies are simulated under the same Blackjack environment so their performance can be compared across repeated games.

## Contents
- [Blackjack Model](./Mathematical%20Modeling%20Project.ipynb)
- [Written Report](./Mathematical%20Modeling%20Project%20Report.pdf)

