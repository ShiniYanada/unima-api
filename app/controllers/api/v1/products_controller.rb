class Api::V1::ProductsController < ApplicationController
    before_action :authenticate_api_user!, only: [:create, :update, :destroy, :trade, :complete]
    before_action :correct_user, only: [:update, :destroy]

    def index 
        @products = Product.all

        render json: @products
    end

    def show
        @product = Product.find_by(id: params[:id])
        
        if @product
            render json: @product
        else
            head :not_found 
        end
    end

    def create 
        @category = Category.find_by(name: category_params[:category])
        @product = current_api_user.sell_products.build(product_params)
        @product.category_id = @category.id if @category

        if @product.save 
            render json: @product, status: :created
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def update
        if @product.update(product_params)
            render json: @product
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def destroy
        if @product.destroy
            render json: @product
        else
            head :internal_server_error
        end
    end

    def trade
        @product = Product.find_by(id: params[:id])
        if @product.update_attributes(buyer_id: current_api_user.id, status: "trade", traded_at: Time.zone.now)
            render json: @product
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def complete
        @product = Product.find_by(id: params[:id])
        if @product.update_attributes(status: "close", closed_at: Time.zone.now)
            head :ok
        else
            render json: @product.errors, status: :unprocessable_entity
        end 
    end

    private 

        def product_params 
            params.permit(:name, :description, :price, :state)
        end

        def category_params
            params.permit(:category)
        end

        def correct_user 
            @product = current_api_user.products.find_by(id: params[:id])
            head :forbidden if @product.nil?
        end
end
