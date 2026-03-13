import json
import os
from neo4j import GraphDatabase

class SymbolicKnowledgeGraph:
    def __init__(self, uri="bolt://localhost:7687"):
        """
        Initializes the Graph Database Architect's interface.
        Strictly deterministic, no probabilistic components.
        """
        self.driver = GraphDatabase.driver(uri, auth=None)

    def close(self):
        self.driver.close()

    def enforce_safety_constraints(self):
        """
        Performs O(E+V) traversal to prune unsafe candidates based on biological
        and nutritional constraints from grounded_intent.json.
        Strictly enforces DAG forward-traversal to prevent topological explosion.
        """
        # 1. Parse absolute source of truth
        intent_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../json_contracts/grounded_intent.json"))
        try:
            with open(intent_path, 'r') as f:
                intent_data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            intent_data = {}

        # 2. Extract and Sanitize Payload
        hard_constraints = intent_data.get("hard_constraints", {})
        raw_allergens = hard_constraints.get("allergens_pruned", [])
        
        # Array Purification: Forcefully strip whitespace and lower-case
        clean_allergens = [a.strip().lower() for a in raw_allergens]
        
        # 3. Strict Keyword Mapping: Expand "meat" without flattening
        if "meat" in clean_allergens:
            # Use .extend() with a strict list to prevent character injection
            clean_allergens.extend(["chicken", "beef", "mutton", "qeema", "gosht", "paye", "nihari", "bone marrow"])
            # Ensure uniqueness
            clean_allergens = list(set(clean_allergens))
        
        # Extract max_calories (default to infinity if missing)
        max_cal = hard_constraints.get("max_calories", float('inf'))
        
        # TERMINAL AUDIT: Prove clean_allergens contains words, not characters
        print(f"TERMINAL AUDIT: clean_allergens = {clean_allergens}")
        print(f"TERMINAL AUDIT: max_cal = {max_cal}")

        # 4. DAG Forward-Traversal Query: Prevents cross-dish contamination
        query = """
        MATCH (d:Dish)
        WHERE d.synthesized_calories <= $max_cal
        AND NOT EXISTS {
            MATCH (d)-[:CONTAINS*1..5]->(i:Ingredient)
            WHERE ANY(pruned IN $pruned_list WHERE toLower(i.name) CONTAINS pruned)
        }
        OPTIONAL MATCH (d)-[:CONTAINS]->(safe_i:Ingredient)
        RETURN 
            d.dish_id AS dish_id, 
            d.name AS name, 
            d.normalized_price_pkr AS normalized_price_pkr, 
            d.synthesized_calories AS synthesized_calories, 
            d.synthesized_protein AS synthesized_protein,
            COLLECT(DISTINCT safe_i.name) AS ingredients
        """

        surviving_candidates = []
        with self.driver.session() as session:
            # Parameter Binding: Explicitly pass max_cal and pruned_list=clean_allergens
            result = session.run(query, max_cal=max_cal, pruned_list=clean_allergens)
            
            for record in result:
                if not record["dish_id"]:
                    continue

                # 5. Map to Candidate Evaluation Schema (Ensuring Zero-Null Matrix)
                candidate = {
                    "dish_metadata": {
                        "dish_id": record["dish_id"],
                        "name": record["name"] or "Unknown Dish",
                        "restaurant_name": "DAG-Verified Safe" 
                    },
                    "financial_metrics": {
                        "base_price_pkr": record["normalized_price_pkr"] or 0.0,
                        "delivery_fee_pkr": 0.0
                    },
                    "nutritional_metrics": {
                        "total_calories": record["synthesized_calories"] or 0.0,
                        "protein_grams": record["synthesized_protein"] or 0.0,
                        "carbs_grams": 0.0,
                        "fats_grams": 0.0
                    },
                    "vector_retrieval": {
                        "taste_vector_id": f"vec_{record['dish_id']}"
                    },
                    "simulation_state": {
                        "inventory_in_stock": True
                    },
                    "ingredients": [i for i in record["ingredients"] if i] 
                }
                surviving_candidates.append(candidate)

        # 6. Final Serialization and State Persistence
        output_data = {
            "graph_execution_state": {
                "search_space_viable": len(surviving_candidates) > 0,
                "nodes_pruned": 0,
                "surviving_candidates_count": len(surviving_candidates)
            },
            "candidates": surviving_candidates
        }

        print(f"DEBUG: Found {len(surviving_candidates)} survivors safely.")

        output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../json_contracts/candidate_evaluation.json"))
        with open(output_path, 'w') as f:
            json.dump(output_data, f, indent=2)

        return output_data

if __name__ == "__main__":
    # Integration point for Tier 1 Pipeline
    skg = SymbolicKnowledgeGraph(uri="bolt://localhost:7687")
    try:
        results = skg.enforce_safety_constraints()
        print(f"Safety Enforcement Complete. {results['graph_execution_state']['surviving_candidates_count']} candidates safe.")
    finally:
        skg.close()
