# frozen_string_literal: true

require_relative "../spec_helper"

describe SuppliedProductBuilder do
  include FileHelper

  subject(:builder) { described_class }
  let(:variant) {
    build(:variant, id: 5).tap do |v|
      v.product.supplier_id = 7
      v.product.primary_taxon = taxon
    end
  }
  let(:taxon) { build(:taxon, name: "Drink", dfc_name: "drink") }

  describe ".supplied_product" do
    it "assigns a semantic id" do
      product = builder.supplied_product(variant)

      expect(product.semanticId).to eq(
        "http://test.host/api/dfc/enterprises/7/supplied_products/5"
      )
    end

    it "assigns a quantity" do
      product = builder.supplied_product(variant)

      expect(product.quantity.value).to eq 1.0
      expect(product.quantity.unit.semanticId).to eq "dfc-m:Gram"
    end

    it "assigns the product name by default" do
      variant.product.name = "Apple"
      product = builder.supplied_product(variant)

      expect(product.name).to eq "Apple"
    end

    it "assigns the variant name if present" do
      variant.product.name = "Apple"
      variant.display_name = "Granny Smith"
      product = builder.supplied_product(variant)

      expect(product.name).to eq "Apple - Granny Smith"
    end

    context "product_type mapping" do
      it "assigns a product type" do
        product = builder.supplied_product(variant)
        drink = DfcLoader.connector.PRODUCT_TYPES.DRINK

        expect(product.productType).to eq drink
      end

      context "with non existing product type" do
        let(:taxon) { build(:taxon, name: "other", dfc_name: "other") }

        it "returns nil" do
          product = builder.supplied_product(variant)

          expect(product.productType).to be_nil
        end
      end

      context "when no taxon set" do
        let(:taxon) { nil }

        it "returns nil" do
          product = builder.supplied_product(variant)

          expect(product.productType).to be_nil
        end
      end
    end

    it "assigns an image_url type" do
      Spree::Image.create!(
        attachment: white_logo_file,
        viewable_id: variant.product.id,
        viewable_type: 'Spree::Product'
      )
      product = builder.supplied_product(variant)

      expect(product.image).to eq variant.product.image.url(:product)
    end
  end
end
