import json
import requests

# 1. Load the immutable JSON contracts from your local disk
with open("../json_contracts/grounded_intent.json", "r") as f:
    intent_payload = json.load(f)

with open("../json_contracts/candidate_evaluation.json", "r") as f:
    candidate_payload = json.load(f)

# 2. Package them into the exact OrchestrationPayload Pydantic schema
orchestration_payload = {
    "grounded_intent": intent_payload,
    "candidate_evaluation": candidate_payload
}

# 3. Execute the HTTP POST request to your localized FastAPI port
print("[SYSTEM] Injecting Tier 1 Simulation Payload into Tier 2 Orchestrator...")
response = requests.post("http://127.0.0.1:8000/api/v1/orchestrate", json=orchestration_payload)

# 4. Print the serialized Abstract Syntax Tree (AST) output
if response.status_code == 200:
    print("\n[SUCCESS] Decision Blueprint JSON Generated:")
    print(json.dumps(response.json(), indent=2))
else:
    print(f"\n[FATAL ERROR] State Machine Crashed. Status Code: {response.status_code}")
    print(response.text)