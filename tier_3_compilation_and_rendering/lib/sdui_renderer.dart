// =============================================================================
// sdui_renderer.dart — Interface Rendering Pipeline
// =============================================================================
// Deterministic widget factory. Walks the Decision Blueprint AST and produces
// Flutter widgets. The UI is a "dumb renderer"—every pixel traces back to an
// AST node. No data is hallucinated or hardcoded.
// =============================================================================

import 'package:flutter/material.dart';
import 'ast_compiler.dart';

// ─── Theme Constants (Wireframe Aesthetic) ──────────────────────────────────

const Color _cardBg = Color(0xFFFFFFFF);
const Color _accentCyan = Color(0xFF007AFF);
const Color _accentGreen = Color(0xFF34C759);
const Color _accentAmber = Color(0xFFFF9500);
const Color _accentPink = Color(0xFFFF2D55);
const Color _textPrimary = Color(0xFF1D1D1F);
const Color _textSecondary = Color(0xFF86868B);
const Color _borderSubtle = Color(0xFFE5E5EA);

const TextStyle _monoLabel = TextStyle(
  fontFamily: 'monospace',
  fontSize: 11,
  color: _textSecondary,
  letterSpacing: 1.2,
);

const TextStyle _monoValue = TextStyle(
  fontFamily: 'monospace',
  fontSize: 16,
  color: _textPrimary,
  fontWeight: FontWeight.w600,
);

// ─── SDUIRenderer: Stateless Widget Factory ─────────────────────────────────

class SDUIRenderer {
  final DecisionBlueprintAST ast;

  const SDUIRenderer({required this.ast});

  // ── Equilibrium Card ────────────────────────────────────────────────────

  Widget renderEquilibriumCard() {
    final candidate = ast.selectedCandidate;
    final eqMeta = ast.equilibriumMetadata;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentCyan.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FINAL RECOMMENDATION',
                  style: _monoLabel,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _accentGreen.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(
                    eqMeta.equilibriumState.toUpperCase().replaceAll('_', ' '),
                    style: _monoLabel.copyWith(
                        color: _accentGreen, fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dish name
            Text(
              candidate.name,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 22,
                color: _textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Restaurant
            Text(
              candidate.restaurantName,
              style: _monoLabel.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Bottom row: price + metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PKR ${candidate.finalTotalPkr}',
                  style: _monoValue.copyWith(
                      color: _accentCyan, fontSize: 20),
                ),
                Text(
                  '${eqMeta.computationalCycles} steps · variance ${eqMeta.deltaUTotal.toStringAsFixed(3)}',
                  style: _monoLabel.copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'dish_id: ${candidate.dishId}',
              style: _monoLabel.copyWith(fontSize: 9, color: _textSecondary.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Utility Badges ──────────────────────────────────────────────────────

  Widget renderUtilityBadges() {
    final u = ast.optimizationState.finalUtilities;

    final badges = <_UtilityBadgeData>[
      _UtilityBadgeData(label: 'Health', value: u.uHealth, color: _accentGreen),
      _UtilityBadgeData(label: 'Budget', value: u.uBudget, color: _accentCyan),
      _UtilityBadgeData(label: 'Taste', value: u.uTaste, color: _accentAmber),
      _UtilityBadgeData(
          label: 'Total Match', value: u.uTotalNash, color: _accentPink),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SCORING BREAKDOWN', style: _monoLabel),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              // On winder screens (>400px), show all 4 spread out evenly
              if (constraints.maxWidth > 400) {
                return Row(
                  children: badges.asMap().entries.map((entry) {
                    final isLast = entry.key == badges.length - 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
                        child: _buildBadge(entry.value),
                      ),
                    );
                  }).toList(),
                );
              } else {
                // On narrow mobile screens, fall back to a 2x2 grid evenly spread
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: _buildBadge(badges[0]),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: _buildBadge(badges[1]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: _buildBadge(badges[2]),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: _buildBadge(badges[3]),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(_UtilityBadgeData data) {
    return Container(
      // Removed margin: const EdgeInsets.symmetric(horizontal: 4) as Wrap handles spacing
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: data.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            data.label,
            style: _monoLabel.copyWith(color: data.color, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            data.value.toStringAsFixed(2),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── XAI Panel ───────────────────────────────────────────────────────────

  Widget renderXAIPanel() {
    final xai = ast.explainableAiAst;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSubtle, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DECISION EXPLANATION', style: _monoLabel),
            const SizedBox(height: 12),

            // Trigger weight
            Row(
              children: [
                Text('prioritized: ', style: _monoLabel.copyWith(fontSize: 10)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accentAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    xai.triggerWeight,
                    style: _monoLabel.copyWith(
                        color: _accentAmber, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Explanation
            Text(
              xai.explanationNode,
              style: _monoLabel.copyWith(
                  fontSize: 12, color: _textPrimary, height: 1.5),
            ),
            const SizedBox(height: 14),

            // XAI badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: xai.xaiBadges.map((badge) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _accentCyan.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    badge,
                    style: _monoLabel.copyWith(
                        color: _accentCyan, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Full Blueprint Renderer ─────────────────────────────────────────────

  Widget renderFullBlueprint() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        renderEquilibriumCard(),
        renderUtilityBadges(),
        renderXAIPanel(),
      ],
    );
  }
}

// ─── Internal Badge Data ────────────────────────────────────────────────────

class _UtilityBadgeData {
  final String label;
  final double value;
  final Color color;

  const _UtilityBadgeData({
    required this.label,
    required this.value,
    required this.color,
  });
}
