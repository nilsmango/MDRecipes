//
//  MDRecipesApp.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

@main
struct MDRecipesApp: App {
    @StateObject private var recipesManager = RecipesManager()
    
    @State private var markdownString = ""
    @State private var showSingleHeaderAlert = false
    
    // ZIP import
    @State private var showZipImportAlert = false
    @State private var fileURL = ""
    
    // Import Overlay
    @State private var showAlertOverlay = false
    @State private var alertOverlayText = ""
    
    // edit view in home view
    @State private var recipeData = Recipe.Data()
    @State private var editViewPresented = false
    @State private var comingFromImportView = false
    
    var body: some Scene {
        WindowGroup {
            
            StartView(recipesManager: recipesManager, editViewPresented: $editViewPresented, newRecipeData: $recipeData, comingFromImportView: $comingFromImportView)
                .alert(isPresented: $showSingleHeaderAlert) {
                    Alert(
                        title: Text("Not a 7III Recipe"),
                        message: Text("Couldn't find a 7III Recipe header in this file."),
                        primaryButton: .destructive(Text("Cancel")) {
                            
                        },
                        secondaryButton: .default(Text("Try Anyway")) {
                            let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                            recipeData = recipeStruct.recipe.data
                            comingFromImportView = true
                            editViewPresented = true
                        }
                    )
                }
                .overlay {
                    ImportRecipesOverlay(recipesManager: recipesManager, showOverlay: $showZipImportAlert, fileURL: fileURL)
                    AlertOverlay(showAlert: $showAlertOverlay, text: alertOverlayText)
                }
                .onAppear {
                    do {
                        try recipesManager.removeInboxAndCopyFolder()
                    } catch {
                        print("Error removing Inbox folder: \(error)")
                    }
                }
                .onOpenURL { url in
                    do {
                        // TODO: make this one func inside my model?
                        let fileExtension = url.pathExtension.lowercased()
                        
                        if fileExtension == "md" {
                            print(url.path)
                            print(recipesManager.recipesDirectory.path)
                            print(url.lastPathComponent)
                            // check if we are coming from our own folder
                            if url.path.contains(recipesManager.recipesDirectory.path) && !url.path.contains("/Inbox/") {
                                print("opening internal file, now to finding")
                                // find the recipe in the recipesArray open it if it's in there
                                if let recipeInArray = recipesManager.recipes.first(where: { Parser.sanitizeFileName($0.title) + ".md" == url.lastPathComponent }) {
                                    recipesManager.path = NavigationPath()
                                    recipesManager.path.append("")
                                    recipesManager.path.append(recipeInArray)
                                    // else try to import the recipe
                                } else {
                                    print("not found")
                                    markdownString = try String(contentsOf: url, encoding: .utf8)
                                    let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                    recipeData = recipeStruct.recipe.data
                                    comingFromImportView = true
                                    editViewPresented = true
                                    // remove the file if it is in the inbox folder
                                    do {
                                        try recipesManager.removeItemInInbox(at: URL(fileURLWithPath: url.path))
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                                
                            } else {
                                markdownString = try String(contentsOf: url, encoding: .utf8)
                                // check if we have the right header in the file, if not ask if we should import it anyway then make recipe and then recipe.data
                                if Parser.isThere7iiiRecipeHeader(in: markdownString) == false {
                                    showSingleHeaderAlert = true
                                    
                                } else {
                                    let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                    recipeData = recipeStruct.recipe.data
                                    comingFromImportView = true
                                    editViewPresented = true
                                    
                                }
                                // remove the file if it is in the inbox folder
                                do {
                                    try recipesManager.removeItemInInbox(at: URL(fileURLWithPath: url.path))
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        } else if fileExtension == "zip" {
                            fileURL = url.path
                            showZipImportAlert = true
                        }
                    }
                    
                    catch {
                        // Showing the alert
                        alertOverlayText = "Error opening file: \(error.localizedDescription)"
                        showAlertOverlay = true
                    }
                }
        }
    }
}
