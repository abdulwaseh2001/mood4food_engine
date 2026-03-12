// =============================================================================
// main.dart — Tier 3 Execution Loop
// =============================================================================
// Entry point for the Mood4Food Decision Rendering Engine.
// Iteration 1: Loads a hardcoded Decision Blueprint JSON (mock from Tier 2),
// compiles it via the AST pipeline, and renders the SDUI in a Scaffold.
// =============================================================================

import 'package:flutter/material.dart';
import 'ast_compiler.dart';
import 'sdui_renderer.dart';
import 'control_surface.dart';

// ─── Mock Decision Blueprint JSON ───────────────────────────────────────────
// This is the deterministic Tier 2 output contract. In production this payload
// arrives via FastAPI; for Iteration 1 it is hardcoded here as the baseline.
// ─────────────────────────────────────────────────────────────────────────────

const String _mockDecisionBlueprintJson = '''
{
  "equilibrium_metadata": {
    "equilibrium_state": "resolved_via_relaxation",
    "computational_cycles": 3,
    "delta_u_total": 0.015
  },
  "selected_candidate": {
    "dish_id": "d_491",
    "name": "Spicy Chicken Karahi",
    "restaurant_name": "Local Vendor A",
    "final_total_pkr": 450
  },
  "optimization_state": {
    "final_utilities": {
      "U_health": 0.88,
      "U_budget": 0.95,
      "U_taste": 0.72,
      "U_total_nash": 0.84
    },
    "active_weights": {
      "w_health": 0.33,
      "w_budget": 0.23,
      "w_taste": 0.44
    }
  },
  "explainable_ai_ast": {
    "trigger_weight": "Taste Focus",
    "explanation_node": "Selected because your priority was Taste. We found a highly-rated dish that still fits your budget constraints.",
    "xai_badges": [
      "Health Rated",
      "Budget Friendly"
    ]
  },
  "control_surface_ast": {
    "rejection_triggers": [
      "gradient_signal_too_expensive",
      "gradient_signal_more_protein"
    ]
  }
}
''';

// ─── Application Bootstrap ─────────────────────────────────────────────────

void main() {
  runApp(const Mood4FoodApp());
}

class Mood4FoodApp extends StatelessWidget {
  const Mood4FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood4Food — Decision Renderer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const DecisionRendererScreen(),
    );
  }
}

// ─── Decision Renderer Screen ───────────────────────────────────────────────

class DecisionRendererScreen extends StatelessWidget {
  const DecisionRendererScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Step 1: Compile the Decision Blueprint JSON into the AST ─────────
    final DecisionBlueprintAST ast =
        DecisionBlueprintAST.compile(_mockDecisionBlueprintJson);

    // ── Step 2: Instantiate the deterministic SDUI renderer ─────────────
    final SDUIRenderer renderer = SDUIRenderer(ast: ast);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MOOD4FOOD  ·  DECISION ENGINE',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            letterSpacing: 2,
            color: Color(0xFF86868B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── SDUI: Compiled Blueprint Widgets ──────────────────────────
            renderer.renderFullBlueprint(),

            const SizedBox(height: 8),

            // ── Control Surface: Gradient Steering ────────────────────────
            ControlSurface(ast: ast),
          ],
        ),
      ),
    );
  }
}
