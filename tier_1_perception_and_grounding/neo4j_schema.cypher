// 1. Constraints
CREATE CONSTRAINT dish_id_unique IF NOT EXISTS FOR (d:Dish) REQUIRE d.dish_id IS UNIQUE;
CREATE CONSTRAINT ingredient_name_unique IF NOT EXISTS FOR (i:Ingredient) REQUIRE i.name IS UNIQUE;

// 2. Mock Data Ingestion (5 Sample Dishes)
// Consistent with JSON Contracts: dish_id, name, normalized_price_pkr, synthesized_calories, synthesized_protein

MERGE (r1:Restaurant {name: "Local Vendor A"})
MERGE (r2:Restaurant {name: "Karachi Grill"})

// Dish 1
MERGE (d1:Dish {dish_id: "d_491"})
SET d1.name = "Spicy Chicken Karahi",
    d1.normalized_price_pkr = 450.0,
    d1.synthesized_calories = 650.0,
    d1.synthesized_protein = 35.0
MERGE (r1)-[:SERVES]->(d1)

// Dish 2
MERGE (d2:Dish {dish_id: "d_492"})
SET d2.name = "Beef Nihari",
    d2.normalized_price_pkr = 550.0,
    d2.synthesized_calories = 850.0,
    d2.synthesized_protein = 45.0
MERGE (r2)-[:SERVES]->(d2)

// Dish 3
MERGE (d3:Dish {dish_id: "d_493"})
SET d3.name = "Chicken Biryani",
    d3.normalized_price_pkr = 400.0,
    d3.synthesized_calories = 720.0,
    d3.synthesized_protein = 28.0
MERGE (r1)-[:SERVES]->(d3)

// Dish 4
MERGE (d4:Dish {dish_id: "d_494"})
SET d4.name = "Daal Mash",
    d4.normalized_price_pkr = 250.0,
    d4.synthesized_calories = 400.0,
    d4.synthesized_protein = 15.0
MERGE (r1)-[:SERVES]->(d4)

// Dish 5
MERGE (d5:Dish {dish_id: "d_495"})
SET d5.name = "Peanut Chicken Skewers",
    d5.normalized_price_pkr = 350.0,
    d5.synthesized_calories = 500.0,
    d5.synthesized_protein = 30.0
MERGE (r2)-[:SERVES]->(d5)

// 3. Topology: (Dish)-[:CONTAINS]->(Ingredient)-[:CLASSIFIED_AS]->(Allergen)

MERGE (pe:Allergen {name: "peanut"})
MERGE (gl:Allergen {name: "gluten"})

MERGE (i1:Ingredient {name: "peanut"})
MERGE (i1)-[:CLASSIFIED_AS]->(pe)

MERGE (i2:Ingredient {name: "wheat flour"})
MERGE (i2)-[:CLASSIFIED_AS]->(gl)

MERGE (i3:Ingredient {name: "chicken"})
MERGE (i4:Ingredient {name: "beef"})
MERGE (i5:Ingredient {name: "lentils"})

// Connect Ingredients to Dishes
MERGE (d1)-[:CONTAINS]->(i3)
MERGE (d2)-[:CONTAINS]->(i4)
MERGE (d2)-[:CONTAINS]->(i2) // Nihari contains wheat flour (gluten)
MERGE (d3)-[:CONTAINS]->(i3)
MERGE (d4)-[:CONTAINS]->(i5)
MERGE (d5)-[:CONTAINS]->(i3)
MERGE (d5)-[:CONTAINS]->(i1) // Contains peanut
