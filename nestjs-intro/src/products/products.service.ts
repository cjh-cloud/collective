import { Injectable, NotFoundException } from "@nestjs/common";

import { Product } from "./product.model";

@Injectable()
export class ProductsService {
    private products: Product[] = [];

    // insertProduct(prod: Product) { }

    // Returning the product ID as a string
    insertProduct(title: string, desc: string, price: number): string {
        // Date used to create ID, not perfectly unique but good enough for now
        const prodId = Math.random().toString(); //new Date().toString();
        const newProduct = new Product(prodId, title, desc, price);
        this.products.push(newProduct);
        return prodId;
    }

    getProducts() {
        return [...this.products]; // Returning a copy of the array instead of reference so that it is not editable (... pulls out all elements in the array)
    }

    getSingleProduct(productId: string) {
        const product = this.findProduct(productId)[0];
        return { ...product };
    }

    updateProduct(productId: string, title: string, desc: string, price: number) {
        const [product, index] = this.findProduct(productId);
        const updatedProduct = { ...product };
        if (title) {
            updatedProduct.title = title;
        }
        if (desc) {
            updatedProduct.description = desc;
        }
        if (price) {
            updatedProduct.price = price;
        }
        this.products[index] = updatedProduct;
    }

    deleteProduct(prodId: string) {
        const [_, index] = this.findProduct(prodId);
        this.products.splice(index, 1); // splice takes index as a starting point and removes 1 element
    }

    private findProduct(id: string): [Product, number] {
        const productIndex = this.products.findIndex((prod) => prod.id == id);
        const product = this.products[productIndex];
        if (!product) {
            throw new NotFoundException('Could not find product.');
        }
        return [product, productIndex];
    }
}