// 1. Ensure "meat" Allergen exists in the biological ontology
MERGE (a_meat:Allergen {name: "meat"});

// 2. Map Urdu semantic terms to the biological "meat" category
MATCH (i:Ingredient)
WHERE toLower(i.name) CONTAINS "gosht"
   OR toLower(i.name) CONTAINS "qeema"
   OR toLower(i.name) CONTAINS "keema"
   OR toLower(i.name) CONTAINS "boti"
   OR toLower(i.name) CONTAINS "tikka"
   OR toLower(i.name) CONTAINS "kebab"
   OR toLower(i.name) CONTAINS "paye"
   OR toLower(i.name) CONTAINS "nihari"
   OR toLower(i.name) CONTAINS "broth"
   OR toLower(i.name) CONTAINS "stock"
MERGE (i)-[:CLASSIFIED_AS]->(a_meat);
