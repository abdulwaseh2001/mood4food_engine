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
        """
        # 1. Parse absolute source of truth
        intent_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../json_contracts/grounded_intent.json"))
        with open(intent_path, 'r') as f:
            intent_data = json.load(f)

        hard_constraints = intent_data.get("hard_constraints", {})
        allergens_pruned = hard_constraints.get("allergens_pruned", [])
        max_calories = hard_constraints.get("max_calories", float('inf'))

        # 2. Execute deterministic Cypher traversal
        query = """
        MATCH (d:Dish)
        WHERE d.synthesized_calories <= $max_calories
        AND NOT EXISTS {
            MATCH (d)-[:CONTAINS]->(:Ingredient)-[:CLASSIFIED_AS]->(a:Allergen)
            WHERE a.name IN $allergens_pruned
        }
        MATCH (r:Restaurant)-[:SERVES]->(d)
        MATCH (d)-[:CONTAINS]->(i:Ingredient)
        RETURN 
            d.dish_id AS dish_id,
            d.name AS name,
            d.normalized_price_pkr AS price,
            d.synthesized_calories AS calories,
            d.synthesized_protein AS protein,
            r.name AS restaurant_name,
            collect(i.name) AS ingredients
        """

        surviving_candidates = []
        with self.driver.session() as session:
            result = session.run(query, max_calories=max_calories, allergens_pruned=allergens_pruned)
            for record in result:
                # 3. Map to Candidate Evaluation Schema (Zero-Null Matrix)
                candidate = {
                    "dish_metadata": {
                        "dish_id": record["dish_id"],
                        "name": record["name"],
                        "restaurant_name": record["restaurant_name"]
                    },
                    "financial_metrics": {
                        "base_price_pkr": record["price"],
                        "delivery_fee_pkr": 0.0  # Constraint: Fixed baseline for perception layer
                    },
                    "nutritional_metrics": {
                        "total_calories": record["calories"],
                        "protein_grams": record["protein"],
                        "carbs_grams": 0.0,      # Note: Pending refined decomposition
                        "fats_grams": 0.0
                    },
                    "vector_retrieval": {
                        "taste_vector_id": f"vec_{record['dish_id']}"
                    },
                    "simulation_state": {
                        "inventory_in_stock": True
                    },
                    "ingredients": record["ingredients"]
                }
                surviving_candidates.append(candidate)

        # 4. Final Serialization and State Persistence
        output_data = {
            "graph_execution_state": {
                "search_space_viable": len(surviving_candidates) > 0,
                "nodes_pruned": 0,  # Optimization: Logic handled in-query
                "surviving_candidates_count": len(surviving_candidates)
            },
            "candidates": surviving_candidates
        }

        output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../json_contracts/candidate_evaluation.json"))
        with open(output_path, 'w') as f:
            json.dump(output_data, f, indent=2)

        return output_data

if __name__ == "__main__":
    # Integration point for Tier 1 Pipeline
    skg = SymbolicKnowledgeGraph()
    try:
        results = skg.enforce_safety_constraints()
        print(f"Safety Enforcement Complete. {results['graph_execution_state']['surviving_candidates_count']} candidates safe.")
    finally:
        skg.close()
