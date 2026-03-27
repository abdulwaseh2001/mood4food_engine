import json
import os
import chromadb
from chromadb.utils import embedding_functions

class VectorArchitect:
    def __init__(self):
        """
        Initializes the Vector Database Architect's interface.
        Uses local offline processing exclusively.
        """
        # 1. Initialize persistent ChromaDB client
        persist_dir = os.path.abspath(os.path.join(
            os.path.dirname(__file__), 
            "../tier_2_vector_layer/chroma_storage/"
        ))
        os.makedirs(persist_dir, exist_ok=True)
        
        self.client = chromadb.PersistentClient(path=persist_dir)
        
        # 2. Load local sentence-transformers model (all-MiniLM-L6-v2)
        # This model produces 384-dimensional vectors
        self.embedding_fn = embedding_functions.SentenceTransformerEmbeddingFunction(
            model_name="all-MiniLM-L6-v2"
        )
        
        self.collection = self.client.get_or_create_collection(
            name="candidate_dishes",
            embedding_function=self.embedding_fn
        )

    def embed_candidate_matrix(self):
        """
        Loads safe candidates from the JSON Contract and maps them into 
        the mathematical coordinate space.
        """
        # 3. Open absolute source of truth
        safe_candidates_path = os.path.abspath(os.path.join(
            os.path.dirname(__file__), 
            "../json_contracts/candidate_evaluation.json"
        ))
        
        if not os.path.exists(safe_candidates_path):
            print(f"Error: {safe_candidates_path} not found.")
            return

        with open(safe_candidates_path, 'r') as f:
            data = json.load(f)

        candidates = data.get("candidates", [])
        if not candidates:
            print("No candidates found for embedding.")
            return

        ids = []
        documents = []
        metadatas = []

        for candidate in candidates:
            dish_id = candidate["dish_metadata"]["dish_id"]
            name = candidate["dish_metadata"]["name"]
            ingredients = candidate.get("ingredients", [])
            
            # 4. Concatenate semantic attributes for embedding
            semantic_string = f"{name}: {', '.join(ingredients)}"
            
            # 5 & 6. Prepare for ChromaDB Upsert
            ids.append(dish_id)
            documents.append(semantic_string)
            # Embed the full JSON dictionary in metadata for downstream agent fidelity
            metadatas.append({"payload": json.dumps(candidate)})

        # Execute Batch Upsert
        self.collection.upsert(
            ids=ids,
            documents=documents,
            metadatas=metadatas
        )

        print(f"Vector Space Updated: {len(ids)} candidates embedded into 'candidate_dishes'.")

if __name__ == "__main__":
    # Tier 1 Vectorization Hook
    architect = VectorArchitect()
    architect.embed_candidate_matrix()
