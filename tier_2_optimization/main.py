from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any
import traceback
from agents import TasteAgent, BudgetAgent, HealthAgent
from database import VectorSubstrate

app = FastAPI(title="Mood4Food Execution Engine")
db = VectorSubstrate()
db.inject_integration_stubs()

class OrchestrationPayload(BaseModel):
    grounded_intent: Dict[str, Any]
    candidate_evaluation: Dict[str, Any]

@app.post("/api/v1/orchestrate")
def compute_equilibrium(payload: OrchestrationPayload):
    try:
        intent = payload.grounded_intent
        eval_matrix = payload.candidate_evaluation
        
        if not eval_matrix["graph_execution_state"]["search_space_viable"]:
            raise HTTPException(status_code=400, detail="Search space depleted.")

        candidates = eval_matrix["candidates"]
        w_health = intent["initial_agent_weights"]["w_health"]
        w_budget = intent["initial_agent_weights"]["w_budget"]
        w_taste = intent["initial_agent_weights"]["w_taste"]
        user_id = intent["intent_metadata"]["user_id"]
        
        user_vector = db.get_user_vector(user_id)
        best_u_total = -1.0
        best_dish = None
        final_utilities = {}

        for dish in candidates:
            taste_id = dish["vector_retrieval"]["taste_vector_id"]
            dish_vector = db.get_dish_vector(taste_id)

            u_t = TasteAgent.calculate_utility(user_vector, dish_vector)
            u_b = BudgetAgent.calculate_utility(
                dish["financial_metrics"]["base_price_pkr"],
                dish["financial_metrics"]["delivery_fee_pkr"],
                intent["hard_constraints"]["budget_max_pkr"]
            )
            u_h = HealthAgent.calculate_utility(
                dish["nutritional_metrics"],
                intent["soft_constraints"]["nutritional_targets"]["target_macro_ratio"],
                intent["soft_constraints"]["nutritional_targets"]["protein_min_grams"]
            )
            
            u_total = (w_health * u_h) + (w_budget * u_b) + (w_taste * u_t)
            
            if u_total > best_u_total:
                best_u_total = u_total
                best_dish = dish
                final_utilities = {"U_health": u_h, "U_budget": u_b, "U_taste": u_t, "U_total": u_total}

        return {
            "selected_candidate": best_dish["dish_metadata"]["name"],
            "utilities": final_utilities
        }

    except Exception as e:
        print("[DEBUG ERROR]:", traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)