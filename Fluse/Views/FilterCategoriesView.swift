//
//  FilterCategoriesView.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 5/11/24.
// Scrolling Carsel

import SwiftUI

struct FilterCategoriesView: View {
    @Binding var selectedCategories: Set<Category>
    private let categories = Category.allCases
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories) { category in
                        FilterButtonView(category: category, isSelected: self.selectedCategories.contains(category), onTap: self.onTap)
                        
                    }
                }
                .padding(.horizontal)
            }
            if selectedCategories.count > 0 {
                Button(role: .destructive) {
                    self.selectedCategories
                        .removeAll()
                } label: {
                    Text("Clear all filter selections (\(self.selectedCategories.count))")
                }
            }
        }
    }
    func onTap(category: Category) {
        /// same type as FilterButtonView
        if selectedCategories.contains(category) {
            /// remove it by toggling it
            selectedCategories.remove(category) // Set
        } else {
           /// Add
            selectedCategories.insert(category) // Set
            print(category.rawValue)
        }
    }
}

struct FilterButtonView: View {
    var category: Category
    var isSelected: Bool
    var onTap: (Category) -> () // Handler, action passes a category returns Void
    var body: some View {
        HStack(spacing: 4) {
            Text(category.rawValue.capitalized)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? category.color : Color.gray, lineWidth:  1)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(isSelected ? category.color : Color.clear)
                }
        }
        .frame(height: 44)
        .onTapGesture {
            self.onTap(category)
        }
        .foregroundStyle(isSelected ? .white : Color.primary)
    }
}

#Preview {
    @State var vm = LogListViewModel()
    return FilterCategoriesView(selectedCategories: $vm.selectedCategories)
}
