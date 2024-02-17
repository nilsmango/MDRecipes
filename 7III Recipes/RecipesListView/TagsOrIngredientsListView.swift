//
//  TagsOrIngredientsListView.swift
//  7III Recipes
//
//  Created by Simon Lang on 28.11.23.
//

import SwiftUI

struct TagsOrIngredientsListView: View {
    @ObservedObject var recipesManager: RecipesManager
        
    var allStrings: [String]
    
    var isTags: Bool
    
    var body: some View {
        // add a row of FlexibleView items that are buttons that will get added to the tags
        VStack {
            
        
        FlexibleView(
            data: allStrings,
            spacing: 5,
            alignment: .leading
        ) { string in

            SelectionButtonLabel(string: string, chosenStrings: $recipesManager.chosenTags, allStrings: allStrings)
                .onTapGesture {
                    if recipesManager.chosenTags.contains(string) {
                        recipesManager.chosenTags.removeAll(where: { $0 == string})
                        } else {
                            recipesManager.chosenTags.append(string)
                        }
                }
        }
        .padding()
            
        List {
            ForEach(recipesManager.filterTheRecipes(string: "", ingredients: isTags ? [] : recipesManager.chosenTags, categories: [], tags: isTags ? recipesManager.chosenTags : [])) { recipe in
                NavigationLink(value: recipe) {
                    ListItemView(recipe: recipe)
                }
                .listStyle(.insetGrouped)
                
            }
        }
        }
        .background(
            .gray
                .opacity(0.1)
        )
        .navigationTitle(Text(recipesManager.chosenTags.count < 2 ? recipesManager.chosenTags.first ?? "Filter by Tags" : recipesManager.chosenTags.first! + " +"))
        
    }
}

#Preview {
    TagsOrIngredientsListView(recipesManager: RecipesManager(), allStrings: ["#Bitch", "#Watermelon", "#SomeOtherTag", "#Funny", "#Crazy"], isTags: true)
}
