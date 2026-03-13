// =============================================================================
// ast_compiler.dart — Decision Compilation Pipeline
// =============================================================================
// Deserializes the Decision Blueprint JSON contract (Tier 2 output) into a
// typed Abstract Syntax Tree (AST). Every field in the JSON maps to a Dart
// class; the UI is compiled from these nodes, never hallucinated.
// =============================================================================

import 'dart:convert';

// ─── AST Node: Equilibrium Metadata ─────────────────────────────────────────

class EquilibriumMetadata {
  final String equilibriumState;
  final int computationalCycles;
  final double deltaUTotal;

  const EquilibriumMetadata({
    required this.equilibriumState,
    required this.computationalCycles,
    required this.deltaUTotal,
  });

  factory EquilibriumMetadata.fromJson(Map<String, dynamic> json) {
    return EquilibriumMetadata(
      equilibriumState: json['equilibrium_state'] as String,
      computationalCycles: json['computational_cycles'] as int,
      deltaUTotal: (json['delta_u_total'] as num).toDouble(),
    );
  }
}

// ─── AST Node: Selected Candidate ───────────────────────────────────────────

class SelectedCandidate {
  final String dishId;
  final String name;
  final String restaurantName;
  final int finalTotalPkr;

  const SelectedCandidate({
    required this.dishId,
    required this.name,
    required this.restaurantName,
    required this.finalTotalPkr,
  });

  factory SelectedCandidate.fromJson(Map<String, dynamic> json) {
    return SelectedCandidate(
      dishId: json['dish_id'] as String,
      name: json['name'] as String,
      restaurantName: json['restaurant_name'] as String,
      finalTotalPkr: json['final_total_pkr'] as int,
    );
  }
}

// ─── AST Node: Final Utility Scores ─────────────────────────────────────────

class FinalUtilities {
  final double uHealth;
  final double uBudget;
  final double uTaste;
  final double uTotalNash;

  const FinalUtilities({
    required this.uHealth,
    required this.uBudget,
    required this.uTaste,
    required this.uTotalNash,
  });

  factory FinalUtilities.fromJson(Map<String, dynamic> json) {
    return FinalUtilities(
      uHealth: (json['U_health'] as num).toDouble(),
      uBudget: (json['U_budget'] as num).toDouble(),
      uTaste: (json['U_taste'] as num).toDouble(),
      uTotalNash: (json['U_total_nash'] as num).toDouble(),
    );
  }
}

// ─── AST Node: Active Agent Weights ─────────────────────────────────────────

class ActiveWeights {
  final double wHealth;
  final double wBudget;
  final double wTaste;

  const ActiveWeights({
    required this.wHealth,
    required this.wBudget,
    required this.wTaste,
  });

  factory ActiveWeights.fromJson(Map<String, dynamic> json) {
    return ActiveWeights(
      wHealth: (json['w_health'] as num).toDouble(),
      wBudget: (json['w_budget'] as num).toDouble(),
      wTaste: (json['w_taste'] as num).toDouble(),
    );
  }
}

// ─── AST Node: Optimization State ───────────────────────────────────────────

class OptimizationState {
  final FinalUtilities finalUtilities;
  final ActiveWeights activeWeights;

  const OptimizationState({
    required this.finalUtilities,
    required this.activeWeights,
  });

  factory OptimizationState.fromJson(Map<String, dynamic> json) {
    return OptimizationState(
      finalUtilities:
          FinalUtilities.fromJson(json['final_utilities'] as Map<String, dynamic>),
      activeWeights:
          ActiveWeights.fromJson(json['active_weights'] as Map<String, dynamic>),
    );
  }
}

// ─── AST Node: Explainable AI AST ───────────────────────────────────────────

class ExplainableAiAst {
  final String triggerWeight;
  final String explanationNode;
  final List<String> xaiBadges;

  const ExplainableAiAst({
    required this.triggerWeight,
    required this.explanationNode,
    required this.xaiBadges,
  });

  factory ExplainableAiAst.fromJson(Map<String, dynamic> json) {
    return ExplainableAiAst(
      triggerWeight: json['trigger_weight'] as String,
      explanationNode: json['explanation_node'] as String,
      xaiBadges: List<String>.from(json['xai_badges'] as List),
    );
  }
}

// ─── AST Node: Control Surface AST ─────────────────────────────────────────

class ControlSurfaceAst {
  final List<String> rejectionTriggers;

  const ControlSurfaceAst({
    required this.rejectionTriggers,
  });

  factory ControlSurfaceAst.fromJson(Map<String, dynamic> json) {
    return ControlSurfaceAst(
      rejectionTriggers: List<String>.from(json['rejection_triggers'] as List),
    );
  }
}

// ─── Root AST Node: Decision Blueprint ──────────────────────────────────────
// This is the top-level compilation target. A single call to
// DecisionBlueprintAST.fromJson() converts the entire JSON contract into the
// full typed AST, proving the UI is compiled—not hallucinated.
// ─────────────────────────────────────────────────────────────────────────────

class DecisionBlueprintAST {
  final EquilibriumMetadata equilibriumMetadata;
  final SelectedCandidate selectedCandidate;
  final OptimizationState optimizationState;
  final ExplainableAiAst explainableAiAst;
  final ControlSurfaceAst controlSurfaceAst;

  const DecisionBlueprintAST({
    required this.equilibriumMetadata,
    required this.selectedCandidate,
    required this.optimizationState,
    required this.explainableAiAst,
    required this.controlSurfaceAst,
  });

  /// Compiles a raw JSON string into the full Decision Blueprint AST.
  factory DecisionBlueprintAST.compile(String rawJson) {
    final Map<String, dynamic> json =
        jsonDecode(rawJson) as Map<String, dynamic>;
    return DecisionBlueprintAST.fromJson(json);
  }

  /// Deserializes a decoded JSON map into the full AST.
  factory DecisionBlueprintAST.fromJson(Map<String, dynamic> json) {
    return DecisionBlueprintAST(
      equilibriumMetadata: EquilibriumMetadata.fromJson(
          json['equilibrium_metadata'] as Map<String, dynamic>),
      selectedCandidate: SelectedCandidate.fromJson(
          json['selected_candidate'] as Map<String, dynamic>),
      optimizationState: OptimizationState.fromJson(
          json['optimization_state'] as Map<String, dynamic>),
      explainableAiAst: ExplainableAiAst.fromJson(
          json['explainable_ai_ast'] as Map<String, dynamic>),
      controlSurfaceAst: ControlSurfaceAst.fromJson(
          json['control_surface_ast'] as Map<String, dynamic>),
    );
  }
}
