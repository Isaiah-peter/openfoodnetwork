module Api
  class VariantsController < Api::BaseController
    respond_to :json

    skip_authorization_check only: [:index, :show]
    before_filter :product

    def index
      @variants = scope.includes(option_values: :option_type).ransack(params[:q]).result
      render json: @variants, each_serializer: Api::VariantSerializer
    end

    def show
      @variant = scope.includes(option_values: :option_type).find(params[:id])
      render json: @variant, serializer: Api::VariantSerializer
    end

    def create
      authorize! :create, Spree::Variant
      @variant = scope.new(params[:variant])
      if @variant.save
        render json: @variant, serializer: Api::VariantSerializer, status: :created
      else
        invalid_resource!(@variant)
      end
    end

    def update
      authorize! :update, Spree::Variant
      @variant = scope.find(params[:id])
      if @variant.update_attributes(params[:variant])
        render json: @variant, serializer: Api::VariantSerializer, status: :ok
      else
        invalid_resource!(@product)
      end
    end

    def destroy
      authorize! :delete, Spree::Variant
      @variant = scope.find(params[:id])
      authorize! :delete, @variant

      VariantDeleter.new.delete(@variant)
      render json: @variant, serializer: Api::VariantSerializer, status: :no_content
    end

    private

    def product
      @product ||= Spree::Product.find_by(permalink: params[:product_id]) if params[:product_id]
    end

    def scope
      if @product
        variants = if current_api_user.has_spree_role?("admin") || params[:show_deleted]
                     @product.variants_including_master.with_deleted
                   else
                     @product.variants_including_master
                   end
      else
        variants = Spree::Variant.scoped
        if current_api_user.has_spree_role?("admin")
          unless params[:show_deleted]
            variants = Spree::Variant.active
          end
        else
          variants = variants.active
        end
      end
      variants
    end
  end
end
