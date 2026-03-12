import chromadb
import numpy as np

class VectorSubstrate:
    """
    Maintains localized geometric representation of taste profiles.
    """
    def __init__(self, storage_path: str = "./chroma_storage"):
        self.client = chromadb.PersistentClient(path=storage_path)
        self.dish_collection = self.client.get_or_create_collection(
            name="dish_feature_vectors", metadata={"hnsw:space": "cosine"}
        )
        self.user_collection = self.client.get_or_create_collection(
            name="user_preference_vectors", metadata={"hnsw:space": "cosine"}
        )

    def inject_integration_stubs(self):
        """Injects baseline matrices for Iteration 1 math testing."""
        self.dish_collection.upsert(
            ids=["vec_d_491", "vec_d_204"],
            embeddings=[[0.8, 0.2, 0.5, 0.9, 0.1], [0.1, 0.9, 0.8, 0.2, 0.3]]
        )
        self.user_collection.upsert(
            ids=["u_992"], 
            embeddings=[[0.9, 0.1, 0.4, 0.8, 0.2]]
        )

    def get_dish_vector(self, taste_vector_id: str) -> np.ndarray:
        result = self.dish_collection.get(ids=[taste_vector_id], include=["embeddings"])
        
        # Explicit check for None or empty list to avoid NumPy ambiguity errors
        if result['embeddings'] is None or len(result['embeddings']) == 0:
            raise ValueError(f"Dish Vector {taste_vector_id} not found.")
            
        # [0] flattens the result from [[x, y, z]] to [x, y, z] for math agents
        return np.array(result['embeddings'][0])

    def get_user_vector(self, user_id: str) -> np.ndarray:
        result = self.user_collection.get(ids=[user_id], include=["embeddings"])
        
        if result['embeddings'] is None or len(result['embeddings']) == 0:
            raise ValueError(f"User Vector {user_id} not found.")
            
        return np.array(result['embeddings'][0])