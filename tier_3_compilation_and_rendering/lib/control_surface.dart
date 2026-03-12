// =============================================================================
// control_surface.dart — Gradient Steering Interface
// =============================================================================
// Stateful control panel for injecting negative/positive gradient feedback.
// In Iteration 1, slider adjustments and rejection triggers log locally via
// debugPrint, simulating the feedback loop that will later re-trigger Tier 2.
// =============================================================================

import 'package:flutter/material.dart';
import 'ast_compiler.dart';

// ─── Theme Constants ────────────────────────────────────────────────────────

const Color _cardBg = Color(0xFFFFFFFF);
const Color _accentCyan = Color(0xFF007AFF);
const Color _accentGreen = Color(0xFF34C759);
const Color _accentAmber = Color(0xFFFF9500);
const Color _accentPink = Color(0xFFFF2D55);
const Color _textSecondary = Color(0xFF86868B);
const Color _borderSubtle = Color(0xFFE5E5EA);

const TextStyle _monoLabel = TextStyle(
  fontFamily: 'monospace',
  fontSize: 11,
  color: _textSecondary,
  letterSpacing: 1.2,
);

// ─── ControlSurface: Stateful Widget ────────────────────────────────────────

class ControlSurface extends StatefulWidget {
  final DecisionBlueprintAST ast;

  const ControlSurface({super.key, required this.ast});

  @override
  State<ControlSurface> createState() => _ControlSurfaceState();
}

class _ControlSurfaceState extends State<ControlSurface> {
  late double _wHealth;
  late double _wBudget;
  late double _wTaste;

  @override
  void initState() {
    super.initState();
    final weights = widget.ast.optimizationState.activeWeights;
    _wHealth = weights.wHealth;
    _wBudget = weights.wBudget;
    _wTaste = weights.wTaste;
  }

  void _onWeightChanged(String label, double value) {
    debugPrint(
      '[GRADIENT SIGNAL] $label adjusted → ${value.toStringAsFixed(3)}'
      ' | w_h=${ _wHealth.toStringAsFixed(3)}'
      ', w_b=${ _wBudget.toStringAsFixed(3)}'
      ', w_t=${ _wTaste.toStringAsFixed(3)}',
    );
  }

  void _onRejectionTrigger(String signal) {
    debugPrint('[REJECTION SIGNAL] User fired: $signal');
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('ADJUST YOUR PRIORITIES', style: _monoLabel),
            const SizedBox(height: 16),

            // ── Weight Sliders ──────────────────────────────────────────

            _buildWeightSlider(
              label: 'Health Focus',
              value: _wHealth,
              activeColor: _accentGreen,
              onChanged: (v) {
                setState(() => _wHealth = v);
                _onWeightChanged('w_health', v);
              },
            ),
            _buildWeightSlider(
              label: 'Budget Focus',
              value: _wBudget,
              activeColor: _accentCyan,
              onChanged: (v) {
                setState(() => _wBudget = v);
                _onWeightChanged('w_budget', v);
              },
            ),
            _buildWeightSlider(
              label: 'Taste Focus',
              value: _wTaste,
              activeColor: _accentAmber,
              onChanged: (v) {
                setState(() => _wTaste = v);
                _onWeightChanged('w_taste', v);
              },
            ),

            const SizedBox(height: 20),

            // ── Rejection Trigger Buttons ───────────────────────────────

            const Text('WHY REJECT THIS?', style: _monoLabel),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.ast.controlSurfaceAst.rejectionTriggers
                  .map((trigger) => _buildRejectionButton(trigger))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Slider Builder ──────────────────────────────────────────────────────

  Widget _buildWeightSlider({
    required String label,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: _monoLabel.copyWith(color: activeColor, fontSize: 10),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: activeColor.withValues(alpha: 0.6),
                inactiveTrackColor: activeColor.withValues(alpha: 0.15),
                thumbColor: activeColor,
                overlayColor: activeColor.withValues(alpha: 0.1),
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: activeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rejection Button Builder ────────────────────────────────────────────

  Widget _buildRejectionButton(String trigger) {
    // Turn "gradient_signal_too_expensive" → "TOO EXPENSIVE"
    final displayLabel = trigger
        .replaceAll('gradient_signal_', '')
        .replaceAll('_', ' ')
        .toUpperCase();

    return OutlinedButton(
      onPressed: () => _onRejectionTrigger(trigger),
      style: OutlinedButton.styleFrom(
        foregroundColor: _accentPink,
        side: BorderSide(color: _accentPink.withValues(alpha: 0.4), width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        '⊘ $displayLabel',
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
