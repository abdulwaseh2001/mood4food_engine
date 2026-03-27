import math
import numpy as np
from typing import Dict

class TasteAgent:
    @staticmethod
    def calculate_utility(user_vector: np.ndarray, dish_vector: np.ndarray) -> float:
        norm_u = np.linalg.norm(user_vector)
        norm_d = np.linalg.norm(dish_vector)
        if norm_u == 0 or norm_d == 0:
            return 0.0
        dot_product = np.dot(user_vector, dish_vector)
        similarity = dot_product / (norm_u * norm_d)
        return float(max(0.0, similarity))

class BudgetAgent:
    @staticmethod
    def calculate_utility(base_price: int, delivery_fee: int, max_budget: int) -> float:
        total_cost = base_price + delivery_fee
        if total_cost > (max_budget * 1.5):
            return 0.0
        k = 1.0 / max_budget
        decay_utility = math.exp(-k * total_cost)
        return float(round(decay_utility, 4))

class HealthAgent:
    @staticmethod
    def calculate_utility(dish_macros: Dict[str, float], target_macros: Dict[str, float], min_protein: float) -> float:
        p_grams = dish_macros.get("protein_grams", 0)
        c_grams = dish_macros.get("carbs_grams", 0)
        f_grams = dish_macros.get("fats_grams", 0)
        total_grams = p_grams + c_grams + f_grams
        if total_grams == 0:
            return 0.0
        p_ratio = p_grams / total_grams
        p_variance = (p_ratio - target_macros.get("protein", 0.4)) ** 2
        u_health = max(0.0, 1.0 - math.sqrt(p_variance))
        if p_grams < min_protein:
            u_health *= 0.5 
        return float(round(u_health, 4))