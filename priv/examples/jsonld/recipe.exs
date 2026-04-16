SEO.JSONLD.Recipe.build(%{
  name: "Chocolate Chip Cookies",
  image: "https://example.com/cookies.jpg",
  author: SEO.JSONLD.Person.build(%{name: "Jane Doe"}),
  prep_time: Duration.new!(minute: 15),
  cook_time: Duration.new!(minute: 12),
  recipe_yield: "24 cookies",
  recipe_category: "Dessert",
  recipe_cuisine: "American",
  recipe_ingredient: ["2 cups flour", "1 cup butter", "1 cup sugar"],
  recipe_instructions: [
    SEO.JSONLD.HowToStep.build(%{name: "Mix dry", text: "Combine flour, salt, baking soda."}),
    SEO.JSONLD.HowToStep.build(%{name: "Cream wet", text: "Beat butter and sugar until fluffy."}),
    SEO.JSONLD.HowToStep.build(%{name: "Bake", text: "Bake at 375F for 10-12 minutes."})
  ],
  nutrition:
    SEO.JSONLD.NutritionInformation.build(%{
      calories: "180 calories",
      serving_size: "1 cookie"
    })
})
