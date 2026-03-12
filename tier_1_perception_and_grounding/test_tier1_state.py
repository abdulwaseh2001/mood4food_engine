import json
import os
import chromadb

def audit_json_contract():
    """Mathematical proof of safety constraints in JSON."""
    intent_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../json_contracts/grounded_intent.json"))
    evaluation_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../json_contracts/candidate_evaluation.json"))

    with open(intent_path, 'r') as f:
        intent = json.load(f)
    with open(evaluation_path, 'r') as f:
        evaluation = json.load(f)

    max_cals = intent["hard_constraints"]["max_calories"]
    pruned_allergens = set(intent["hard_constraints"]["allergens_pruned"])
    
    candidates = evaluation.get("candidates", [])
    print(f"--- JSON Audit: {len(candidates)} Candidates ---")
    
    for c in candidates:
        name = c["dish_metadata"]["name"]
        cals = c["nutritional_metrics"]["total_calories"]
        # Safety Check 1: Calorie Bound
        assert cals <= max_cals, f"FAIL: {name} exceeds {max_cals} calories."
        
        # Safety Check 2: Allergen Severance
        # Note: In Tier 1, ingredients are returned in the candidate metadata for verification
        ingredients = set(c.get("ingredients", []))
        # This audit assumes any ingredient matching an allergen name is unsafe
        # (The graph does more complex traversal, but this is the primary check)
        intersection = ingredients.intersection(pruned_allergens)
        assert not intersection, f"FAIL: {name} contains prohibited allergens: {intersection}"
        
        print(f"PASS: {name} ({cals} kcal)")

def audit_vector_geometry():
    """Geometric assertion of the embedding space."""
    persist_dir = os.path.abspath(os.path.join(
        os.path.dirname(__file__), 
        "../tier_2_optimization_and_debate/chroma_storage/"
    ))
    
    client = chromadb.PersistentClient(path=persist_dir)
    collection = client.get_collection(name="candidate_dishes")
    
    results = collection.get(include=['embeddings', 'metadatas'])
    ids = results['ids']
    embeddings = results['embeddings']
    metadatas = results['metadatas']

    print(f"\n--- Vector Audit: {len(ids)} Embeddings ---")
    
    for i in range(len(ids)):
        # Audit 1: Dimensionality (all-MiniLM-L6-v2 = 384)
        vector = embeddings[i]
        assert len(vector) == 384, f"FAIL: ID {ids[i]} has incorrect dimension {len(vector)}"
        
        # Audit 2: Metadata Fidelity
        payload = json.loads(metadatas[i]["payload"])
        assert "dish_metadata" in payload, f"FAIL: Metadata corrupt for ID {ids[i]}"
        
        print(f"PASS: ID {ids[i]} | Geometry: 384-D | Metadata: Valid JSON")

if __name__ == "__main__":
    try:
        audit_json_contract()
        audit_vector_geometry()
        print("\nTIER 1 STATE VALIDATION: SUCCESS")
    except Exception as e:
        print(f"\nTIER 1 STATE VALIDATION: FAILED\n{str(e)}")
