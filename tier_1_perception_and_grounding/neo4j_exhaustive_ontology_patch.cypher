// 1. Ensure "meat" Allergen exists
MERGE (a_meat:Allergen {name: "meat"});

// 2. Aggressively link all meat-based and animal-derived primary ingredients
MATCH (i:Ingredient)
WHERE toLower(i.name) CONTAINS "beef" 
   OR toLower(i.name) CONTAINS "chicken" 
   OR toLower(i.name) CONTAINS "mutton" 
   OR toLower(i.name) CONTAINS "lamb" 
   OR toLower(i.name) CONTAINS "meat"
   OR toLower(i.name) CONTAINS "keema"
   OR toLower(i.name) CONTAINS "marrow"
   OR toLower(i.name) CONTAINS "suet"
   OR toLower(i.name) CONTAINS "bacon"
   OR toLower(i.name) CONTAINS "pork"
MERGE (i)-[:CLASSIFIED_AS]->(a_meat);

// 3. Specifically target secondary ingredients in the current 15-dish schema
MATCH (i:Ingredient)
WHERE i.name IN ["bone marrow", "beef shank", "chicken pieces", "mutton pieces", "minced beef"]
MERGE (i)-[:CLASSIFIED_AS]->(a_meat);
