// 1. DISHES (Authentic Pakistani Corpus - Remaining 7)

MERGE (r1:Restaurant {name: "Monal"})
MERGE (r2:Restaurant {name: "Cheezious"})
MERGE (r3:Restaurant {name: "Savour Foods"})
MERGE (r4:Restaurant {name: "Local Vendor B"})

// Dish 9: Haleem
MERGE (d9:Dish {dish_id: "d_pak_009"})
SET d9.name = "Haleem",
    d9.normalized_price_pkr = 380.0,
    d9.synthesized_calories = 620.0,
    d9.synthesized_protein = 28.0
MERGE (r3)-[:SERVES]->(d9);

// Dish 10: Paye
MERGE (d10:Dish {dish_id: "d_pak_010"})
SET d10.name = "Paye",
    d10.normalized_price_pkr = 450.0,
    d10.synthesized_calories = 980.0,
    d10.synthesized_protein = 32.0
MERGE (r4)-[:SERVES]->(d10);

// Dish 11: Chana Chaat
MERGE (d11:Dish {dish_id: "d_pak_011"})
SET d11.name = "Chana Chaat",
    d11.normalized_price_pkr = 180.0,
    d11.synthesized_calories = 320.0,
    d11.synthesized_protein = 12.0
MERGE (r4)-[:SERVES]->(d11);

// Dish 12: Samosa
MERGE (d12:Dish {dish_id: "d_pak_012"})
SET d12.name = "Samosa",
    d12.normalized_price_pkr = 60.0,
    d12.synthesized_calories = 280.0,
    d12.synthesized_protein = 6.0
MERGE (r4)-[:SERVES]->(d12);

// Dish 13: Chicken Tikka
MERGE (d13:Dish {dish_id: "d_pak_013"})
SET d13.name = "Chicken Tikka",
    d13.normalized_price_pkr = 350.0,
    d13.synthesized_calories = 240.0,
    d13.synthesized_protein = 40.0
MERGE (r1)-[:SERVES]->(d13);

// Dish 14: Mutanjan
MERGE (d14:Dish {dish_id: "d_pak_014"})
SET d14.name = "Mutanjan",
    d14.normalized_price_pkr = 420.0,
    d14.synthesized_calories = 1450.0,
    d14.synthesized_protein = 15.0
MERGE (r3)-[:SERVES]->(d14);

// Dish 15: Zinger Burger
MERGE (d15:Dish {dish_id: "d_pak_015"})
SET d15.name = "Zinger Burger",
    d15.normalized_price_pkr = 650.0,
    d15.synthesized_calories = 880.0,
    d15.synthesized_protein = 34.0
MERGE (r2)-[:SERVES]->(d15);

// 2. INGREDIENTS
MERGE (i1:Ingredient {name: "wheat flour"})
MERGE (i2:Ingredient {name: "maida"})
MERGE (i3:Ingredient {name: "beef"})
MERGE (i4:Ingredient {name: "chicken"})
MERGE (i5:Ingredient {name: "mutton"})
MERGE (i6:Ingredient {name: "yogurt"})
MERGE (i7:Ingredient {name: "ghee"})
MERGE (i8:Ingredient {name: "butter"})
MERGE (i9:Ingredient {name: "cheese"})
MERGE (i10:Ingredient {name: "bone marrow"})
MERGE (i11:Ingredient {name: "rice"})
MERGE (i12:Ingredient {name: "lentils"})
MERGE (i13:Ingredient {name: "chickpeas"})
MERGE (i14:Ingredient {name: "peanut"})
MERGE (i15:Ingredient {name: "spices"})

// 3. ALLERGENS
MERGE (a1:Allergen {name: "gluten"})
MERGE (a2:Allergen {name: "dairy"})
MERGE (a3:Allergen {name: "peanut"})
MERGE (a4:Allergen {name: "shellfish"})

// 4. TOPOLOGY: (Ingredient)-[:CLASSIFIED_AS]->(Allergen)
MERGE (i1)-[:CLASSIFIED_AS]->(a1)
MERGE (i2)-[:CLASSIFIED_AS]->(a1)
MERGE (i6)-[:CLASSIFIED_AS]->(a2)
MERGE (i7)-[:CLASSIFIED_AS]->(a2)
MERGE (i8)-[:CLASSIFIED_AS]->(a2)
MERGE (i9)-[:CLASSIFIED_AS]->(a2)
MERGE (i14)-[:CLASSIFIED_AS]->(a3)

// 5. TOPOLOGY: (Dish)-[:CONTAINS]->(Ingredient)
// Connect dishes from Part 1
MATCH (d1:Dish {dish_id: "d_pak_001"}) MERGE (d1)-[:CONTAINS]->(i1) MERGE (d1)-[:CONTAINS]->(i3) MERGE (d1)-[:CONTAINS]->(i7) // Nihari: gluten, beef, dairy
MATCH (d2:Dish {dish_id: "d_pak_002"}) MERGE (d2)-[:CONTAINS]->(i4) MERGE (d2)-[:CONTAINS]->(i6) MERGE (d2)-[:CONTAINS]->(i7) // Karahi: chicken, dairy, dairy
MATCH (d3:Dish {dish_id: "d_pak_003"}) MERGE (d3)-[:CONTAINS]->(i1) MERGE (d3)-[:CONTAINS]->(i7) // Halwa Puri: gluten, dairy
MATCH (d4:Dish {dish_id: "d_pak_004"}) MERGE (d4)-[:CONTAINS]->(i12) // Daal Mash: lentils (SAFE control)
MATCH (d5:Dish {dish_id: "d_pak_005"}) MERGE (d5)-[:CONTAINS]->(i5) MERGE (d5)-[:CONTAINS]->(i11) // Mutton Pulao
MATCH (d6:Dish {dish_id: "d_pak_006"}) MERGE (d6)-[:CONTAINS]->(i3) MERGE (d6)-[:CONTAINS]->(i1) // Chapli Kebab: beef, gluten
MATCH (d7:Dish {dish_id: "d_pak_007"}) MERGE (d7)-[:CONTAINS]->(i4) MERGE (d7)-[:CONTAINS]->(i11) MERGE (d7)-[:CONTAINS]->(i6) // Sindhi Biryani: chicken, rice, dairy
MATCH (d8:Dish {dish_id: "d_pak_008"}) MERGE (d8)-[:CONTAINS]->(i3) // Seekh Kebab (SAFE control: pure beef)

// Connect dishes from Part 2
MERGE (d9)-[:CONTAINS]->(i1) MERGE (d9)-[:CONTAINS]->(i3) MERGE (d9)-[:CONTAINS]->(i12) // Haleem: gluten, beef, lentils
MERGE (d10)-[:CONTAINS]->(i10) MERGE (d10)-[:CONTAINS]->(i5) // Paye: bone marrow, mutton (SAFE control)
MERGE (d11)-[:CONTAINS]->(i13) MERGE (d11)-[:CONTAINS]->(i6) // Chana Chaat: chickpeas, dairy
MERGE (d12)-[:CONTAINS]->(i1) // Samosa: gluten
MERGE (d13)-[:CONTAINS]->(i4) // Chicken Tikka (SAFE control: pure chicken)
MERGE (d14)-[:CONTAINS]->(i11) MERGE (d14)-[:CONTAINS]->(i7) // Mutanjan: rice, dairy
MERGE (d15)-[:CONTAINS]->(i4) MERGE (d15)-[:CONTAINS]->(i2) MERGE (d15)-[:CONTAINS]->(i9) // Zinger: chicken, gluten, dairy
