// 1. UNIQUE CONSTRAINTS
CREATE CONSTRAINT dish_id_unique IF NOT EXISTS FOR (d:Dish) REQUIRE d.dish_id IS UNIQUE;
CREATE CONSTRAINT ingredient_name_unique IF NOT EXISTS FOR (i:Ingredient) REQUIRE i.name IS UNIQUE;
CREATE CONSTRAINT restaurant_name_unique IF NOT EXISTS FOR (r:Restaurant) REQUIRE r.name IS UNIQUE;

// 2. RESTAURANTS (4 Distinct Locations)
MERGE (r1:Restaurant {name: "Monal"})
SET r1.latitude = 33.7483, r1.longitude = 73.0617;

MERGE (r2:Restaurant {name: "Cheezious"})
SET r2.latitude = 33.6844, r2.longitude = 73.0479;

MERGE (r3:Restaurant {name: "Savour Foods"})
SET r3.latitude = 33.7117, r3.longitude = 73.0583;

MERGE (r4:Restaurant {name: "Local Vendor B"})
SET r4.latitude = 33.6515, r4.longitude = 73.1566;

// 3. DISHES (Authentic Pakistani Corpus - First 8)

// Dish 1: Beef Nihari
MERGE (d1:Dish {dish_id: "d_pak_001"})
SET d1.name = "Beef Nihari",
    d1.normalized_price_pkr = 580.0,
    d1.synthesized_calories = 850.0,
    d1.synthesized_protein = 45.0
MERGE (r3)-[:SERVES]->(d1);

// Dish 2: Chicken Karahi
MERGE (d2:Dish {dish_id: "d_pak_002"})
SET d2.name = "Chicken Karahi",
    d2.normalized_price_pkr = 1250.0,
    d2.synthesized_calories = 950.0,
    d2.synthesized_protein = 75.0
MERGE (r1)-[:SERVES]->(d2);

// Dish 3: Halwa Puri
MERGE (d3:Dish {dish_id: "d_pak_003"})
SET d3.name = "Halwa Puri",
    d3.normalized_price_pkr = 280.0,
    d3.synthesized_calories = 750.0,
    d3.synthesized_protein = 12.0
MERGE (r4)-[:SERVES]->(d3);

// Dish 4: Daal Mash
MERGE (d4:Dish {dish_id: "d_pak_004"})
SET d4.name = "Daal Mash",
    d4.normalized_price_pkr = 350.0,
    d4.synthesized_calories = 420.0,
    d4.synthesized_protein = 18.0
MERGE (r4)-[:SERVES]->(d4);

// Dish 5: Mutton Pulao
MERGE (d5:Dish {dish_id: "d_pak_005"})
SET d5.name = "Mutton Pulao",
    d5.normalized_price_pkr = 650.0,
    d5.synthesized_calories = 880.0,
    d5.synthesized_protein = 38.0
MERGE (r3)-[:SERVES]->(d5);

// Dish 6: Chapli Kebab
MERGE (d6:Dish {dish_id: "d_pak_006"})
SET d6.name = "Chapli Kebab",
    d6.normalized_price_pkr = 450.0,
    d6.synthesized_calories = 550.0,
    d6.synthesized_protein = 30.0
MERGE (r2)-[:SERVES]->(d6);

// Dish 7: Sindhi Biryani
MERGE (d7:Dish {dish_id: "d_pak_007"})
SET d7.name = "Sindhi Biryani",
    d7.normalized_price_pkr = 480.0,
    d7.synthesized_calories = 780.0,
    d7.synthesized_protein = 32.0
MERGE (r3)-[:SERVES]->(d7);

// Dish 8: Seekh Kebab
MERGE (d8:Dish {dish_id: "d_pak_008"})
SET d8.name = "Seekh Kebab",
    d8.normalized_price_pkr = 520.0,
    d8.synthesized_calories = 480.0,
    d8.synthesized_protein = 35.0
MERGE (r1)-[:SERVES]->(d8);
