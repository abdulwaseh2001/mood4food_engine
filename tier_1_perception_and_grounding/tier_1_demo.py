import streamlit as st
import json
import os
import sys
import subprocess
import pandas as pd
import chromadb
from chromadb.utils import embedding_functions

# --- Configuration & Paths ---
# Use absolute paths to ensure the demo runs reliably from any terminal context
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
INTENT_PATH = os.path.abspath(os.path.join(BASE_DIR, "../json_contracts/grounded_intent.json"))
EVAL_PATH = os.path.abspath(os.path.join(BASE_DIR, "../json_contracts/candidate_evaluation.json"))
# Path updated as per user confirmation: tier_2_optimization
CHROMA_DIR = os.path.abspath(os.path.join(BASE_DIR, "../tier_2_optimization/chroma_storage/"))

# Script execution targets
SYMBOLIC_SCRIPT = os.path.join(BASE_DIR, "symbolic_anchoring.py")
EMBEDDING_SCRIPT = os.path.join(BASE_DIR, "baseline_embeddings.py")

# --- UI Layout ---
st.set_page_config(page_title="Tier 1 Demo UI", layout="wide", initial_sidebar_state="expanded")
st.title("🎛️ Tier 1: Perception & Grounding Control Surface")
st.markdown("---")

# sidebar: Hard Constraint Input
st.sidebar.header("Input: Grounded Intent")

# 1. Allergen Pruning (Multiselect)
selected_allergens = st.sidebar.multiselect(
    "Prune Allergens",
    options=["peanut", "dairy", "gluten", "shellfish", "wheat", "soy", "egg", "meat", "rice"],
    default=["peanut"]
)

# 2. Calorie Constraints
max_cals = st.sidebar.number_input("Max Calories (Threshold)", min_value=0, max_value=5000, value=800, step=50)

# 3. Location Constraints
st.sidebar.subheader("Geospatial Constraint")
user_lat = st.sidebar.number_input("User Latitude", value=33.6844, format="%.4f")
user_lon = st.sidebar.number_input("User Longitude", value=73.0479, format="%.4f")
max_radius = st.sidebar.slider("Max Radius (km)", 0.1, 50.0, 5.0)

# Execution Trigger
execute_btn = st.sidebar.button("🚀 Execute Tier 1 Pipeline", type="primary", use_container_width=True)

# --- Execution Logic ---
if execute_btn:
    with st.status("Running Neuro-Symbolic Pipeline...", expanded=True) as status:
        # Step 1: Serialize UI state to JSON Contract
        st.write("Writing `grounded_intent.json`...")
        intent_payload = {
            "intent_metadata": {
                "intent_id": "streamlit_demo_req",
                "timestamp": "2026-03-12T19:30:00Z"
            },
            "hard_constraints": {
                "max_calories": max_cals,
                "allergens_pruned": selected_allergens
            },
            "location_constraint": {
                "user_lat": user_lat,
                "user_lon": user_lon,
                "max_radius_km": max_radius
            }
        }
        
        os.makedirs(os.path.dirname(INTENT_PATH), exist_ok=True)
        with open(INTENT_PATH, 'w') as f:
            json.dump(intent_payload, f, indent=2)

        # Step 2: Sequential Pipeline Execution
        try:
            st.write(f"Executing `{os.path.basename(SYMBOLIC_SCRIPT)}`...")
            subprocess.run([sys.executable, SYMBOLIC_SCRIPT], check=True, capture_output=True, text=True)
            st.success("Symbolic Pruning Complete.")
            
            st.write(f"Executing `{os.path.basename(EMBEDDING_SCRIPT)}`...")
            subprocess.run([sys.executable, EMBEDDING_SCRIPT], check=True, capture_output=True, text=True)
            st.success("Vector Embedding Complete.")
            
            status.update(label="Pipeline Completed Successfully!", state="complete", expanded=False)
        except subprocess.CalledProcessError as e:
            st.error(f"Pipeline Failed: {e.stderr}")
            st.stop()

    # --- Output Visualization ---
    col1, col2 = st.columns([3, 1])

    with col1:
        st.subheader("Mathematically Safe Candidates")
        if os.path.exists(EVAL_PATH):
            with open(EVAL_PATH, 'r') as f:
                eval_data = json.load(f)
            
            candidates = eval_data.get("candidates", [])
            if candidates:
                # Flattening JSON for tabular display
                rows = []
                for c in candidates:
                    rows.append({
                        "ID": c["dish_metadata"]["dish_id"],
                        "Dish Name": c["dish_metadata"]["name"],
                        "Restaurant": c["dish_metadata"]["restaurant_name"],
                        "Price (PKR)": c["financial_metrics"]["base_price_pkr"],
                        "Calories": c["nutritional_metrics"]["total_calories"],
                        "Protein (g)": c["nutritional_metrics"]["protein_grams"],
                        "Ingredients": ", ".join(c.get("ingredients", []))
                    })
                df = pd.DataFrame(rows)
                st.dataframe(df, use_container_width=True)
            else:
                st.warning("Total Annihilation: Zero candidates survived the constraints.")
        else:
            st.error("Error: `candidate_evaluation.json` not found.")

    with col2:
        st.subheader("Vector Space Audit")
        try:
            # Connect to ChromaDB to verify count
            client = chromadb.PersistentClient(path=CHROMA_DIR)
            # Reusing the embedding function from the baseline script
            ef = embedding_functions.SentenceTransformerEmbeddingFunction(model_name="all-MiniLM-L6-v2")
            collection = client.get_or_create_collection(name="candidate_dishes", embedding_function=ef)
            vector_count = collection.count()
            
            st.metric("ChromaDB Count", vector_count)
            if os.path.exists(EVAL_PATH):
                json_count = len(eval_data.get("candidates", []))
                if vector_count == json_count:
                    st.success("Integrity Verified: JSON vs Vector DB Sync.")
                else:
                    st.warning("Integrity Mismatch detected between JSON and Vector DB.")
        except Exception as e:
            st.error(f"ChromaDB Error: {str(e)}")

else:
    st.info("Adjust the constraints in the sidebar and click 'Execute Tier 1 Pipeline' to see results.")
