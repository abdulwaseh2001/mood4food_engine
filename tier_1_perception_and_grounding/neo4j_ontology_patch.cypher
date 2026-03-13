// 1. Instantiate the "meat" Allergen node
MERGE (a_meat:Allergen {name: "meat"});

// 2 & 3. Locate existing meat-based Ingredients and construct CLASSIFIED_AS edges
MATCH (i_beef:Ingredient {name: "beef"})
MERGE (i_beef)-[:CLASSIFIED_AS]->(a_meat);

MATCH (i_chicken:Ingredient {name: "chicken"})
MERGE (i_chicken)-[:CLASSIFIED_AS]->(a_meat);

MATCH (i_mutton:Ingredient {name: "mutton"})
MERGE (i_mutton)-[:CLASSIFIED_AS]->(a_meat);

MATCH (i_marrow:Ingredient {name: "bone marrow"})
MERGE (i_marrow)-[:CLASSIFIED_AS]->(a_meat);
