# Tier 3 Compilation and Rendering: Architecture & Flow Guide

This document explains the architecture and data flow of the **Tier 3 Compilation and Rendering Engine** (Mood4Food), focusing specifically on the contents of the `lib/` directory.

The primary goal of Tier 3 is to take a backend decision payload (JSON Contract) from Tier 2, compile it into strongly-typed Dart objects (Abstract Syntax Tree - AST), and deterministically render it as a Server-Driven User Interface (SDUI).

---

## 1. High-Level Pipeline Flow

The engine strictly follows a linear 4-step process:
1. **Receive JSON Contract** (Input)
2. **Compile to AST** (Parsing)
3. **Render SDUI** (Presentation)
4. **Collect Steering Feedback** (User Control)

Here is a breakdown of how data travels across the application:

---

## 2. Component-by-Component Breakdown

### `main.dart` (The Entry Point)
**Role:** Serves as the starting execution loop. It orchestrates the process by orchestrating the compiler and the renderer.

- **Input:** A JSON string (`_mockDecisionBlueprintJson`). In Iteration 1 this is hardcoded, but it simulates the response from a FastAPI backend.
- **Process Flow:**
    1. The JSON string is passed to `DecisionBlueprintAST.compile(_mockDecisionBlueprintJson)`.
    2. The resulting `ast` object is passed into smaller renderer classes: `SDUIRenderer(ast: ast)` and `ControlSurface(ast: ast)`.
- **Output:** The main `DecisionRendererScreen` Scaffold widget containing the rendered UI and control sliders.

### `ast_compiler.dart` (The Parser)
**Role:** To ensure that the application never hallucinates UI elements. It maps every field in the JSON contract to typed Dart classes.

- **Main Function:** `DecisionBlueprintAST.compile(String rawJson)`
    - *Input:* A raw JSON string.
    - *Processing:* Decodes the string using `jsonDecode()`.
    - *Output:* Delegates to `DecisionBlueprintAST.fromJson()`.
- **Main Function:** `DecisionBlueprintAST.fromJson(Map<String, dynamic> json)`
    - *Input:* A parsed JSON map.
    - *Processing:* Calls the `.fromJson()` factories of several sub-nodes:
        - `EquilibriumMetadata.fromJson()`
        - `SelectedCandidate.fromJson()`
        - `OptimizationState.fromJson()`
        - `ExplainableAiAst.fromJson()`
        - `ControlSurfaceAst.fromJson()`
    - *Output:* Returns the populated `DecisionBlueprintAST` object.

> **Example:** When the JSON contains `"selected_candidate": {"dish_id": "d_491", "name": "Spicy Chicken Karahi", ... }`, the compiler creates a `SelectedCandidate` Dart object where `ast.selectedCandidate.name` evaluates strictly to `"Spicy Chicken Karahi"`.

### `sdui_renderer.dart` (The Presentation Layer)
**Role:** This is the stateless widget factory for Server-Driven UI (SDUI). It takes the previously built AST and turns it into pixels. 

- **Input:** Constructed using `SDUIRenderer(ast: DecisionBlueprintAST)`.
- **Process Flow:** 
  It breaks down the UI into logical parts using sub-methods:
    1. **`renderEquilibriumCard()`:**
       - *Reads from AST:* `ast.selectedCandidate` (dish name, restaurant, price) and `ast.equilibriumMetadata` (steps, variance).
       - *Returns:* The top card suggesting the dish.
    2. **`renderUtilityBadges()`:**
       - *Reads from AST:* `ast.optimizationState.finalUtilities` (Health, Budget, Taste scores).
       - *Returns:* The 2x2 grid showing the breakdown scores out of 1.00.
    3. **`renderXAIPanel()`:**
       - *Reads from AST:* `ast.explainableAiAst`.
       - *Returns:* A box explaining *why* the AI selected this dish, including dynamic trigger words, textual explanation, and requirement badges.
- **Output:** Flutter Widgets via `renderFullBlueprint()`.

### `control_surface.dart` (The Feedback Loop)
**Role:** Provides a stateful control panel where the user alters backend logic (e.g. weights) and triggers feedback signals.

- **Input:** Constructed using `ControlSurface(ast: DecisionBlueprintAST)`.
- **Process Flow:**
    - **Initial State:** During `initState()`, it parses `ast.optimizationState.activeWeights` to populate the slider positions (e.g., matching the `0.33` health preference assigned by the AI).
    - **Sliders (Weight Adjustments):** When the user drags a slider, it triggers `_onWeightChanged()`.
    - **Rejection Triggers:** Reads `ast.controlSurfaceAst.rejectionTriggers` list (e.g. `"gradient_signal_too_expensive"`). For every item, it dynamically generates an `OutlinedButton`.
- **Output:** For Iteration 1, interactions output to the console via `debugPrint()`. Eventually, moving sliders or tapping reject buttons will generate a new JSON payload to send *back* to Tier 2 (Backend) for re-optimizing the recommendation.

---

## 3. Summary of Data Passing (Inputs & Outputs)

| Function / Constructor | Input | Output | Purpose |
|-----------------------|-------|--------|---------|
| `DecisionBlueprintAST.compile()` | `String rawJson` | `DecisionBlueprintAST` | Parses string into strongly-typed Dart tree representing the backend model. |
| `SDUIRenderer()` | `DecisionBlueprintAST` | Instance of `SDUIRenderer` | Factory instance initialized with all necessary data. |
| `SDUIRenderer.renderFullBlueprint()` | None (uses instance `ast`) | `Widget` (Flutter) | Draws the static views (Cards, Badges, Explanations). |
| `ControlSurface()` | `DecisionBlueprintAST` | Instance of `ControlSurface` | Receives slider states and dynamically drawn buttons. |
| `ControlSurface._onWeightChanged()` | `String label`, `double value` | Console Log | Collects local gradient adjustments to feed back into algorithms. |
| `ControlSurface._onRejectionTrigger()`| `String signal` | Console Log | Sends rejection logic (e.g. 'Too Expensive') to re-fetch recommendations. |

---

## 4. How to Run Locally

To preview the UI locally on your computer:

1. Open your terminal and navigate to the `tier_3_compilation_and_rendering` directory:
   ```bash
   cd "path/to/tier_3_compilation_and_rendering"
   ```
2. Retrieve the Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on your desired device. E.g., for Chrome:
   ```bash
   flutter run -d chrome
   ```
   *(Note: For MacOS Desktop, you might need to enable desktop support via `flutter create .` first if the `macos/` folder does not exist)*.
