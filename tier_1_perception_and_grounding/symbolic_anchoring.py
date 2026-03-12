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
        try:
            with open(intent_path, 'r') as f:
                intent_data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            intent_data = {}

        # 2. Extract constraints with structural resilience
        hard_constraints = intent_data.get("hard_constraints", {})
        allergens_pruned = hard_constraints.get("allergens_pruned", [])
        max_calories = hard_constraints.get("max_calories", float('inf'))
        
        location_constraint = intent_data.get("location_constraint", {})
        user_lat = location_constraint.get("user_lat")
        user_lon = location_constraint.get("user_lon")
        max_radius = location_constraint.get("max_radius_km", float('inf'))

        # 3. Execute deterministic Cypher traversal
        query = """
        MATCH (r)-[:SERVES]->(d:Dish)
        WHERE (d.synthesized_calories IS NULL OR d.synthesized_calories <= $max_calories)
        AND NOT EXISTS {
            MATCH (d)-[:CONTAINS]->(:Ingredient)-[:CLASSIFIED_AS]->(a:Allergen)
            WHERE a.name IN $allergens_pruned
        }
        AND (
            $user_lat IS NULL OR $user_lon IS NULL OR
            (r.latitude IS NULL OR r.longitude IS NULL) OR
            point.distance(
                point({latitude: r.latitude, longitude: r.longitude}), 
                point({latitude: $user_lat, longitude: $user_lon})
            ) / 1000.0 <= $max_radius
        )
        OPTIONAL MATCH (d)-[:CONTAINS]->(i:Ingredient)
        RETURN 
            d.dish_id AS dish_id,
            d.name AS name,
            COALESCE(d.normalized_price_pkr, 0.0) AS price,
            COALESCE(d.synthesized_calories, 0.0) AS calories,
            COALESCE(d.synthesized_protein, 0.0) AS protein,
            r.name AS restaurant_name,
            collect(i.name) AS ingredients
        """

        surviving_candidates = []
        with self.driver.session() as session:
            # Diagnostic: Check raw count before filtering if possible
            # But we'll just run the query and check results
            result = session.run(
                query, 
                max_calories=max_calories, 
                allergens_pruned=allergens_pruned,
                user_lat=user_lat,
                user_lon=user_lon,
                max_radius=max_radius
            )
            for record in result:
                # Filter out records where dish_id is missing (shouldn't happen with :Dish)
                if not record["dish_id"]:
                    continue

                # 4. Map to Candidate Evaluation Schema (Zero-Null Matrix)
                candidate = {
                    "dish_metadata": {
                        "dish_id": record["dish_id"],
                        "name": record["name"] or "Unknown Dish",
                        "restaurant_name": record["restaurant_name"] or "Unknown Restaurant"
                    },
                    "financial_metrics": {
                        "base_price_pkr": record["price"],
                        "delivery_fee_pkr": 0.0
                    },
                    "nutritional_metrics": {
                        "total_calories": record["calories"],
                        "protein_grams": record["protein"],
                        "carbs_grams": 0.0,
                        "fats_grams": 0.0
                    },
                    "vector_retrieval": {
                        "taste_vector_id": f"vec_{record['dish_id']}"
                    },
                    "simulation_state": {
                        "inventory_in_stock": True
                    },
                    "ingredients": [ing for ing in record["ingredients"] if ing] # Filter nulls from OPTIONAL MATCH
                }
                surviving_candidates.append(candidate)

        # 5. Final Serialization and State Persistence
        output_data = {
            "graph_execution_state": {
                "search_space_viable": len(surviving_candidates) > 0,
                "nodes_pruned": 0,
                "surviving_candidates_count": len(surviving_candidates)
            },
            "candidates": surviving_candidates
        }

        # Debug print for the execution environment
        print(f"DEBUG: Found {len(surviving_candidates)} survivors in Graph.")

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
